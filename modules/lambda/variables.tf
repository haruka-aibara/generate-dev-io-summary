variable "filename" {
  type = string
}

variable "function_name" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "handler" {
  type = string
}

variable "runtime" {
  type = string
}

variable "timeout" {
  type = number
}

variable "environment_variables" {
  type = map(string)
}

variable "layer_zip_path" {
  type = string
}

variable "layer_source_code_hash" {
  type = string
}
