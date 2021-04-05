
variable region {
  default = "ap-northeast-1"
}

variable existed_keyname {
  default=/* key pair name*/
}

provider aws {
 profile = "default"
 // access_key = var.access_key
 // secret_key = var.secret_key
 region = var.region
}
