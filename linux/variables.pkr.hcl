//  variables.pkr.hcl
// For those variables that you don't provide a default for, you must
// set them from the command line, a var-file, or the environment.


variable "image_id" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."


  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^ami-", var.image_id))
    error_message = "The image_id value must be a valid AMI id, starting with \"ami-\"."
  }
}

variable "share_with" {
  type = list(string)
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ssh_user" {
  type = string
}
variable "inst_type" {
  type = string
}

variable "vol_size" {
  type = number
}

variable "vol_type" {
  type = string
}

variable "iam_profile" {
  type = string
}