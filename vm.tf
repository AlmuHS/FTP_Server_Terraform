resource "google_compute_network" "vpc_network" {
  name = "vpc-network"
  auto_create_subnetworks = true
}

resource "google_compute_address" "webserver-static-address" {
  name = "webserver-static-ip"
}

resource "google_compute_instance" "ftp-server" {
  name         = "ftp"
  machine_type = "f1-micro"
  zone         = "europe-west1-b"

  tags = ["ftp"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10-buster-v20210512"
      size = 10
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name

    access_config {
    }
  }

  metadata = {
      ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_key_file)}"
  }
}

resource "google_compute_instance" "down-server" {
  name         = "download-server"
  machine_type = "f1-micro"
  zone         = "europe-west1-b"

  tags = ["download-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10-buster-v20210512"
      size = 10
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name

    access_config {
      nat_ip = "${google_compute_address.webserver-static-address.address}"
    }
  }

  metadata = {
      ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_key_file)}"
  }
}


resource "google_compute_firewall" "ssh-rule" {
  name = "ssh"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  target_tags = ["ftp", "download-server"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "ftp-rule" {
  name = "ftp"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports = ["20", "21"]
  }
  target_tags = ["ftp"]
  source_tags = ["download-server"]
}

resource "google_compute_firewall" "web-rule" {
  name = "http"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports = ["80"]
  }
  target_tags = ["download-server"]
  source_ranges = ["0.0.0.0/0"]
}