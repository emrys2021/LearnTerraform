#* 此配置文件主要用于设置provider相关的设置
terraform {
  # Terraform 配置文件必须声明需要使用哪些providers，Terraform configurations must declare which providers they require
  # https://developer.hashicorp.com/terraform/language/providers/requirements
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "2.15.1"
    }
    alicloud = {
      source = "aliyun/alicloud"
    }
    template = {
      source = "hashicorp/template"
    }
  }
}

# vultr provider用于连接vultr创建vm
provider "vultr" {
  api_key = var.vultr_api_key
}

# 声明input变量，用于vultr_api_key
variable "vultr_api_key" {}

# alicloud provider用于连接阿里云创建dns A record
provider "alicloud" {
  access_key = var.aliyun_access_key
  secret_key = var.aliyun_secret_key
  region     = var.region
}

# 声明input变量，用于阿里云相关设置
variable "aliyun_access_key" {
  type = string
}

variable "aliyun_secret_key" {
  type = string
}

variable "region" {
  type = string
}