## Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
## SPDX-License-Identifier: MIT-0
variable "cluster_name" {
  type = string
}

variable "cluster_region" {
  type = string
}

variable "cluster_cidr" {
  type = string
}

variable "cluster_version" {
  type    = string
  default = "1.30"
}
variable "gameservers_instance_types" {
  type    = list(any)
  default = ["m5a.large", "m5zn.large", "m6id.large", "m5ad.large"]
}

variable "gameservers_min_size" {
  type    = number
  default = 1
}

variable "gameservers_max_size" {
  type    = number
  default = 1
}

variable "gameservers_desired_size" {
  type    = number
  default = 1
}

variable "agones_system_instance_types" {
  type    = list(any)
  default = ["m5a.large", "m5zn.large", "m6id.large", "m5ad.large"]
}

variable "agones_system_min_size" {
  type    = number
  default = 1
}

variable "agones_system_max_size" {
  type    = number
  default = 1
}

variable "agones_system_desired_size" {
  type    = number
  default = 1
}

variable "agones_metrics_instance_types" {
  type    = list(any)
  default = ["m5a.large", "m5zn.large", "m6id.large", "m5ad.large"]
}

variable "agones_metrics_min_size" {
  type    = number
  default = 1
}

variable "agones_metrics_max_size" {
  type    = number
  default = 1
}

variable "agones_metrics_desired_size" {
  type    = number
  default = 1
}

variable "open_match_instance_types" {
  type    = list(any)
  default = ["m5a.large", "m5zn.large", "m6id.large", "m5ad.large"]
}

variable "open_match_min_size" {
  type    = number
  default = 1
}

variable "open_match_max_size" {
  type    = number
  default = 1
}

variable "open_match_desired_size" {
  type    = number
  default = 1
}

variable "agones_openmatch_instance_types" {
  type    = list(any)
  default = ["m5a.large", "m5zn.large", "m6id.large", "m5ad.large"]
}

variable "agones_openmatch_min_size" {
  type    = number
  default = 1
}

variable "agones_openmatch_max_size" {
  type    = number
  default = 1
}

variable "agones_openmatch_desired_size" {
  type    = number
  default = 1
}

variable "gameserver_minport" {
  type    = number
  default = 7000
}
variable "gameserver_maxport" {
  type    = number
  default = 7029
}
variable "open_match" {
  type = bool
}
