variable "tenancy_ocid" {
  description = "OCID del arrendamiento (Tenancy)"
  type        = string
}

variable "user_ocid" {
  description = "OCID del usuario de OCI"
  type        = string
}

variable "fingerprint" {
  description = "Huella digital de la clave API"
  type        = string
}

variable "private_key_path" {
  description = "Ruta local al archivo .pem"
  type        = string
}

variable "region" {
  description = "Región de OCI"
  type        = string
  default     = "sa-saopaulo-1"
}

variable "compartment_ocid" {
  description = "OCID del compartimiento donde se creará todo (usaremos el Tenancy OCID)"
  type        = string
}