### 介绍
基于centos操作系统利用ansible实现k8s集群的新建, 扩容, 销毁, 缩容功能; 单独部署etcd集群. 

### 安装包下载
一些centos常用的必备的安装包通过yum or dnf提前下载

[etcd](https://github.com/etcd-io/etcd/releases)以及相关的镜像等, 提前下载好离线安装文件放置到最外层files目录中
```bash
ETCD_VER=v3.5.17
# etcd下载, 或者通过github页面下载压缩包
wget https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz

# kube rpms; 通过阿里云repo下载需要的版本 http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/Packages
curl http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/Packages/2de91de7e1a27c52533426a65bb9dba3aa255a92844eaa22fb9801e8d5585a42-kubectl-1.20.1-0.x86_64.rpm -o kubectl-1.20.1-0.x86_64.rpm
curl http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/Packages/651677e32820964b6d269b50f519a369b1efb13bd143f64324a3c61b1179b34a-kubelet-1.20.1-0.x86_64.rpm -o kubelet-1.20.1-0.x86_64.rpm
curl http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/Packages/c1101e7903201b851394502c28830132a130290a9d496c89172a471c2f2f5a28-kubeadm-1.20.1-0.x86_64.rpm -o kubeadm-1.20.1-0.x86_64.rpm
curl http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/Packages/14bfe6e75a9efc8eca3f638eb22c7e2ce759c67f95b43b16fae4ebabde1549f3-cri-tools-1.13.0-0.x86_64.rpm -o cri-tools-1.13.0-0.x86_64.rpm
curl http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/Packages/548a0dcd865c16a50980420ddfa5fbccb8b59621179798e6dc905c9bf8af3b34-kubernetes-cni-0.7.5-0.x86_64.rpm -o kubernetes-cni-0.7.5-0.x86_64.rpm
```

### 使用方法
