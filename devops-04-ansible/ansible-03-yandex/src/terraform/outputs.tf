output "all_vms" {
  value = flatten([
    [for i in yandex_compute_instance.centos7 : {
      name = i.name
      ip_external   = i.network_interface[0].nat_ip_address
      ip_internal = i.network_interface[0].ip_address
    }],
  ])
}