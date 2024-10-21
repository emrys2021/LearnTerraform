# vsphere provider
terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.2.0"
    }
  }
}

# vsphere地址、凭据
provider "vsphere" {
  vsphere_server       = var.vsphere_server
  user                 = var.vsphere_user
  password             = var.vsphere_password
  allow_unverified_ssl = true
}

# 指明数据中心
data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

# 指明esxi节点
data "vsphere_host" "hosts" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

# 未创建集群
# data "vsphere_compute_cluster" "compute_cluster" {
#   name			= var.vsphere_compute_cluster
#   datacenter_id		= data.vsphere_datacenter.dc.id
# }

# 指明数据存储
data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

# 指明端口组
data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

# 指明从哪个模板克隆虚拟机
data "vsphere_virtual_machine" "template" {
  name          = var.vm_template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# 指明虚拟机配置
resource "vsphere_virtual_machine" "vm" {
  for_each = var.vms

  datastore_id = data.vsphere_datastore.datastore.id
#   resource_pool_id	= data.vsphere_compute_cluster.compute_cluster.resource_pool_id
  resource_pool_id = data.vsphere_host.hosts.resource_pool_id
  guest_id         = var.vm_guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type # 设置SCSI控制器类型和模板相同 (报错inaccessable boot device)
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  name = each.value.name

  num_cpus = var.vm_vcpu
  memory   = var.vm_memory
  firmware = var.vm_firmware

  wait_for_guest_net_timeout = 30

  disk {
    label            = var.vm_disk_label
    size             = var.vm_disk_size
    thin_provisioned = var.vm_disk_thin # 需要和模板的一样，不然创建的时候不生效，仍然以模板为主
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      timeout = 0
      # linux_options {
      # host_name       = each.value.name
      # domain		= var.vm_domain
      # }
      windows_options {
        computer_name  = each.value.name
        workgroup      = "workgroup"
        admin_password = "Qwerty123$"
      }
      network_interface {
        ipv4_address    = each.value.vm_ip
        ipv4_netmask    = var.vm_ipv4_netmask
        dns_server_list = var.vm_dns_servers
      }
      ipv4_gateway = var.vm_ipv4_gateway
    }
  }
}