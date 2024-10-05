variable "function_name" {
  type        = string
  description = "(Required) Unique name for your Lambda Function."
}

variable "role" {
  type        = string
  description = "(Required) Amazon Resource Name (ARN) of the function's execution role. The role provides the function's identity and access to AWS services and resources."
}

# variable "architectures" {
#   type        = string
#   description = "(Optional) Instruction set architecture for your Lambda function. Valid values are [\"x86_64\"] and [\"arm64\"]. Default is [\"x86_64\"]. Removing this attribute, function's architecture stay the same."
# }














variable "filename" {
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
