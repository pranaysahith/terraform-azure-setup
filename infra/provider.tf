provider "azurerm" {
  version = "1.39"
  client_id = "${var.client_id}"
  client_secret = "${var.client_secret}"
  subscription_id = "${var.subscription_id}"
  tenant_id = "${var.tenant_id}"
  environment = "public"
}

resource "azurerm_resource_group" "rg" {
  location = "${var.location}"
  name = "${var.org_name}-${var.env}-rg"
}

provider "tls" {}
