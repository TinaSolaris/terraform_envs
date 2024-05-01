variable "backend_app_name" {
  type = string
  default = "a7-back-app"
}

variable "backend_container_port" {
  type = number
  default = 8080 # backend container port
}