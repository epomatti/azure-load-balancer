# Azure Load Balancer

Demo implementation of Azure Load Balancer with Terraform.

> [!NOTE]
> Azure Load Balancer of `Basic` SKU [will be retired][1] in 2025. Use or migrate to `Standard`.

## Setup

Create the variables file:

```sh
cp config/local.auto.tfvars .auto.tfvars
```

Set the required variables:

```terraform
subscription_id = ""
```

Create the virtual machine keys:

```sh
mkdir .keys && ssh-keygen -f .keys/temp_rsa
```

Create the resources:

```sh
terraform init
terraform apply -auto-approve
```

[1]: https://learn.microsoft.com/en-us/azure/load-balancer/skus
