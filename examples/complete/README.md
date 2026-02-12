# Complete Example

This example demonstrates how to use the improve-app-availability module to create a complete auto-scaling application infrastructure on Alibaba Cloud.

## What This Example Creates

This example creates:

- A VPC with 4 VSwitches across different availability zones
- Security group with rules for HTTP and HTTPS traffic
- Application Load Balancer (ALB) with server group and listener
- Elastic Scaling Service (ESS) with scaling group, configuration, rules and scheduled tasks
- Automatic scaling policies for high availability

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money. Run `terraform destroy` when you don't need these resources.

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| common_name | Common name prefix for all resources | `string` | `"improve-app-availability"` | no |
| scale_up_time | Scheduled time for scaling up. Format: YYYY-MM-DDTHH:mmZ | `string` | `null` | no |
| scale_down_time | Scheduled time for scaling down. Format: YYYY-MM-DDTHH:mmZ | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| web_url | The web access URL of the application |
| vpc_id | The ID of the VPC |
| alb_dns_name | The DNS name of the ALB load balancer |
| ess_scaling_group_id | The ID of the ESS scaling group |
| ess_scaling_rule_aris | Map of ESS scaling rule names to their ARIs |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| alicloud | >= 1.131.0 |
| random | >= 3.0 |