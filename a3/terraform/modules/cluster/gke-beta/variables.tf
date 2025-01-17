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
}

variable "resource_prefix" {
  description = "Arbitrary string with which all names of newly created resources will be prefixed."
  type        = string
}

variable "region" {
  description = "The region in which the cluster master will be created. The cluster will be a regional cluster with multiple masters spread across zones in the region, and with default node locations in those zones as well."
  type        = string
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

variable "node_service_account" {
  description = <<-EOT
    The service account to be used by the Node VMs. If not specified, the "default" service account is used.

    Related docs: [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_node_config), [gcloud](https://cloud.google.com/sdk/gcloud/reference/container/clusters/create#--service-account).
    EOT
  type        = string
  default     = null
}

variable "gke_endpoint" {
  description = "The GKE control plane endpoint to use"
  type        = string
  default     = null
}

variable "enable_gke_dashboard" {
  description = <<-EOT
    Flag to enable GPU usage dashboards for the GKE cluster.
    EOT
  type        = bool
  default     = true

  validation {
    condition     = var.enable_gke_dashboard != null
    error_message = "must not be null"
  }
}

variable "node_pools" {
  description = <<-EOT
    The list of node pools for the GKE cluster.
    ```
    zone: The zone in which the node pool's nodes should be located. Related docs: [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool.html#node_locations)
    node_count: The number of nodes per node pool. This field can be used to update the number of nodes per node pool. Related docs: [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool.html#node_count)
    machine_type: (Optional) The machine type for the node pool. Only supported machine types are 'a3-highgpu-8g' and 'a2-highgpu-1g'. [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#machine_type)
    ```
    EOT
  type = list(object({
    zone         = string,
    node_count   = number,
    machine_type = optional(string, "a3-highgpu-8g")
  }))
  default  = []
  nullable = false
}

variable "resize_node_counts" {
  description = <<-EOT
    The list of resized node counts for node pools of the GKE cluster.
    The resize node count is used in the same order as the node pool, i.e: the first resize node count will be applied for the first node pool and so on.
    EOT
  type        = list(number)
  default     = []
}

variable "kubernetes_setup_config" {
  description = <<-EOT
    The configuration for setting up Kubernetes after GKE cluster is created.
    ```
    kubernetes_service_account_name: The KSA (kubernetes service account) name to be used for Pods. Default value is `aiinfra-gke-sa`.
    kubernetes_service_account_namespace: The KSA (kubernetes service account) namespace to be used for Pods. Default value is `default`.
    ```

    Related Docs: [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
    EOT
  type = object({
    kubernetes_service_account_name      = string,
    kubernetes_service_account_namespace = string
  })
  default = null
}
