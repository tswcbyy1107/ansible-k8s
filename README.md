### 使用方法
---
基于centos7 4.19内核利用ansible-playbook分role实现k8s集群的新建、扩容、销毁、缩容功能, etcd集群部署等. 部分资源是离线下载安装, 如kubeadm等安装包、kube镜像等, 一些是在线安装如containerd、docker等, 可自行根据环境需求修改playbook.

支持按照不同环境配置参数变量, 变量统一在group_vars目录和vars/{{env}}.yml中. 已经内置了k8s版本变量, 后续可增加不同版本的k8s部署. 支持指定网络模式安装calico或者flannel网络插件.

仅创建etcd集群: `ansible-playbook -i hosts/demo cluster-create.yml -e env=dev --tags="etcd"` or `ansible-playbook -i hosts/demo etcd-create.yml -e env=dev`

创建k8s集群(包含etcd外部集群搭建): `ansible-playbook -i hosts/demo cluster-create.yml -e env=dev`

删除k8s集群(包括删除etcd外部集群): `ansible-playbook -i hosts/demo cluster-destroy.yml`

新增节点: `ansible-playbook -i hosts/demo cluster-expanda.yml -e env=dev`

删除节点: `ansible-playbook -i hosts/demo cluster-reduce.yml`

### 目录结构
---
```bash
├── files # 全局文件
├── group_vars # group变量
├── hosts # inventory host
├── roles # role列表
│   ├── common # 通用角色, 安装软件, 创建文件夹等
│   │   ├── files
│   │   ├── tasks
│   │   └── templates
│   ├── etcd # 创建etcd集群
│   │   ├── files
│   │   ├── handlers
│   │   ├── tasks
│   │   └── templates
│   ├── kube-master # 创建master, 支持多master
│   │   ├── files
│   │   ├── tasks
│   │   └── templates
│   ├── kube-network # 应用网络
│   │   ├── files
│   │   └── tasks
│   └── kube-node # 增加node
│       ├── files
│       ├── tasks
│       └── templates
└── vars # env环境变量配置
```


### 参考文档
---
[kubernetes/CHANGELOG/CHANGELOG-1.24.md/dependencies](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.24.md#dependencies)

[kubernetes.io](https://kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

### 离线资源下载和安装
---
etcd.tar.gz下载:
```bash
# 或者通过github etcd页面下载指定版本的压缩包
ETCD_VER=v3.5.17
wget https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz
cp etcd-v3.5.16-linux-amd64.tar.gz files/
```

<br>

k8s相关rpm离线下载安装示例: kubeadm kubectl kubelet cri-tools kubernetes-cni. 无外网情况下通过[阿里云mirros](http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/Packages)下载下来通过createrepo命令自建仓库, 或者放入到已有自建仓库中, 或者直接通过ansible copy到目标机器rpm安装. 
```bash
curl http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/Packages/de422b616a367cafae90aef704625fc34b0b222353f4fb59235bb3cf2f9d0988-kubelet-1.24.0-0.x86_64.rpm -o kubelet-1.24.0-0.x86_64.rpm
...
rpm -ivh kubernetes-cni-1.2.0-0.x86_64.rpm kubelet-1.24.0-0.x86_64.rpm
rpm -ivh cri-tools-1.19.0-0.x86_64.rpm kubectl-1.24.0-0.x86_64.rpm
rpm -ivh kubeadm-1.24.0-0.x86_64.rpm
```

<br>

kubeadm相关镜像离线下载导入示例: 相关镜像可以提前下载通过docker save/load到目标master机器, 此处是k8s v1.24.0 docker版本示例
```bash
# config imageRepository=registry.aliyuncs.com/google_containers, 无法访问公网的情况下提前下载并save
kubeadm config print init-defaults > default-init.yml
# 设置仓库地址为imageRepository: registry.aliyuncs.com/google_containers
vim default-init.yml 
# 查看需要的镜像
kubeadm config images list --config=./default-init.yml
registry.aliyuncs.com/google_containers/kube-apiserver:v1.24.0
registry.aliyuncs.com/google_containers/kube-controller-manager:v1.24.0
registry.aliyuncs.com/google_containers/kube-scheduler:v1.24.0
registry.aliyuncs.com/google_containers/kube-proxy:v1.24.0
registry.aliyuncs.com/google_containers/pause:3.7
registry.aliyuncs.com/google_containers/coredns:v1.8.6

# images下载示例
for i in registry.aliyuncs.com/google_containers/kube-apiserver:v1.24.0 registry.aliyuncs.com/google_containers/kube-controller-manager:v1.24.0 registry.aliyuncs.com/google_containers/kube-scheduler:v1.24.0 registry.aliyuncs.com/google_containers/kube-proxy:v1.24.0 registry.aliyuncs.com/google_containers/pause:3.2 registry.aliyuncs.com/google_containers/coredns:1.6.7;do docker pull $i;done

# docker save load举例
docker save -o kubeadm-v1.24.0.images.tar.gz registry.aliyuncs.com/google_containers/kube-apiserver:v1.27.0 registry.aliyuncs.com/google_containers/kube-controller-manager:v1.27.0 registry.aliyuncs.com/google_containers/kube-scheduler:v1.27.0 registry.aliyuncs.com/google_containers/kube-proxy:v1.27.0 registry.aliyuncs.com/google_containers/pause:3.9 registry.aliyuncs.com/google_containers/coredns:v1.10.1
docker save -o infra-pause.3.7.image.tar.gz registry.aliyuncs.com/google_containers/pause:3.7

docker load -i infra-pause.3.7.image.tar.gz
docker load -i kubeadm-v1.24.0.images.tar.gz

# containerd export import举例
ctr -n k8s.io images export kubeadm-v1.24.0.images.tar.gz registry.aliyuncs.com/google_containers/coredns:v1.8.6 xxx
ctr -n k8s.io image import kubeadm-v1.24.0.images.tar.gz
```

<br>

flannel网络插件安装:
```bash
for i in docker.io/flannel/flannel:v0.26.2 docker.io/flannel/flannel-cni-plugin:v1.6.0-flannel1 docker.io/flannel/flannel:v0.26.2;do docker pull $i; done
docker save -o flannel-v0.26.2.images.tar.gz docker.io/flannel/flannel:v0.26.2 docker.io/flannel/flannel-cni-plugin:v1.6.0-flannel1 docker.io/flannel/flannel:v0.26.2
wget https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml 
# scp 
docker load -i flannel-v0.26.2.images.tar.gz
# ctr -n k8s.io image import flannel-v0.26.2.images.tar.gz
kubectl apply -f kube-flannel.yml 
```

<br>

calico网络插件安装:
```bash
for i in calico.tar.gz docker.io/calico/cni:v3.24.1 docker.io/calico/cni:v3.24.1 docker.io/calico/node:v3.24.1 docker.io/calico/node:v3.24.1 docker.io/calico/kube-controllers:v3.24.1;do docker pull $i; done
docker save -o calico-v3.24.1.images.tar.gz calico.tar.gz docker.io/calico/cni:v3.24.1 docker.io/calico/cni:v3.24.1 docker.io/calico/node:v3.24.1 docker.io/calico/node:v3.24.1 docker.io/calico/kube-controllers:v3.24.1
wget wget https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/calico.yaml
# scp 
docker load -i calico-v3.24.1.images.tar.gz
# ctr -n k8s.io image import calico-v3.24.1.images.tar.gz
kubectl apply -f kube-calico.yml 
```

<br>

[docker-public centos7 x86_64 mirrors](https://download.docker.com/linux/centos/7/x86_64/stable/Packages/): 下载docker和containerd安装略


