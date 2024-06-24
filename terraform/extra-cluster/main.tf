provider "aws" {
  region = var.cluster_1_region
}

provider "aws" {
  alias  = "ecr"
  region = var.cluster_1_region
}
# provider "aws" {
#   alias  = "peer"
#   region = var.cluster_2_region
# }

data "aws_caller_identity" "current" {}

## ECR
# resource "aws_ecr_replication_configuration" "cross_ecr_replication" {
#   count = var.multi_cluster ? 1 : 0
#   replication_configuration {
#     rule {
#       destination {
#         region      = var.cluster_2_region
#         registry_id = data.aws_caller_identity.current.account_id
#       }
#     }
#   }
# }

resource "aws_ecr_repository" "agones-openmatch-director" {
  name                 = "agones-openmatch-director"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "agones-openmatch-mmf" {
  name                 = "agones-openmatch-mmf"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "agones-openmatch-ncat-server" {
  name                 = "agones-openmatch-ncat-server"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

## Peering
# resource "aws_vpc_peering_connection" "peer" {
#   count       = var.multi_cluster ? 1 : 0
#   vpc_id      = var.requester_vpc_id
#   peer_vpc_id = var.accepter_vpc_id
#   peer_region = var.cluster_2_region
#   auto_accept = false

#   tags = {
#     Side = "Requester"
#   }
# }

# resource "aws_vpc_peering_connection_accepter" "peer" {
#   count                    = var.multi_cluster ? 1 : 0
#   provider                 = aws.peer
#   vpc_peering_connection_id = aws_vpc_peering_connection.peer[0].id
#   auto_accept              = true

#   tags = {
#     Side = "Accepter"
#   }
# }

# resource "aws_route" "requester" {
#   count                   = var.multi_cluster ? 1 : 0
#   route_table_id          = var.requester_route
#   destination_cidr_block  = var.accepter_cidr
#   vpc_peering_connection_id = aws_vpc_peering_connection.peer[0].id
# }

# resource "aws_route" "accepter" {
#   count                   = var.multi_cluster ? 1 : 0
#   provider                = aws.peer
#   route_table_id          = var.accepter_route
#   destination_cidr_block  = var.requester_cidr
#   vpc_peering_connection_id = aws_vpc_peering_connection.peer[0].id
# }

## AWS Global Accelerators
data "aws_lb" "frontend_lb" {
  name = "${var.cluster_1_name}-om-fe"
}

resource "aws_globalaccelerator_accelerator" "aga_frontend" {
  name            = "${var.cluster_1_name}-om-fe"
  ip_address_type = "IPV4"
  enabled         = true
}

resource "aws_globalaccelerator_listener" "aga_frontend" {
  accelerator_arn = aws_globalaccelerator_accelerator.aga_frontend.id
  protocol        = "TCP"

  port_range {
    from_port = 50504
    to_port   = 50504
  }
}

resource "aws_globalaccelerator_endpoint_group" "aga_frontend" {
  listener_arn = aws_globalaccelerator_listener.aga_frontend.id

  endpoint_configuration {
    endpoint_id                    = data.aws_lb.frontend_lb.arn
    client_ip_preservation_enabled = true
    weight                         = 100
  }
}

## Game servers Accelerators
resource "aws_globalaccelerator_custom_routing_accelerator" "aga_gs_cluster_1" {
  name            = "agones-openmatch-gameservers-cluster-1"
  ip_address_type = "IPV4"
  enabled         = true
}

resource "aws_globalaccelerator_custom_routing_listener" "aga_gs_cluster_1" {
  accelerator_arn = aws_globalaccelerator_custom_routing_accelerator.aga_gs_cluster_1.id
  port_range {
    from_port = 1
    to_port   = 65535
  }
}

resource "aws_globalaccelerator_custom_routing_endpoint_group" "aga_gs_cluster_1" {
  listener_arn          = aws_globalaccelerator_custom_routing_listener.aga_gs_cluster_1.id
  endpoint_group_region = var.cluster_1_region
  destination_configuration {
    from_port = 7000
    to_port   = 7029
    protocols = ["TCP", "UDP"]
  }

  endpoint_configuration {
    endpoint_id = var.cluster_1_gameservers_subnets[0]
  }
  endpoint_configuration {
    endpoint_id = var.cluster_1_gameservers_subnets[1]
  }
}

resource "null_resource" "allow_custom_routing_traffic_cluster_1" {
  triggers = {
    always_run         = "${timestamp()}"
    endpoint_group_arn = aws_globalaccelerator_custom_routing_endpoint_group.aga_gs_cluster_1.id
    endpoint_id_1      = var.cluster_1_gameservers_subnets[0]
    endpoint_id_2      = var.cluster_1_gameservers_subnets[1]
  }

  provisioner "local-exec" {
    command = "aws globalaccelerator allow-custom-routing-traffic --endpoint-group-arn ${self.triggers.endpoint_group_arn} --endpoint-id ${self.triggers.endpoint_id_1} --allow-all-traffic-to-endpoint --region us-west-2;aws globalaccelerator allow-custom-routing-traffic --endpoint-group-arn ${self.triggers.endpoint_group_arn} --endpoint-id ${self.triggers.endpoint_id_2} --allow-all-traffic-to-endpoint --region us-west-2"
  }

  depends_on = [
    aws_globalaccelerator_custom_routing_endpoint_group.aga_gs_cluster_1
  ]
}

# resource "aws_globalaccelerator_custom_routing_accelerator" "aga_gs_cluster_2" {
#   count           = var.multi_cluster ? 1 : 0
#   name            = "agones-openmatch-gameservers-cluster-2"
#   ip_address_type = "IPV4"
#   enabled         = true
# }

# resource "aws_globalaccelerator_custom_routing_listener" "aga_gs_cluster_2" {
#   count           = var.multi_cluster ? 1 : 0
#   accelerator_arn = aws_globalaccelerator_custom_routing_accelerator.aga_gs_cluster_2[0].id
#   port_range {
#     from_port = 1
#     to_port   = 65535
#   }
# }

# resource "aws_globalaccelerator_custom_routing_endpoint_group" "aga_gs_cluster_2" {
#   count                   = var.multi_cluster ? 1 : 0
#   listener_arn            = aws_globalaccelerator_custom_routing_listener.aga_gs_cluster_2[0].id
#   endpoint_group_region   = var.cluster_2_region
#   destination_configuration {
#     from_port = 7000
#     to_port   = 7029
#     protocols = ["TCP", "UDP"]
#   }

#   endpoint_configuration {
#     endpoint_id = var.cluster_2_gameservers_subnets[0]
#   }
#   endpoint_configuration {
#     endpoint_id = var.cluster_2_gameservers_subnets[1]
#   }
# }

# resource "null_resource" "allow_custom_routing_traffic_cluster_2" {
#   count = var.multi_cluster ? 1 : 0

#   triggers = {
#     always_run         = "${timestamp()}"
#     endpoint_group_arn = aws_globalaccelerator_custom_routing_endpoint_group.aga_gs_cluster_2[0].id
#     endpoint_id_1      = var.cluster_2_gameservers_subnets[0]
#     endpoint_id_2      = var.cluster_2_gameservers_subnets[1]
#   }

#   provisioner "local-exec" {
#     command = "aws globalaccelerator allow-custom-routing-traffic --endpoint-group-arn ${self.triggers.endpoint_group_arn} --endpoint-id ${self.triggers.endpoint_id_1} --allow-all-traffic-to-endpoint --region us-west-2;aws globalaccelerator allow-custom-routing-traffic --endpoint-group-arn ${self.triggers.endpoint_group_arn} --endpoint-id ${self.triggers.endpoint_id_2} --allow-all-traffic-to-endpoint --region us-west-2"
#   }

#   depends_on = [
#     aws_globalaccelerator_custom_routing_endpoint_group.aga_gs_cluster_2
#   ]
# }

resource "null_resource" "aga_mapping_cluster_1_single" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    when    = create
    command = "nohup ${path.cwd}/scripts/deploy-mapping-configmap-single.sh ${var.cluster_1_name} ${aws_globalaccelerator_custom_routing_accelerator.aga_gs_cluster_1.id}&"
  }

  depends_on = [
    aws_globalaccelerator_custom_routing_endpoint_group.aga_gs_cluster_1
  ]
}

# resource "null_resource" "aga_mapping_cluster_1_multi" {
#   triggers = {
#     always_run = "${timestamp()}"
#   }

#   provisioner "local-exec" {
#     when    = create
#     command = "nohup ${path.cwd}/scripts/deploy-mapping-configmap-multi.sh ${var.cluster_1_name} ${aws_globalaccelerator_custom_routing_accelerator.aga_gs_cluster_1.id} ${var.cluster_2_name} ${aws_globalaccelerator_custom_routing_accelerator.aga_gs_cluster_2.id}&"
#   }

#   depends_on = [
#     aws_globalaccelerator_custom_routing_endpoint_group.aga_gs_cluster_1,
#     aws_globalaccelerator_custom_routing_endpoint_group.aga_gs_cluster_2
#   ]
# }

resource "null_resource" "singlecluster_allocation" {
  count = var.multi_cluster ? 1 : 0

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    when    = create
    command = "nohup ${path.cwd}/scripts/configure-singlecluster-allocation.sh ${var.cluster_1_name} ${path.cwd}&"
  }
}

# resource "null_resource" "multicluster_allocation" {
#   count = var.multi_cluster ? 1 : 0

#   triggers = {
#     always_run = "${timestamp()}"
#   }

#   provisioner "local-exec" {
#     when    = create
#     command = "nohup ${path.cwd}/scripts/configure-multicluster-allocation.sh ${var.cluster_1_name} ${var.cluster_2_name} ${path.cwd}&"
#   }
# }
