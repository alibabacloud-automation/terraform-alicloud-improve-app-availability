阿里云提升应用可用性 Terraform 模块

================================================ 

# terraform-alicloud-improve-app-availability

[English](https://github.com/alibabacloud-automation/terraform-alicloud-improve-app-availability/blob/main/README.md) | 简体中文

本 Terraform 模块实现了阿里云上的[自动弹性，稳定交付](https://www.aliyun.com/solution/tech-solution/improve-app-availability)解决方案。该模块创建了完整的高可用基础设施，包括专有网络（VPC）、交换机（VSwitch）、云服务器（ECS）、应用型负载均衡器（ALB）和弹性伸缩（ESS）资源，确保您的应用程序能够自动扩缩容并在不同负载下保持稳定交付。

## 使用方法

此模块帮助您快速建立具有负载均衡和高可用性功能的自动扩缩容 Web 应用程序基础设施。该基础设施根据需求自动调整 ECS 实例数量，并通过 ALB 分发流量以实现最佳性能。

```terraform
data "alicloud_zones" "default" {
  available_resource_creation = "VSwitch"
}

data "alicloud_alb_zones" "default" {}

data "alicloud_instance_types" "default" {
  availability_zone = data.alicloud_zones.default.zones[0].id
  instance_type_family = "ecs.g7"
}

data "alicloud_images" "default" {
  name_regex  = "^aliyun_3_9_x64_20G_*"
  most_recent = true
  owners      = "system"
}

module "improve_app_availability" {
  source  = "alibabacloud-automation/improve-app-availability/alicloud"

  vpc_config = {
    vpc_name   = "my-app-vpc"
    cidr_block = "192.168.0.0/16"
  }

  vswitches_config = [
    {
      name         = "ecs_vswitch_1"
      cidr_block   = "192.168.1.0/24"
      zone_id      = data.alicloud_zones.default.zones[0].id
      vswitch_name = "my-app-ecs-vsw-1"
    },
    {
      name         = "alb_vswitch_1"
      cidr_block   = "192.168.3.0/24"
      zone_id      = data.alicloud_alb_zones.default.zones[0].id
      vswitch_name = "my-app-alb-vsw-1"
    }
  ]

  security_group_config = {
    security_group_name = "my-app-sg"
  }

  security_group_rules_config = [
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "80/80"
      cidr_ip     = "0.0.0.0/0"
    }
  ]

  alb_config = {
    load_balancer_name = "my-app-alb"
  }

  alb_server_group_config = {
    server_group_name = "my-app-server-group"
  }

  alb_listener_config = {
    listener_protocol = "HTTP"
    listener_port     = 80
  }

  ess_scaling_group_config = {
    scaling_group_name = "my-app"
    min_size           = 2
    max_size           = 5
    vswitch_names      = ["ecs_vswitch_1"]
  }

  ess_scaling_configuration_config = {
    image_id      = data.alicloud_images.default.images[0].id
    instance_types = [data.alicloud_instance_types.default.instance_types[0].id]
    password      = "YourPassword123!"
    instance_name = "my-app-ess"
  }
}
```

## 示例

* [完整示例](https://github.com/alibabacloud-automation/terraform-alicloud-improve-app-availability/tree/main/examples/complete)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## 提交问题

如果您在使用此模块时遇到任何问题，请提交一个 [provider issue](https://github.com/aliyun/terraform-provider-alicloud/issues/new) 并告知我们。

**注意：** 不建议在此仓库中提交问题。

## 作者

由阿里云 Terraform 团队创建和维护(terraform@alibabacloud.com)。

## 许可证

MIT 许可。有关完整详细信息，请参阅 LICENSE。

## 参考

* [Terraform-Provider-Alicloud Github](https://github.com/aliyun/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)