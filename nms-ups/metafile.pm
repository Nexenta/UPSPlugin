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
# Copyright (C) 2006-2009 Nexenta Systems, Inc.
# All rights reserved.
#
package Plugin::Ups;
use base qw(NZA::IpcPlugin);

$Plugin::CLASS			= 'Ups';

$Plugin::Ups::NAME		= 'nms-ups';
$Plugin::Ups::AUTHOR		= 'Nexenta Systems, Inc';
$Plugin::Ups::LICENSE		= 'Commercial';
$Plugin::Ups::DESCRIPTION	= 'UPS monitoring and easy management extension';
$Plugin::Ups::GROUP		= '!ups';
$Plugin::Ups::VERSION		= '0.8';
$Plugin::Ups::IPC_PATH		= '/Root/Ups';
@Plugin::Ups::FILES		= ('Ups.pm', 'Consts.pm');

$Plugin::Ups::HELP_METHODS_FILE	= 'ups-methods.hlp';
$Plugin::Ups::HELP_PROPS_FILE	= 'ups-props.hlp';

require 'nms-ups/Ups.pm';

sub construct {
	my ($self, $server) = @_;

	$server->{ups} = NZA::UpsIPC->new($server->{root});
}

1;
