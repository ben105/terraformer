variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "tag" {
  type = string
}

variable "iap" {
  type = object({
    id = string
    secret = string
  })
  
  default = null
}
