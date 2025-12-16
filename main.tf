/**
 * # Fortigate Webfilter configuration module
 *
 * This terraform module configures webfilters, zones & hardware
 * switches on a firewall
 */
terraform {
  required_version = ">= 1.13.0"
  required_providers {
    fortios = {
      source  = "fortinetdev/fortios"
      version = ">= 1.22.0"
    }
  }
}

locals {
  vdom_webfilter_yaml = {
    for vdom in var.vdoms : vdom => yamldecode(file("${var.config_path}/${vdom}/webfilter.yaml")) if fileexists("${var.config_path}/${vdom}/webfilter.yaml")
  }


  profiles = flatten([
    for vdom in var.vdoms : [
      for name, object in try(local.vdom_webfilter_yaml[vdom].profiles, []) : merge(object, { name = name, vdomparam = vdom })
    ]
  ])

  urlfilters = flatten([
    for vdom in var.vdoms : [
      for name, object in try(local.vdom_webfilter_yaml[vdom].urlfilters, []) : merge(object, { name = name, vdomparam = vdom })
    ]
  ])
}

resource "fortios_webfilter_urlfilter" "filters" {
  for_each              = { for filter in local.urlfilters : filter.fosid => filter }
  fosid                 = each.value.fosid
  name                  = each.value.name
  comment               = try(each.value.comment, null)
  one_arm_ips_urlfilter = try(each.value.one_arm_ips_urlfilter, null)
  ip_addr_block         = try(each.value.ip_addr_block, null)
  ip4_mapped_ip6        = try(each.value.ip4_mapped_ip6, null)
  include_subdomains    = try(each.value.include_subdomains, null)
  vdomparam             = try(each.value.vdom, null)

  dynamic "entries" {
    for_each = { for entry in try(each.value.entries, []) : index(try(each.value.entries, []), entry) => entry }
    content {
      id                 = try(entries.value.id, null)
      url                = try(entries.value.url, null)
      type               = try(entries.value.type, null)
      action             = try(entries.value.action, null)
      antiphish_action   = try(entries.value.antiphish_action, null)
      status             = try(entries.value.status, null)
      exempt             = try(entries.value.exempt, null)
      web_proxy_profile  = try(entries.value.web_proxy_profile, null)
      referrer_host      = try(entries.value.referrer_host, null)
      dns_address_family = try(entries.value.dns_address_family, null)
      comment            = try(entries.value.comment, null)
    }
  }
  dynamic_sort_subtable = "natural"
}

resource "fortios_webfilter_profile" "profiles" {
  for_each = { for profile in local.profiles : profile.name => profile }

  depends_on = [fortios_webfilter_urlfilter.filters]

  name                          = each.value.name
  comment                       = try(each.value.comment, null)
  feature_set                   = try(each.value.feature_set, null)
  replacemsg_group              = try(each.value.replacemsg_group, null)
  inspection_mode               = try(each.value.inspection_mode, null)
  options                       = try(each.value.options, null)
  https_replacemsg              = try(each.value.https_replacemsg, null)
  web_flow_log_encoding         = try(each.value.web_flow_log_encoding, null)
  ovrd_perm                     = try(each.value.ovrd_perm, null)
  post_action                   = try(each.value.post_action, null)
  youtube_channel_status        = try(each.value.youtube_channel_status, null)
  wisp                          = try(each.value.wisp, null)
  wisp_algorithm                = try(each.value.wisp_algorithm, null)
  log_all_url                   = try(each.value.log_all_url, null)
  web_content_log               = try(each.value.web_content_log, null)
  web_filter_activex_log        = try(each.value.web_filter_activex_log, null)
  web_filter_command_block_log  = try(each.value.web_filter_command_block_log, null)
  web_filter_cookie_log         = try(each.value.web_filter_cookie_log, null)
  web_filter_applet_log         = try(each.value.web_filter_applet_log, null)
  web_filter_jscript_log        = try(each.value.web_filter_jscript_log, null)
  web_filter_js_log             = try(each.value.web_filter_js_log, null)
  web_filter_vbs_log            = try(each.value.web_filter_vbs_log, null)
  web_filter_unknown_log        = try(each.value.web_filter_unknown_log, null)
  web_filter_referer_log        = try(each.value.web_filter_referer_log, null)
  web_filter_cookie_removal_log = try(each.value.web_filter_cookie_removal_log, null)
  web_url_log                   = try(each.value.web_url_log, null)
  web_invalid_domain_log        = try(each.value.web_invalid_domain_log, null)
  web_ftgd_err_log              = try(each.value.web_ftgd_err_log, null)
  web_ftgd_quota_usage          = try(each.value.web_ftgd_quota_usage, null)
  extended_log                  = try(each.value.extended_log, null)
  web_extended_all_action_log   = try(each.value.web_extended_all_action_log, null)
  web_antiphishing_log          = try(each.value.web_antiphishing_log, null)
  vdomparam                     = try(each.value.vdom, null)

  dynamic "file_filter" {
    for_each = { for file_filter in try(each.value.file_filter, []) : index(try(each.value.file_filter, []), file_filter) => file_filter }
    content {
      status                = try(file_filter.value.status, null)
      log                   = try(file_filter.value.log, null)
      scan_archive_contents = try(file_filter.value.scan_archive_contents, null)
      dynamic "entries" {
        for_each = { for entry in try(file_filter.value.entries, []) : index(try(file_filter.value.entries, []), entry) => entry }
        content {
          filter             = try(entries.value.filter, null)
          comment            = try(entries.value.comment, null)
          protocol           = try(entries.value.protocol, null)
          action             = try(entries.value.action, null)
          direction          = try(entries.value.direction, null)
          password_protected = try(entries.value.password_protected, null)
          dynamic "file_type" {
            for_each = { for type in try(entries.value.file_types, []) : type => type }
            content {
              name = file_type.value
            }
          }
        }
      }
    }
  }

  dynamic "override" {
    for_each = { for override in try(each.value.override, []) : index(try(each.value.override, []), override) => override }
    content {
      ovrd_cookie       = try(override.value.ovrd_cookie, null)
      ovrd_scope        = try(override.value.ovrd_scope, null)
      profile_type      = try(override.value.profile_type, null)
      ovrd_dur_mode     = try(override.value.ovrd_dur_mode, null)
      ovrd_dur          = try(override.value.ovrd_dur, null)
      profile_attribute = try(override.value.profile_attribute, null)

      dynamic "ovrd_user_group" {
        for_each = { for group in try(override.value.ovrd_user_group, []) : group => group }
        content {
          name = ovrd_user_group.value
        }
      }

      dynamic "profile" {
        for_each = { for profile in try(override.value.profile, []) : profile => profile }
        content {
          name = profile.value
        }
      }
    }
  }

  web {
    bword_threshold     = try(each.value.web.bword_threshold, null)
    bword_table         = try(each.value.web.bword_table, null)
    urlfilter_table     = try(each.value.web.urlfilter_table, null)
    content_header_list = try(each.value.web.content_header_list, null)
    blocklist           = try(each.value.web.blocklist, null)
    allowlist           = try(each.value.web.allowlist, null)
    blacklist           = try(each.value.web.blacklist, null)
    whitelist           = try(each.value.web.whitelist, null)
    safe_search         = try(each.value.web.safe_search, null)
    youtube_restrict    = try(each.value.web.youtube_restrict, null)
    vimeo_restrict      = try(each.value.web.vimeo_restrict, null)
    log_search          = try(each.value.web.log_search, null)

    dynamic "keyword_match" {
      for_each = { for keyword in try(each.value.web.keyword_match, []) : keyword => keyword }
      content {
        pattern = keyword_match.value
      }
    }
  }

  dynamic "youtube_channel_filter" {
    for_each = { for youtube_channel_filter in try(each.value.youtube_channel_filter, []) : index(try(each.value.youtube_channel_filter, []), youtube_channel_filter) => youtube_channel_filter }
    content {
      id         = try(youtube_channel_filter.value.id, null)
      channel_id = try(youtube_channel_filter.value.channel_id, null)
      comment    = try(youtube_channel_filter.value.comment, null)
    }
  }

  ftgd_wf {
    options      = try(each.value.ftgd_wf.options, null)
    exempt_quota = try(each.value.ftgd_wf.exempt_quota, null)
    ovrd         = try(each.value.ftgd_wf.ovrd, null)

    dynamic "filters" {
      for_each = { for filter in try(each.value.ftgd_wf.filters, []) : index(try(each.value.ftgd_wf.filters, []), filter) => filter }
      content {
        id            = try(filters.value.id, null)
        category      = try(filters.value.category, null)
        action        = try(filters.value.action, null)
        warn_duration = try(filters.value.warn_duration, null)

        dynamic "auth_usr_grp" {
          for_each = { for auth_usr_grp in try(filters.value.auth_usr_grp, []) : auth_usr_grp => auth_usr_grp }
          content {
            name = auth_usr_grp.value
          }
        }

        log                   = try(filters.value.log, null)
        override_replacemsg   = try(filters.value.override_replacemsg, null)
        warning_prompt        = try(filters.value.warning_prompt, null)
        warning_duration_type = try(filters.value.warning_duration_type, null)
      }
    }

    dynamic "risk" {
      for_each = { for risk in try(each.value.ftgd_wf.risk, []) : index(try(each.value.ftgd_wf.risk, []), risk) => risk }
      content {
        id         = try(risk.value.id, null)
        risk_level = try(risk.value.risk_level, null)
        action     = try(risk.value.action, null)
        log        = try(risk.value.log, null)
      }
    }

    dynamic "quota" {
      for_each = { for quota in try(each.value.ftgd_wf.quota, []) : index(try(each.value.ftgd_wf.quota, []), quota) => quota }
      content {
        id                  = try(quota.value.id, null)
        category            = try(quota.value.category, null)
        type                = try(quota.value.type, null)
        unit                = try(quota.value.unit, null)
        value               = try(quota.value.value, null)
        duration            = try(quota.value.duration, null)
        override_replacemsg = try(quota.value.override_replacemsg, null)
      }
    }

    max_quota_timeout    = try(each.value.ftgd_wf.max_quota_timeout, null)
    rate_image_urls      = try(each.value.ftgd_wf.rate_image_urls, null)
    rate_javascript_urls = try(each.value.ftgd_wf.rate_javascript_urls, null)
    rate_css_urls        = try(each.value.ftgd_wf.rate_css_urls, null)
    rate_crl_urls        = try(each.value.ftgd_wf.rate_crl_urls, null)
  }

  dynamic "antiphish" {
    for_each = { for antiphish in try(each.value.antiphish, []) : index(try(each.value.antiphish, []), antiphish) => antiphish }
    content {
      status              = try(antiphish.value.status, null)
      domain_controller   = try(antiphish.value.domain_controller, null)
      ldap                = try(antiphish.value.ldap, null)
      default_action      = try(antiphish.value.default_action, null)
      check_uri           = try(antiphish.value.check_uri, null)
      check_basic_auth    = try(antiphish.value.check_basic_auth, null)
      check_username_only = try(antiphish.value.check_username_only, null)
      max_body_len        = try(antiphish.value.max_body_len, null)

      dynamic "inspection_entries" {
        for_each = { for inspection_entry in try(antiphish.value.inspection_entries, []) : index(try(antiphish.value.inspection_entries, []), inspection_entry) => inspection_entry }
        content {
          name                = try(inspection_entries.value.name, null)
          fortiguard_category = try(inspection_entries.value.fortiguard_category, null)
          action              = try(inspection_entries.value.action, null)
        }
      }

      dynamic "custom_patterns" {
        for_each = { for custom_pattern in try(antiphish.value.custom_patterns, []) : index(try(antiphish.value.custom_patterns, []), custom_pattern) => custom_pattern }
        content {
          pattern  = try(custom_patterns.value.pattern, null)
          category = try(custom_patterns.value.category, null)
          type     = try(custom_patterns.value.type, null)
        }
      }
      authentication = try(antiphish.value.authentication, null)
    }
  }

  dynamic "wisp_servers" {
    for_each = { for wisp_server in try(each.value.wisp_servers, []) : wisp_server => wisp_server }
    content {
      name = wisp_servers.value
    }
  }
}
