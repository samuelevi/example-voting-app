variable "github_sub" {
  description = "OIDC subject GitHub sends for runs on main"
  type        = string
  default     = "repo:samuelevi@60100689/example-voting-app@1430414102:ref:refs/heads/main"
}

# Lets GitHub Actions prove its identity to AWS without stored keys
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

data "aws_iam_policy_document" "github_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    # Only runs on the main branch of this repository may assume the role
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [var.github_sub]
    }
  }
}

resource "aws_iam_role" "github_deploy" {
  name               = "${var.cluster_name}-github-deploy"
  assume_role_policy = data.aws_iam_policy_document.github_assume.json
}

data "aws_iam_policy_document" "github_deploy" {
  statement {
    actions   = ["eks:DescribeCluster"]
    resources = [aws_eks_cluster.this.arn]
  }
}

resource "aws_iam_role_policy" "github_deploy" {
  name   = "describe-cluster"
  role   = aws_iam_role.github_deploy.id
  policy = data.aws_iam_policy_document.github_deploy.json
}

# Give the role Kubernetes permissions, limited to the voting namespace
resource "aws_eks_access_entry" "github_deploy" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_iam_role.github_deploy.arn
}

resource "aws_eks_access_policy_association" "github_deploy" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_iam_role.github_deploy.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type       = "namespace"
    namespaces = ["voting"]
  }

  depends_on = [aws_eks_access_entry.github_deploy]
}

output "github_deploy_role_arn" {
  value = aws_iam_role.github_deploy.arn
}