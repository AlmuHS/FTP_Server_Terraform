provider "google" {
    credentials= "${file(var.project_credentials_file)}" 
    project     = var.project_name
    region      = "europe-west1"
    zone = "europe-west1-b"
}