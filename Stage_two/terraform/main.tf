terraform {
  required_version = ">= 1.3.0"
}

variable "vagrant_workdir" {
  type        = string
  description = "Path to the Vagrant environment root (where Vagrantfile is)."
  default     = "${path.module}/.."
}

# Keep things simple: use local-exec to invoke Vagrant, which in turn runs Ansible (ansible_local)
resource "null_resource" "vagrant_up" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command     = "vagrant up --provision"
    working_dir = var.vagrant_workdir
  }
}
