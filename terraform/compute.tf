# 1. Obtenemos la zona de datos de tu región
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

# 2. Buscamos la imagen oficial de Ubuntu 22.04 para procesadores AMD (x86_64)
data "oci_core_images" "ubuntu_amd" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = "VM.Standard.E2.1.Micro"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# 3. Creamos el Servidor (Plan B: La Vieja Confiable)
resource "oci_core_instance" "n8n_server" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "n8n-rag-server-amd"
  shape               = "VM.Standard.E2.1.Micro"
  # Eliminamos el bloque shape_config porque esta máquina tiene recursos fijos (1/8 OCPU y 1GB RAM)

  create_vnic_details {
    subnet_id        = oci_core_subnet.n8n_subnet.id
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_amd.images[0].id
  }

  metadata = {
    ssh_authorized_keys = file("./n8n_key.pub")
    
    # Inyectamos un script de Bash para crear 4GB de memoria Swap en el disco duro automáticamente
    user_data = base64encode(<<-EOF
      #!/bin/bash
      fallocate -l 4G /swapfile
      chmod 600 /swapfile
      mkswap /swapfile
      swapon /swapfile
      echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
    EOF
    )
  }
}

# 4. Imprimimos la IP pública al terminar
output "ip_publica_servidor" {
  value       = oci_core_instance.n8n_server.public_ip
  description = "IP de la Vieja Confiable"
}