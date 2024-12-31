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

Create the virtual machines keys:

```sh
mkdir .keys && ssh-keygen -f .keys/temp_rsa
```

Create the resources:

```sh
terraform init
terraform apply -auto-approve
```

Confirm if the virtual machines have been initiated correctly:

> [!NOTE]
> The NAT Gateway will be created in parallel with the VMs

```sh
cloud-init status
```


## Using the Load Balancer

### Simple HTTP

The solution will be deployed two virtual machines running NGINX.

Simply call the LB public IP and port `80`:

```sh
curl loadbalancer:80
```

This will balance the request across the pool

### Inbound NAT rule

An [inbound NAT rule][2] with port `22` will direct the requests exclusively to VM001.

To use it, SSH using the load balance public IP, instead of the VM.

For this project configuration in particular, the options [TCP rest and idle timeout][3] and [floating IP][4] are enabled.

## Health extension

This project deploys the [Application Health](https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-health-extension?tabs=rest-api) extensions for [Linux](https://github.com/Azure/applicationhealth-extension-linux).


[1]: https://learn.microsoft.com/en-us/azure/load-balancer/skus
[2]: https://learn.microsoft.com/en-us/azure/load-balancer/inbound-nat-rules
[3]: https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-tcp-idle-timeout?tabs=tcp-reset-idle-portal
[4]: https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-floating-ip
