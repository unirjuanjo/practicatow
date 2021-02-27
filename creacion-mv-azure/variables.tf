#
variable "location" {
  type string
  description = "Región de Azure donde queremos crearnos la infraesturctura"
  default = "West Wurope"
}

variable mv1 {
  type string
  description = "Máquina virtual que contendrá un servidor NFS y un controller de Ansible"
  default = "mv_nfs_ansible"
}

variable mv2 {
  type string
  description = "Máquina virtual que hará de nodo master de kubernetes"
  default = "mv_master_kuberetes"
}

variable mv3 {
  type string
  description = "Máquina virtual que hará de nodo worker de kubernetes"
  default = "mv_worker"
}

variable mv1_cpu {
  type string
  description = "Numero de CPUs mv1"
  default = "2"
}

variable mv1_ram {
  type string
  description = "Numero de GBs RAM mv1"
  default = "4"
}

variable mv2_cpu {
  type string
  description = "Numero de CPUs mv2"
  default = "2"
}

variable mv2_ram {
  type string
  description = "Numero de GBs RAM mv2"
  default = "4"
}

variable mv3_cpu {
  type string
  description = "Numero de CPUs mv3"
  default = "2"
}

variable mv3_ram {
  type string
  description = "Numero de GBs RAM mv3"
  default = "4"
}
