### 介绍
基于centos操作系统利用ansible实现k8s集群的新建, 扩容, 销毁, 缩容功能; 单独部署etcd集群. 

### 资源下载
必要的资源下载: download放置到playbook的file目录
1. [etcd安装包下载](https://github.com/etcd-io/etcd/releases), 通过github下载
2. [阿里云repo](http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/Packages)下载kubeadm, kubelet, kubectl等rpm安装包. 无法访问公网的话通过createrepo命令可以自建yum仓库, 也可以提前安装到机器上, 跳过playbook中的安装步骤.
3. 无法直接访问k8s.gcr.io的话, 从[阿里云container repo](registry.aliyuncs.com/google_containers)下载kubeadm相关镜像, 导入到相关机器

```bash
# etcd下载, 或者通过github页面下载压缩包
ETCD_VER=v3.5.17
wget https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz

# kube rpms; 通过阿里云repo下载需要的版本 http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/Packages, 复制到对应主机安装
curl http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/Packages/de422b616a367cafae90aef704625fc34b0b222353f4fb59235bb3cf2f9d0988-kubelet-1.18.8-0.x86_64.rpm -o kubelet-1.18.8-0.x86_64.rpm
curl http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/Packages/efd73a4178ebf9939f86b4200dba0247a57ead65f2403d8576b241faf478ac42-kubectl-1.18.8-0.x86_64.rpm -o kubectl-1.18.8-0.x86_64.rpm
curl http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/Packages/f1795288ba09abd5e6738fbf82e237e3792ee2dcda4512fa5d35388dae622cef-kubeadm-1.18.8-0.x86_64.rpm -o kubeadm-1.18.8-0.x86_64.rpm

# kubeadm镜像准备, 设置config imageRepository=registry.aliyuncs.com/google_containers
kubeadm config print init-defaults > default-init.yml
# 根据官网修改配置, https://kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/control-plane-flags/
# 查看需要的镜像load到对应机器中
kubeadm config images list --config=/tmp/init.yaml
registry.aliyuncs.com/google_containers/kube-apiserver:v1.18.8
registry.aliyuncs.com/google_containers/kube-controller-manager:v1.18.8
registry.aliyuncs.com/google_containers/kube-scheduler:v1.18.8
registry.aliyuncs.com/google_containers/kube-proxy:v1.18.8
registry.aliyuncs.com/google_containers/pause:3.2
registry.aliyuncs.com/google_containers/coredns:1.6.7

for i in registry.aliyuncs.com/google_containers/kube-apiserver:v1.18.8 registry.aliyuncs.com/google_containers/kube-controller-manager:v1.18.8 registry.aliyuncs.com/google_containers/kube-scheduler:v1.18.8 registry.aliyuncs.com/google_containers/kube-proxy:v1.18.8 registry.aliyuncs.com/google_containers/pause:3.2 registry.aliyuncs.com/google_containers/coredns:1.6.7;do docker pull $i;done

docker save -o kubeadm.v1.18.8.tar.gz registry.aliyuncs.com/google_containers/kube-apiserver:v1.18.8 registry.aliyuncs.com/google_containers/kube-controller-manager:v1.18.8 registry.aliyuncs.com/google_containers/kube-scheduler:v1.18.8 registry.aliyuncs.com/google_containers/kube-proxy:v1.18.8 registry.aliyuncs.com/google_containers/pause:3.2 registry.aliyuncs.com/google_containers/coredns:1.6.7

# 复制到对应主机load
docker load -i kubeadm.v1.18.8.tar.gz
```

### 使用方法
