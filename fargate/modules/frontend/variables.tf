variable "my_cluster_id" {
    type = string
}

variable "backend_host" {
    type = string
}

variable "subnet_id" {
    type = string
    default = "MY_SUBNET_ID"
}

variable "frontend_port" {
    type = number
    default = 3000
}

variable "frontend_image_uri" {
    type = string
    default = "MY_FRONTEND_IMAGE_URI"
}

variable "backend_port" {
    type = number
    default = 8080
}