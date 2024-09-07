# 定义节点名和节点属性的映射
variable "nodes" {
  default = {
    node1 = { region = "ord", os_id = "387" }
    node2 = { region = "ord", os_id = "387" }
  }
}

# 使用for_each遍历节点名列表创建cloudinit模板
data "template_file" "cloudinit_template" {
  for_each = var.nodes
  template = file("wulabing_ws_tls.yaml") # 使用相同的模板文件

  vars = {
    node_name = each.key # 为每个模板实例传递不同的节点名
  }
}

# 使用for_each遍历cloudinit模板创建虚拟机instance
resource "vultr_instance" "v2ray_instance" {
  for_each = data.template_file.cloudinit_template
  plan     = "vc2-1c-1gb"
  region   = var.nodes[each.key].region # 使用每个节点的对应的region
  os_id    = var.nodes[each.key].os_id  # 使用每个节点的对应的os
  # each.value对应每个模板实例id，将渲染后的模板传递给user_data
  user_data = each.value.rendered

}

# 使用for_each遍历虚拟机instance创建dns record资源
resource "alicloud_alidns_record" "record" {
  for_each    = vultr_instance.v2ray_instance
  domain_name = "jackyleo.online"
  rr          = each.key
  type        = "A"
  value       = each.value.main_ip
  status      = "ENABLE"
}

output "cloudinit_template_keys" {
  value = tomap({
    for k, instance in data.template_file.cloudinit_template : k => instance.id
  })
}

output "vultr_instance_keys" {
  value = tomap({
    for k, instance in vultr_instance.v2ray_instance : k => instance.id
  })
}
