# LearnTerraform
学习terraform的应用

1. Docker_Tutorial，跟随官方示例，使用docker provider，拉取nginx镜像，运行一个nginx容器
2. Vultr_V2ray，使用vultr provider和aliyun provider
    1. 在aliyun上创建子域名A记录
    2. 并在vultr上创建虚拟机实例，使用cloud-init执行v2ray安装脚本，并使用expect脚本自动执行v2ray安装脚本的交互操作
3. Vsphere_Template_Vm，连接搭建的vsphere测试环境，使用已有的windows10模板，创建一个虚拟机