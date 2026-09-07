# resource "aws_instance" "this" {
#   count         = 2
#   subnet_id     = aws_subnet.public.id
#   ami           = "ami-0aa2bfca464a9be6b"
#   instance_type = "t3.micro"
#   tags = {
#     Name = "test-${count.index + 1}-instance"
#   }

# }


# resource "aws_instance" "this" {
#   for_each = {
#     "a" = "logs"
#     "b" = "media"
#     "c" = "backups"
#   }
#   subnet_id     = "subnet-0f605fdc42a4dda32"
#   ami           = "ami-0aa2bfca464a9be6b"
#   instance_type = "t3.micro"
#   tags = {
#     Name = "test-${each.value}-instance" # each.key
#   }

# }


# output "prt_instance" {
#   value = aws_instance.this["a"].tags
#   #   value = { for k, v in aws_instance.this : k => v.tags }
# } 
