variable "name" {}
variable "root" {}
variable "role_policy" {}
variable "runtime" {
  default = "nodejs18.x"
}
variable "environment_variables" {
  default = {}
}