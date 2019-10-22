output "cluster_id" {
  value       = join("", aws_emr_cluster.emr_cluster.*.id)
  description = "The ID of the EMR Cluster"
}

output "cluster_name" {
  value       = join("", aws_emr_cluster.emr_cluster.*.name)
  description = "The name of the cluster"
}

output "master_public_dns" {
  value       = join("", aws_emr_cluster.emr_cluster.*.master_public_dns)
  description = "The public DNS name of the master EC2 instance"
}

output "master_security_group_id" {
  value       = aws_security_group.master.id
  description = "Master security group ID"
}

output "slave_security_group_id" {
  value       = aws_security_group.slave.id
  description = "Slave security group ID"
}

output "log_uri" {
  value       = aws_emr_cluster.emr_cluster.log_uri
  description = "The path to the Amazon S3 location where logs for this cluster are stored"
}
