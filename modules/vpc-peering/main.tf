resource "aws_vpc_peering_connection" "this" {
  vpc_id        = var.requester_vpc_id
  peer_vpc_id   = var.accepter_vpc_id
  auto_accept   = true

  tags = {
    Name = "peering-${var.requester_vpc_id}-${var.accepter_vpc_id}"
  }
}

# Ruta desde la VPC requester hacia la VPC peer
resource "aws_route" "to_peer" {
  count = length(var.requester_route_table_ids)

  route_table_id            = var.requester_route_table_ids[count.index]
  destination_cidr_block    = var.accepter_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}
