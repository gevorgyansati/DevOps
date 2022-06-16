locals {
    az = [
        "eu-central-1a",
        "eu-central-1b",
        "eu-central-1c"
    ]

    versions = {
        "v1" = "ami-0bc6ca33d28ddd776",
        "v2" = "ami-0cd51cd68380afcb3"
    }

}

variable "ami_version" {
  description = "Version:"
validation {
  condition = var.ami_version == "v1" || var.ami_version == "v2"
  error_message = "Unknown key!!."
}
}