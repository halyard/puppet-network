# @summary Configure basic networking
#
# @param resolvers list of resolvers for DNS lookups
# @param domains list of domains for search path
# @param dnsovertls enable DNS over TLS
# @param bridges sets interfaces which should be bridged
# @param ignore sets interface regex patterns to not create network configurations for
class network (
  Array[String] $resolvers = ['8.8.8.8#dns.google', '8.8.4.4#dns.google'],
  Array[String] $domains = [],
  Boolean $dnsovertls = true,
  Hash[String, Array[String]] $bridges = {},
  Array[String] $ignore = ['^lo$', '^docker0$', '^(tap|veth)', '^wg\d+'],
) {
  case $facts['os']['family'] {
    'Archlinux': { include network::systemd }
    'Arch': { include network::systemd }
    default: { fail("Module does not support ${facts['os']['family']}") }
  }
}
