variable "my_cluster_id" {
    type = string
}

variable "subnet_id" {
    type = string
    default = "MY_SUBNET_ID"
}

variable "backend_port" {
    type = number
    default = 8080
}

variable "backend_image_uri" {
    type = string
    default = "MY_BACKEND_IMAGE_URI"
}