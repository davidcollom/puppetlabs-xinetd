# Definition: xinetd::service
#
# sets up a xinetd service
# all parameters match up with xinetd.conf(5) man page
#
# Parameters:
#   $ensure         - optional - defaults to 'present'
#   $log_on_success - optional - may contain any combination of
#                       'PID', 'HOST', 'USERID', 'EXIT', 'DURATION', 'TRAFFIC'
#   $log_on_failure - optional - may contain any combination of
#                       'HOST', 'USERID', 'ATTEMPT'
#   $service_type   - optional - type setting in xinetd
#                       may contain any combinarion of 'RPC', 'INTERNAL',
#                       'TCPMUX/TCPMUXPLUS', 'UNLISTED'
#   $cps            - optional
#   $flags          - optional
#   $per_source     - optional
#   $port           - required - determines the service port
#   $server         - required - determines the program to execute for this service
#   $server_args    - optional
#   $disable        - optional - defaults to "no"
#   $socket_type    - optional - defaults to "stream"
#   $protocol       - optional - defaults to "tcp"
#   $user           - optional - defaults to "root"
#   $group          - optional - defaults to "root"
#   $groups         - optional - defaults to "yes"
#   $instances      - optional - defaults to "UNLIMITED"
#   $only_from      - optional
#   $wait           - optional - based on $protocol will default to "yes" for udp and "no" for tcp
#   $xtype          - optional - determines the "type" of service, see xinetd.conf(5)
#   $no_access      - optional
#   $access_times   - optional
#   $log_type       - optional
#   $bind           - optional
#
# Actions:
#   setups up a xinetd service by creating a file in /etc/xinetd.d/
#
# Requires:
#   $server must be set
#   $port must be set
#
# Sample Usage:
#   # setup tftp service
#   xinetd::service { 'tftp':
#     port        => '69',
#     server      => '/usr/sbin/in.tftpd',
#     server_args => '-s $base',
#     socket_type => 'dgram',
#     protocol    => 'udp',
#     cps         => '100 2',
#     flags       => 'IPv4',
#     per_source  => '11',
#   } # xinetd::service
#
define xinetd::service (
  $port,
  $server,
  $ensure         = present,
  $log_on_success = undef,
  $log_on_failure = undef,
  $service_type   = undef,
  $service_name   = $title,
  $cps            = undef,
  $disable        = 'no',
  $flags          = undef,
  $group          = 'root',
  $groups         = 'yes',
  $instances      = 'UNLIMITED',
  $log_on_failure = undef,
  $per_source     = undef,
  $protocol       = 'tcp',
  $server_args    = undef,
  $socket_type    = 'stream',
  $user           = 'root',
  $only_from      = undef,
  $wait           = undef,
  $xtype          = undef,
  $no_access      = undef,
  $access_times   = undef,
  $log_type       = undef,
  $bind           = undef,
) {

  include xinetd

  if $wait {
    $_wait = $wait
  } else {
    validate_re($protocol, '(tcp|udp)')
    $_wait = $protocol ? {
      tcp => 'no',
      udp => 'yes'
    }
  }

  # Template uses:
  # - $port
  # - $disable
  # - $socket_type
  # - $protocol
  # - $_wait
  # - $user
  # - $group
  # - $groups
  # - $server
  # - $bind
  # - $service_type
  # - $server_args
  # - $only_from
  # - $per_source
  # - $log_on_success
  # - $log_on_failure
  # - $cps
  # - $flags
  # - $xtype
  # - $no_access
  # - $access_types
  # - $log_type
  file { "${xinetd::confdir}/${title}":
    ensure  => $ensure,
    owner   => 'root',
    mode    => '0644',
    content => template('xinetd/service.erb'),
    notify  => Service[$xinetd::service_name],
    require => File[$xinetd::confdir],
  }

}
