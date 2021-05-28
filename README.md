# Tarea 4: Infraestructura como Código: Terraform
## Cloud Computing

## Enunciado

Para desarrollar esta tarea realiza los siguientes  pasos:

- Crear los ficheros necesarios con Terraform para crear una infraestructura a tu elección en GCP o AWS
- Sube a un repositorio Github los ficheros generados
- Publica el enlace al repositorio en esta tarea de Moodle

## Infraestructura seleccionada

La infraestructura seleccionada consistirá en dos máquinas virtuales: una que haga de servidor ftp, y otra que haga de página web de descargas, que ofrezca acceso para descarga a los ficheros del servidor ftp.

La página web tendrá IP estática, mientras que el servidor tendrá IP dinámica.

### Plataforma seleccionada

La plataforma seleccionada para el despliegue de dicha infraestructura será Google Cloud Platform

## Recursos a desplegar

La infraestructura desplegada constará de los siguientes recursos:

- **vpc_network:** Red VPC compartida entre las dos máquinas
- **webserver-static-address:** Dirección IP estática de la página web
- **ftp-server:** Instancia de la VM del servidor ftp
- **down-server:** Instancia de la VM de la página web de descargas
- **ssh-rule:** Regla de firewall para permitir el acceso SSH desde Internet a ambas máquinas
- **ftp-rule:** Regla de firewall para permitir el acceso al servidor FTP desde la página web
- **web-rule:** Regla de firewall para permitir el acceso a la página web desde Internet

## Ficheros

Los ficheros creados para la infraestructura son:

- [`provider.tf`](https://github.com/AlmuHS/Practica_Terraform_Cloud/blob/main/provider.tf): Provee de acceso al proyecto de GCP, utilizando el fichero de credenciales de la cuenta de servicio

- [`vm.tf`](https://github.com/AlmuHS/Practica_Terraform_Cloud/blob/main/vm.tf): Realiza el despliegue de la infraestructura, utilizando los recursos de la API de GCP.

- [`vars.tf`](https://github.com/AlmuHS/Practica_Terraform_Cloud/blob/main/vars.tf): Declara las variables de entorno necesarias para almacenar información fuera del fichero de infraestructura.

- [`terraform.tfvars`](https://github.com/AlmuHS/Practica_Terraform_Cloud/blob/main/terraform.tfvars): Fichero de variables. Inicializa las variables creadas en el fichero anterior

## Modo de uso

### Inicializando Terraform

Para realizar el despliegue con estos ficheros, debemos instalar Terraform, e inicializarlo en nuestro directorio con

	terraform init

Si todo ha ido bien, veremos algo como esto:

	Initializing the backend...
	
	Initializing provider plugins...
	- Reusing previous version of hashicorp/google from the dependency lock file
	- Using previously-installed hashicorp/google v3.69.0
	
	Terraform has been successfully initialized!
	
	You may now begin working with Terraform. Try running "terraform plan" to see
	any changes that are required for your infrastructure. All Terraform commands
	should now work.
	
	If you ever set or change modules or backend configuration for Terraform,
	rerun this command to reinitialize your working directory. If you forget, other
	commands will detect it and remind you to do so if necessary.

### Configuración de las variables de entorno

Para que nuestro plan de ejecución funcione, necesitamos configurar algunos variables:

- `ssh_pub_key_file`: Ruta del fichero que almacena la clave ssh pública del usuario (debe tener extensión .pub)
- `ssh_user`: Nombre del usuario utilizado para el acceso ssh
- `project_name`: nombre del proyecto de GCP
- `project_credentials_file`: Fichero de credenciales para la cuenta de servicio de GCP

Estas variables deben editarse en el fichero [`vars.tf`](https://github.com/AlmuHS/Practica_Terraform_Cloud/blob/main/vars.tf).

### Plan de ejecución

Una vez inicializado Terraform y configuradas las variables de entorno, preparamos el plan de ejecución con el comando:

	terraform plan

Esto nos mostrará el plan con la infraestructura a desplegar. En nuestro caso, debe aparecer algo como esto:

	Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
	  + create
	
	Terraform will perform the following actions:
	
	  # google_compute_firewall.ftp-rule will be created
	  + resource "google_compute_firewall" "ftp-rule" {
	      + creation_timestamp = (known after apply)
	      + destination_ranges = (known after apply)
	      + direction          = (known after apply)
	      + enable_logging     = (known after apply)
	      + id                 = (known after apply)
	      + name               = "ftp"
	      + network            = "vpc-network"
	      + priority           = 1000
	      + project            = (known after apply)
	      + self_link          = (known after apply)
	      + source_ranges      = (known after apply)
	      + source_tags        = [
	          + "download-server",
	        ]
	      + target_tags        = [
	          + "ftp",
	        ]
	
	      + allow {
	          + ports    = [
	              + "20",
	              + "21",
	            ]
	          + protocol = "tcp"
	        }
	    }
	
	  # google_compute_firewall.ssh-rule will be created
	  + resource "google_compute_firewall" "ssh-rule" {
	      + creation_timestamp = (known after apply)
	      + destination_ranges = (known after apply)
	      + direction          = (known after apply)
	      + enable_logging     = (known after apply)
	      + id                 = (known after apply)
	      + name               = "ssh"
	      + network            = "vpc-network"
	      + priority           = 1000
	      + project            = (known after apply)
	      + self_link          = (known after apply)
	      + source_ranges      = [
	          + "0.0.0.0/0",
	        ]
	      + target_tags        = [
	          + "download-server",
	          + "ftp",
	        ]
	
	      + allow {
	          + ports    = [
	              + "22",
	            ]
	          + protocol = "tcp"
	        }
	    }
	
	  # google_compute_firewall.web-rule will be created
	  + resource "google_compute_firewall" "web-rule" {
	      + creation_timestamp = (known after apply)
	      + destination_ranges = (known after apply)
	      + direction          = (known after apply)
	      + enable_logging     = (known after apply)
	      + id                 = (known after apply)
	      + name               = "http"
	      + network            = "vpc-network"
	      + priority           = 1000
	      + project            = (known after apply)
	      + self_link          = (known after apply)
	      + source_ranges      = [
	          + "0.0.0.0/0",
	        ]
	      + target_tags        = [
	          + "download-server",
	        ]
	
	      + allow {
	          + ports    = [
	              + "80",
	            ]
	          + protocol = "tcp"
	        }
	    }
	
	  # google_compute_instance.down-server will be created
	  + resource "google_compute_instance" "down-server" {
	      + can_ip_forward       = false
	      + cpu_platform         = (known after apply)
	      + current_status       = (known after apply)
	      + deletion_protection  = false
	      + guest_accelerator    = (known after apply)
	      + id                   = (known after apply)
	      + instance_id          = (known after apply)
	      + label_fingerprint    = (known after apply)
	      + machine_type         = "f1-micro"
	      + metadata             = {
	          + "ssh-keys" = <<-EOT
	                user:ssh-rsa ... = user@machine
	            EOT
	        }
	      + metadata_fingerprint = (known after apply)
	      + min_cpu_platform     = (known after apply)
	      + name                 = "download-server"
	      + project              = (known after apply)
	      + self_link            = (known after apply)
	      + tags                 = [
	          + "download-server",
	        ]
	      + tags_fingerprint     = (known after apply)
	      + zone                 = "europe-west1-b"
	
	      + boot_disk {
	          + auto_delete                = true
	          + device_name                = (known after apply)
	          + disk_encryption_key_sha256 = (known after apply)
	          + kms_key_self_link          = (known after apply)
	          + mode                       = "READ_WRITE"
	          + source                     = (known after apply)
	
	          + initialize_params {
	              + image  = "debian-cloud/debian-10-buster-v20210512"
	              + labels = (known after apply)
	              + size   = 10
	              + type   = (known after apply)
	            }
	        }
	
	      + confidential_instance_config {
	          + enable_confidential_compute = (known after apply)
	        }
	
	      + network_interface {
	          + name               = (known after apply)
	          + network            = "vpc-network"
	          + network_ip         = (known after apply)
	          + subnetwork         = (known after apply)
	          + subnetwork_project = (known after apply)
	
	          + access_config {
	              + nat_ip       = "192.158.31.215"
	              + network_tier = (known after apply)
	            }
	        }
	
	      + scheduling {
	          + automatic_restart   = (known after apply)
	          + min_node_cpus       = (known after apply)
	          + on_host_maintenance = (known after apply)
	          + preemptible         = (known after apply)
	
	          + node_affinities {
	              + key      = (known after apply)
	              + operator = (known after apply)
	              + values   = (known after apply)
	            }
	        }
	    }
	
	  # google_compute_instance.ftp-server will be created
	  + resource "google_compute_instance" "ftp-server" {
	      + can_ip_forward       = false
	      + cpu_platform         = (known after apply)
	      + current_status       = (known after apply)
	      + deletion_protection  = false
	      + guest_accelerator    = (known after apply)
	      + id                   = (known after apply)
	      + instance_id          = (known after apply)
	      + label_fingerprint    = (known after apply)
	      + machine_type         = "f1-micro"
	      + metadata             = {
	          + "ssh-keys" = <<-EOT
	               user:ssh-rsa ... = user@machine
	            EOT
	        }
	      + metadata_fingerprint = (known after apply)
	      + min_cpu_platform     = (known after apply)
	      + name                 = "ftp"
	      + project              = (known after apply)
	      + self_link            = (known after apply)
	      + tags                 = [
	          + "ftp",
	        ]
	      + tags_fingerprint     = (known after apply)
	      + zone                 = "europe-west1-b"
	
	      + boot_disk {
	          + auto_delete                = true
	          + device_name                = (known after apply)
	          + disk_encryption_key_sha256 = (known after apply)
	          + kms_key_self_link          = (known after apply)
	          + mode                       = "READ_WRITE"
	          + source                     = (known after apply)
	
	          + initialize_params {
	              + image  = "debian-cloud/debian-10-buster-v20210512"
	              + labels = (known after apply)
	              + size   = 10
	              + type   = (known after apply)
	            }
	        }
	
	      + confidential_instance_config {
	          + enable_confidential_compute = (known after apply)
	        }
	
	      + network_interface {
	          + name               = (known after apply)
	          + network            = "vpc-network"
	          + network_ip         = (known after apply)
	          + subnetwork         = (known after apply)
	          + subnetwork_project = (known after apply)
	
	          + access_config {
	              + nat_ip       = (known after apply)
	              + network_tier = (known after apply)
	            }
	        }
	
	      + scheduling {
	          + automatic_restart   = (known after apply)
	          + min_node_cpus       = (known after apply)
	          + on_host_maintenance = (known after apply)
	          + preemptible         = (known after apply)
	
	          + node_affinities {
	              + key      = (known after apply)
	              + operator = (known after apply)
	              + values   = (known after apply)
	            }
	        }
	    }
	
	  # google_compute_network.vpc_network will be created
	  + resource "google_compute_network" "vpc_network" {
	      + auto_create_subnetworks         = true
	      + delete_default_routes_on_create = false
	      + gateway_ipv4                    = (known after apply)
	      + id                              = (known after apply)
	      + mtu                             = (known after apply)
	      + name                            = "vpc-network"
	      + project                         = (known after apply)
	      + routing_mode                    = (known after apply)
	      + self_link                       = (known after apply)
	    }
	
	Plan: 6 to add, 0 to change, 0 to destroy.
	
	────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
	
	Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.

### Despliegue de la infraestructura

Finalmente, desplegamos la infraestructura con el comando:

	terraform apply

Nos aparecerá una impresión del plan de ejecución y, al final, un mensaje como este:  
	  
	Plan: 6 to add, 0 to change, 0 to destroy.
	
	Do you want to perform these actions?
	  Terraform will perform the actions described above.
	  Only 'yes' will be accepted to approve.
	
	  Enter a value: 

Introducimos "yes" y pulsamos Enter

Si todo ha ido bien, veremos una salida como esta:

	google_compute_network.vpc_network: Creating...
	google_compute_network.vpc_network: Still creating... [10s elapsed]
	google_compute_network.vpc_network: Still creating... [20s elapsed]
	google_compute_network.vpc_network: Still creating... [30s elapsed]
	google_compute_network.vpc_network: Still creating... [40s elapsed]
	google_compute_network.vpc_network: Still creating... [50s elapsed]
	google_compute_network.vpc_network: Creation complete after 54s [id=projects/cloudcomputing-311313/global/networks/vpc-network]
	google_compute_firewall.web-rule: Creating...
	google_compute_firewall.ftp-rule: Creating...
	google_compute_firewall.ssh-rule: Creating...
	google_compute_instance.ftp-server: Creating...
	google_compute_instance.down-server: Creating...
	google_compute_firewall.web-rule: Still creating... [10s elapsed]
	google_compute_firewall.ftp-rule: Still creating... [10s elapsed]
	google_compute_firewall.ssh-rule: Still creating... [10s elapsed]
	google_compute_instance.ftp-server: Still creating... [10s elapsed]
	google_compute_instance.down-server: Still creating... [10s elapsed]
	google_compute_firewall.ssh-rule: Creation complete after 13s [id=projects/cloudcomputing-311313/global/firewalls/ssh]
	google_compute_firewall.web-rule: Creation complete after 13s [id=projects/cloudcomputing-311313/global/firewalls/http]
	google_compute_firewall.ftp-rule: Creation complete after 13s [id=projects/cloudcomputing-311313/global/firewalls/ftp]
	google_compute_instance.down-server: Creation complete after 15s [id=projects/cloudcomputing-311313/zones/europe-west1-b/instances/download-server]
	google_compute_instance.ftp-server: Creation complete after 16s [id=projects/cloudcomputing-311313/zones/europe-west1-b/instances/ftp]
	
	Apply complete! Resources: 6 added, 0 changed, 0 destroyed.