resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits = 2048
}

provider "local" {}

resource "local_file" "private_key" {
  filename = "private_key.pem"
  content = "${tls_private_key.key.private_key_pem}"
}
