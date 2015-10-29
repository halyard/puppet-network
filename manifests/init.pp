# == Class: network
#
# Configure network settings
#
class network (
) {
  sysctl { 'net.inet6.ip6.use_tempaddr':
    value => '0',
  }
}
