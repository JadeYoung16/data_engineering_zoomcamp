terraform {
  required_providers {
    snowflake = {
      source  = "snowflake-labs/snowflake"
      version = "~> 0.87"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-2" 
}

# --- AWS S3 Data Lake ---
resource "aws_s3_bucket" "data_lake" {
  bucket = "data-engineer-project-ee-datalake" 
  force_destroy = true 
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.data_lake.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [aws_s3_bucket_ownership_controls.example]
  bucket     = aws_s3_bucket.data_lake.id
  acl        = "private"
}

# --- Snowflake Infrastructure ---
provider "snowflake" {
  organization_name = "BNNZHHH"    
  account_name      = "KJ98615"   
  user              = "JADE"
  role              = "ACCOUNTADMIN"
  authenticator     = "JWT"
  private_key       = file("${path.module}/snowflake_tf_key.p8")
}

resource "snowflake_warehouse" "ee_wh" {
  name           = "EE_COMPUTE_WH"
  warehouse_size = "XSMALL"
  auto_suspend   = 60    
  auto_resume    = true
}

# 1. Create the Database
resource "snowflake_database" "employee_db" {
  name = "EMPLOYEE_DATA_DB"
}

# 2. Create the Stage
resource "snowflake_stage" "employee_stage" {
  name     = "employee_raw_stage"
  database = snowflake_database.employee_db.name
  schema   = "PUBLIC" 
}

# 3. Create the Staging Schema
resource "snowflake_schema" "staging" {
  database = snowflake_database.employee_db.name
  name     = "STAGING"
}

# 4. Create the Production Schema
resource "snowflake_schema" "production" {
  database = snowflake_database.employee_db.name
  name     = "PRODUCTION"
}

# 5. Create the Table
resource "snowflake_table" "raw_data" {
  database = snowflake_database.employee_db.name
  schema   = snowflake_schema.staging.name
  name     = "RAW_EMPLOYEE_DATA"
  
  column {
    name = "RAW_FILE_CONTENT"
    type = "VARIANT"
  }
}

# --- User & Permissions ---
resource "snowflake_user" "airflow_user" {
  name                 = "AIRFLOW_USER"
  login_name           = "AIRFLOW_USER"
  password             = "MyNewStrongPassword2026!" 
  
  # Use the <<-EOT marker for multi-line strings
  rsa_public_key       = <<-EOT
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqv00N4QE6d6n5QYsSvsu
s22nCqxSJaptEcetGlCinBHZJBFd6dH9uRov9hL+bDm1TW2lPmBArt0F8OI255gS
Khrf44+AdvWXAAaaFCcTH+r1s8nVi99W2sWUDYznOKKHcNQWbM8GWyb1kO0CBrER
K32TnIg2dUxNvGvBHbbBxIbcnQHuoLAryyj89g0MVNM5AlH0AGNiRF4GB70RqS1C
q2SZQqL6PSKMTChCoD2HpB2DFIGfeAQYg028K7gv92iLOsuse2o7o0X/vdJArrWB
UuoP17A4cvLgduTLxX3XIVnKEH3HeC7sk8TvS7iE0oITf3WDmCy5J64eQr13EWaR
tQIDAQAB
EOT

  default_warehouse    = snowflake_warehouse.ee_wh.name
  default_role         = "SYSADMIN"
  must_change_password = false
}

resource "snowflake_grant_privileges_to_account_role" "wh_usage" {
  privileges        = ["USAGE"]
  account_role_name = "SYSADMIN"
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.ee_wh.name
  }
}