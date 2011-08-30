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

##########################################################################
package NZA::UpsConsts;
########################################################################

$NZA::UPS::StateChangedTimeout = 30;

#################################################
# UPS r/w variable indexes
#################################################

$NZA::UPS::RWVarIdxDesc = 0;
$NZA::UPS::RWVarIdxType = 1;
$NZA::UPS::RWVarIdxPossibleValues = 2;

#################################################
# UPS Exceptions
#################################################

$Exception::UPS::UPSWrongAuthInfo = 'UPSWrongAuthInfo';
$Exception::UPS::PortAlreadySpecified = 'PortAlreadySpecified';
$Exception::UPS::DriverNotSupported = 'DriverNotSupported';

#################################################
# Config files
#################################################

$NZA::UPS_CONF_FILE = '/etc/nut/ups.conf';
$NZA::UPSD_USERS_CONF_FILE = '/etc/nut/upsd.users';

#################################################
# General
#################################################

$NZA::UPS = "Ups";
$NZA::UPS::SerialType = 'SERIAL';
$NZA::UPS::USBType = 'USB';

$NZA::UPS::UpsUser = 'nzaups';
$NZA::UPS::PropPassword = 'password';
$NZA::UPS::PropActions = 'actions';
$NZA::UPS::PropAllowfrom = 'allowfrom';
$NZA::UPS::PropInstcmd = 'instcmds';

$NZA::UPS::PropSerial = 'serial';
$NZA::UPS::PropVendorId = 'vendorid';
$NZA::UPS::PropDesc = 'desc';
$NZA::UPS::PropPort = 'port';

$NZA::UPS::ValueYes = 'yes';
$NZA::UPS::ValueNo = 'no';
$NZA::UPS::ValueOn = 'on';
$NZA::UPS::ValueOff = 'off';

#################################################
# UPS Variables
#################################################

########################
# General unit information
########################

# UPS status
# Possible values:
#   OL     - On line
#   OB     - On battery (inverter is providing load power)
#   LB     - Low battery
#   RB     - The battery needs to be replaced
#   BYPASS - UPS bypass circuit is active - no battery protection is available
#   CAL    - UPS is currently performing runtime calibration (on battery)
#   OFF    - UPS is offline and is not supplying power to the load
#   OVER   - UPS is overloaded
#   TRIM   - UPS is trimming incoming voltage (called "buck" in some hardware)
#   BOOST  - UPS is boosting incoming voltage
$NZA::UPS::VAR_UPS_STATUS = "ups.status";
$NZA::UPS::ONLINE_STATUS_OL = "OL";
$NZA::UPS::ONLINE_STATUS_STATUS_OB = "OB";
$NZA::UPS::ONLINE_STATUS_LB = "LB";
$NZA::UPS::ONLINE_STATUS_RB = "RB";
$NZA::UPS::ONLINE_STATUS_BYPASS = "BYPASS";
$NZA::UPS::ONLINE_STATUS_CAL = "CAL";
$NZA::UPS::ONLINE_STATUS_OFF = "OFF";
$NZA::UPS::ONLINE_STATUS_OVER = "OVER";
$NZA::UPS::ONLINE_STATUS_TRIM = "TRIM";
$NZA::UPS::ONLINE_STATUS_BOOST = "BOOST";
%NZA::UPS::ONLINE_STATUSES = (
	$NZA::UPS::ONLINE_STATUS_OL		=> 'On line',
	$NZA::UPS::ONLINE_STATUS_STATUS_OB	=> 'On battery (inverter is providing load power)',
	$NZA::UPS::ONLINE_STATUS_LB		=> 'Low battery',
	$NZA::UPS::ONLINE_STATUS_RB		=> 'The battery needs to be replaced',
	$NZA::UPS::ONLINE_STATUS_BYPASS		=> 'UPS bypass circuit is active - no battery protection is available',
	$NZA::UPS::ONLINE_STATUS_CAL		=> 'UPS is currently performing runtime calibration (on battery)',
	$NZA::UPS::ONLINE_STATUS_OFF		=> 'UPS is offline and is not supplying power to the load',
	$NZA::UPS::ONLINE_STATUS_OVER		=> 'UPS is overloaded',
	$NZA::UPS::ONLINE_STATUS_TRIM		=> 'UPS is trimming incoming voltage (called "buck" in some hardware)',
	$NZA::UPS::ONLINE_STATUS_BOOST		=> 'UPS is boosting incoming voltage',
);

# UPS alarms
# There is no official list of alarm words.
$NZA::UPS::VAR_UPS_ALARM = "ups.alarm";

# Internal UPS clock time
$NZA::UPS::VAR_UPS_TIME = "ups.time";

# Internal UPS clock date
$NZA::UPS::VAR_UPS_DATE = "ups.date";

# UPS model
$NZA::UPS::VAR_UPS_MODEL = "ups.model";

# UPS manufacturer
$NZA::UPS::VAR_UPS_MANUFACTURER = "ups.mfr";

# UPS manufacturing date
$NZA::UPS::VAR_UPS_MANUFACTURING_DATE = "ups.mfr.date";

# UPS serial number
$NZA::UPS::VAR_UPS_SERIAL_NUMBER = "ups.serial";

# Vendor ID for USB devices
$NZA::UPS::VAR_UPS_VENDOR_ID = "ups.vendorid";

# Product ID for USB devices
$NZA::UPS::VAR_UPS_PRODUCT_ID = "ups.productid";

# UPS firmware
$NZA::UPS::VAR_UPS_FIRMWARE = "ups.firmware";

# Auxiliary device firmware
$NZA::UPS::VAR_UPS_FIRMWARE_AUX = "ups.firmware.aux";

# UPS temperature (degrees C)
$NZA::UPS::VAR_UPS_TEMPERATURE = "ups.temperature";

# Load on UPS (percent)
$NZA::UPS::VAR_UPS_LOAD = "ups.load";

# Load when UPS switches to overload condition ("OVER")
$NZA::UPS::VAR_UPS_LOAD_HIGH = "ups.load.high";

# UPS system identifier
$NZA::UPS::VAR_UPS_ID = "ups.id";

# Interval to wait before restarting the load (seconds)
$NZA::UPS::VAR_UPS_DELAY_START = "ups.delay.start";

# Interval to wait before rebooting the UPS (seconds)
$NZA::UPS::VAR_UPS_DELAY_REBOOT = "ups.delay.reboot";

# Interval to wait after shutdown with delay command (seconds)
$NZA::UPS::VAR_UPS_DELAY_SHUTDOWN = "ups.delay.shutdown";

# Interval between self tests (seconds)
$NZA::UPS::VAR_UPS_TEST_INTERVAL = "ups.test.interval";

# Results of last self test
$NZA::UPS::VAR_UPS_TEST_RESULT = "ups.test.result";

# Language to use on front panel
$NZA::UPS::VAR_UPS_DISPLAY_LANG = "ups.display.language";

# UPS external contact sensors
$NZA::UPS::VAR_UPS_CONTACTS = "ups.contacts";

# Current value of apparent power (Volt-Amps)
$NZA::UPS::VAR_UPS_POWER = "ups.power";

# Nominal value of apparent power (Volt-Amps)
$NZA::UPS::VAR_UPS_POWER_NOMINAL = "ups.power.nominal";

# Current value of real power (Watts)
$NZA::UPS::VAR_UPS_REALPOWER = "ups.realpower";

# Nominal value of real power (Watts)
$NZA::UPS::VAR_UPS_REALPOWER_NOMINAL = "ups.realpower.nominal";

# UPS beeper status (enabled, disabled or muted)
$NZA::UPS::VAR_UPS_BEEPER_STATUS = "ups.beeper.status";

# UPS type
$NZA::UPS::VAR_UPS_TYPE = "ups.type";

# UPS watchdog status (enabled or disabled)
$NZA::UPS::VAR_UPS_WATCHDOG_STATUS = "ups.watchdog.status";

# UPS coldstarts from battery (enabled or disabled)
$NZA::UPS::VAR_UPS_COLDSTART = "ups.coldstart";


########################
# Incoming line/power information
########################

# Input voltage
$NZA::UPS::INPUT_VOLTAGE = "input.voltage";

# Maximum incoming voltage seen
$NZA::UPS::INPUT_VOLTAGE_MAX = "input.voltage.maximum";

# Minimum incoming voltage seen
$NZA::UPS::INPUT_VOLTAGE_MIN = "input.voltage.minimum";

# Nominal input voltage
$NZA::UPS::INPUT_VOLTAGE_NOMINAL = "input.voltage.nominal";

# Reason for last transfer to battery
$NZA::UPS::INPUT_TRANSFER_REASON = "input.transfer.reason";

# Low voltage transfer point
$NZA::UPS::INPUT_TRANSFER_LOW = "input.transfer.low";

# High voltage transfer point
$NZA::UPS::INPUT_TRANSFER_HIGH = "input.transfer.high";

# smallest settable low voltage transfer point
$NZA::UPS::INPUT_TRANSFER_LOW_MIN = "input.transfer.low.min";

# greatest settable low voltage transfer point
$NZA::UPS::INPUT_TRANSFER_LOW_MAX = "input.transfer.low.max";

# smallest settable high voltage transfer point
$NZA::UPS::INPUT_TRANSFER_HIGH_MIN = "input.transfer.high.min";

# greatest settable high voltage transfer point
$NZA::UPS::INPUT_TRANSFER_HIGH_MAX = "input.transfer.high.max";

# Input power sensitivity
$NZA::UPS::INPUT_SENSITIVITY = "input.sensitivity";

# Input power quality
$NZA::UPS::INPUT_QUALITY = "input.quality";

# Input line frequency (Hz)
$NZA::UPS::INPUT_FREQUENCY = "input.frequency";

# Nominal input line frequency (Hz)
$NZA::UPS::INPUT_FREQUENCY_NOMINAL = "input.frequency.nominal";

# Input line frequency low (Hz)
$NZA::UPS::INPUT_FREQUENCY_LOW = "input.frequency.low";

# Input line frequency high (Hz)
$NZA::UPS::INPUT_FREQUENCY_HIGH = "input.frequency.high";

# Low voltage boosting transfer point
$NZA::UPS::INPUT_TRANSFER_BOOST_LOW = "input.transfer.boost.low";

# High voltage boosting transfer point
$NZA::UPS::INPUT_TRANSFER_BOOST_HIGH = "input.transfer.boost.high";

# Low voltage trimming transfer point
$NZA::UPS::INPUT_TRANSFER_TRIM_LOW = "input.transfer.trim.low";

# High voltage trimming transfer point
$NZA::UPS::INPUT_TRANSFER_TRIM_HIGH = "input.transfer.trim.high";



########################
# Outgoing power/inverter information
########################

# Output voltage (V)
$NZA::UPS::OUTPUT_VOLTAGE = "output.voltage";

# Nominal output voltage (V)
$NZA::UPS::OUTPUT_VOLTAGE_NOMINAL = "output.voltage.nominal";

# Output frequency (Hz)
$NZA::UPS::OUTPUT_FREQUENCY = "output.frequency";

# Nominal output frequency (Hz)
$NZA::UPS::OUTPUT_FREQUENCY_NOMINAL = "output.frequency.nominal";

# Output current (amps)
$NZA::UPS::OUTPUT_CURRENT = "output.current";



########################
# Any battery details
########################

# Battery charge (percent)
$NZA::UPS::BATTERY_CHARGE = "battery.charge";

# Remaining battery level when UPS switches to LB (percent)
$NZA::UPS::BATTERY_CHARGE_LOW = "battery.charge.low";

# Minimum battery level for UPS restart after power-off
$NZA::UPS::BATTERY_CHARGE_RESTART = "battery.charge.restart";

# Battery level when UPS switches to "Warning" state (percent)
$NZA::UPS::BATTERY_CHARGE_WARNING = "battery.charge.warning";

# Battery voltage (volts)
$NZA::UPS::BATTERY_VOLTAGE = "battery.voltage";

# Battery capacity (Amp - hours)
$NZA::UPS::BATTERY_CAPACITY = "battery.capacity";

# Battery current (amps)
$NZA::UPS::BATTERY_CURRENT = "battery.current";

# Battery temperature (degrees C)
$NZA::UPS::BATTERY_TEMPERATURE = "battery.temperature";

# Nominal battery voltage (V)
$NZA::UPS::BATTERY_VOLTAGE_NOMINAL = "battery.voltage.nominal";

# Battery runtime (seconds)
$NZA::UPS::BATTERY_RUNTIME = "battery.runtime";

# Remaining battery runtime when UPS switches to LB (seconds)
$NZA::UPS::BATTERY_RUNTIME_LOW = "battery.runtime.low";

# Battery alarm threshold
$NZA::UPS::BATTERY_ALARM_THRESHOLD = "battery.alarm.threshold";

# Battery change date
$NZA::UPS::BATTERY_DATE = "battery.date";

# Battery manufacturing date
$NZA::UPS::BATTERY_MANUFACTURING_DATE = "battery.mfr.date";

# Number of battery packs
$NZA::UPS::BATTERY_PACKS_NUM = "battery.packs";

# Number of bad battery packs
$NZA::UPS::BATTERY_BAD_PACKS_NUM = "battery.packs.bad";

# Battery chemistry
$NZA::UPS::BATTERY_TYPE = "battery.type";



########################
# Conditions from external probe equipment
########################

# Ambient temperature (degrees C)
$NZA::UPS::AMBIENT_TEMPERATURE = "ambient.temperature";

# Set if ambient temperature alarm is active (0 - passive, 1 - active)
$NZA::UPS::AMBIENT_TEMPERATURE_ALARM = "ambient.temperature.alarm";

# Maximum allowed temperature
$NZA::UPS::AMBIENT_TEMPERATURE_ALARM_MAX = "ambient.temperature.alarm.maximum";

# Minimum allowed temperature
$NZA::UPS::AMBIENT_TEMPERATURE_ALARM_MIN = "ambient.temperature.alarm.minimum";

# Enable alarm for ambient temperature (0 - disable, 1 - enable)
$NZA::UPS::AMBIENT_TEMPERATURE_ALARM_ENABLE = "ambient.temperature.alarm.enable";

# Ambient relative humidity (percent)
$NZA::UPS::AMBIENT_HUMIDITY = "ambient.humidity";

# Set if ambient humidity alarm is active (0 - passive, 1 - active)
$NZA::UPS::AMBIENT_HUMIDITY_ALARM = "ambient.humidity.alarm";

# Maximum allowed humidity
$NZA::UPS::AMBIENT_HUMIDITY_ALARM_MAX = "ambient.humidity.alarm.maximum";

# Minimum allowed humidity
$NZA::UPS::AMBIENT_HUMIDITY_ALARM_MIN = "ambient.humidity.alarm.minimum";

# Enable alarm for ambient humidity (0 - disable, 1 - enable)
$NZA::UPS::AMBIENT_HUMIDITY_ALARM_ENABLE = "ambient.humidity.alarm.enable";



########################
# Smart outlet management (smart on/off switch, ...)
########################

# Outlet system identifier
$NZA::UPS::OUTLET_ID = "outlet.id";

# Outlet description
$NZA::UPS::OUTLET_DESC = "outlet.desc";

# Outlet switch control (on/off)
$NZA::UPS::OUTLET_SWITCH = "outlet.switch";

# Outlet switch status (on/off)
$NZA::UPS::OUTLET_STATUS = "outlet.status";

# Outlet switch ability (yes/no)
$NZA::UPS::OUTLET_SWITCHABLE = "outlet.switchable";

# Remaining battery level to power off this outlet (percent)
$NZA::UPS::OUTLET_AUTOSWITCH_CHARGE_LOW = "outlet.autoswitch.charge.low";

# Interval to wait before shutting down this outlet (seconds)
$NZA::UPS::OUTLET_DELAY_SHUTDOWN = "outlet.delay.shutdown";

# Interval to wait before restarting this outlet (seconds)
$NZA::UPS::OUTLET_DELAY_START = "outlet.delay.start";

########################
# Internal driver information
########################

# Driver name
$NZA::UPS::DRIVER_NAME = "driver.name";

# Driver version (NUT release)
$NZA::UPS::DRIVER_VERSION = "driver.version";

# Internal driver version (if tracked separately)
$NZA::UPS::DRIVER_INTERNAL_VERSION = "driver.version.internal";



########################
# Instant commands
########################

# Turn off the load immediately
$NZA::UPS::CMD_LOAD_OFF = "load.off";

# Turn on the load immediately
$NZA::UPS::CMD_LOAD_ON = "load.on";

# Turn off the load possibly after a delay and return when power is back
$NZA::UPS::CMD_SHUTDOWN_RETURN = "shutdown.return";

# Turn off the load possibly after a delay and remain off even if power returns
$NZA::UPS::CMD_SHUTDOWN_STAYOFF = "shutdown.stayoff";

# Stop a shutdown in progress
$NZA::UPS::CMD_SHUTDOWN_STOP = "shutdown.stop";

# Shut down the load briefly while rebooting the UPS
$NZA::UPS::CMD_SHUTDOWN_REBOOT = "shutdown.reboot";

# After a delay, shut down the load briefly while rebooting the UPS
$NZA::UPS::CMD_SHUTDOWN_REBOOT_GRACEFUL = "shutdown.reboot.graceful";

# Start testing the UPS panel
$NZA::UPS::CMD_TEST_PANEL_START = "test.panel.start";

# Stop a UPS panel test
$NZA::UPS::CMD_TEST_PANEL_STOP = "test.panel.stop";

# Start a simulated power failure
$NZA::UPS::CMD_TEST_FAILURE_START = "test.failure.start";

# Stop simulating a power failure
$NZA::UPS::CMD_TEST_FAILURE_STOP = "test.failure.stop";

# Start a battery test
$NZA::UPS::CMD_TEST_BATTERY_START = "test.battery.start";

# Start a "quick" battery test
$NZA::UPS::CMD_TEST_BATTERY_START_QUICK = "test.battery.start.quick";

# Start a "deep" battery test
$NZA::UPS::CMD_TEST_BATTERY_START_DEEP = "test.battery.start.deep";

# Stop the battery test
$NZA::UPS::CMD_TEST_BATTERY_STOP = "test.battery.stop";

# Start runtime calibration
$NZA::UPS::CMD_CALIBRATE_START = "calibrate.start";

# Stop runtime calibration
$NZA::UPS::CMD_CALIBRATE_STOP = "calibrate.stop";

# Put the UPS in bypass mode
$NZA::UPS::CMD_BYPASS_START = "bypass.start";

# Take the UPS out of bypass mode
$NZA::UPS::CMD_BYPASS_STOP = "bypass.stop";

# Reset minimum and maximum input voltage status
$NZA::UPS::CMD_RESET_INPUT_MINMAX = "reset.input.minmax";

# Reset watchdog timer (forced reboot of load)
$NZA::UPS::CMD_RESET_WATCHDOG = "reset.watchdog";

# Enable UPS beeper/buzzer
$NZA::UPS::CMD_BEEPER_ON = "beeper.on";

# Temporarily mute UPS beeper/buzzer
$NZA::UPS::CMD_BEEPER_OFF = "beeper.off";

# Toggle UPS beeper/buzzer
$NZA::UPS::CMD_BEEPER_TOGGLE = "beeper.toggle";



#################################################
# UPS Drivers
#################################################

# Parameters for all drivers
%NZA::UPS::DRV::REQ_PARAMS = (
	"driver" => "This specifies which program will be monitoring this UPS.",
	"port" => "This is the serial port where the UPS is connected.",
);
%NZA::UPS::DRV::OPT_PARAMS = (
	"sdorder" => "When  you have multiple UPSes on your system, you usually need to turn them off in a certain order.",
	"desc" => "This allows you to set a brief description that upsd will provide to clients that ask for a list  of  connected equipment.",
	"nolock" => "When  you specify this, the driver skips the port locking routines every time it starts.",
	"maxstartdelay" => "This can be set as a global variable above your first UPS definition and it can also be set in a  UPS  section.",
);

# Driver for American Power Conversion Smart Protocol UPS equipment
$NZA::UPS::DRV_APCSMART = "apcsmart";
%NZA::UPS::DRV_APCSMART::OPT_PARAMS = (
	"cable" => "Configure the serial port for the APC 940-0095B dual-mode cable.",
	"sdtype" => "Shutdown type",
);
%NZA::UPS::DRV_APCSMART::DESC = (
	'name' => 'American Power Conversion Smart Protocol UPS equipment',
	'optparams' => \%NZA::UPS::DRV_APCSMART::OPT_PARAMS,
);

# Driver for UPS'es supporting the BCM/XCP protocol
$NZA::UPS::DRV_BCMXCP = "bcmxcp";
%NZA::UPS::DRV_BCMXCP::OPT_PARAMS = (
	"shutdown_delay" => "The number of seconds that the UPS should wait between receiving the shutdown command (OB LB) and actually shutting off.",
	"baud_rate" => "Communication  speed for the UPS.",
);
%NZA::UPS::DRV_BCMXCP::DESC = (
	'name' => 'UPS\'es supporting the BCM/XCP protocol',
	'optparams' => \%NZA::UPS::DRV_BCMXCP::OPT_PARAMS,
);

# Experimental driver for UPS'es supporting the BCM/XCP protocol over USB
$NZA::UPS::DRV_BCMXCP_USB = "bcmxcp_usb";
%NZA::UPS::DRV_BCMXCP_USB::OPT_PARAMS = (
	"shutdown_delay" => "The number of seconds that the UPS should wait between receiving the shutdown command and actually shutting off.",
);
%NZA::UPS::DRV_BCMXCP_USB::DESC = (
	'name' => 'UPS\'es supporting the BCM/XCP protocol over USB',
	'optparams' => \%NZA::UPS::DRV_BCMXCP_USB::OPT_PARAMS,
);

# Driver for Belkin serial UPS equipment
$NZA::UPS::DRV_BELKIN = "belkin";
%NZA::UPS::DRV_BELKIN::OPT_PARAMS = ();
%NZA::UPS::DRV_BELKIN::DESC = (
	'name' => 'Belkin serial UPS equipment',
	'optparams' => \%NZA::UPS::DRV_BELKIN::OPT_PARAMS,
);

# Driver for Belkin "Universal UPS" and compatible
$NZA::UPS::DRV_BELKINUNV = "belkinunv";
%NZA::UPS::DRV_BELKINUNV::OPT_PARAMS = ();
%NZA::UPS::DRV_BELKINUNV::DESC = (
	'name' => 'Belkin "Universal UPS" and compatible',
	'optparams' => \%NZA::UPS::DRV_BELKINUNV::OPT_PARAMS,
);

# Driver for Best Power Fortress/Ferrups
$NZA::UPS::DRV_BESTFCOM = "bestfcom";
%NZA::UPS::DRV_BESTFCOM::OPT_PARAMS = ();
%NZA::UPS::DRV_BESTFCOM::DESC = (
	'name' => 'Best Power Fortress/Ferrups',
	'optparams' => \%NZA::UPS::DRV_BESTFCOM::OPT_PARAMS,
);

# Driver for Best Power Micro-Ferrups
$NZA::UPS::DRV_BESTUFERRUPS = "bestuferrups";
%NZA::UPS::DRV_BESTUFERRUPS::OPT_PARAMS = ();
%NZA::UPS::DRV_BESTUFERRUPS::DESC = (
	'name' => 'Best Power Micro-Ferrups',
	'optparams' => \%NZA::UPS::DRV_BESTUFERRUPS::OPT_PARAMS,
);

# Driver for Best Power / SOLA (Phoenixtec protocol) UPS equipment
$NZA::UPS::DRV_BESTUPS = "bestups";
%NZA::UPS::DRV_BESTUPS::OPT_PARAMS = (
	"nombattvolt" => "Override the nominal battery voltage which is normally determined by asking the hardware.",
	"ID" => "Set the Identification response string.",
);
%NZA::UPS::DRV_BESTUPS::DESC = (
	'name' => 'Best Power / SOLA (Phoenixtec protocol) UPS equipment',
	'optparams' => \%NZA::UPS::DRV_BESTUPS::OPT_PARAMS,
);

# Driver for newer model CyberPower UPSs
$NZA::UPS::DRV_CPSUPS = "cpsups";
%NZA::UPS::DRV_CPSUPS::OPT_PARAMS = ();
%NZA::UPS::DRV_CPSUPS::DESC = (
	'name' => 'Newer model CyberPower UPSs',
	'optparams' => \%NZA::UPS::DRV_CPSUPS::OPT_PARAMS,
);

# Serial Driver for most Cyber Power Systems UPS equipment
$NZA::UPS::DRV_CYBERPOWER = "cyberpower";
%NZA::UPS::DRV_CYBERPOWER::OPT_PARAMS = ();
%NZA::UPS::DRV_CYBERPOWER::DESC = (
	'name' => 'Most Cyber Power Systems UPS equipment',
	'optparams' => \%NZA::UPS::DRV_CYBERPOWER::OPT_PARAMS,
);

# Driver for ETA UPS equipment
$NZA::UPS::DRV_ETAPRO = "etapro";
%NZA::UPS::DRV_ETAPRO::OPT_PARAMS = ();
%NZA::UPS::DRV_ETAPRO::DESC = (
	'name' => 'ETA UPS equipment',
	'optparams' => \%NZA::UPS::DRV_ETAPRO::OPT_PARAMS,
);

# Driver for Ever UPS models
$NZA::UPS::DRV_EVERUPS = "everups";
%NZA::UPS::DRV_EVERUPS::OPT_PARAMS = ();
%NZA::UPS::DRV_EVERUPS::DESC = (
	'name' => 'Ever UPS models',
	'optparams' => \%NZA::UPS::DRV_EVERUPS::OPT_PARAMS,
);

# Driver for Gamatronic UPS equipment
$NZA::UPS::DRV_GAMATRONIC = "gamatronic";
%NZA::UPS::DRV_GAMATRONIC::OPT_PARAMS = ();
%NZA::UPS::DRV_GAMATRONIC::DESC = (
	'name' => 'Gamatronic UPS equipment',
	'optparams' => \%NZA::UPS::DRV_GAMATRONIC::OPT_PARAMS,
);

# Driver for contact-closure UPS equipment
$NZA::UPS::DRV_GENERICUPS = "genericups";
%NZA::UPS::DRV_GENERICUPS::OPT_PARAMS = (
	"upstype" => "Configures  the  driver  for  a specific kind of UPS.",
	"mfr" => "The very nature of a generic UPS driver sometimes means that the stock manufacturer data has no relation to the actual  hardware  that  is  attached.",
	"model" => "This is like mfr above, but it overrides the model string instead.",
	"serial" => "This is like mfr above and intended to record the identification string of the UPS.",
	"sdtime" => "The  driver  will  sleep  for this many seconds after setting the shutdown signal.",
);
%NZA::UPS::DRV_GENERICUPS::DESC = (
	'name' => 'Contact-closure UPS equipment',
	'optparams' => \%NZA::UPS::DRV_GENERICUPS::OPT_PARAMS,
);

# Driver for ISBMEX UPS equipment
$NZA::UPS::DRV_ISBMEX = "isbmex";
%NZA::UPS::DRV_ISBMEX::OPT_PARAMS = ();
%NZA::UPS::DRV_ISBMEX::DESC = (
	'name' => 'ISBMEX UPS equipment',
	'optparams' => \%NZA::UPS::DRV_ISBMEX::OPT_PARAMS,
);

# Driver for Liebert contact-closure UPS equipment
$NZA::UPS::DRV_LIEBERT = "liebert";
%NZA::UPS::DRV_LIEBERT::OPT_PARAMS = ();
%NZA::UPS::DRV_LIEBERT::DESC = (
	'name' => 'Liebert contact-closure UPS equipment',
	'optparams' => \%NZA::UPS::DRV_LIEBERT::OPT_PARAMS,
);

# Driver for Masterguard UPS equipment
$NZA::UPS::DRV_MASTERGUARD = "masterguard";
%NZA::UPS::DRV_MASTERGUARD::OPT_PARAMS = ();
%NZA::UPS::DRV_MASTERGUARD::DESC = (
	'name' => 'Masterguard UPS equipment',
	'optparams' => \%NZA::UPS::DRV_MASTERGUARD::OPT_PARAMS,
);

# Driver for Megatec protocol based UPS equipment
$NZA::UPS::DRV_MEGATEC = "megatec";
%NZA::UPS::DRV_MEGATEC::OPT_PARAMS = (
	"mfr" => "Specify the UPS manufacturer name.",
	"model" => "Specify the UPS model name.",
	"serial" => "Specify the UPS serial number.",
	"offdelay" => "After receiving a shutdown command, the UPS will wait this many minutes before turning off  the  load.",
	"ondelay" => "After turning off the load (see offdelay), the UPS will wait at least this  many  minutes  before  coming  back online.",
	"lowbatt" => "Low battery level (%). Overrides the hardware default level.",
	"battvolts" => "The battery voltage interval",
);
%NZA::UPS::DRV_MEGATEC::DESC = (
	'name' => 'Megatec protocol based UPS equipment',
	'optparams' => \%NZA::UPS::DRV_MEGATEC::OPT_PARAMS,
);

# Driver for Meta System UPS equipment
$NZA::UPS::DRV_METASYS = "metasys";
%NZA::UPS::DRV_METASYS::OPT_PARAMS = ();
%NZA::UPS::DRV_METASYS::DESC = (
	'name' => 'Meta System UPS equipment',
	'optparams' => \%NZA::UPS::DRV_METASYS::OPT_PARAMS,
);

# Driver for MGE UPS serial SHUT Protocol UPS equipment
$NZA::UPS::DRV_MGE_SHUT = "mge-shut";
%NZA::UPS::DRV_MGE_SHUT::OPT_PARAMS = (
	"lowbatt" => "Set  the  low  battery warning threshold.",
	"offdelay" => "Set the timer before the UPS is turned off after the kill power command is sent (via the -k switch).",
	"ondelay" => "Set the timer for the UPS to switch on in case the power returns after the kill power command had been sent but before the actual switch off.",
	"notification" => "Set  notification type",
);
%NZA::UPS::DRV_MGE_SHUT::DESC = (
	'name' => 'MGE UPS serial SHUT Protocol UPS equipment',
	'optparams' => \%NZA::UPS::DRV_MGE_SHUT::OPT_PARAMS,
);

# Driver for MGE UPS SYSTEMS UTalk protocol hardware
$NZA::UPS::DRV_MGE_UTALK = "mge-utalk";
%NZA::UPS::DRV_MGE_UTALK::OPT_PARAMS = (
	"lowbatt" => "Low battery level below which LB is raised.",
	"ondelay" => "Set delay before startup, in minutes.",
	"offdelay" => "Delay before shutdown, in seconds",
);
%NZA::UPS::DRV_MGE_UTALK::DESC = (
	'name' => 'MGE UPS SYSTEMS UTalk protocol hardware',
	'optparams' => \%NZA::UPS::DRV_MGE_UTALK::OPT_PARAMS,
);

# Driver for USB/HID UPS equipment
$NZA::UPS::DRV_USBHID_UPS = "usbhid-ups";
%NZA::UPS::DRV_USBHID_UPS::OPT_PARAMS = (
	"offdelay" => "Set the timer before the UPS is turned off after the kill power command is sent.",
	"ondelay" => "Set the timer for the UPS to switch on in case the power returns after the kill power command had been sent but before the actual  switch off.",
	"pollfreq" => "Set polling frequency, in seconds, to reduce the USB data flow.",
	"vendor" => "Regex for vendor",
	"product" => "Regex for product name",
	"serial" => "Regex for product serial number",
	"vendorid" => "Regex for vector id",
	"productid" => "Select  a  specific  UPS,  in  case  there  is  more than one connected via USB.",
	"bus" => "Select  a  UPS on a specific USB bus or group of busses.",
	"explore" => "With this option, the driver will connect to any device, including ones that are not yet supported.",
);
%NZA::UPS::DRV_USBHID_UPS::DESC = (
	'name' => 'USB/HID UPS equipment',
	'optparams' => \%NZA::UPS::DRV_USBHID_UPS::OPT_PARAMS,
);

# Driver for Oneac UPS equipment
$NZA::UPS::DRV_ONEAC = "oneac";
%NZA::UPS::DRV_ONEAC::OPT_PARAMS = (
	"testtime" => "Change battery test time from the 2 minute default.",
);
%NZA::UPS::DRV_ONEAC::DESC = (
	'name' => 'Oneac UPS equipment',
	'optparams' => \%NZA::UPS::DRV_ONEAC::OPT_PARAMS,
);

# UPS driver for Powercom/Trust/Advice UPS equipment
$NZA::UPS::DRV_POWERCOM = "powercom";
%NZA::UPS::DRV_POWERCOM::OPT_PARAMS = (
	"linevoltage" => "An  integer  specifying  the  mains  voltage. It can't be auto detected.",
	"manufacturer" => "Specify the manufacturer name, which also can't be auto detected.",
	"modelname" => "Specify  the  model  name, which also can't be auto detected.",
	"serialnumber" => "Like modelname above, but for the serial number.",
	"type" => "The exact type of the communication protocol within the powercom family, that will be used to communicate  with  the  UPS.",
	"numOfBytesFromUPS" => "The number of bytes in a UPS frame. The default is type dependant and is given below.",
	"voltage" => "A quad that is used convert the raw data to human readable voltage reading.",
	"methodOfFlowControl" => "The  method  of  serial  communication flow control that is engaged by the UPS.",
	"frequency" => "A pair to convert the raw data to human readable frequency reading.",
	"batteryPercentage" => "A 5 tuple to convert the raw data to human readable battery percentage reading.",
	"loadPercentage" => "A quad to convert the raw data to human readable load percentage reading.",
	"validationSequence" => "3  pairs  to  be  used for validating the UPS by comparing bytes of the raw data with constant values.",
	"shutdownArguments" => "The minutes and seconds that the UPS should wait between receiving the shutdown command and  actually  shutting  off.",
);
%NZA::UPS::DRV_POWERCOM::DESC = (
	'name' => 'Powercom/Trust/Advice UPS equipment',
	'optparams' => \%NZA::UPS::DRV_POWERCOM::OPT_PARAMS,
);

# Driver for Brazilian Microsol RHINO UPS equipment
$NZA::UPS::DRV_RHINO = "rhino";
%NZA::UPS::DRV_RHINO::OPT_PARAMS = (
	"battext" => "(default = 0, no extra battery, where n = Ampere*hour )",
);
%NZA::UPS::DRV_RHINO::DESC = (
	'name' => 'Brazilian Microsol RHINO UPS equipment',
	'optparams' => \%NZA::UPS::DRV_RHINO::OPT_PARAMS,
);

# Driver for SafeNet compatible UPS equipment
$NZA::UPS::DRV_SAFENET = "safenet";
%NZA::UPS::DRV_SAFENET::OPT_PARAMS = (
	"manufacturer" => "Autodetection of this parameter is not possible yet (and it probably never will be).",
	"modelname" => "UPS model name",
	"serialnumber" => "Serial number of UPS",
);
%NZA::UPS::DRV_SAFENET::DESC = (
	'name' => 'SafeNet compatible UPS equipment',
	'optparams' => \%NZA::UPS::DRV_SAFENET::OPT_PARAMS,
);

# SNMP UPS Driver
$NZA::UPS::DRV_SNMP_UPS = "snmp-ups";
%NZA::UPS::DRV_SNMP_UPS::OPT_PARAMS = ();
%NZA::UPS::DRV_SNMP_UPS::DESC = (
	'name' => 'SNMP UPS',
	'optparams' => \%NZA::UPS::DRV_SNMP_UPS::OPT_PARAMS,
);

# Driver for Brazilian Microsol SOLIS UPS equipment
$NZA::UPS::DRV_SOLIS = "solis";
%NZA::UPS::DRV_SOLIS::OPT_PARAMS = (
	"battext" => "(default = 0, no extra battery, where n = Ampere*hour )",
	"prgshut" => "(default = 0, no programable shutdown )",
);
%NZA::UPS::DRV_SOLIS::DESC = (
	'name' => 'Brazilian Microsol SOLIS UPS equipment',
	'optparams' => \%NZA::UPS::DRV_SOLIS::OPT_PARAMS,
);

# Driver for Tripp-Lite SmartPro UPS equipment
$NZA::UPS::DRV_TRIPPLITE = "tripplite";
%NZA::UPS::DRV_TRIPPLITE::OPT_PARAMS = (
	"offdelay" => "Time to wait before the UPS is turned off after the kill power command is sent.",
	"rebootdelay" => "Set the timer before the UPS is cycled after the reboot command is sent.",
	"startdelay" => "Set  the  time that the UPS waits before it turns itself back on after a reboot command.",
);
%NZA::UPS::DRV_TRIPPLITE::DESC = (
	'name' => 'Tripp-Lite SmartPro UPS equipment',
	'optparams' => \%NZA::UPS::DRV_TRIPPLITE::OPT_PARAMS,
);

# Driver for Tripp-Lite SmartOnline (SU) UPS equipment
$NZA::UPS::DRV_TRIPPLITESU = "tripplitesu";
%NZA::UPS::DRV_TRIPPLITESU::OPT_PARAMS = (
	"lowbatt" => "Set the low battery warning threshold in percent at which shutdown.",
);
%NZA::UPS::DRV_TRIPPLITESU::DESC = (
	'name' => 'Tripp-Lite SmartOnline (SU) UPS equipment',
	'optparams' => \%NZA::UPS::DRV_TRIPPLITESU::OPT_PARAMS,
);

# Driver for older Tripp Lite USB UPSes (non-PDC HID)
$NZA::UPS::DRV_TRIPPLITE_USB = "tripplite_usb";
%NZA::UPS::DRV_TRIPPLITE_USB::OPT_PARAMS = (
	"offdelay" => "This setting controls the delay between receiving the \"kill\" command (\"-k\") and actually cutting power to the computer.",
	"bus" => "This regular expression is used to match the USB bus.",
	"product" => "A regular expression to match the product string for the UPS.",
	"productid" => "The productid is a regular expression which matches the UPS PID as four hexadecimal digits.",
	"serial" => "It does not appear that these particular Tripp Lite UPSes use the iSerial descriptor field to return a serial number.",
);
%NZA::UPS::DRV_TRIPPLITE_USB::DESC = (
	'name' => 'Older Tripp Lite USB UPSes (non-PDC HID)',
	'optparams' => \%NZA::UPS::DRV_TRIPPLITE_USB::OPT_PARAMS,
);

# Driver for UPScode II compatible UPS equipment
$NZA::UPS::DRV_UPSCODE2 = "upscode2";
%NZA::UPS::DRV_UPSCODE2::OPT_PARAMS = (
	"manufacturer" => "Manufacturer name",
	"input_timeout" => "The timeout waiting for a response from the UPS.",
	"output_pace" => "Delay between characters sent to the UPS.",
	"baudrate" => "The default baudrate is 1200, which is the standard for the UPScode II protocol.",
	"full_update_timer" => "Number of seconds between collection of normative values.",
	"use_crlf" => "Flag to set if commands towards to UPS need to be terminated with CR-LF, and not just CR.",
	"use_pre_lf" => "Flag to set if commands towards to UPS need to be introduced with an LF.",
);
%NZA::UPS::DRV_UPSCODE2::DESC = (
	'name' => 'UPScode II compatible UPS equipment',
	'optparams' => \%NZA::UPS::DRV_UPSCODE2::OPT_PARAMS,
);

# Driver for IMV/Victron UPS unit Match, Match Lite, NetUps
$NZA::UPS::DRV_VICTRONUPS = "victronups";
%NZA::UPS::DRV_VICTRONUPS::OPT_PARAMS = (
	"modelname" => "Set model name",
	"usd" => "Set delay before shutdown on UPS",
);
%NZA::UPS::DRV_VICTRONUPS::DESC = (
	'name' => 'IMV/Victron UPS unit Match, Match Lite, NetUps',
	'optparams' => \%NZA::UPS::DRV_VICTRONUPS::OPT_PARAMS,
);

# Driver for Megatec protocol based USB UPS equipment
$NZA::UPS::DRV_MEGATEC_USB = 'megatec_usb';
%NZA::UPS::DRV_MEGATEC_USB::OPT_PARAMS = (
	'mfr' => 'Specify the UPS manufacturer name.',
	'model' => 'Specify the UPS model name.',
	'serial' => 'Specify the UPS serial number.',
	'lowbat' => 'Low battery level (%). Overrides the hardware default level.',
	'ondelay' => 'Delay before the UPS is turned back on (minutes).',
	'offdelay' => 'Delay before the UPS is turned off (minutes).',
	'battvolts' => 'The battery voltage interval (volts).',
	"vendor" => "Regex for vendor",
	"product" => "Regex for product name",
	"vendorid" => "Regex for vector id",
	"productid" => "Select  a  specific  UPS,  in  case  there  is  more than one connected via USB.",
	'bus' => 'Select a UPS on a specific USB bus or group of busses. The argument is a regular expression that must match the bus name where the UPS is connected (e.g. bus="002", bus="00[2-3]").',
	'subdriver' => 'Select a serial-over-USB subdriver to use. You have a choice between "agiler" and "krauler" subdrivers currently.',
);
%NZA::UPS::DRV_MEGATEC_USB::DESC = (
	'name' => 'Driver for Megatec protocol based USB UPS equipment',
	'optparams' => \%NZA::UPS::DRV_MEGATEC_USB::OPT_PARAMS,
);

# Serial port UPSes
%NZA::UPS::SERIAL_UPSES = (
	$NZA::UPS::DRV_APCSMART => \%NZA::UPS::DRV_APCSMART::DESC,
	$NZA::UPS::DRV_BCMXCP => \%NZA::UPS::DRV_BCMXCP::DESC,
	$NZA::UPS::DRV_BELKIN => \%NZA::UPS::DRV_BELKIN::DESC,
	$NZA::UPS::DRV_BELKINUNV => \%NZA::UPS::DRV_BELKINUNV::DESC,
	$NZA::UPS::DRV_BESTFCOM => \%NZA::UPS::DRV_BESTFCOM::DESC,
	$NZA::UPS::DRV_BESTUFERRUPS => \%NZA::UPS::DRV_BESTUFERRUPS::DESC,
	$NZA::UPS::DRV_BESTUPS => \%NZA::UPS::DRV_BESTUPS::DESC,
	$NZA::UPS::DRV_CPSUPS => \%NZA::UPS::DRV_CPSUPS::DESC,
	$NZA::UPS::DRV_CYBERPOWER => \%NZA::UPS::DRV_CYBERPOWER::DESC,
	$NZA::UPS::DRV_ETAPRO => \%NZA::UPS::DRV_ETAPRO::DESC,
	$NZA::UPS::DRV_EVERUPS => \%NZA::UPS::DRV_EVERUPS::DESC,
	$NZA::UPS::DRV_GAMATRONIC => \%NZA::UPS::DRV_GAMATRONIC::DESC,
	$NZA::UPS::DRV_GENERICUPS => \%NZA::UPS::DRV_GENERICUPS::DESC,
	$NZA::UPS::DRV_ISBMEX => \%NZA::UPS::DRV_ISBMEX::DESC,
	$NZA::UPS::DRV_LIEBERT => \%NZA::UPS::DRV_LIEBERT::DESC,
	$NZA::UPS::DRV_MASTERGUARD => \%NZA::UPS::DRV_MASTERGUARD::DESC,
	$NZA::UPS::DRV_MEGATEC => \%NZA::UPS::DRV_MEGATEC::DESC,
	$NZA::UPS::DRV_METASYS => \%NZA::UPS::DRV_METASYS::DESC,
	$NZA::UPS::DRV_MGE_SHUT => \%NZA::UPS::DRV_MGE_SHUT::DESC,
	$NZA::UPS::DRV_MGE_UTALK => \%NZA::UPS::DRV_MGE_UTALK::DESC,
	$NZA::UPS::DRV_ONEAC => \%NZA::UPS::DRV_ONEAC::DESC,
	$NZA::UPS::DRV_POWERCOM => \%NZA::UPS::DRV_POWERCOM::DESC,
	$NZA::UPS::DRV_RHINO => \%NZA::UPS::DRV_RHINO::DESC,
	$NZA::UPS::DRV_SAFENET => \%NZA::UPS::DRV_SAFENET::DESC,
	$NZA::UPS::DRV_SOLIS => \%NZA::UPS::DRV_SOLIS::DESC,
	$NZA::UPS::DRV_TRIPPLITE => \%NZA::UPS::DRV_TRIPPLITE::DESC,
	$NZA::UPS::DRV_TRIPPLITESU => \%NZA::UPS::DRV_TRIPPLITESU::DESC,
	$NZA::UPS::DRV_UPSCODE2 => \%NZA::UPS::DRV_UPSCODE2::DESC,
	$NZA::UPS::DRV_VICTRONUPS => \%NZA::UPS::DRV_VICTRONUPS::DESC,
);

# USB port UPSes
%NZA::UPS::USB_UPSES = (
	$NZA::UPS::DRV_USBHID_UPS => \%NZA::UPS::DRV_USBHID_UPS::DESC,
	$NZA::UPS::DRV_TRIPPLITE_USB => \%NZA::UPS::DRV_TRIPPLITE_USB::DESC,
	$NZA::UPS::DRV_MEGATEC_USB => \%NZA::UPS::DRV_MEGATEC_USB::DESC,
);

1;

