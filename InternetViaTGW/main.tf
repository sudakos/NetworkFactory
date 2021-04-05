/*
  Set the follows on your shell
  $ export TF_VAR_access_key="AKIAXXXXXXXXXXXXXXXXXX"
  $ export TF_VAR_secret_key="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

  or you can run the command with the variables
  $ terraform apply \
  -var 'access_key=AKIAXXXXXXXXXXXXXXXXXX' \
  -var 'secret_key=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'

  https://qiita.com/f96q/items/181c17459bfacf34c100
*/

variable region {
  default = "ap-northeast-1"
}

variable existed_keyname {
  default="ap-north-01_20201202"
}

provider aws {
 profile = "default"
 // access_key = var.access_key
 // secret_key = var.secret_key
 region = var.region
}
