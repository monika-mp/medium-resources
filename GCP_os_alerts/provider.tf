provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

terraform {
  required_version = "1.9.6"
  required_providers {
    google = {
      version = ">= 6.4.0"
    }
    google-beta = {
      version = ">= 6.4.0"
    }
  }

}
