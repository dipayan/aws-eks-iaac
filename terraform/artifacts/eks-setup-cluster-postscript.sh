
mkdir -p ~/.kube

cat > /data/kubernetes/${eks_cluster_name}/config-map-aws-auth.yaml <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${eks_iam_worker_arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH


cat > ~/.kube/config <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${eks_cluster_endpoint}
    certificate-authority-data: ${eks_cluster_cert}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: heptio-authenticator-aws
      args:
        - "token"
        - "-i"
        - ${eks_cluster_name}
KUBECONFIG

kubectl apply -f /data/kubernetes/${eks_cluster_name}/config-map-aws-auth.yaml
sleep 60
kubectl get nodes
kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/v1.0.0/config/v1.0/aws-k8s-cni-calico.yaml
kubectl get daemonsets --namespace=kube-system
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/alternative/kubernetes-dashboard.yaml
kubectl create clusterrolebinding kubernetes-dashboard-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
kubectl get po --namespace=kube-system
kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/rbac/heapster-rbac.yaml
kubectl get po --namespace=kube-system

cat > /data/kubernetes/${eks_cluster_name}/gp2-storage-class.yaml <<EOF
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: gp2
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Retain
mountOptions:
  - debug
EOF

kubectl create -f /data/kubernetes/${eks_cluster_name}/gp2-storage-class.yaml
kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
kubectl get storageclass

kubectl create clusterrolebinding add-on-cluster-admin   --clusterrole=cluster-admin   --serviceaccount=kube-system:default
helm init
sleep 90
helm install stable/nginx-ingress --name nginx-ingress \
 --set controller.kind=DaemonSet \
 --set controller.service.type=NodePort \
 --set controller.service.nodePorts.http=${ingress_http_port} \
 --set controller.service.nodePorts.https=${ingress_https_port}

cat > /data/kubernetes/${eks_cluster_name}/kubernetes-dashboard.yaml <<EOF
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: kubernetes-dashboard
  labels:
    app: kubernetes-dashboard
  annotations:
    kubernetes.io/ingress.class: nginx
  namespace: kube-system
spec:
  rules:
  - host: kubernetes-dashboard.${ingress_domain_name}
    http:
      paths:
      - backend:
          serviceName: kubernetes-dashboard
          servicePort: 80
EOF


kubectl apply -f /data/kubernetes/${eks_cluster_name}/kubernetes-dashboard.yaml

kubectl create namespace dev