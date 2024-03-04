variable "project" {
  type = string
}

variable "backends" {
  type = list(object({
    host    = string
    name    = string
    service = string
  }))
}