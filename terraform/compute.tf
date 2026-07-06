# 1. Obtenemos la zona de datos de tu región (Dominio de Disponibilidad)
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

# 2. Buscamos automáticamente la imagen oficial de Ubuntu 22.04 para ARM
data "oci_core_images" "ubuntu_arm" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# 3. Creamos el Servidor (La Bestia)
resource "oci_core_instance" "n8n_server" {
  # Lo ponemos en la primera zona disponible
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "n8n-rag-server"
  shape               = "VM.Standard.A1.Flex"

  # Asignamos los recursos gratuitos máximos
  shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }

  # Lo conectamos a la calle con internet que creamos antes
  create_vnic_details {
    subnet_id        = oci_core_subnet.n8n_subnet.id
    assign_public_ip = true
  }

  # Le instalamos el sistema operativo Ubuntu
  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_arm.images[0].id
  }

  # Le inyectamos tu llave SSH pública
  metadata = {
    ssh_authorized_keys = file("./n8n_key.pub")
  }
}

# 4. Al finalizar, le pedimos a Terraform que nos imprima la IP de tu nuevo servidor
output "ip_publica_servidor" {
  value       = oci_core_instance.n8n_server.public_ip
  description = "Guarda esta IP, es la direccion web de tu proyecto"
}