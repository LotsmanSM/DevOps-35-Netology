variable "vm_web_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "Ubuntu Version"
}

variable "vm_web_name" {
  type        = string
  default     = "netology-develop-platform-web"
  description = "Instant Name"
}

variable "vm_web_platform_id" {
  type        = string
  default     = "standard-v1"
  description = "Platform ID"
}

variable "vm_web_cores" {
  type        = string
  default     = "2"
  description = "vCPU"
}

variable "vm_web_memory" {
  type        = string
  default     = "1"
  description = "VM memory, Gb"
}

variable "vm_web_core_fraction" {
  type        = string
  default     = "5"
  description = "core fraction, %"
}



variable "vm_db_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "Ubuntu Version"
}

variable "vm_db_name" {
  type        = string
  default     = "netology-develop-platform-db"
  description = "Instant Name"
}

variable "vm_db_platform_id" {
  type        = string
  default     = "standard-v1"
  description = "Platform ID"
}

variable "vm_db_cores" {
  type        = string
  default     = "2"
  description = "vCPU"
}

variable "vm_db_memory" {
  type        = string
  default     = "2"
  description = "VM memory, Gb"
}

variable "vm_db_core_fraction" {
  type        = string
  default     = "20"
  description = "core fraction, %"
}

variable "vms_resources" {
  description = "Resources for VMs"
  type = map(map(number))
  default = {
    vm_web_resources = {
      cores         = 2
      memory        = 1
      core_fraction = 5
    }
    vm_db_resources = {
      cores         = 2
      memory        = 2
      core_fraction = 20
    }
  }
}