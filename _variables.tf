variable "name" {
  type        = string
  description = "Name of this RDS Database"
}

variable "environment_name" {
  type        = string
  description = "Environment name to use as a prefix to this DB"
}

variable "db_type" {
  type        = string
  description = "Valid values are: rds, aurora or serverless"
}

variable "iam_database_authentication_enabled" {
  type    = bool
  default = false
}

variable "allow_security_group_ids" {
  type        = list(string)
  description = "List of Security Group IDs to allow connection to this DB"
  default     = []
}

variable "allow_cidrs" {
  type        = list(string)
  default     = []
  description = "List of CIDRs to allow connection to this DB"
}

variable "user" {
  type        = string
  description = "DB User"
}

variable "retention" {
  type        = number
  description = "Snapshot retention period in days"
}

variable "instance_class" {
  type = string
}

variable "engine" {
  type = string
}

variable "engine_version" {
  type    = string
  default = ""
}

variable "port" {
  type        = number
  description = "Port number for this DB (usually 3306 for MySQL and 5432 for Postgres)"
}

#variable "parameter_group_name" {
#  type        = string
#  description = "Parameter group name for this DB"
#}

variable "apply_immediately" {
  type        = bool
  default     = true
  description = "Apply changes immediately or wait for the maintainance window"
}

variable "skip_final_snapshot" {
  type        = bool
  default     = false
  description = "Skips the final snapshot if the database is destroyed programatically"
}


variable "snapshot_identifier" {
  type        = string
  default     = ""
  description = "Pass a snapshot identifier for the database to be created from this snapshot"
}

variable "identifier" {
  type        = string
  default     = ""
  description = "Optional identifier for DB. If not passed, {environment_name}-{name} will be used"
}

variable "database_name" {
  description = "Database Name"
  type        = string
  default     = ""
}

variable "allocated_storage" {
  type        = number
  description = "Storage size in GB"
  default     = null
}

variable "storage_encrypted" {
  type        = bool
  description = "Enables storage encryption"
}

variable "kms_key_arn" {
  type        = string
  default     = ""
  description = "KMS Key ARN to use a CMK instead of default shared key, when storage_encrypted is true"
}

variable "backup" {
  type        = bool
  description = "Enables automatic backup with AWS Backup"
}

variable "vpc_id" {
  type = string
}

variable "create_db_subnet_group" {
  description = "Create a Subnet group?"
  default     = false
}

variable "db_subnet_group_id" {
  description = "RDS Subnet Group Name"
  type        = string
}

variable "db_subnet_group_subnet_ids" {
  type        = list(any)
  description = "List of Subnet IDs for the RDS Subnet Group"
  default     = []
}

variable "preferred_backup_window" {
  description = "(Aurora Only) The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance_window"
  type        = string
  default     = "07:00-09:00"
}

variable "count_aurora_instances" {
  description = "Number of Aurora Instances"
  type        = number
  default     = "1"
}

# DB and Cluster parameter group
variable "create_cluster_parameter_group" {
  description = "Whether to create a cluster parameter group"
  type        = bool
  default     = false
}

variable "cluster_parameters" {
  description = "A list of Cluster parameters (map) to apply"
  type        = list(map(string))
  default     = []
}

variable "create_db_parameter_group" {
  description = "Whether to create a database parameter group"
  type        = bool
  default     = false
}

variable "db_parameters" {
  description = "A list of DB parameters (map) to apply"
  type        = list(map(string))
  default     = []
}

variable "parameter_group_name" {
  description = "Name of the DB parameter group to associate or create"
  type        = string
  default     = null
}

#variable "use_name_prefix" {
#  description = "Determines whether to use `parameter_group_name` as is or create a unique name beginning with `parameter_group_name` as the specified prefix"
#  type        = bool
#  default     = true
#}

variable "parameter_group_description" {
  description = "The description of the DB parameter group"
  type        = string
  default     = "Managed by Terraform"
}

variable "family" {
  description = "The family of the DB parameter group"
  type        = string
  default     = ""
}

# DB option group
variable "create_db_option_group" {
  description = "(Optional) Create a database option group"
  type        = bool
  default     = false
}

variable "option_group_name" {
  description = "Name of the option group"
  type        = string
  default     = null
}

variable "option_group_use_name_prefix" {
  description = "Determines whether to use `option_group_name` as is or create a unique name beginning with the `option_group_name` as the prefix"
  type        = bool
  default     = true
}

variable "option_group_description" {
  description = "The description of the option group"
  type        = string
  default     = "Managed by Terraform"
}

variable "major_engine_version" {
  description = "Specifies the major version of the engine that this option group should be associated with"
  type        = string
  default     = ""
}

variable "options" {
  description = "A list of Options to apply."
  type        = any
  default     = []
}

variable "deletion_protection" {
  description = "The database can't be deleted when this value is set to true."
  type        = bool
  default     = false
}


variable "multi_az" {
  description = "Deploy multi-az instance database"
  type        = bool
  default     = false
}


variable "performance_insights_enabled" {
  description = "Enable performance insights on instance"
  type        = bool
  default     = false
}


variable "max_allocated_storage" {
  type        = number
  description = "Argument higher than the allocated_storage to enable Storage Autoscaling, size in GB. 0 to disable Storage Autoscaling"
  default     = 0
}

variable "ssm" {
  description = "Enable the use of ssm for SSM parameter store"
  type = bool
  default = true
}

variable "secrets_manager" {
  description = "Enables the creation of a secret in AWS Secrets Manager for the rds database"
  type = bool
  default = false
}

# variable "secret_method" {
#   description = "Use ssm for SSM parameters store which is the default option, or secretsmanager for AWS Secrets Manager"
#   type        = string
#   default     = "ssm"
# }

variable "secret_rotation" {
  description = "(Optional) Enable secret rotation for database master user, if AWS Secrets Manager is used"
  type        = bool
  default     = false
}

variable "secret_rotate_days" {
  description = "(Optional) Number of days for the secret to rotate"
  type = number
  default = 30
}

variable "lambda_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for VPC lambda, if secret rotation is enabled"
}

variable "enabled_cloudwatch_logs_exports" {
  description = "(Optional) Set of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values (depending on engine)"
  default     = null
}

variable "option_name" {
  description = "(Required) The Name of the Option"
  type        = string
  default     = ""
}

variable "publicly_accessible" {
  description = "(Optional) Bool to control if instance is publicly accessible"
  type        = bool
  default     = false
}

variable "license_model" {
  description = "License model information for this DB instance (Optional, but required for some DB engines, i.e. Oracle SE1 and SQL Server)"
  type        = string
  default     = null
}
variable "monitoring_interval" {
  type        = number
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance"
  default     = 0
}

variable "maintenance_window" {
  type        = string
  description = "(RDS Only) The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'"
  default     = "Sun:04:00-Sun:05:00"
}

variable "backup_window" {
  description = "(RDS Only) The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance_window"
  type        = string
  default     = "03:00-03:30"
}

variable "preferred_maintenance_window" {
  type        = string
  description = "(Aurora Only) The weekly time range during which system maintenance can occur, in (UTC) e.g., wed:04:00-wed:04:30"
  default     = "Sun:04:00-Sun:05:00"
}


variable "var.secret_exclude_characters" {
  description = "Define exclude characters in database password on secret rotation"
  default = "/@\"'\\"
}