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
# METAFILE FOR NMC

package Plugin::NmcUPS;
use base qw(NZA::Plugin);

$Plugin::CLASS			= 'NmcUPS';

$Plugin::NmcUPS::NAME		= 'nmc-ups';
$Plugin::NmcUPS::DESCRIPTION	= 'UPS monitoring and easy management extension for NMC';
$Plugin::NmcUPS::AUTHOR		= 'Nexenta Systems, Inc';
$Plugin::NmcUPS::LICENSE	= 'Commercial';
$Plugin::NmcUPS::GROUP		= 'ups';
$Plugin::NmcUPS::VERSION	= '0.8';
$Plugin::NmcUPS::LOADER		= 'UPS.pm';
@Plugin::NmcUPS::FILES		= ('UPS.pm');

1;
