# Variables for Stage 2 Terraform orchestration
variable "vagrant_workdir" {
  type        = string
  description = "Path to the Vagrant environment root (where Vagrantfile is)."
  default     = "${path.module}/.."
}
