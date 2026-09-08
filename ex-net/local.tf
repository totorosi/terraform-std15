locals {
  tag_header = "std15-"
  azs        = data.aws_availability_zones.available_az.names
}
