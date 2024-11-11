#* 此配置文件主要用于设置v2ray vm实例相关的设置

# （自定义一个nodes列表变量）定义节点名和节点属性的映射
variable "nodes" {
  default = {
    #* 自定义此处：Chicago + Ubuntu 20.04 LTS 
    #! 版本不能乱改，不然一些脚本会跑失败，若修改，需同步验证脚本运行情况：web console查看cloud-init日志
    # share2 = { region = "ord", os_id = "387" }
    share2 = { region = "sjc", os_id = "387" }
    #* 自定义此处：Silicon Valley + Ubuntu 24.04 LTS
    # share2 = { region = "sjc", os_id = "2284" }
  }
}

#* data block请求terraform从指定的数据源template_file读取数据，并将结果导出至本地标识cloudinit_template下，name可以在同一个module的其他地方引用该数据源，
#* A data block requests that Terraform read from a given data source ("aws_ami") and export the result under the given local name ("example").
#* https://developer.hashicorp.com/terraform/language/data-sources

#* 每个数据源都是一个provider，此处使用的provider是hashicorp/template，这个provider定义了一个叫做template_file的data sources
#* https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
#! terraform 0.12及之后，已经被templatefile函数取代

#* 如果一个资源或者模块block包含for_each参数，它的值是个字符串map或者字符串set，则terraform会为该map或者set中的每个成员都创建一个实例

# 使用for_each遍历nodes节点名列表创建cloudinit模板
data "template_file" "cloudinit_template" {
  for_each = var.nodes
  template = file("wulabing_ws_tls.yaml") # 使用相同的模板文件，即每个node都使用wulabing_ws_tls.yaml文件

  #! wulabing_ws_tls.yaml文件是原始数据源，其中使用了变量${node_name}，这里可以将node_name赋值，渲染出最终的模板文件
  vars = {
    node_name = each.key # 为每个模板实例传递不同的节点名
  }
}

# 使用for_each遍历cloudinit模板创建虚拟机instance
resource "vultr_instance" "v2ray_instance" {
  for_each = data.template_file.cloudinit_template
  plan     = "vc2-1c-1gb"

  #* 最初的each对象，是定义的node列表，每个node的key是share1、share2，使用每个node创建了一个cloudinit_template后，每个cloudinit_template对象的key也是share1、share2（使用terraform output打印验证），
  #* 这里是使用cloudinit_teplate的key，从nodes变量中拿到每个node的region和os_id
  region   = var.nodes[each.key].region # 使用每个节点的对应的region
  os_id    = var.nodes[each.key].os_id  # 使用每个节点的对应的os
  
  #* user_data获取一个cloud-init的配置文件，实现自动化配置一些内容，这里自动化配置v2ray
  # each.value对应每个模板实例id，将渲染后的模板传递给user_data
  user_data = each.value.rendered

}

# 使用for_each遍历虚拟机instance创建dns record资源
resource "alicloud_alidns_record" "record" {
  #* 阿里云provider创建dns record资源，需要获取vm实例的name和ip，这些只有在vm创建之后才能获取，
  #* 这里使用for_each遍历创建后的vm实例，v2ray_instance对象是遍历cloudinit_template对象创建的，key也是share1、share2（使用terraform output打印验证），
  for_each    = vultr_instance.v2ray_instance
  domain_name = "jackyleo.online"
  rr          = each.key
  type        = "A"
  value       = each.value.main_ip
  status      = "ENABLE"
}

# 使用terraform output命令打印cloudinit_template的key和instance.id
output "cloudinit_template_keys" {
  value = tomap({
    for k, instance in data.template_file.cloudinit_template : k => instance.id
  })
}

# 使用output指令打印v2ray_instance的key和instance.id
output "vultr_instance_keys" {
  value = tomap({
    for k, instance in vultr_instance.v2ray_instance : k => instance.id
  })
}
