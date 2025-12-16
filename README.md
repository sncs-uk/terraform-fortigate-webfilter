<!-- BEGIN_TF_DOCS -->
# Fortigate Webfilter configuration module

This terraform module configures webfilters, zones & hardware
switches on a firewall

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.0 |
| <a name="requirement_fortios"></a> [fortios](#requirement\_fortios) | >= 1.22.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_fortios"></a> [fortios](#provider\_fortios) | >= 1.22.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [fortios_webfilter_profile.profiles](https://registry.terraform.io/providers/fortinetdev/fortios/latest/docs/resources/webfilter_profile) | resource |
| [fortios_webfilter_urlfilter.filters](https://registry.terraform.io/providers/fortinetdev/fortios/latest/docs/resources/webfilter_urlfilter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_path"></a> [config\_path](#input\_config\_path) | Path to base configuration directory | `string` | n/a | yes |
| <a name="input_vdoms"></a> [vdoms](#input\_vdoms) | List of VDOMs from which to pull in configuration | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->