/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

variable "project_id" {
  description = "GCP Project ID to which the cluster will be deployed."
  type        = string
  nullable    = false
}

variable "resource_prefix" {
  description = "Arbitrary string with which all names of newly created resources will be prefixed."
  type        = string
  nullable    = false
}

variable "region" {
  description = "The region in which the cluster master will be created. The cluster will be a regional cluster with multiple masters spread across zones in the region, and with default node locations in those zones as well."
  type        = string
  nullable    = false
}

variable "disk_size_gb" {
  description = <<-EOT
    Size of the disk attached to each node, specified in GB. The smallest allowed disk size is 10GB. Defaults to 200GB.

    Related docs: [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#disk_size_gb), [gcloud](https://cloud.google.com/sdk/gcloud/reference/container/clusters/create#--disk-size).
    EOT
  type        = number
  default     = 200
  nullable    = false
}

variable "disk_type" {
  description = <<-EOT
    Type of the disk attached to each node. The default disk type is 'pd-standard'

    Possible values: `["pd-ssd", "local-ssd", "pd-balanced", "pd-standard"]`

    Related docs: [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#disk_type), [gcloud](https://cloud.google.com/sdk/gcloud/reference/container/clusters/create#--disk-type).
    EOT
  type        = string
  default     = "pd-ssd"
  nullable    = false
}

variable "enable_gke_dashboard" {
  description = <<-EOT
    Flag to enable GPU usage dashboards for the GKE cluster.
    EOT
  type        = bool
  default     = true
  nullable    = false
}

variable "gke_version" {
  description = <<-EOT
    The GKE version to be used as the minimum version of the master. The default value for that is latest master version.
    More details can be found [here](https://cloud.google.com/kubernetes-engine/versioning#specifying_cluster_version)

    Related docs: [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#name), [gcloud](https://cloud.google.com/sdk/gcloud/reference/container/clusters/create#--name).
    EOT
  type        = string
  default     = null
}

variable "network_existing" {
  description = "Existing network to attach to nic0. Setting to null will create a new network for it."
  type = object({
    network_name    = string
    subnetwork_name = string
  })
  default = null
}

variable "node_service_account" {
  description = <<-EOT
    The service account to be used by the Node VMs. If not specified, the "default" service account is used.

    Related docs: [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_node_config), [gcloud](https://cloud.google.com/sdk/gcloud/reference/container/clusters/create#--service-account).
    EOT
  type        = string
  default     = null
}

variable "host_maintenance_interval" {
  description = "Specifies the frequency of planned maintenance events. 'PERIODIC' is th only supported value for host_maintenance_interval. This enables using stable fleet VM."
  type        = string
  default     = "PERIODIC"
  validation {
    condition = var.host_maintenance_interval != null ? contains(
      ["PERIODIC"],
      var.host_maintenance_interval,
    ) : true
    error_message = "'PERIODIC' is th only supported value for host_maintenance_interval."
  }
}

variable "node_pools" {
  description = <<-EOT
    The list of node pools for the GKE cluster.
    - `zone`: The zone in which the node pool's nodes should be located. Related docs: [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool.html#node_locations)
    - `node_count`: The number of nodes per node pool. This field can be used to update the number of nodes per node pool. Related docs: [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool.html#node_count)
    - `use_compact_placement_policy`: (Optional) The flag to create and use a superblock level compact placement policy for the instances. Currently only 1 resource policy is supported. Related docs: [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool.html#policy_name)
    - `machine_type`: (Optional) The machine type for the node pool. Only supported machine types are 'a3-highgpu-8g' and 'a2-highgpu-1g'. [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#machine_type)
    EOT
  type = list(object({
    zone                         = string,
    node_count                   = number,
    use_compact_placement_policy = optional(bool, false),
    machine_type                 = optional(string, "a3-highgpu-8g")
  }))
  default  = []
  nullable = false

  validation {
    condition     = length(var.node_pools) != 0
    error_message = "must be non-empty list"
  }
}

variable "kubernetes_setup_config" {
  description = <<-EOT
    The configuration for setting up Kubernetes after GKE cluster is created.

    - `enable_kubernetes_setup`: Flag to enable kubernetes setup
    - `kubernetes_service_account_name`: The KSA (kubernetes service account) name to be used for Pods
    - `kubernetes_service_account_namespace`: The KSA (kubernetes service account) namespace to be used for Pods

    Related Docs: [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
    EOT
  type = object({
    enable_kubernetes_setup              = bool,
    kubernetes_service_account_name      = string,
    kubernetes_service_account_namespace = string
  })
  default = {
    enable_kubernetes_setup              = true
    kubernetes_service_account_name      = "aiinfra-gke-sa"
    kubernetes_service_account_namespace = "default"
  }
  nullable = false
}
