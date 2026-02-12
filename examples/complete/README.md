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

## Cost

You can use the [Alibaba Cloud Pricing Calculator](https://www.alibabacloud.com/pricing-calculator) to get a cost estimate for resources created by this example.
