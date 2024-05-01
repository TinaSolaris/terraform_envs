variable "backend_url" {
  description = "URL of the backend service"
  type        = string
}

variable "frontend_app_name" {
  type = string
  default = "a7-front-app"
}

variable "frontend_container_port" {
  type = number
  default = 3000 # Input your frontend container port
}
