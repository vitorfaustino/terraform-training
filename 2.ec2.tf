#######################################################################
# FRONTEND | Elastic IP
#######################################################################
resource "aws_eip" "frontend" {
  vpc = true
  //instance                  = aws_instance.frontend.id
}

#######################################################################
# FRONTEND | Create EC2 resource below
#######################################################################