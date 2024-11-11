# 执行 terraform init 下载 provider 插件等初始化工作
# 执行 terraform plan 预览操作
# 执行 terraform apply 执行操作

## provider.tf：定义了vultr provider和aliyun provider，并设置对应的凭据；

## terraform.tfvars：定义了vultr provider和aliyun provider的凭据；

## v2ray.tf：定义了vultr虚拟机实例和aliyun云解析dns记录；

> os版本ubuntu20.04  
> ubuntu24.04运行wulabing版本v2ray脚本有一处需要修改的地方

## wulabing_ws_tls.yaml：定义了vultr虚拟机实例创建后，部署v2ray的过程：

### cloud-init大致流程

- 重定向工作目录到 /root
- 下载wulabing版本v2ray脚本：https://raw.githubusercontent.com/wulabing/V2Ray_ws-tls_bash_onekey/master/install.sh
- 下载google原版bbr脚本：https://github.com/teddysun/across/raw/master/bbr.sh
- 下载改版x-ui脚本：https://raw.githubusercontent.com/FranzKafkaYu/x-ui/master/install.sh
- 执行expect脚本
- 将生成在根目录的v2ray_info.inf文件移动到/root目录
- 安装sqlite3，将x-ui相关配置写入x-ui数据库，重启x-ui

### expect脚本定义了自动化安装v2ray、bbr和x-ui的过程（自动应答）：

 - 设置expect命令超时时间
 - 设置expect日志文件  # 也可以不设置，/var/log/cloud-init-output.log不仅记录了expect的日志还记录了cloud-init的其他日志
 - 执行v2ray脚本
 - 执行bbr脚本
 - 执行x-ui脚本

> sqlite3相关命令

- apt install sqlite3 -y  
- sqlite3 /etc/x-ui/x-ui.db "select * from settings;"  
- sqlite3 /etc/x-ui/x-ui.db "INSERT INTO settings (key, value) VALUES ('webBasePath', '/v2ray/');"  
- sqlite3 /etc/x-ui/x-ui.db "DELETE FROM settings WHERE key = 'webCertFile';"  
- sqlite3 /etc/x-ui/x-ui.db "DELETE FROM settings WHERE key = 'webKeyFile';"  
- sqlite3 /etc/x-ui/x-ui.db "INSERT INTO settings (key, value) VALUES ('webCertFile', '/data/v2ray.crt');"  
- sqlite3 /etc/x-ui/x-ui.db "INSERT INTO settings (key, value) VALUES ('webKeyFile', '/data/v2ray.key');"  