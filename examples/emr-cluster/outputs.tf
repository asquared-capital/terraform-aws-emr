output "cluster_id" {
  value = module.emr_cluster.cluster_id
}

output "cluster_name" {
  value = module.emr_cluster.cluster_name
}

output "master_public_dns" {
  value = module.emr_cluster.master_public_dns
}

output "master_security_group_id" {
  value = module.emr_cluster.master_security_group_id
}

output "slave_security_group_id" {
  value = module.emr_cluster.slave_security_group_id
}
