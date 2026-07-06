# 1. Creamos la Red Virtual (VCN) principal
resource "oci_core_vcn" "n8n_vcn" {
  compartment_id = var.compartment_ocid
  cidr_block     = "10.0.0.0/16"
  display_name   = "n8n-rag-vcn"
}

# 2. Creamos la puerta de salida a Internet
resource "oci_core_internet_gateway" "n8n_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.n8n_vcn.id
  display_name   = "n8n-internet-gateway"
  enabled        = true
}

# 3. Creamos la tabla de rutas (el mapa de calles) para que el tráfico salga por el Internet Gateway
resource "oci_core_route_table" "n8n_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.n8n_vcn.id
  display_name   = "n8n-public-route-table"
  
  route_rules {
    network_entity_id = oci_core_internet_gateway.n8n_igw.id
    destination       = "0.0.0.0/0"
  }
}

# 4. Creamos el Firewall (Security List). Abrimos puertos específicos.
resource "oci_core_security_list" "n8n_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.n8n_vcn.id
  display_name   = "n8n-security-list"

  # Regla de salida: El servidor puede conectarse a cualquier parte de internet
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # Regla de entrada: SSH (Puerto 22) para conectarnos a la consola
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options { 
      max = 22
      min = 22 
    }
  }

  # Regla de entrada: HTTP (Puerto 80)
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options { 
      max = 80
      min = 80 
    }
  }
  
  # Regla de entrada: HTTPS (Puerto 443) para webhooks
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options { 
      max = 443
      min = 443 
    }
  }

  # Regla de entrada: n8n (Puerto 5678)
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options { 
      max = 5678
      min = 5678 
    }
  }
}

# 5. Creamos la Subred donde vivirá la máquina conectando todo lo anterior
resource "oci_core_subnet" "n8n_subnet" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.n8n_vcn.id
  cidr_block        = "10.0.1.0/24"
  display_name      = "n8n-public-subnet"
  route_table_id    = oci_core_route_table.n8n_rt.id
  security_list_ids = [oci_core_security_list.n8n_sl.id]
}