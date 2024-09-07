#Provider
vsphere_user     = "Administrator@vsphere.local"
vsphere_password = "Qwerty123$"
vsphere_server   = "10.15.17.123"

#Infrastructure
vsphere_datacenter = "Datacenter01"
vsphere_host       = "10.15.17.13"
# vsphere_compute_cluster = "Test_cluster"
vsphere_datastore = "datastore3-2"
# vsphere_network = "VM Network"
vsphere_network = "DPortGroup"

#VM
vm_template_name = "win10-template"
# vm_guest_id = "windows10"
vm_guest_id     = "windows9_64Guest"
vm_vcpu         = "2"
vm_memory       = "4096"
vm_ipv4_netmask = "24"
vm_ipv4_gateway = "10.15.17.1"
vm_dns_servers  = ["10.20.193.2", "172.31.1.1"]
vm_disk_label   = "disk0"
# vm_disk_size  = "50"
vm_disk_size = "100"
vm_disk_thin = "false"
vm_domain    = "example.com"
vm_firmware  = "efi"

vms = {
  windows_test_1 = {
    # name                = "rocky-1"
    name  = "win-1"
    vm_ip = "10.15.17.225"
  },
  windows_test_2 = {
    # name                = "rocky-2"
    name  = "win-2"
    vm_ip = "10.15.17.226"
  }
}