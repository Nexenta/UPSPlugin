#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#

#
# Copyright (C) 2005-2011 Nexenta Systems, Inc.
# All rights reserved.
#

#############################################################################
package NZA::Ups;
#############################################################################

use NZA::Common;
use NZA::Exception;
use NZA::Config;
use NZA::Utils;
use strict;
no warnings 'redefine';
use base qw(NZA::Object);

require 'nms-ups/Consts.pm';

sub new {
	my ($class, $name, $type) = @_;

	my $self = $class->SUPER::new($name);
        $self->{type} = $type;
	$self->{rw_var_cache} = undef;
	$self->{inst_cmd_cache} = undef;
	$self->{outlet_count} = undef;
	bless $self, $class;

	return $self;
}

#return outlet count of UPS or 0 if outlet control is absent
sub outlet_count {
	my ($self) = @_;

	if (!(defined($self->{outlet_count}))) {
		my $vars = $self->get_status();
		$self->{outlet_count} = 0;
		foreach my $var (keys %$vars) {
			if ($var =~ /outlet\.\d+\.switchable/) {
				$self->{outlet_count}++;
			}
		}
	}

	return $self->{outlet_count};
}

sub _check_outlet_num {
	my ($self, $num) = @_;

	my $oc = $self->outlet_count();
	die new NZA::Exception($Exception::WrongArguments,
		"Number of outlet format error or out of bounds") if (!defined($num) || $num < 0 || $num >= $oc);
}

sub outlet_status {
	my ($self, $num) = @_;

	$self->_check_outlet_num($num);

	my %outlet_status = ();
	my $vars = $self->get_status();
	foreach my $var (keys %$vars) {
		$outlet_status{$NZA::UPS::OUTLET_ID} = $vars->{$var} if ($var =~ /outlet\.$num\.id/);
		$outlet_status{$NZA::UPS::OUTLET_DESC} = $vars->{$var} if ($var =~ /outlet\.$num\.desc/);
		$outlet_status{$NZA::UPS::OUTLET_SWITCH} = $vars->{$var} if ($var =~ /outlet\.$num\.switch/);
		$outlet_status{$NZA::UPS::OUTLET_STATUS} = $vars->{$var} if ($var =~ /outlet\.$num\.status/);
		$outlet_status{$NZA::UPS::OUTLET_SWITCHABLE} = $vars->{$var} if ($var =~ /outlet\.$num\.switchable/);
		$outlet_status{$NZA::UPS::OUTLET_AUTOSWITCH_CHARGE_LOW} = $vars->{$var}
			if ($var =~ /outlet\.$num\.autoswitch\.charge\.low/);
		$outlet_status{$NZA::UPS::OUTLET_DELAY_SHUTDOWN} = $vars->{$var} if ($var =~ /outlet\.$num\.delay\.shutdown/);
		$outlet_status{$NZA::UPS::OUTLET_DELAY_START} = $vars->{$var} if ($var =~ /outlet\.$num\.delay.start/);
	}

	return \%outlet_status;
}

# $sw must be on or off
sub outlet_switch {
	my ($self, $num, $sw) = @_;

	my $ostatus = $self->outlet_status($num);
	die new NZA::Exception($Exception::IOError, "Outlet control is absent for UPS '$self->{name}'") if ($self->outlet_count() <= 0);
	die new NZA::Exception($Exception::IOError, "Outlet $num is not switchable for UPS '$self->{name}'")
		if (!defined($ostatus->{$NZA::UPS::OUTLET_SWITCHABLE}) ||
			(!($ostatus->{$NZA::UPS::OUTLET_SWITCHABLE} =~ /$NZA::UPS::ValueYes/)));
	die new NZA::Exception($Exception::WrongArguments,
		"Can't identify value '$sw'. Must be '$NZA::UPS::ValueOn' or '$NZA::UPS::ValueOff'")
		if (!defined($sw) || !($sw eq $NZA::UPS::ValueOn || $sw eq $NZA::UPS::ValueOff));

	$self->set_var_value("outlet.$num.switch", $sw);
}

sub set_params {
	my ($self, $params) = @_;

	die new NZA::Exception($Exception::WrongArguments, "UPS: '$self->{name}'. Parameters must be specified.")
		if (!defined($params) ||  ref($params) ne 'HASH');
	die new NZA::Exception($Exception::WrongArguments, "UPS: '$self->{name}'. 'driver' is read only parameter")
		if (exists $params->{driver});
	die new NZA::Exception($Exception::WrongArguments, "UPS: '$self->{name}'. 'port' is read only parameter for USB UPS")
		if ($self->{type} eq $NZA::UPS::USBType && exists $params->{port});
	die new NZA::Exception($Exception::WrongArguments, "UPS: '$self->{name}'. 'port' can't removed. This is mandatory parameter.")
		if (exists $params->{port} && !defined($params->{port}));

	my $cfg = $self->parent()->{configuration};

	my $port = $params->{port};
	if (defined($port)) {
		die new NZA::Exception($Exception::IOError, "UPS: '$self->{name}'. Port '$port' not found") if (!(-e $port));
		my $sections = $cfg->list_sections();
		foreach my $sec (@$sections) {
			my $tmp = $cfg->get_option($sec, $NZA::UPS::PropPort);
			if ($sec ne $self->{name} && $tmp eq $port){
				die new NZA::Exception($Exception::UPS::PortAlreadySpecified,
					"UPS: '$self->{name}'. Port '$port' already specified for other UPS");
			}
		}
	}

	my $sn = $self->{name};
	foreach my $key (keys %$params) {
		my $v = $params->{$key};
		if ($v ne '') {
			if ($cfg->option_exists($sn, $key)) {
				$cfg->set_option($sn, $key, $v);
			} else {
				$cfg->add_option($sn, $key, $v);
			}
		} else {
			$cfg->remove_option($sn, $key);
		}
	}

	$cfg->commit_on_change("Changing USB configuration");
}

sub get_params {
	my ($self) = @_;

	return $self->parent()->{configuration}->list_options($self->{name});
}

sub send_instant_command {
	my ($self, $command) = @_;

	die new NZA::Exception($Exception::WrongArguments, "UPS: '$self->{name}'. Command must be specified") if (!(defined($command)));

	my ($ups_username, $ups_password) = $self->parent()->get_auth_info();

	my $awcmds = $self->get_instant_commands();
	foreach my $cmd (keys %$awcmds) {
		if ($cmd eq $command) {
			my @lines = ();
			if (nza_exec("upscmd -u $ups_username -p $ups_password $self->{name}\@localhost $command", \@lines) != 0) {
				die new NZA::Exception($Exception::IOError, "UPS: '$self->{name}'. Can't execute command $command") if (scalar @lines <= 0);
				die new NZA::Exception($Exception::IOError, "UPS: '$self->{name}':\n" . $lines[0]);
			}
			return;
		}
	}

	die new NZA::Exception($Exception::WrongArguments, "Command '$command' not supported for UPS '$self->{name}'");
}

sub get_instant_commands {
	my ($self) = @_;

	my %cmds = ();
	my @lines = ();
	if (defined($self->{inst_cmd_cache})) {
		return $self->{inst_cmd_cache};
	} else {
		if (nza_exec("upscmd -l $self->{name}\@localhost", \@lines) != 0) {
			die new NZA::Exception($Exception::IOError, "UPS: '$self->{name}'. Can't get list of instant commands") if (scalar @lines <= 0);
			die new NZA::Exception($Exception::IOError, "UPS: '$self->{name}':\n" . $lines[0]);
		}

		if (scalar @lines > 0) {
			my $line = shift @lines;
			$line = shift @lines;
			while (defined($line = shift @lines)) {
				my @nad = split /\s-\s/, $line;
				$cmds{$nad[0]} = $nad[1];
			}
		}

		$self->{inst_cmd_cache} = \%cmds;
	}

	return \%cmds;
}

sub set_var_value {
	my ($self, $varname, $varvalue) = @_;

	die new NZA::Exception($Exception::WrongArguments, "UPS: '$self->{name}'. Name of variable must be defined")
		if (!(defined($varname)));
	$varvalue = ' ' if (!(defined($varvalue)));

	my ($ups_username, $ups_password) = $self->parent()->get_auth_info();

	my @lines = ();
	if (nza_exec("upsrw -s $varname=$varvalue -u $ups_username -p $ups_password $self->{name}\@localhost", \@lines) != 0){
		die new NZA::Exception($Exception::IOError, "UPS: '$self->{name}'. Can't set variable $varname") if (scalar @lines <= 0);
		die new NZA::Exception($Exception::IOError, "UPS: '$self->{name}':\n" . $lines[0]);
	}
}

sub get_rw_vars {
	my ($self) = @_;

	my $rw_vars;
	my @lines = ();
	if (defined($self->{rw_var_cache})) {
		$rw_vars = $self->{rw_var_cache};
	} else {
		my ($ups_username, $ups_password) = $self->parent()->get_auth_info();

		if (nza_exec("upsrw -u $ups_username -p $ups_password $self->{name}\@localhost", \@lines) != 0){
			die new NZA::Exception($Exception::IOError, "UPS: '$self->{name}'. Can't get list of rw variables") if (scalar @lines <= 0);
			die new NZA::Exception($Exception::IOError, "UPS: '$self->{name}':\n" . $lines[0]);
		}

		if (scalar @lines > 0) {
			my %vars = ();
			my $line;
			while (defined($line = shift @lines)) {
				if ($line =~ /\[(.*)\]/) {
					my ($vn, $vd, $vt, $vv) = ($1, shift @lines, undef, undef);
					$line = shift @lines;
					if ($line && $line =~ /Type:\s(.*)/) {
						$vt = $1;
						$line = shift @lines;
						if ($line && $line =~ /Value:\s(.*)/) {
							$vv = $1;
							$vars{$vn} = [$vd, $vt, $vv];
							$line = shift @lines;
						} elsif ($line && $line =~ /Option:\s(.*)/) {
							my @pv = ();

							while ($line && ($line =~ /Option:\s(.*)/)) {
								my $v = $1;
								if ($v && $v =~ /^(.*)\sSELECTED$/){
									$vv = $1;
									$vv =~ s/^\"//;
									$vv =~ s/\"$//;
									push(@pv, $vv);
								} else {
									$v =~ s/^\"//;
									$v =~ s/\"$//;
									push(@pv, $v);
								}
								$line = shift @lines;
							}

							$vars{$vn} = [$vd, $vt, join('|', @pv)];
						} else {
							last;
						}
					} else {
						last;
					}
				} else {
					last;
				}
			}
			$rw_vars = \%vars;
			$self->{rw_var_cache} = $rw_vars;
		}
	}

	return $rw_vars;
}



sub get_online_status {
	my ($self) = @_;

	return $self->get_var_value($NZA::UPS::VAR_UPS_STATUS);
}

sub get_var_value
{
	my ($self, $var_name) = @_;

	my @lines = ();
	if (nza_exec("upsc $self->{name}\@localhost $var_name", \@lines) != 0) {
		die new NZA::Exception($Exception::IOError, "UPS: '$self->{name}'. Can't get status information by upsc")
			if (scalar @lines <= 0);
		die new NZA::Exception($Exception::IOError, "UPS: '$self->{name}':\n" . $lines[0]);
	}

	if (scalar @lines > 0) {
		return $lines[0];
	}

	return 'UNKNOWN';
}

sub get_status {
	my ($self) = @_;

	my @lines = ();
	if (nza_exec("upsc $self->{name}\@localhost", \@lines) != 0) {
		die new NZA::Exception($Exception::IOError, "UPS: '$self->{name}'. Can't get status information by upsc")
			if (scalar @lines <= 0);
		die new NZA::Exception($Exception::IOError, "UPS: '$self->{name}':\n" . $lines[0]);
	}
	my %statuses = ();
	foreach my $line(@lines) {
		$line =~ /^([^:]+):\s(.*)/;
		my ($lname, $lvalue) = ($1, $2);
		chomp($lvalue);
		$statuses{$lname} = $lvalue;
	}
	return \%statuses;
}

#############################################################################
package NZA::UpsContainer;
#############################################################################

use NZA::Common;
use NZA::Utils;
use NZA::Container;
use NZA::Config;
use strict;
use base qw(NZA::Container);

require 'nms-ups/Consts.pm';

$NZA::UPS::PropStartUPSD = 'START_UPSD';

#constructor
sub new {
	my ($class, $ipc) = @_;

	my $self = $class->SUPER::new('UpsContainer', $ipc);
	bless $self, $class;

	nza_exec("touch $NZA::UPS_CONF_FILE") unless (-e $NZA::UPS_CONF_FILE);
	$self->{configuration} = new NZA::IniStyleConfig($NZA::UPS_CONF_FILE);
	my $sections = $self->{configuration}->list_sections();
	foreach my $sec (@$sections) {
		my $obj = new NZA::Ups($sec);
		$self->attach($obj, 1);
	}
	$self->{username} = undef;
	$self->{userpasswd} = undef;

	$self->_find_auth_info();

	return $self;
}

#sub _check_user_permissions {
#	my ($self) = @_;
#
#	my @lines = ();
#	if (nza_exec('groups nut') != 0) {
#		die new NZA::Exception($Exception::IOError, "Can't get groups for user nut");
#	}
#
#	if (scalar @lines > 0 && !($lines[0] =~ /uucp/)) {
#		????
#	}
#}

sub set_auth_info {
	my ($self, $ups_username, $ups_password) = @_;

	die new NZA::Exception($Exception::WrongArguments, 'User name must be specified')
		if (!(defined($ups_username)));
	die new NZA::Exception($Exception::WrongArguments, 'User password must be specified')
		if (!(defined($ups_password)));

	$self->{username} = $ups_username;
	$self->{userpasswd} = $ups_password;
}

sub get_auth_info {
	my ($self) = @_;

	if (!(defined($self->{username}))) {
		$self->_find_auth_info();
	}

	return ($self->{username}, $self->{userpasswd});
}

# for using  default auth information you must define follow section in /etc/nut/upsd.users
#
# [nzaups]
# password = <password>
# allowfrom = localhost
# actions = set fsd
# instcmds = all
sub _find_auth_info {
	my ($self) = @_;

	nza_exec("touch $NZA::UPSD_USERS_CONF_FILE") if (!(-e $NZA::UPSD_USERS_CONF_FILE));
	my $cl = new NZA::IniStyleConfig($NZA::UPSD_USERS_CONF_FILE);

	$self->_create_auth_info($cl) if (!($cl->section_exists($NZA::UPS::UpsUser)));

	my $passwd = $cl->get_option($NZA::UPS::UpsUser, $NZA::UPS::PropPassword);
	my $actions = $cl->get_option($NZA::UPS::UpsUser, $NZA::UPS::PropActions);
	my $allowfrom = $cl->get_option($NZA::UPS::UpsUser, $NZA::UPS::PropAllowfrom);
	my $instcmd = $cl->get_option($NZA::UPS::UpsUser, $NZA::UPS::PropInstcmd);
	die new NZA::Exception($Exception::PropertyNotFound,
		"User '$NZA::UPS::UpsUser' not found or define incorrectly in file $NZA::UPSD_USERS_CONF_FILE")
		if (!defined($passwd) || !defined($actions) || !defined($allowfrom) || !defined($instcmd));

	die new NZA::Exception($Exception::UPS::UPSWrongAuthInfo,
		"For user '$NZA::UPS::UpsUser' must be defined 'actions=set fsd' in $NZA::UPSD_USERS_CONF_FILE")
		if (!($actions =~ /\bset/i) || !($actions =~ /\bfsd/i));

	die new NZA::Exception($Exception::UPS::UPSWrongAuthInfo,
		"For user '$NZA::UPS::UpsUser' must be defined 'allowfrom=localhost' in $NZA::UPSD_USERS_CONF_FILE")
		if (!(hostname_is_local($allowfrom)));

	die new NZA::Exception($Exception::UPS::UPSWrongAuthInfo,
		"For user '$NZA::UPS::UpsUser' must be defined 'instcmd=all' in $NZA::UPSD_USERS_CONF_FILE")
		if (!($instcmd =~ /\ball/i));

	$self->{username} = $NZA::UPS::UpsUser;
	$self->{userpasswd} = $passwd;
}

sub _create_auth_info {
	my ($self, $cl) = @_;

	$cl->begin_changes();

	$cl->add_section($NZA::UPS::UpsUser);
	$cl->add_option($NZA::UPS::UpsUser, $NZA::UPS::PropActions, 'set fsd');
	$cl->add_option($NZA::UPS::UpsUser, $NZA::UPS::PropAllowfrom, 'localhost');
	$cl->add_option($NZA::UPS::UpsUser, $NZA::UPS::PropInstcmd, 'all');
	$cl->add_option($NZA::UPS::UpsUser, $NZA::UPS::PropPassword, $self->_generate_password(10));

	my $state = $self->get_service_state();
	unless ($state =~ /disabled/) {
#		TODO: print message
	}

	my $commit_msg = 'Basic UPS users parameter configuration';
	$cl->commit_changes($commit_msg);
}

sub _generate_password {
	my ($self, $length) = @_;

	my $possible = 'abcdefghijkmnpqrstuvwxyz23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
	my $password;
	while (length($password) < $length) {
		$password .= substr($possible, (int(rand(length($possible)))), 1);
	}
	return $password;
}

sub remove_ups {
	my ($self, $name) = @_;

	die new NZA::Exception($Exception::WrongArguments,
		'Name of UPS must be specified') if (!(defined($name)));
	die new NZA::Exception($Exception::DeviceNotFound,
		"UPS name $name not found") if (!$self->object_exists($name));

	if ($self->object_exists($name))
	{
		$self->{configuration}->remove_section($name);
		$self->{configuration}->commit_on_change("Removing UPS configuration");
        $self->get_object($name)->destroy();
	}
}

# Check port or serial number already configured
sub is_configured
{
	my ($self, $portorserial) = @_;

	foreach my $name($self->get_names()) {
		my $s = $self->{configuration}->get_option($name, $NZA::UPS::PropSerial);
		my $p = $self->{configuration}->get_option($name, $NZA::UPS::PropPort);
		if ($s && $s eq $portorserial) {
			return 1;
		} elsif ($p && $p eq $portorserial) {
			return 1;
		}
	}

	return 0;
}

# configure USB HID UPSes
# in params must be specified driver and (serial or $device_info)
sub configure_usb_hid_ups {
	my ($self, $name, $params, $device_info) = @_;

	die new NZA::Exception($Exception::WrongArguments,
		'Name of UPS must be specified') if (!(defined($name)));
	die new NZA::Exception($Exception::DuplicateObjectName,
		"UPS name $name already exists") if ($self->object_exists($name));
	die new NZA::Exception($Exception::WrongArguments,
		"Params must be a HASH type") if(!defined($params) || !(ref($params) eq 'HASH'));


	# check mandatory parameters
	die new NZA::Exception($Exception::PropertyNotFound,
		"Parameter 'driver' must be specified") if(!(defined($params->{driver})));
	my $driver = $params->{driver};
	die new NZA::Exception($Exception::UPS::DriverNotSupported,
		"Driver $driver not supported") if (!(exists $NZA::UPS::USB_UPSES{$driver}));
	die new NZA::Exception($Exception::PropertyNotFound,
		"Parameter 'serial' or device information must be specified")
		if(!(defined($params->{serial})) && !(defined($device_info) && ref($device_info) eq 'HASH'));

	# detect serialno
	my $tmp_serial = $device_info->{$NZA::USB::USBSerialNo}->{'value'};
	die new NZA::Exception($Exception::PropertyNotFound,
		'Serial number of USB device not found in specified device information') if (!(defined($tmp_serial)));
	$tmp_serial =~ s/\|//;
	my $serialno = undef;

	# detect vendorid
	my $mustVendorId = $driver eq $NZA::UPS::DRV_USBHID_UPS || $driver eq $NZA::UPS::DRV_MEGATEC_USB;
	my $vendorid;
	if ($mustVendorId) {
		$vendorid = $device_info->{$NZA::USB::USBVendorId}->{'value'};
		die new NZA::Exception($Exception::PropertyNotFound,
			'Vendor ID of USB device not found in specified device information') if (!(defined($vendorid)));
		$vendorid =~ s/\|//;
		$vendorid = substr($vendorid, -4);
	}

	# find specified USB device
	my $appl_obj = $NZA::server_obj->get_impl_object('appliance');
	my $configured = $appl_obj->list_conf_ugen_hid_devs();
	foreach my $dev (@$configured) {
		my $ts = $dev->{$NZA::USB::USBSerialNo}->{'value'};
		if (defined($ts)) {
			$ts =~ s/\|//;
			if ($ts eq $tmp_serial) {
				$serialno = $tmp_serial;
				last;
			}
		}

	}
	die new NZA::Exception($Exception::DeviceNotFound,
		"Configured Generic USB device with serial number $tmp_serial not found") if(!(defined($serialno)));

	# check already configured UPSes
	if ($self->is_configured($serialno)) {
		die new NZA::Exception($Exception::UPS::PortAlreadySpecified,
			"Device with serial number $serialno already specified");
	}

	# configure new UPS
	my $cfg = $self->{configuration};
	$cfg->add_section($name);
	foreach my $key (%$params) {
		my $v = $params->{$key};
		$cfg->add_option($name, $key, $v) if (defined($v));
	}
	if ($cfg->option_exists($name, $NZA::UPS::PropPort)) {
		$cfg->set_option($name, $NZA::UPS::PropPort, 'auto');
	} else {
		$cfg->add_option($name, $NZA::UPS::PropPort, 'auto');
	}
	if ($cfg->option_exists($name, $NZA::UPS::PropSerial)) {
		$cfg->set_option($name, $NZA::UPS::PropSerial, $serialno);
	} else {
		$cfg->add_option($name, $NZA::UPS::PropSerial, $serialno);
	}
	if ($mustVendorId) {
		if ($cfg->option_exists($name, $NZA::UPS::PropVendorId)) {
			$cfg->set_option($name, $NZA::UPS::PropVendorId, $vendorid);
		} else {
			$cfg->add_option($name, $NZA::UPS::PropVendorId, $vendorid);
		}
	}

	# set description if not found in $params
	if (!(defined($params->{desc}))) {
		my $desc = "($serialno)";
		my $name = $device_info->{$NZA::USB::USBProductName}->{'value'};
		if (defined($name)) {
			$name =~ s/\|//;
			$desc .= " $name";
		}
		if ($cfg->option_exists($name, $NZA::UPS::PropDesc)) {
			$cfg->set_option($name, $NZA::UPS::PropDesc, $desc);
		} else {
			$cfg->add_option($name, $NZA::UPS::PropDesc, $desc);
		}
	}

	# create child object
	my $obj = new NZA::Ups($name, $NZA::UPS::USBType);
	$self->attach($obj, 1);

	#commit changes in config
	$cfg->commit_on_change("Configuring new USB device");
}

# Configure serial UPS
# in params must be specified driver and port
sub configure_serial_ups {
	my ($self, $name, $params) = @_;

	die new NZA::Exception($Exception::WrongArguments,
		'Name of UPS must be specified') if (!(defined($name)));
	die new NZA::Exception($Exception::DuplicateObjectName,
		"UPS name $name already exists") if ($self->object_exists($name));
	die new NZA::Exception($Exception::WrongArguments,
		"Params must be a HASH type") if(!defined($params) || !(ref($params) eq 'HASH'));

	# check mandatry parameters
	foreach my $mp (keys %NZA::UPS::DRV::REQ_PARAMS) {
		die new NZA::Exception($Exception::PropertyNotFound,
			"Mandatory parameter $mp not specified") if (!(defined $params->{$mp}));
	}

	# check driver and port params
	my $driver = $params->{driver};
	die new NZA::Exception($Exception::UPS::DriverNotSupported,
		"Driver '$driver' not supported") if (!(exists $NZA::UPS::SERIAL_UPSES{$driver}));
	die new NZA::Exception($Exception::PropertyNotFound,
		"Property 'port' not found in params") if(!(defined($params->{port})));

	my $cfg = $self->{configuration};

	# check port exists
	my $port = $params->{port};
	die new NZA::Exception($Exception::IOError,
		"Port '$port' not found") unless (-e $port);
	if ($self->is_configured($port)) {
		die new NZA::Exception($Exception::UPS::PortAlreadySpecified,
			"Port '$port' already specified");
	}

	# configure new UPS
	$cfg->add_section($name);
	foreach my $key (%$params) {
		my $v = $params->{$key};
		$cfg->add_option($name, $key, $v) if (defined($v));
	}

	# create child object
	my $obj = new NZA::Ups($name, $NZA::UPS::SerialType);
	$self->attach($obj, 1);

	#commit changes in config
	$cfg->commit_on_change("Configuring new SERIAL device");
}

sub get_service_state {
	my ($self) = @_;

	my @lines = ();
	if (nza_exec("svcs -H nut", \@lines) != 0) {
		die new NZA::Exception($Exception::StateNotFound, 'NUT service not found: plugin is not properly installed.');
	}

	my ($state) = $lines[0] =~ /^\s*(\S+)/;
	return $state;
}

sub enable_service {
	my ($self) = @_;

#	my $names = $self->get_names();
#	die new NZA::Exception($Exception::DeviceNotFound, "Can't enable NUT service: at least one UPS device must be configured")
#		if (scalar @$names == 0);

	my @lines = ();
	my $state = $self->get_service_state();
	if ($state eq $NZA::SMF_STATE_MAINTENANCE) {
		if (nza_exec("svcadm clear nut", \@lines) != 0) {
			die new NZA::Exception($Exception::SystemCallError, \@lines);
		}
		return;
	}

	if (nza_exec("svcadm enable nut", \@lines) != 0){
		die new NZA::Exception($Exception::OperationFailed, "Can't enable NUT service") if (scalar @lines <= 0);
		die new NZA::Exception($Exception::SystemCallError, \@lines);
	}
}

sub disable_service {
	my ($self) = @_;

	my $state = $self->get_service_state();
	return if ($state =~ /disabled/);

	my @lines = ();
	if (nza_exec("svcadm disable nut", \@lines) != 0){
		die new NZA::Exception($Exception::OperationFailed, "Can't disable NUT service") if (scalar @lines <= 0);
		die new NZA::Exception($Exception::SystemCallError, \@lines);
	}
}

#sub refresh {
#	my ($self) = @_;
#
#	$self->disable_service();
#	for (my $i = 0; $i < $NZA::UPS::StateChangedTimeout && (!($self->get_service_state() =~ /disabled/)); $i++) {
#		sleep ($i < 10 ? 1 : 2);
#		$i++ if ($i >= 10);
#	}
#
#	if ($self->get_service_state() =~ /disabled/) {
#		$self->enable_service();
#	} else {
#		die new NZA::Exception($Exception::OperationFailed, 'Disable state not reached for NUT service');
#	}
#	for (my $i = 0; $i < $NZA::UPS::StateChangedTimeout && (!($self->get_service_state() =~ /online/)); $i++) {
#		sleep ($i < 10 ? 1 : 2);
#		$i++ if ($i >= 10);
#	}
#	die new NZA::Exception($Exception::OperationFailed, 'Online state not reached for NUT service')
#		if (!($self->get_service_state() =~ /online/));
#}

# Return configured UPSes names
sub get_upses {
	my ($self) = @_;

	return $self->get_names();
}

# Return available driver names and descriptions for serial UPSes
sub get_serial_ups_drivers {
	my ($self) = @_;

	return \%NZA::UPS::SERIAL_UPSES;
}

# Return available driver names and descriptions for USB UPSes
sub get_usb_ups_drivers {
	my ($self) = @_;
	return \%NZA::UPS::USB_UPSES;
}



#############################################################################
package NZA::UpsIPC;
#############################################################################

use strict;
use base qw(NZA::ContainerIPC);
use Net::DBus::Exporter qw(com.nexenta.nms.Ups);

my %props = (
	upstype	=> { member => 'type', access => $NZA::API_DELEGATE_CHILD },
);

my %methods = (
	get_usb_ups_drivers	=> { proto => "[], [['dict', 'string', ['dict', 'string', 'string']]]",
				     access => $NZA::API_DELEGATE_IMPL },
	get_serial_ups_drivers  => { proto => "[], [['dict', 'string', ['dict', 'string', 'string']]]",
				     access => $NZA::API_DELEGATE_IMPL },
	get_upses		=> { proto => "[], [['array', 'string']]",
				     access => $NZA::API_DELEGATE_IMPL },
#	refresh			=> { proto => "[], []",
#				     access => $NZA::API_WRITE.$NZA::API_DELEGATE_IMPL },
	disable_service		=> { proto => "[], []",
				     access => $NZA::API_WRITE.$NZA::API_DELEGATE_IMPL },
	enable_service		=> { proto => "[], []",
				     access => $NZA::API_WRITE.$NZA::API_DELEGATE_IMPL },
	get_service_state	=> { proto => "[], ['string']",
				     access => $NZA::API_DELEGATE_IMPL },
	configure_serial_ups	=> { proto => "['string', ['dict', 'string', 'string']], []",
				     access => $NZA::API_WRITE.$NZA::API_DELEGATE_IMPL },
	configure_usb_hid_ups	=> { proto => "['string', ['dict', 'string', 'string'], ['dict', 'string', ['dict', 'string', 'string']]], []",
				     access => $NZA::API_WRITE.$NZA::API_DELEGATE_IMPL },
	remove_ups		=> { proto => "['string'], []",
				     access => $NZA::API_WRITE.$NZA::API_DELEGATE_IMPL },
	is_configured		=> { proto => "['string'], ['bool']",
				     access => $NZA::API_WRITE.$NZA::API_DELEGATE_IMPL },


	get_status		=> { proto => "['string'], [['dict', 'string', 'string']]",
				     access => $NZA::API_DELEGATE_CHILD },
	get_online_status	=> { proto => "['string'], ['string']",
				     access => $NZA::API_DELEGATE_CHILD },
	get_rw_vars		=> { proto => "['string'], [['dict', 'string', ['array', 'string']]]",
				     access => $NZA::API_DELEGATE_CHILD },
	get_var_value		=> { proto => "['string', 'string'], ['string']",
				     access => $NZA::API_DELEGATE_CHILD },
	set_var_value		=> { proto => "['string', 'string', 'string'], []",
				     access => $NZA::API_WRITE.$NZA::API_DELEGATE_CHILD },
	get_instant_commands	=> { proto => "['string'], [['dict', 'string', 'string']]",
				     access => $NZA::API_DELEGATE_CHILD },
	send_instant_command	=> { proto => "['string', 'string'], []",
				     access => $NZA::API_WRITE.$NZA::API_DELEGATE_CHILD },
	get_params		=> { proto => "['string'], [['dict', 'string', 'string']]",
				     access => $NZA::API_DELEGATE_CHILD },
	set_params		=> { proto => "['string', ['dict', 'string', 'string']], []",
				     access => $NZA::API_WRITE.$NZA::API_DELEGATE_CHILD },
	outlet_switch		=> { proto => "['string', 'int32', 'string'], []",
				     access => $NZA::API_WRITE.$NZA::API_DELEGATE_CHILD },
	outlet_status		=> { proto => "['string', 'int32'], [['dict', 'string', 'string']]",
				     access => $NZA::API_DELEGATE_CHILD },
	outlet_count		=> { proto => "['string'], ['int32']",
				     access => $NZA::API_DELEGATE_CHILD },
);

sub new {
	my ($class, $parent) = @_;

	my $container = new NZA::UpsContainer($parent);
	my $self = $class->SUPER::new('Ups', $parent, $container, \%props, \%methods);

	bless $self, $class;

	eval $self->_gen_api();

	return $self;
}

1;
