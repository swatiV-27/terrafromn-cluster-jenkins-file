#provider
provider "aws" {
          region = "ap-northeast-3"
      }

 
#	Data.tf

data "aws_vpc" "default" {
   default = true
}

data "aws_subnets" "my_subnets" {
  filter {
    name = "vpc-id"
    values  = [data.aws_vpc.default.id]
  }
    filter {
    name   = "default-for-az"
    values = ["true"]
  }
}



#	Cluster-role.tf


resource "aws_iam_role" "cluster_role" {
  name = "cluster_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}




4.	Node-role.tf



resource "aws_iam_role" "node_role" {
  name = "eks-auto-node-example"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.node_role.name
}


#	Eks-cluster.tf



resource "aws_eks_cluster" "eks_cluster" {
  name = "eks_cluster"
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    subnet_ids = data.aws_subnets.my_subnets.ids
    security_group_ids = ["sg-03a37d18c4b9144e5"]
   }
  depends_on = [
     aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
    ]
  }




#	 Eks-node.tf



resource "aws_eks_node_group" "eks_node" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks_node"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = aws_eks_cluster.eks_cluster.vpc_config[0].subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }
  instance_types = ["m7i-flex.large"]
  update_config {
    max_unavailable = 1
  }
  depends_on = [
   aws_eks_cluster.eks_cluster


  ]
}


