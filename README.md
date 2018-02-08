# radm - wrapper to manage remote vmadm and imgadm

`radm` provides a simple wrapper for SmartOS `vmadm` and `imgadm` to run these
command on the remote hypervisor. The only additional feature provided for the
moment is `vmadm create` which supports templates.

## Usage

```
$ radm hypervisor.examle.com vmadm create example \
--uuid=fed94887-71ce-4d41-a940-c1c5ec26b514 \
--fqdn=zone.example.com \
--ips=192.168.2.10/25 \
--ips=fe80::181e:49d2:b5f4:9ec5/64 \
--gateways=192.168.2.1
```
