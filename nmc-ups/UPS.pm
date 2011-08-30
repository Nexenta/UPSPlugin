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

package nmc_ups;

use NZA::Common;
use NMC::Const;
use NMC::Util;
use NMC::Term::Clui;
use strict;
use warnings;


require 'nms-ups/Consts.pm';


##############################  variables  ####################################

my $verb = 'ups';

my %setup_ups_words =
(
	_help => ["Configure and control UPSes"],

	add => {
		_help => ["add new UPS configuration"],
		_usage => \&setup_ups_usage,

		_unknown => {
			_recompute => \&setup_drivers_recompute,
			_usage => \&setup_ups_usage,

			_unknown => {
				_recompute => \&setup_ports_or_serials_recompute,
				_enter => \&setup_ups,
				_usage => \&setup_ups_usage,
			},
		},
	},

	service => {
		_help => ["enable or disable NUT service"],
		_usage => \&setup_service_manage_usage,

		enable => {
			_help => ["enable NUT service"],
			_enter => \&setup_service_manage,
			_usage => \&setup_service_manage_usage,
		},

		disable => {
			_help => ["disable NUT service"],
			_enter => \&setup_service_manage,
			_usage => \&setup_service_manage_usage,
		},
	},

	_unknown => {
		_recompute => \&recompute_upses,
		_usage => \&setup_ups_genusage,

		remove => {
			_help => ["remove this UPS configuration"],

			_enter => \&setup_cfg_remove,
			_usage => \&setup_cfg_remove_usage,
		},

		'modify' => {
			_help => ["add, modify or remove property from UPS configuration"],
			_usage => \&setup_modify_usage,

			_unknown => {
				_recompute => \&setup_properties_recompute,
				_usage => \&setup_modify_usage,

				set => {
					_help => ["add or modify property for UPS configuration"],

					_enter => \&setup_property_set,
					_usage => \&setup_modify_set_usage,
				},

				remove => {
					_help => ["remove property from UPS configuration"],

					_enter => \&setup_property_set,
					_usage => \&setup_modify_remove_usage,
				},
			},
		},

		'set-var' => {
			_help => ["set value for r/w UPS variable"],

			_unknown => {
				_recompute => \&setup_setvar_recompute,
				_enter => \&setup_setvar,
				_usage => \&setup_setvar_usage,
			},
		},

		'send-command' => {
			_help => ["Send instant command to UPS device for execution"],

			_unknown => {
				_recompute => \&setup_sendcmd_recompute,
				_enter => \&setup_sendcmd,
				_usage => \&setup_sendcmd_usage,
			},
		},

		outlet => {
			_help => ["Enable or disable separate outlet"],

			_unknown => {
				_help => ["Select outlet number"],
				_recompute => \&setup_outlet_recompute,

				enable => {
					_help => ["Enable this outlet"],
					_enter => \&enable_outlet,
					_usage => \&setup_outlet_usage,
				},

				disable => {
					_help => ["Disable this outlet"],
					_enter => \&enable_outlet,
					_usage => \&setup_outlet_usage,
				},
			},
		},
	},

);

my %show_ups_words =
(
	_help => ["Show available UPS devices, their status, properties,",
	          "supported management operations, and power outlets"],
	_usage => \&show_usage,

	service => {
		_help => ["Show Network UPS Tools (NUT) service state"],
		_enter => \&show_service_state,
		_usage => \&show_service_state_usage,
	},

	_unknown => {
		_help => ["UPS device '#lastword#': status, properties,",
			  "supported management operations, and power outlets"],

		_recompute => \&recompute_upses,
		_usage => \&show_ups_usage,

		'short-status' => {
			_help => ["UPS device status: brief summary information"],
			_enter => \&show_ups_unk_short_status,
			_usage => \&show_ups_unk_short_status_usage,
		},

		'full-status' => {
			_help => ["Detailed UPS device status"],
			_enter => \&show_ups_unk_full_status,
			_usage => \&show_ups_unk_full_status_usage,
		},

		commands => {
			_help => ["Supported instant commands"],
			_enter => \&show_ups_unk_commands,
			_usage => \&show_ups_unk_commands_usage,
		},

		outlets => {
			_help => ["Available outlets and their status information"],
			_enter => \&show_ups_unk_outlets,
			_usage => \&show_ups_unk_outlets_usage,
		},

		properties => {
			_help => ["Show UPS device properties and their current values"],
			_enter => \&show_ups_properties,
			_usage => \&show_ups_properties_usage,
		},
	},
);

############################## Plugin Hooks ####################################

sub construct {
	my $all_builtin_word_trees = shift;

	my $setup_words = $all_builtin_word_trees->{setup};
	$setup_words->{$verb} = \%setup_ups_words;
	my $show_words = $all_builtin_word_trees->{show};
	$show_words->{$verb} = \%show_ups_words;

	$NMC::RESERVED{$verb} = 1;
}

############################## Setup Command ####################################

sub _get_free_usb_devices
{
	my @freeserials = ();
	my $busyserials = _get_busy_serial_no();
	my $usbdevs;
	eval {
		$usbdevs = &NZA::appliance->list_conf_ugen_hid_devs();
	}; if ($@) {
		return undef;
	}
	for my $dev (@$usbdevs) {
		my $dev_serno = $dev->{$NZA::USB::USBSerialNo}->{value};
		$dev_serno =~ s/\|//;
		push(@freeserials, $dev_serno) unless (exists($busyserials->{$dev_serno}));
	}
	eval {
		$usbdevs = &NZA::appliance->list_unconf_hid_devs();
	}; if($@) {
		return \@freeserials;
	}
	for my $dev (@$usbdevs) {
		my $dev_serno = $dev->{$NZA::USB::USBSerialNo}->{value};
		$dev_serno =~ s/\|//;
		push(@freeserials, $dev_serno);
	}

	return \@freeserials;
}

sub _get_free_serial_ports
{
	my @files = </dev/tty0*>;
	my $busy = _get_busy_serial_ports();
	my @free = ();

	for my $port (@files) {
		push(@free, $port) unless (-d $port || exists($busy->{$port}));
	}

	return \@free;
}

sub _get_busy_serial_no
{
	my %busy_serials = ();
	my $upses;
	eval {
		$upses = &NZA::plugin('nms-ups')->get_upses();
	}; if ($@) {
		return \%busy_serials;
	}
	for my $ups (@$upses) {
		my $upstype;
		eval {
			$upstype = &NZA::plugin('nms-ups')->get_child_prop($ups, 'upstype');
		}; next if ($@);
		if ($upstype eq $NZA::UPS::USBType) {
			my $params;
			eval {
				$params = &NZA::plugin('nms-ups')->get_params($ups);
			}; next if ($@);
			my $serial = $params->{$NZA::UPS::PropSerial};
			$busy_serials{$serial} = $ups;
		}
	}

	return \%busy_serials;
}

sub _get_busy_serial_ports
{
	my %busy_ports = ();
	my $upses;
	eval {
		$upses = &NZA::plugin('nms-ups')->get_upses();
	}; if ($@) {
		return \%busy_ports;
	}
	for my $ups (@$upses) {
		my $upstype;
		eval {
			$upstype = &NZA::plugin('nms-ups')->get_child_prop($ups, 'upstype');
		}; next if ($@);
		if ($upstype eq $NZA::UPS::SerialType) {
			my $params;
			eval {
				$params = &NZA::plugin('nms-ups')->get_params($ups);
			}; next if ($@);
			my $port = $params->{$NZA::UPS::PropPort};
			$busy_ports{$port} = $ups;
		}
	}
	return \%busy_ports;
}

sub recompute_upses
{
	my ($h) = @_;

	my $ups_names;
	eval {
		$ups_names = &NZA::plugin('nms-ups')->get_upses();
	}; if ($@) {
		return $h;
	}

	for my $name (@$ups_names) {
		my $tmp = NMC::Util::duplicate_hash_deep($h->{_unknown});

		# Get and set UPS description as help in UPS list
		my $ups_props = {};
		eval {
			$ups_props = &NZA::plugin('nms-ups')->get_params($name);
		};
		if (defined($ups_props->{$NZA::UPS::PropDesc})) {
			$tmp->{_help} = ["Setup '" . $ups_props->{$NZA::UPS::PropDesc} . "'"];
		} else {
			$tmp->{_help} = ["Setup UPS '$name'\n"];
		}

		# if NUT service state not in 'online' state remove any menu item
		my $state = 'unknown';
		eval {
			$state = &NZA::plugin('nms-ups')->get_service_state();
		};
		if ($state =~ /online/) {
			# if no UPS r/w variables remove 'set-var' menu item
			my $tmplist = {};
			eval {
				$tmplist = &NZA::plugin('nms-ups')->get_rw_vars($name);
			};
			unless (scalar keys %$tmplist > 0) {
				delete $tmp->{'set-var'};
			}

			# if no UPS instant commands remove 'send-command' menu item
			$tmplist = {};
			eval {
				$tmplist = &NZA::plugin('nms-ups')->get_instant_commands($name);
			};
			unless (scalar keys %$tmplist > 0) {
				delete $tmp->{'send-command'};
			}

			#if UPS no outlet control remove 'outlet' menu item
			$tmplist = 0;
			eval {
				$tmplist = &NZA::plugin('nms-ups')->outlet_count();
			};
			unless ($tmplist > 0) {
				delete $tmp->{outlet};
			}
		} else {
			delete $tmp->{'set-var'};
			delete $tmp->{'send-command'};
			delete $tmp->{'outlet'};
		}

		$h->{$name} = $tmp;

	}
	return $h;
}

sub setup_ports_or_serials_recompute
{
	my ($h, @path) = @_;
	my ($service, $action, $driver) = @path;

	if (exists($NZA::UPS::SERIAL_UPSES{$driver})) {
		my $freeports = _get_free_serial_ports();
		for my $port (@$freeports) {
			$h->{$port} = $h->{_unknown};
		}
	} elsif (exists($NZA::UPS::USB_UPSES{$driver})) {
		my $freeserials = _get_free_usb_devices();
		for my $ser (@$freeserials) {
			$h->{$ser} = $h->{_unknown};
		}
	}

	return $h;
}

sub setup_drivers_recompute
{
	my($h, @path) = @_;

	my @drvnames = keys %NZA::UPS::SERIAL_UPSES;
	for my $drv (@drvnames) {
		my $tmp = NMC::Util::duplicate_hash_deep($h->{_unknown});
		$tmp->{_help} = [$NZA::UPS::SERIAL_UPSES{$drv}->{name}];
		$h->{$drv} = $tmp;
	}
	my ($usbdevs, $unconf_devs);
	eval {
		$usbdevs = &NZA::appliance->list_conf_ugen_hid_devs();
	}; if ($@) {
		return $h;
	}
	unless (scalar @$usbdevs > 0) {
		eval {
			$unconf_devs = &NZA::appliance->list_unconf_hid_devs();
		}; if ($@) {
			return $h;
		}
	}
	if (scalar @$usbdevs > 0 || scalar @$unconf_devs > 0) {
		@drvnames = keys %NZA::UPS::USB_UPSES;
		for my $drv (@drvnames) {
			my $tmp = NMC::Util::duplicate_hash_deep($h->{_unknown});
			$tmp->{_help} = [$NZA::UPS::USB_UPSES{$drv}->{name}];
			$h->{$drv} = $tmp;
		}
	}

	return $h;
}

sub _refresh_service
{
	my $state;

	eval {
		&NZA::plugin('nms-ups')->disable_service();
	}; if ($@) {
		print_error("Can't disable NUT service. Reason: $@\n");
		return 0;
	}
	for (my $i = 0; $i < $NZA::UPS::StateChangedTimeout; $i++) {
		eval {
			$state = &NZA::plugin('nms-ups')->get_service_state();
		}; if ($@) {
			print_error("Can' get NUT service state. Reason: $@\n");
			return 0;
		}
		last if ($state =~ /disabled/);
		sleep ($i < 10 ? 1 : 2);
		$i++ if ($i >= 10);
	}

	eval {
		$state = &NZA::plugin('nms-ups')->get_service_state();
	}; if ($@) {
		print_error("Can' get NUT service state. Reason: $@\n");
		return 0;
	}
	if ($state =~ /disabled/) {
		eval {
			&NZA::plugin('nms-ups')->enable_service();
		}; if ($@) {
			print_error("Can't enable NUT service. Reason: $@\n");
			return 0;
		}
	} else {
		print_error("Disabled state not reached for NUT service\n");
		return 0;
	}
	for (my $i = 0; $i < $NZA::UPS::StateChangedTimeout; $i++) {
		eval {
			$state = &NZA::plugin('nms-ups')->get_service_state();
		}; if ($@) {
			print_error("Can' get NUT service state. Reason: $@\n");
			return 0;
		}
		last if ($state =~ /online/);
		sleep ($i < 10 ? 1 : 2);
		$i++ if ($i >= 10);
	}
	eval {
		$state = &NZA::plugin('nms-ups')->get_service_state();
	}; if ($@) {
		print_error("Can' get NUT service state. Reason: $@\n");
		return 0;
	}
	unless ($state =~ /online/){
		print_error("Online state not reached for NUT service\n");
		return 0;
	}
	return 1;
}

sub _apply_changes
{
	my($yes) = @_;

	my $svc_state;
	eval {
		$svc_state = &NZA::plugin('nms-ups')->get_service_state();
	}; if ($@) {
		print_error("Can't get NUT service state. Reason: $@\n");
		return;
	}

	my $cfg_count;
	eval {
		my $ups_names = &NZA::plugin('nms-ups')->get_upses();
		$cfg_count = scalar @$ups_names;
	}; if ($@) {
		print_error("Can't get UPS count. Reason: $@\n");
		return;
	}

	if ($svc_state =~ /online/) {
		if ($cfg_count > 0) {
			if ($yes || &NMC::Util::input_confirm("NUT service restart is required to apply configuration changes. Proceed?")) {
				_refresh_service();
			}
		} else {
			if ($yes || &NMC::Util::input_confirm("Configuration is empty. Disable NUT service?")) {
				eval {
					&NZA::plugin('nms-ups')->disable_service();
				}; if ($@) {
					print_error("Can't disable NUT service. Reason: $@\n");
				}
			}
		}
	} elsif ($svc_state =~ /disabled/ && $cfg_count > 0 &&
		 ($yes || &NMC::Util::input_confirm("NUT service is currently disabled. Enable it now?"))) {
		eval {
			&NZA::plugin('nms-ups')->enable_service();
		}; if ($@) {
			print_error("Can't enable NUT service. Reason: $@\n");
		}
	}
}

sub setup_ups
{
	my ($h, @path) = @_;
	my ($service, $action, $driver, $port_or_serial) = @path;

	if (exists($NZA::UPS::SERIAL_UPSES{$driver})) {
		return _setup_serial_ups(@_);
	} elsif (exists($NZA::UPS::USB_UPSES{$driver})) {
		return _setup_usb_ups(@_);
	} else {
		print_error("Driver '$driver' not found\n");
		return 0;
	}
}

sub _setup_serial_ups
{
	my ($h, @path) = @_;
	my ($service, $action, $driver, $port) = @path;
	my ($yes, $ups_name, $ups_desc, $sdorder, $maxstartdelay) = NMC::Util::get_optional('yn:d:o:t:', \@path);

	unless (-e $port || !(-d $port)) {
		print_error("Incorrect port '$port' specified\n");
		return 0;
	}

	unless ($ups_name) {
		return 0 if (!NMC::Util::input_field('UPS name',
				10,
				"Please enter UPS name",
				\$ups_name,
				cmdopt => 'n:',
				'on-empty' => "UPS name must be specified\n"));
		return 0 if (&choose_ret_ctrl_c());
	}

	unless ($ups_desc || $yes) {
		NMC::Util::input_field('UPS description',
			17,
			"Please enter UPS description",
			\$ups_desc,
			cmdopt => 'd:',
			'empty-ok' => 1);
		return 0 if(&choose_ret_ctrl_c());
	}

	my %params = (
		driver => $driver,
		port => $port,
	);
	$params{desc} = $ups_desc if ($ups_desc);
	$params{sdorder} = $sdorder if (defined($sdorder));
	$params{maxstartdelay} = $maxstartdelay if (defined($maxstartdelay));

	eval {
		&NZA::plugin('nms-ups')->configure_serial_ups($ups_name, \%params);
	}; if ($@) {
		print_error("$@\n");
		return 0;
	}

	print_out("Successfully created UPS configuration '$ups_name'\n");
	_apply_changes($yes);

	return 1;
}

sub setup_ups_usage
{
        my ($cmdline, $prompt, $service, $action, $driver, $port, @path) = @_;

	my $forUsage = 'for a selected serial or USB based UPS device.';
	if ($driver && $driver !~ /^-/ && $driver !~ /help/) {
		if (exists($NZA::UPS::SERIAL_UPSES{$driver})) {
			$forUsage = 'for ' . $NZA::UPS::SERIAL_UPSES{$driver}->{name};
		} elsif (exists $NZA::UPS::USB_UPSES{$driver}) {
			$forUsage = 'for ' . $NZA::UPS::USB_UPSES{$driver}->{name};
		}
	}
	if ($port && $port !~ /^-/ && $port !~ /help/) {
		$forUsage .= " on port $port";
	}

	print_out <<EOF;
$cmdline
Usage:
       <driver> <port|serialno> [-y]
                                [-n <ups name>]
                                [-d <ups description>]
	                        [-o <sdorder>]
			        [-t maxstartdelay]

Create new UPS configuration $forUsage

   -y                  Skip confirmation dialog by automatically
   		       responding Yes
   -n  <ups_name>      UPS device name
   -d  <description>   Description

   -o  <sdorder>       Shutdown order ('sdorder') - the order in
   		       which your UPS devices receive shutdown commands.
		       With multiple UPSes in the system, you would
		       typically need to turn them off in a certain
		       pre-defined order.

   -t <maxstartdelay>  This can be set as a global sustem-wide setting,
	               as well as on a per UPS device.

Examples:
=========
1) Add new configuration for APC Smart UPS on COM1 port and name
   this UPS configuration "main_ups".

${prompt}setup ups add apcsmart /dev/cua0 -n main_ups

2) Add new configuration for USB HID UPS with serial number ST0123218547
   and name this UPS configuration "second_ups". Option -y skips
   confirmation dialog and restarts NUT service automatically.

${prompt}setup ups add usbhid-ups ST0123218547 -y -n second_ups


See also: 'setup ups <ups_name> remove'
See also: 'setup ups <ups_name> modify'

See also: 'show ups <ups_name>'

EOF
}

sub _setup_usb_ups
{
	my ($h, @path) = @_;
	my ($service, $action, $ups_drv, $serialno) = @path;
	my ($yes, $ups_name, $ups_desc, $sdorder, $maxstartdelay) = NMC::Util::get_optional('yn:d:o:t:', \@path);

	my $usbdevs;
	eval {
		$usbdevs = &NZA::appliance->list_conf_ugen_hid_devs();
	}; if ($@) {
		print_error("Can't get list of configured USB devices. Reason: $@\n");
		return 0;
	}
	my $usb_unconf;
	eval {
		$usb_unconf = &NZA::appliance->list_unconf_hid_devs();
	}; if ($@) {
		print_error("Can't get list of unconfigured USB devices. Reason: $@\n");
		return 0;
	}

	my $device_info;
	my $cfg_flag;
	for my $dev (@$usbdevs) {
		my $dser = $dev->{$NZA::USB::USBSerialNo}->{value};
		$dser =~ s/\|//;
		if ($dser eq $serialno) {
			$device_info = $dev;
			$cfg_flag = 1;
			last;
		}
	}
	unless(defined($device_info)) {
		for my $dev (@$usb_unconf) {
			my $dser = $dev->{$NZA::USB::USBSerialNo}->{value};
			$dser =~ s/\|//;
			if ($dser eq $serialno) {
				$device_info = $dev;
				last;
			}
		}
	}

	if (defined($device_info)) {

		# if USB device not configured. Configure it now
		unless ($cfg_flag) {
			eval {
				&NZA::appliance->configure_ugen_device($device_info);
			}; if ($@) {
				print_error("Can't configure USB device with Generic USB driver. Reason: $@\n");
				return 0;
			}
		}

		unless ($ups_name) {
			return 0 if (!NMC::Util::input_field('UPS name',
					10,
					"Please enter UPS name",
					\$ups_name,
					cmdopt => 'n:',
					'on-empty' => "UPS name must be specified\n"));
			return 0 if (&choose_ret_ctrl_c());
		}

		unless ($ups_desc || $yes) {
			NMC::Util::input_field('UPS description',
				17,
				"Please enter UPS description",
				\$ups_desc,
				cmdopt => 'd:',
				'empty-ok' => 1);
			return 0 if (&choose_ret_ctrl_c());
		}

		my %params = (
			'driver' => $ups_drv,
			'serial' => $device_info->{$NZA::USB::USBSerialNo},
		);
		$params{desc} = $ups_desc if ($ups_desc);
		$params{sdorder} = $sdorder if (defined($sdorder));
		$params{maxstartdelay} = $maxstartdelay if (defined($maxstartdelay));

		eval {
			&NZA::plugin('nms-ups')->configure_usb_hid_ups($ups_name, \%params, $device_info);
		}; if ($@) {
			print_error("$@\n");
			return 0;
		}
	} else {
		print_error("Configured USB HID device not found with specified serial number '$serialno'\n");
		return 0;
	}

	print_out("Successfully created UPS configuration '$ups_name'\n");
	_apply_changes($yes);

	return 1;
}

sub setup_cfg_remove
{
	my ($h, @path) = @_;
	my ($service, $ups_name) = @path;
	my ($yes) = NMC::Util::get_optional('y', \@path);

	if ($yes || &NMC::Util::input_confirm("Remove UPS '$ups_name'?")) {
		my $state;
		eval {
			$state = &NZA::plugin('nms-ups')->get_service_state();
		}; if ($@) {
			print_error("$@\n");
			return 0;
		}
		unless ($state =~ /disabled/) {
			eval {
				&NZA::plugin('nms-ups')->disable_service();
			}; if ($@) {
				print_error("$@\n");
			}
			for(my $i = 0; $i < $NZA::UPS::StateChangedTimeout; $i++) {
				sleep 1;
				my $s = &NZA::plugin('nms-ups')->get_service_state();
				last if ($s =~ /disabled/);
			}
		}
		eval {
			&NZA::plugin('nms-ups')->remove_ups($ups_name);
		}; if ($@) {
			print_error("UPS '$ups_name' not removed.\nReason: $@\n");
			return 0;
		}
		my $cfg_count;
		eval {
			my $ups_names = &NZA::plugin('nms-ups')->get_upses();
			$cfg_count = scalar @$ups_names;
		}; if ($@) {
			print_error("Can't get UPS count. Reason: $@\n");
			return 0;
		}
		if (!($state =~ /disabled/) && $cfg_count > 0) {
			eval {
				&NZA::plugin('nms-ups')->enable_service();
			}; if ($@) {
				print_error("$@\n");
				return 0;
			}
		}
	}

	print_out("Successfully removed UPS configuration '$ups_name'\n");
	return 1;
}

sub setup_ups_genusage
{
        my ($cmdline, $prompt, $service, $ups_name, $action, @path) = @_;

	print_out <<EOF;
$cmdline
Usage:

Setup UPS device. The following UPS management operations
are available:

  * setup ups <ups_name> remove
    to remove selected UPS configuration

  * setup ups <ups_name> modify
    to modify (add, change or remove properties) for the
    specified UPS configuration.

                   Note:
                   =====
The next 3 operations require that the state of the underlying
Network UPS Tools (NUT) is online.

  * setup ups <ups_name> set-var
    to inspect or assign a UPS device property.

  * setup ups <ups_name> send-command
    to execute an instant command to selected UPS.

  * setup ups <ups_name> outlet
    to administer UPS outlet(s)


$NZA::PRODUCT UPS plugin uses Network UPS Tools (NUT)
service to provide reliable monitoring of UPS hardware and
ensure safe shutdowns of the UPS connected systems.

Features:

 * Multiple manufacturer support
 * Common Power Management support
 * Multiple UPS support - Hot swap/high availability power supplies
 * Security and access control
 * One UPS, many clients
 * Many UPSes, many clients
 * Easy UPS management and control

For more information on NUT functionality, please see:

 * http://eu1.networkupstools.org/features/ for more information.

For supported hardware see:

  * http://eu1.networkupstools.org/compat/stable.html


See also: 'setup ups <ups_name> remove'

See also: 'setup ups <ups_name> modify <property> set'
See also: 'setup ups <ups_name> modify <property> remove'

See also: 'setup ups <ups_name> set-var <var_name>'

See also: 'setup ups <ups_name> send-command <cmd_name>'

See also: 'setup ups <ups_name> outlet <outlet_num> enable'
See also: 'setup ups <ups_name> outlet <outlet_num> disable'

See also: 'show ups <ups_name>'

EOF
}

sub setup_cfg_remove_usage
{
        my ($cmdline, $prompt, $service, $ups_name, $action, @path) = @_;

	print_out <<EOF;
$cmdline
Usage: [-y]

    -y    Skip confirmation dialog by automatically responding Yes

Remove selected UPS configuration. This operation automatically
restarts Network UPS Tools (NUT) service, if the latter is enabled.

Example:
=========
1) Remove UPS configuration named "main_ups"

${prompt}setup ups main_ups remove


See also: 'setup ups <ups_name> modify'
See also: 'setup ups <ups_name> set-var'
See also: 'setup ups <ups_name> send-command'
See also: 'setup ups <ups_name> outlet'

See also: 'show ups <ups_name>'

EOF
}

sub setup_setvar_recompute
{
	my ($h, @path) = @_;
	my ($service, $ups_name, $action) = @path;

	my $state;
	eval {
		$state = &NZA::plugin('nms-ups')->get_service_state();
	}; if ($@) {
		return $h;
	}

	if ($state =~ /online/) {
		my $rw_vars;
		eval {
			$rw_vars = &NZA::plugin('nms-ups')->get_rw_vars($ups_name);
			for my $var_name (keys %$rw_vars) {
				my $tmp = NMC::Util::duplicate_hash_deep($h->{_unknown});
				$tmp->{_help} = [$rw_vars->{$var_name}->[$NZA::UPS::RWVarIdxDesc]];
				$h->{$var_name} = $tmp;
			}
		}; if ($@) {
			print_error("Can't get list of r/w variables. Reason: $@\n");
		}
	}

	return $h;
}

sub setup_setvar
{
	my ($h, @path) = @_;
	my ($service, $ups_name, $action, $var_name) = @path;
	my ($value) = NMC::Util::get_optional('s:', \@path);

	my $state;
	eval {
		$state = &NZA::plugin('nms-ups')->get_service_state();
	}; if ($@) {
		print_error("Can't get service state. Reason: $@\n");
		return $h;
	}

	if ($state =~ /online/) {
		my $rw_vars;
		eval {
			$rw_vars = &NZA::plugin('nms-ups')->get_rw_vars($ups_name);
		}; if ($@) {
			print_error("$@\n");
			return 0;
		}
		unless (exists($rw_vars->{$var_name})) {
			print_error("R/W variable '$var_name' not found for UPS '$ups_name'\n");
			return 0;
		}

		my $old_value;
		unless (defined($value)) {
			eval {
				$old_value = &NZA::plugin('nms-ups')->get_var_value($ups_name, $var_name);
			}; if ($@) {
				print_error("Can't get value for variable '$var_name' of UPS '$ups_name'. Reason: $@\n");
				return 0;
			}
			print_out("Currect value of variable '$var_name' for UPS '$ups_name' is '$old_value'\n");

			if ($rw_vars->{$var_name}->[$NZA::UPS::RWVarIdxType] eq 'ENUM') {
				my @pv = split(/\|/, $rw_vars->{$var_name}->[$NZA::UPS::RWVarIdxPossibleValues]);

				return 0 if (!NMC::Util::input_field('New value',
						10,
						"Please select new value for '$var_name' r/w variable for UPS '$ups_name'",
						\$value,
						'on-empty' => "New value of r/w variable must be selected\n",
						cmdopt => 's:',
						'choose-from' => \@pv));
				return 0 if (&choose_ret_ctrl_c());
			} else {
				return 0 if (!NMC::Util::input_field('New value',
						10,
						"Please enter new value for '$var_name' r/w variable for UPS '$ups_name'",
						\$value,
						cmdopt => 's:',
						'on-empty' => "New value of r/w variable must be specified\n"));
				return 0 if (&choose_ret_ctrl_c());
			}
		}

		eval {
			&NZA::plugin('nms-ups')->set_var_value($ups_name, $var_name, $value);
		}; if ($@) {
			print_error("Can't set new value for r/w variable '$var_name'. Reason: $@\n");
			return 0;
		}

		print_out("Set new value for variable '$var_name' successfully\n");
	} else {
		print_error("Service is not in online state\n");
		return 0;
	}

	return 1;
}

sub setup_setvar_usage
{
        my ($cmdline, $prompt, $service, $ups_name, $action, @path) = @_;

	print_out <<EOF;
$cmdline
Usage: [-s <new_value>]

   -s   new UPS device property value

Modify UPS device property. Note that Network UPS Tools (NUT)
service must be enabled and the new value must be in a valid range.

Examples:
=========
1) Set test interval to 3000 seconds for UPS identified
   as "main_ups".

${prompt}setup ups main_ups set-var ups.test.interval -s 3000

2) Mute beeper on the "second_ups":

${prompt}setup ups second_ups set_var ups.beeper.status -s muted


See also: 'setup ups <ups_name> modify'
See also: 'setup ups <ups_name> remove'
See also: 'setup ups <ups_name> send-command'
See also: 'setup ups <ups_name> outlet'

See also: 'show ups <ups_name>'

EOF
}

sub setup_sendcmd_recompute
{
	my ($h, @path) = @_;
	my ($service, $ups_name, $action) = @path;

	my $state;
	eval {
		$state = &NZA::plugin('nms-ups')->get_service_state();
	}; if ($@) {
		return $h;
	}

	if ($state =~ /online/) {
		my $inst_cmds;
		eval {
			$inst_cmds = &NZA::plugin('nms-ups')->get_instant_commands($ups_name);
		}; if ($@) {
			print_error("Can't get list of instant commands. Reason: $@\n");
		}
		my $cmd_count = scalar keys %$inst_cmds;
		if ($cmd_count > 0) {
			for my $cmd_name (keys %$inst_cmds) {
				my $tmp = NMC::Util::duplicate_hash_deep($h->{_unknown});
				$tmp->{_help} = [$inst_cmds->{$cmd_name}];
				$h->{$cmd_name} = $tmp;
			}
		}
	}

	return $h;
}

sub setup_sendcmd
{
	my ($h, @path) = @_;
	my ($service, $ups_name, $action, $cmd_name) = @path;

	my $state;
	eval {
		$state = &NZA::plugin('nms-ups')->get_service_state();
	}; if ($@) {
		print_error("Can't get service state. Reason: $@\n");
		return 0;
	}

	if ($state =~ /online/) {
		my $inst_cmds;
		eval {
			$inst_cmds = &NZA::plugin('nms-ups')->get_instant_commands($ups_name);
		}; if ($@) {
			print_error("Can't get list of instant commands. Reason: $@\n");
		}
		unless(exists($inst_cmds->{$cmd_name})) {
			print_error("Instant command '$cmd_name' not found for this UPS\n");
			return 0;
		}
		eval {
			&NZA::plugin('nms-ups')->send_instant_command($ups_name, $cmd_name);
		}; if ($@) {
			print_error("$@\n");
			return 0;
		}
		print_out("Instant command '$cmd_name' successfully send to UPS '$ups_name'\n");
	} else {
		print_error("Service is not in online state\n");
		return 0;
	}

	return 1;

}

sub setup_properties_recompute
{
	my ($h, @path) = @_;
	my ($service, $ups_name, $action) = @path;

	my $drv_name = _get_driver_by_name($ups_name);
	return $h unless ($drv_name);

	my $drv_params = {};
	if ($NZA::UPS::SERIAL_UPSES{$drv_name}) {
		$drv_params = $NZA::UPS::SERIAL_UPSES{$drv_name}->{optparams};
	} elsif ($NZA::UPS::USB_UPSES{$drv_name}) {
		$drv_params = $NZA::UPS::USB_UPSES{$drv_name}->{optparams};
	}
	for my $pn (keys %$drv_params) {
		my $tmp = NMC::Util::duplicate_hash_deep($h->{_unknown});
		$tmp->{_help} = [$drv_params->{$pn}];
		$h->{$pn} = $tmp;
	}
	for my $pn (keys %NZA::UPS::DRV::OPT_PARAMS) {
		my $tmp = NMC::Util::duplicate_hash_deep($h->{_unknown});
		$tmp->{_help} = [$NZA::UPS::DRV::OPT_PARAMS{$pn}];
		$h->{$pn} = $tmp;
	}

	return $h;
}

sub _get_driver_by_name
{
	my ($ups_name) = @_;

	my $params;
	eval {
		$params = &NZA::plugin('nms-ups')->get_params($ups_name);
	}; if ($@) {
		return undef;
	}

	return $params->{driver};
}

sub setup_modify_set_usage
{
        my ($cmdline, $prompt, $service, $ups_name, $action, $prop_name, $prop_action, @path) = @_;

	my $prop_desc = '';
	if ($prop_name) {
		my $drv_name = _get_driver_by_name($ups_name);

		if ($drv_name) {
			if (exists($NZA::UPS::DRV::OPT_PARAMS{$prop_name})) {
				$prop_desc = "\nProperty '$prop_name' note:\n==========\n    $NZA::UPS::DRV::OPT_PARAMS{$prop_name}\n";
			} else {
				my $drv_params;
				if ($NZA::UPS::SERIAL_UPSES{$drv_name}) {
					$drv_params = $NZA::UPS::SERIAL_UPSES{$drv_name}->{optparams};
				} elsif ($NZA::UPS::USB_UPSES{$drv_name}) {
					$drv_params = $NZA::UPS::USB_UPSES{$drv_name}->{optparams};
				}
				$prop_desc = "\nProperty '$prop_name' note:\n==========\n    $drv_params->{$prop_name}\n";
			}
		}
	}

	print_out <<EOF;
$cmdline
Usage: [-y] [-s <new_value>]

    -y    Skip confirmation dialog by automatically responding Yes
    -s	  New UPS configuration property value

Modify UPS configuration property value.

Examples:
=========
1) Set description for UPS configuration named 'main_ups'.
${prompt}setup ups main_ups modify desc set -s "Main UPS for Omega server"

2) Set cable model to 940-0095B for UPS configuration named 'second_ups'.

${prompt}setup ups second_ups modify cable set -s "940-0095B"

$prop_desc


See also: setup ups <ups_name> modify <property_name> remove

See also: 'show ups <ups_name>'

EOF
}

sub setup_modify_remove_usage
{
        my ($cmdline, $prompt, $service, $ups_name, $action, $prop_name, $prop_action, @path) = @_;

	print_out <<EOF;
$cmdline
Usage: [-y]

    -y    Skip confirmation dialog by automatically responding Yes

Remove UPS configuration property.

Examples:
=========
1) Remove property 'cable' from UPS configuration named 'second_ups'.

${prompt}setup ups second_ups modify cable remove


See also: 'setup ups <ups_name> modify <property_name> set'
See also: 'show ups <ups_name>'

EOF
}
sub setup_modify_usage
{
        my ($cmdline, $prompt, $service, $ups_name, $action, $prop_name, $prop_action, @path) = @_;

	my $props_list = "General property list:\n======================\n";
	for my $p (sort keys %NZA::UPS::DRV::OPT_PARAMS) {
		$props_list .= "    $p\n        $NZA::UPS::DRV::OPT_PARAMS{$p}\n";
	}
	my $drv_name = _get_driver_by_name($ups_name);
	if ($drv_name) {

		my $drv_params;
		if ($NZA::UPS::SERIAL_UPSES{$drv_name}) {
			$drv_params = $NZA::UPS::SERIAL_UPSES{$drv_name}->{optparams};
		} elsif ($NZA::UPS::USB_UPSES{$drv_name}) {
			$drv_params = $NZA::UPS::USB_UPSES{$drv_name}->{optparams};
		}

		if ($drv_params && scalar keys %$drv_params > 0) {
			$props_list .= "\nDriver '$drv_name' of UPS '$ups_name' property list:\n======================\n";
			for my $p (sort keys %$drv_params) {
				$props_list .= "    $p\n        $drv_params->{$p}\n";
			}
		}
	}

	print_out <<EOF;
$cmdline
Usage:

Modify UPS configuration property value or remove UPS configuration
property.

Examples:
=========
1) Set description for UPS configuration named 'main_ups'.
${prompt}setup ups main_ups modify desc set -s "Main UPS for Omega server"

2) Set cable model to 940-0095B for UPS configuration named 'second_ups'.
${prompt}setup ups second_ups modify cable set -s "940-0095B"

3) Remove property 'cable' from UPS configuration named 'second_ups'.
${prompt}setup ups second_ups modify cable remove

$props_list


See also: setup ups <ups_name> modify <property_name> set
See also: setup ups <ups_name> modify <property_name> remove

See also: 'show ups <ups_name>'

EOF
}

sub setup_property_set
{
	my ($h, @path) = @_;
	my ($service, $ups_name, $action0, $var_name, $action1) = @path;
	my ($yes, $value) = NMC::Util::get_optional('ys:', \@path);

	my $params = {};
	eval {
		$params = &NZA::plugin('nms-ups')->get_params($ups_name);
	}; if ($@) {
		print_error("$@\n");
		return 0;
	}
	my $drv_name = $params->{driver};

	unless (exists($NZA::UPS::SERIAL_UPSES{$drv_name}->{optparams}->{$var_name}) ||
		exists($NZA::UPS::USB_UPSES{$drv_name}->{optparams}->{$var_name}) ||
		exists($NZA::UPS::DRV::OPT_PARAMS{$var_name})) {
		print_error("Property '$var_name' not found for UPS '$ups_name'\n");
		return 0;
	}

	my %setparams = ();
	if ($action1 eq 'remove') {
		$setparams{$var_name} = undef;
	} else {
		unless (defined($value)) {
			return 0 if (!NMC::Util::input_field('Value',
					7,
					"Please enter value for property '$var_name' for UPS '$ups_name'",
					\$value,
					cmdopt => 's:',
					'on-empty' => "Property value must be specified\n"));
			return 0 if (&choose_ret_ctrl_c());
		}
		$setparams{$var_name} = $value;
	}

	eval {
		&NZA::plugin('nms-ups')->set_params($ups_name, \%setparams);
	}; if ($@) {
		print_error("$@\n");
	}

	_apply_changes($yes);

	return 1;
}

sub setup_sendcmd_usage
{
        my ($cmdline, $prompt, $service, $ups_name, $action, @path) = @_;

	print_out <<EOF;
$cmdline
Usage: <cmd_name>

Send instant command to the specified UPS device for execution.

Note:
=====
    Some UPS hardware and drivers support instant commands,
    such as starting a battery test, or powering off the load.

Examples:
=========
1) Start panel test for UPS identified by configuration
   named 'main_ups'.

${prompt}setup ups main_ups send-command test.panel.start

2) Start batery test for UPS identified by configuration
   named 'second_ups'.

${prompt}setup ups second_ups send-command test.batery.start


See also: setup ups <ups_name> modify
See also: setup ups <ups_name> remove
See also: setup ups <ups_name> set-var
See also: setup ups <ups_name> outlet

See also: 'show ups <ups_name>'

EOF
}

sub setup_outlet_recompute
{
	my ($h, @path) = @_;
	my ($service, $ups_name, $action) = @path;

	my $state;
	eval {
		$state = &NZA::plugin('nms-ups')->get_service_state();
	}; if ($@) {
		return $h;
	}

	if ($state =~ /online/) {
		my $outlet_count = 0;
		eval {
			$outlet_count = &NZA::plugin('nms-ups')->outlet_count();
		}; if ($@) {
			print_error("Can't get outlet count. Reason: $@\n");
			return $h;
		}

		for(my $i = 0; $i < $outlet_count; $i++) {
			$h->{$i} = $h->{_unknown};
		}
	}

	return $h;
}

sub enable_outlet
{
	my ($h, @path) = @_;
	my ($service, $ups_name, $action0, $outlet_num, $action1) = @path;

	my $sw = $NZA::UPS::ValueOn;
	$sw = $NZA::UPS::ValueOff if ($action1 eq 'disable');

	eval {
		&NZA::plugin('nms-ups')->outlet_switch($ups_name, $outlet_num, $sw);
	}; if ($@) {
		print_error("$@\n");
		return 0;
	}
	return 1;
}

sub setup_outlet_usage
{
        my ($cmdline, $prompt, $service, $ups_name, $action, @path) = @_;

	print_out <<EOF;
$cmdline
Usage:

Enable or disable the specified UPS outlet.

This operation requires that the the Network UPS Tools (NUT)
service is enabled.

$NZA::PRODUCT UPS plugin uses Network UPS Tools (NUT)
service to provide reliable monitoring of UPS hardware and
ensure safe shutdowns of the UPS connected systems.

Examples:
=========
1) Power off outlet number 0 for UPS identified by
   configuration named 'main_ups'.

${prompt}setup ups main_ups outlet 0 disable

2) Power on outlet number 2 for UPS identified by
   configuration named 'second_ups'.

${prompt}setup ups second_ups outlet 2 enable


See also: 'setup ups <ups_name> modify'
See also: 'setup ups <ups_name> remove'
See also: 'setup ups <ups_name> set-var'
See also: 'setup ups <ups_name> send-command'

See also: 'show ups <ups_name>'

EOF
}

sub setup_service_manage
{
	my ($h, @path) = @_;
	my ($service, $menu_item, $action) = @path;

	if ($action =~ /enable/) {
		eval {
			&NZA::plugin('nms-ups')->enable_service();
		}; if ($@) {
			print_error("Can't enable NUT service. Reason: $@\n");
			return 0;
		}
		my $state;
		for (my $i = 0; $i < $NZA::UPS::StateChangedTimeout; $i++) {
			eval {
				$state = &NZA::plugin('nms-ups')->get_service_state();
			}; if ($@) {
				print_error("Can' get NUT service state. Reason: $@\n");
				return 0;
			}
			last if ($state =~ /online/);
			sleep ($i < 10 ? 1 : 2);
			$i++ if ($i >= 10);
		}
		_print_service_state();
	} else {
		eval {
			&NZA::plugin('nms-ups')->disable_service();
		}; if ($@) {
			print_error("Can't disable NUT service. Reason: $@\n");
			return 0;
		}
		my $state;
		for (my $i = 0; $i < $NZA::UPS::StateChangedTimeout; $i++) {
			eval {
				$state = &NZA::plugin('nms-ups')->get_service_state();
			}; if ($@) {
				print_error("Can' get NUT service state. Reason: $@\n");
				return 0;
			}
			last if ($state =~ /disabled/);
			sleep ($i < 10 ? 1 : 2);
			$i++ if ($i >= 10);
		}
		_print_service_state();
	}
}

sub setup_service_manage_usage
{
        my ($cmdline, $prompt, $service, $menu_item, $action, @path) = @_;

	my $action_txt = "Enable or disable";
	if ($action) {
		if ($action =~ /enable/) {
			$action_txt = "Enable";
		} elsif ($action =~ /disable/){
			$action_txt = "Disable";
		}
	}

	print_out <<EOF;
$cmdline
Usage:

$action_txt Network UPS Tools (NUT) service.

$NZA::PRODUCT UPS (Uninterruptible Power Supply) extension provides
reliable monitoring and easy management of UPS hardware.

The extension uses Network UPS Tools (NUT) service to provide
reliable monitoring of UPS hardware and ensure safe shutdowns of
the UPS connected systems.

The UPS extension features:

 * Multiple manufacturer support
 * Common Power Management support
 * Multiple UPS support - Hot swap/high availability power supplies
 * Security and access control
 * One UPS, many clients
 * Many UPSes, many clients
 * Easy UPS management and control

For more information on NUT functionality, please see:

 * http://eu1.networkupstools.org/features/ for more information.

For supported hardware see:

  * http://eu1.networkupstools.org/compat/stable.html

Examples:
=========
1) Start NUT service.
${prompt}setup ups service enable

2) Stop NUT service.
${prompt}setup ups service disable


See also: 'setup ups service enable'
See also: 'setup ups service disable'

See also: 'show ups service'

EOF
}

############################## Show Command ####################################

sub _print_short_status
{
	my ($upsname) = @_;
	my $statuses;

	eval {
		$statuses = &NZA::plugin('nms-ups')->get_online_status($upsname);
		my @arr = split(/\s/, $statuses);
		if (scalar @arr > 0) {
			print_out("Online status of UPS '$upsname':\n");
			for my $s (@arr) {
				my $s_desc = $NZA::UPS::ONLINE_STATUSES{$s};
				if (defined($s_desc)) {
					print_out(" $s_desc\n");
				} else {
					print_out(" $s\n");
				}
			}
		} else {
			print_out("Status of UPS $upsname not found\n");
		}
	}; if ($@) {
		print_error("$@\n");
		return;
	}
}

sub show_ups_unk_short_status
{
	my ($h, $service, $upsname, $action) = @_;

	_print_short_status($upsname);
}

sub show_ups_unk_short_status_usage
{
	my ($cmdline, $prompt, @path) = @_;
	print_out <<EOF;
$cmdline
Usage:

Show online status of the specified UPS device.
UPS online status may have one of the following enumerated values:

EOF

	for my $st (sort values %NZA::UPS::ONLINE_STATUSES) {
		print_out("$st\n");
	}

	print_out <<EOF

See also: 'show ups <ups_name> full-status'
See also: 'show ups <ups_name> commands'
See also: 'show ups <ups_name> outlets'
See also: 'show ups <ups_name> properties'

See also: 'setup ups <ups_name>'

EOF
}

sub _print_full_status {
	my ($upsname) = @_;
	my ($vars, $rws);

	eval {
		$vars = &NZA::plugin('nms-ups')->get_status($upsname);
		$rws = &NZA::plugin('nms-ups')->get_rw_vars($upsname);
	}; if ($@) {
		print_error("$@\n");
		return;
	}

	if (scalar keys %$vars > 0) {
		print_out("Full status of UPS '$upsname':\n");

		for my $var (keys %$vars) {
			unless ($var =~ /outlet/) {
				print_out(" $var: ");
				my $value = $vars->{$var};
				if (defined($value)){
					print_out($value);
				}
				if (exists($rws->{$var})) {
					my ($type, $enums);
					$type = $rws->{$var}->[1];
					$enums = $rws->{$var}->[3];
					print_out(" (r/w) /$type/");
					if (defined($enums)) {
						print_out(" [$enums]");
					}
				}
			}
			print_out("\n");
		}
	} else {
		print_out("Status of UPS '$upsname' not found");
	}
}

sub show_ups_unk_full_status
{
	my ($h, $service, $upsname, $action) = @_;

	_print_full_status($upsname);
}

sub show_ups_unk_full_status_usage
{
	my ($cmdline, $prompt, @path) = @_;
	print_out <<EOF;
$cmdline

For the specified UPS device, show detailed status information,
including all device's properties and their values.


See also: 'show ups <ups_name> short-status'
See also: 'show ups <ups_name> commands'
See also: 'show ups <ups_name> outlets'
See also: 'show ups <ups_name> properties'

See also: 'setup ups <ups_name>'

EOF
}

sub _print_available_inst_cmds
{
	my ($upsname) = @_;
	my $cmds;

	eval {
		$cmds = &NZA::plugin('nms-ups')->get_instant_commands($upsname);
	}; if ($@) {
		print_error("$@\n");
		return;
	}

	if (scalar keys %$cmds > 0) {
		print_out("Available instant commands for UPS '$upsname':\n");

		for my $cmd (keys %$cmds) {
			print_out(" $cmd - $cmds->{$cmd}\n");
		}
	} else {
		print_out(" This UPS not supported instant commands\n");
	}
}

sub show_ups_unk_commands
{
	my ($h, $service, $upsname, $action) = @_;

	_print_available_inst_cmds($upsname);
}

sub show_ups_unk_commands_usage
{
	my ($cmdline, $prompt, @path) = @_;
	print_out <<EOF;
$cmdline
Usage:

Display all instant commands (if any) supported by a given UPS device.

Note:
=====
    Some UPS hardware and drivers support instant commands,
    such as starting a battery test, or powering off the load.


See also: 'show ups <ups_name> short-status'
See also: 'show ups <ups_name> full-status'
See also: 'show ups <ups_name> outlets'
See also: 'show ups <ups_name> properties'

See also: 'setup ups <ups_name>'

EOF
}

sub _print_outlet_statuses
{
	my ($upsname) = @_;

	my ($outlet_count, $outlet_status);
	eval {
		$outlet_count = &NZA::plugin('nms-ups')->outlet_count($upsname);
		if ($outlet_count > 0) {
			print_out("UPS '$upsname' have $outlet_count outlets with following statuses:\n");

			for (my $i = 0; $i < $outlet_count; $i++) {
				print_out(" Outlet $i status:\n");
				eval {
					$outlet_status = &NZA::plugin('nms-ups')->outlet_status($upsname);

					for my $vn (keys %$outlet_status) {
						print_out("  $vn=$outlet_status->{$vn}\n");
					}
				}; if ($@) {
					print_error("  $@\n");
				}
			}
		} else {
			print_out("Outlets control not supported by UPS '$upsname'\n");
		}
	}; if ($@) {
		print_error("$@\n");
	}
}

sub show_ups_unk_outlets {
	my ($h, $service, $upsname, $action) = @_;

	_print_outlet_statuses($upsname);
}

sub show_ups_unk_outlets_usage
{
	my ($cmdline, $prompt, @path) = @_;
	print_out <<EOF;
$cmdline
Usage:

If outlet control information is supported by the device,
display detailed status of the selected UPS outlets.


See also: 'show ups <ups_name> short-status'
See also: 'show ups <ups_name> full-status'
See also: 'show ups <ups_name> commands'
See also: 'show ups <ups_name> properties'

See also: 'setup ups <ups_name>'

EOF
}

sub _print_service_state
{
	my $service_state;
	eval {
		$service_state = &NZA::plugin('nms-ups')->get_service_state();
	}; if ($@) {
		print_error("Can't get NUT service state. Reason: $@\n");
		return;
	}

	print_out("NUT service state: $service_state\n");
}

sub show_service_state
{
	my ($h, $service) = @_;

	_print_service_state();
}

sub show_service_state_usage
{
	my ($cmdline, $prompt, @path) = @_;
	print_out <<EOF;
$cmdline
Usage:

Show Network UPS Tools (NUT) service state.

Network UPS Tools (NUT) provides a common interface
for monitoring and administering UPS hardware.

$NZA::PRODUCT pluggable extension uses Network UPS Tools (NUT)
service to provide reliable monitoring of UPS hardware and
ensure safe shutdowns of the UPS connected systems.

EOF
}

sub _print_ups_properties
{
	my ($ups_name) = @_;

	my $params;
	eval {
		$params = &NZA::plugin('nms-ups')->get_params($ups_name);
	}; if ($@) {
		print_error("Can't get properties for UPS '$ups_name'. Reason: $@\n");
		return;
	}
	print_out("Properties of UPS '$ups_name':\n");
	for my $prop (keys %$params) {
		print_out("  $prop = $params->{$prop}\n");
	}
}

sub show_ups_properties
{
	my ($h, $service, $ups_name) = @_;

	_print_ups_properties($ups_name);
}

sub show_ups_properties_usage
{
	my ($cmdline, $prompt, @path) = @_;
	print_out <<EOF;
$cmdline
Usage:

Display configuration properties of the specified UPS device.

See also: 'show ups <ups_name> short-status'
See also: 'show ups <ups_name> full-status'
See also: 'show ups <ups_name> commands'
See also: 'show ups <ups_name> outlets'

See also: 'setup ups <ups_name>'

EOF
}

sub show_usage
{
	my ($cmdline, $prompt, @path) = @_;
	print_out <<EOF;
$cmdline
Usage:

$NZA::PRODUCT UPS (Uninterruptible Power Supply) extension provides
reliable monitoring and easy management of UPS hardware.

Use NMC 'show' operations (listed below) to view:

  * the state of the underlying UPS service called Network UPS Tools
    (NUT)
  * available UPS devices
  * their properties
  * management operations by the UPS devices,
  * and their power outlets.


See also: 'show ups service'
See also: 'setup ups service'

See also: 'show ups <ups_name> short-status'
See also: 'show ups <ups_name> full-status'
See also: 'show ups <ups_name> commands'
See also: 'show ups <ups_name> outlets'
See also: 'show ups <ups_name> properties'

EOF
}

sub show_ups_usage
{
	my ($cmdline, $prompt, @path) = @_;
	print_out <<EOF;

$NZA::PRODUCT UPS (Uninterruptible Power Supply) extension provides
reliable monitoring and easy management of UPS hardware.

Run:

  * show ups <ups_name> short-status
    to show online status of the specified UPS device.

  * show ups <ups_name> full-status
    to list all UPS device's properties and their values

  * show ups <ups_name> commands
    to view all instant commands supported by a given UPS device.

                 Note:
                 =====
Some UPS hardware and drivers support instant commands,
such as starting a battery test, or powering off the load.


  * show ups <ups_name> outlets
    to list power outlets of the selected UPS, if the outlet
    control information is available.

EOF
}

1;
