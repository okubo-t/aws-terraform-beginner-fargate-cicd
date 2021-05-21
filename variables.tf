## access_key
variable "aws_access_key" {}

## secret key
variable "aws_secret_key" {}

## region
variable "aws_region" {}

## aws account reference
data "aws_caller_identity" "current" {}

## prefix
variable "prefix" {}

## environment
variable "env" {}

## r53 zone
variable "hosted_zone" {}

## source ip
variable "source_ip" {}

## repository name
variable "repo_name" {}

## repository description
variable "repo_description" {}
