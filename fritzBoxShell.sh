#!/bin/bash
# shellcheck disable=SC1090,SC2154

# Protokoll TR-064 was used to control the Fritz!Box and

# http://fritz.box:49000/tr64desc.xml
# https://wiki.fhem.de/wiki/FRITZBOX#TR-064
# https://avm.de/service/schnittstellen/

deviceinfo() {

	do=Dokumente
	p=$(cat $ho/$do/irule)

	location=/upnp/control/deviceinfo
	uri="urn:dslforum-org:service:DeviceInfo:1"
	action=GetInfo

### -- General function for sending the SOAP request via TR-064 Protocol - called from other functions -- ###

	curlOutput1=$(curl -s -k -m 5 --anyauth -u "$user:$p" "http://$boxip:49000$location" -H 'Content-Type: text/xml; charset="utf-8"' -H "SoapAction:$uri#$action" -d "<?xml version='1.0' encoding='utf-8'?><s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'><s:Body><u:$action xmlns:u='$uri'></u:$action></s:Body></s:Envelope>") 
	# | grep "<New" | awk -F"</" '{print $1}' | sed -En "s/<(.*)>(.*)/\1 \2/p"
	
	echo $curlOutput1
}

version=1.0.5
ho=$HOME
fb_folder=$ho/fritzbox
source $fb_folder/config.sh
# echo pw $boxpw

deviceinfo

wlanstate() {
	echo $boxip
	# Building inputs for the SOAP Action based on which WiFi to switch ON/OFF
	# option1=2g
	option=0
	# if [ "$option1" = "2g" ] || [ "$option1" = "wlan" ]; then
	location="/upnp/control/wlanconfig1"
	uri="urn:dslforum-org:service:WLANConfiguration:1"
	action=SetEnable

	if [ "$option2" = "0" ] || [ "$option2" = "1" ]; then curl -k -m 5 "http://$boxip:49000$location" -H 'Content-Type: text/xml; charset="utf-8"' -H "SoapAction:$uri#$action" -d "<?xml version='1.0' encoding='utf-8'?><s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'><s:Body><u:$action xmlns:u='$uri'><NewEnable>$option</NewEnable></u:$action></s:Body></s:Envelope>" -s >/dev/null; fi # Changing the state of the WIFI

	action=GetInfo
	curlOutput1=$(curl -s -k -m 5 "http://$boxip:49000$location" -H 'Content-Type: text/xml; charset="utf-8"' -H "SoapAction:$uri#$action" -d "<?xml version='1.0' encoding='utf-8'?><s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'><s:Body><u:$action xmlns:u='$uri'></u:$action></s:Body></s:Envelope>" | grep NewEnable | awk -F">" '{print $2}' | awk -F"<" '{print $1}')

	curlOutput2=$(curl -s -k -m 5 "http://$boxip:49000$location" -H 'Content-Type: text/xml; charset="utf-8"' -H "SoapAction:$uri#$action" -d "<?xml version='1.0' encoding='utf-8'?><s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'><s:Body><u:$action xmlns:u='$uri'></u:$action></s:Body></s:Envelope>" | grep NewSSID | awk -F">" '{print $2}' | awk -F"<" '{print $1}')
	echo "2,4 Ghz $curlOutput2 ist $curlOutput1"
	# fi
}
# wlanstate

DisplayArguments() {
	echo "Invalid Action and/or parameter $option1. Possible combinations:"
	echo "|---------|------------------|-----------|"
	echo "|  Action  | Parameter       | Description  |"
	echo "|--------------|-------------|----------------------|"
	echo "| info   | state    | info about Fritz!Box like ModelName, SN, etc. |"
	echo "| 2g   | 0 or 1 or state | ON, OFF or checking state WiFi   |"
	echo "| 2g    | STATISTICS      | WiFi digestible by telegraf  |"
	echo "| wlan_5g      | 0 or 1 or state        | ON, OFF, state 5 Ghz WiFi|"
	echo "| wlan_5g      | STATISTICS | digestible by telegraf             |"
	echo "| wlan         | 0 or 1 or state  |  2,4Ghz and 5 Ghz WiFi    |"
	echo "|--------------|-------------------------|"
	echo "| LED   | 0 or 1 | Switching ON (1) or OFF (0) LEDs in front |"
	echo "| KEYLOCK      | 0 or 1  | Activate (1) or  (0) the Keylock buttons |"
	echo "|--------------|------------------|"
	echo "| LAN    | state  | Statistics digestible by telegraf  |"
	echo "| DSL  | state  | Statistics digestible by telegraf  |"
	echo "| WAN          | state   | Statistics  digestible by telegraf  |"
	echo "| LINK         | state  | Statistics WAN DSL LINK digble by telegraf|"
	echo "| IGDWAN       | state   | WAN LINK digestible by telegraf   |"
	echo "| IGDDSL       | state   | DSL LINK digestible by telegraf  |"
	echo "| IGDIP        | state  | Statistics for the DSL IP by telegraf    |"
	echo "| REBOOT       | Box	    | Rebooting Fritz!Box	|"
	echo "| UPNPMetaData | state or <filename>    | Full unformatted output of tr64desc.xml to console or file |"
	echo "| IGDMetaData  | state or <filename>    | Full unformatted output of igddesc.xml to console or file |"
	echo "|--------------|------------------------|"
	echo "| version      | | Version of the fritzBoxShell.sh   |"
	echo "|--------------|-----------------|------------|"
	echo ""
}

# dir=$(dirname "$0")

# Parsing arguments
# ./fritzBoxShell.sh --boxip 192.168.178.1 --boxuser foo --boxpw baa 2g 1
POSITIONAL=()
while [[ $# -gt 0 ]]; do
	key="$1"

	case $key in
	--boxip)
		boxip="$2"
		shift
		shift
		;;
	--boxuser)
		boxuser="$2"
		shift
		shift
		;;
	--boxpw)
		boxpw="$2"
		shift
		shift
		;;
	*)                  # unknown option
		POSITIONAL+=("$1") # save it in an array for later
		shift              # past argument
		;;
	esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters

# Storing shell parameters in variables
# Example:
# ./fritzBoxShell.sh 2g 1
# $1 = "2g"
# $2 = "1"

option1="$1"
option2="$2"
option3="$3"

### --------- FUNCTION getSID is used to get a SID for all requests through AHA-HTTP-Interface----------- ###
### ------------------------------- SID is stored then in global variable ------------------------------- ###

# Global variable for SID
SID=""

getSID() {
	location="/upnp/control/deviceconfig"
	uri="urn:dslforum-org:service:DeviceConfig:1"
	action='X_AVM-DE_CreateUrlSID'

	SID=$(curl -s -k -m 5 --anyauth -u "$boxuser:$boxpw" "http://$boxip:49000$location" -H 'Content-Type: text/xml; charset="utf-8"' -H "SoapAction:$uri#$action" -d "<?xml version='1.0' encoding='utf-8'?><s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'><s:Body><u:$action xmlns:u='$uri'></u:$action></s:Body></s:Envelope>" | grep "NewX_AVM-DE_UrlSID" | awk -F">" '{print $2}' | awk -F"<" '{print $1}' | awk -F"=" '{print $2}')
}

### ----------- FUNCTION LEDswitch FOR SWITCHING ON OR OFF THE LEDS IN front of the Fritz!Box ----------- ###
### ----------------------------- Here the TR-064 protocol cannot be used. ------------------------------ ###
### ---------------------------------------- AHA-HTTP-Interface ----------------------------------------- ###

LEDswitch() {
	# Get the a valid SID
	getSID

	if [ "$option2" = "0" ]; then LEDstate=2; fi # When
	if [ "$option2" = "1" ]; then LEDstate=0; fi

	# led_display=0 -> ON
	# led_display=1 -> DELAYED ON (20200106: not really slower that option 0 - NOT USED)
	# led_display=2 -> OFF
	wget -O - --post-data sid=$SID\&led_display=$LEDstate\&apply= http://$boxip/system/led_display.lua 2>/dev/null
	if [ "$option2" = "0" ]; then echo "LEDs switched OFF"; fi
	if [ "$option2" = "1" ]; then echo "LEDs switched ON"; fi

	# Logout the "used" SID
	wget -O - "http://$boxip/home/home.lua?sid=$SID&logout=1" &>/dev/null
}

### --------- FUNCTION keyLockSwitch FOR ACTIVATING or DEACTIVATING the buttons on the Fritz!Box -------- ###
### ------ Here the TR-064 protocol cannot be used. - ###
### --------AHA-HTTP-Interface------------ ###

keyLockSwitch() {
	# Get the a valid SID
	getSID
	wget -O - --post-data sid=$SID\&keylock_enabled=$option2\&apply= http://$boxip/system/keylocker.lua 2>/dev/null
	if [ "$option2" = "0" ]; then echo "KeyLock NOT active"; fi
	if [ "$option2" = "1" ]; then echo "KeyLock active"; fi

	# Logout the "used" SID
	wget -O - "http://$boxip/home/home.lua?sid=$SID&logout=1" &>/dev/null
}


### ---- FUNCTION UPNPMetaData - TR-064 Protocol -- ###

UPNPMetaData() {
	location="/tr64desc.xml"

	if [ "$option2" = "state" ]; then
		curl -k -m 5 --anyauth -u "$boxuser:$boxpw" "http://$boxip:49000$location"
	else
		curl -k -m 5 --anyauth -u "$boxuser:$boxpw" "http://$boxip:49000$location" >"$DIRECTORY/$option2"
	fi
}

### ------FUNCTION IGDMetaData - TR-064 Protocol- ###

IGDMetaData() {
	location="/igddesc.xml"

	if [ "$option2" = "state" ]; then
		curl -k -m 5 --anyauth -u "$boxuser:$boxpw" "http://$boxip:49000$location"
	else
		curl -k -m 5 --anyauth -u "$boxuser:$boxpw" "http://$boxip:49000$location" >"$DIRECTORY/$option2"
	fi
}

### ------FUNCTION wlanstatistics for 2.4 Ghz - TR-064 Protocol-------- ###

wlanstatistics() {
	location="/upnp/control/wlanconfig1"
	uri="urn:dslforum-org:service:WLANConfiguration:1"
	action='GetStatistics'

	readout

	action='GetTotalAssociations'

	readout

	action='GetInfo'

	readout
	echo "NewGHz 2.4"
}

### ------------------------ FUNCTION wlanstatistics for 5 Ghz - TR-064 Protocol ------------------------ ###

wlan5statistics() {
	location="/upnp/control/wlanconfig2"
	uri="urn:dslforum-org:service:WLANConfiguration:2"
	action=GetStatistics

	readout

	action=GetTotalAssociations

	readout

	action=GetInfo

	readout
	echo NewGHz 5
}

### --- FUNCTION LANstate - TR-064 Protocol------ ###

LANstate() {
	location="/upnp/control/lanethernetifcfg"
	uri="urn:dslforum-org:service:LANEthernetInterfaceConfig:1"
	action='GetStatistics'

	readout
}

### -----FUNCTION DSLstate - TR-064 Protocol------- ###

DSLstate() {
	location="/igdupnp/control/wandslifconfig1"
	uri="urn:dslforum-org:service:WANDSLInterfaceConfig:1"
	action='GetInfo'

	readout
}

### --- FUNCTION WANstate - TR-064 Protocol  ###

WANstate() {
	location="/upnp/control/wancommonifconfig1"
	uri="urn:dslforum-org:service:WANCommonInterfaceConfig:1"
	action='GetTotalBytesReceived'

	readout

	action='GetTotalBytesSent'

	readout

	action='GetTotalPacketsReceived'

	readout

	action='GetTotalPacketsSent'

	readout

	action='GetCommonLinkProperties'

	readout

	#action='GetInfo'

	#readout

}

### - FUNCTION WANDSLLINKstate - TR-064 Protocol ----------------------------- ###

WANDSLLINKstate() {
	location="/upnp/control/wandsllinkconfig1"
	uri="urn:dslforum-org:service:WANDSLLinkConfig:1"
	action='GetStatistics'

	readout

}

### --- FUNCTION IGDWANstate - TR-064 Protocol -- ###

IGDWANstate() {
	location="/igdupnp/control/WANCommonIFC1"
	uri="urn:schemas-upnp-org:service:WANCommonInterfaceConfig:1"
	action='GetAddonInfos'

	readout

}

### ----FUNCTION IGDDSLLINKstate - TR-064 Protocol ------ ###

IGDDSLLINKstate() {
	location="/igdupnp/control/WANDSLLinkC1"
	uri="urn:schemas-upnp-org:service:WANDSLLinkConfig:1"
	action='GetDSLLinkInfo'

	readout

	action='GetAutoConfig'

	readout

	action='GetModulationType'

	readout

	action='GetDestinationAddress'

	readout

	action='GetATMEncapsulation'

	readout

	action='GetFCSPreserved'

	readout

}

IGDIPstate() {
	location="/igdupnp/control/WANIPConn1"
	uri="urn:schemas-upnp-org:service:WANIPConnection:1"
	action='GetConnectionTypeInfo'

	readout

	action='GetAutoDisconnectTime'

	readout

	action='GetIdleDisconnectTime'

	readout

	action='GetStatusInfo'

	readout

	action='GetNATRSIPStatus'

	readout

	action='GetExternalIPAddress'

	readout

	action='X_AVM_DE_GetExternalIPv6Address'

	readout

	action='X_AVM_DE_GetIPv6Prefix'

	readout

	action='X_AVM_DE_GetDNSServer'

	readout

	action='X_AVM_DE_GetIPv6DNSServer'

	readout

}

Reboot() {

	# Building the inputs for the SOAP Action

	location="/upnp/control/deviceconfig"
	uri="urn:dslforum-org:service:DeviceConfig:1"
	action='Reboot'
	if [[ "$option2" = "Box" ]]; then
		echo "Sending Reboot command to $1"
		curl -k -m 5 --anyauth -u "$boxuser:$boxpw" "http://$boxip:49000$location" -H 'Content-Type: text/xml; charset="utf-8"' -H "SoapAction:$uri#$action" -d "<?xml version='1.0' encoding='utf-8'?><s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'><s:Body><u:$action xmlns:u='$uri'></u:$action></s:Body></s:Envelope>" -s >/dev/null
	fi
}

script_version() {
	echo "fritzBoxShell.sh version ${version}"
}

# Check if an argument was supplied for shell script
# if [ $# -eq 0 ]; then
# 	DisplayArguments
# elif [ -z "$2" ]; then
# 	if [ "$option1" = "version" ]; then
# 		script_version
# 	else
# 		DisplayArguments
# 	fi
# else
# 	#If argument was provided, check which function to be called
# 	if [ "$option1" = "2g" ] || [ "$option1" = "wlan_5g" ] || [ "$option1" = "wlan" ]; then
# 		if [ "$option2" = "1" ]; then
# 			wlanstate "ON"
# 		elif [ "$option2" = "0" ]; then
# 			wlanstate "OFF"
# 		elif [ "$option2" = "state" ]; then
# 			wlanstate "state"
# 		elif [ "$option2" = "STATISTICS" ]; then
# 			if [ "$option1" = "2g" ]; then
# 				wlanstatistics
# 			elif [ "$option1" = "wlan_5g" ]; then
# 				wlan5statistics
# 			else
# 				DisplayArguments
# 			fi
# 		else
# 			DisplayArguments
# 		fi
# 	elif [ "$option1" = "LAN" ]; then
# 		if [ "$option2" = "state" ]; then
# 			LANstate "$option2"
# 		else
# 			DisplayArguments
# 		fi
# 	elif [ "$option1" = "DSL" ]; then
# 		if [ "$option2" = "state" ]; then
# 			DSLstate "$option2"
# 		else
# 			DisplayArguments
# 		fi
# 	elif [ "$option1" = "WAN" ]; then
# 		if [ "$option2" = "state" ]; then
# 			WANstate "$option2"
# 		else
# 			DisplayArguments
# 		fi
# 	elif [ "$option1" = "LINK" ]; then
# 		if [ "$option2" = "state" ]; then
# 			WANDSLLINKstate "$option2"
# 		else
# 			DisplayArguments
# 		fi
# 	elif [ "$option1" = "IGDWAN" ]; then
# 		if [ "$option2" = "state" ]; then
# 			IGDWANstate "$option2"
# 		else
# 			DisplayArguments
# 		fi
# 	elif [ "$option1" = "IGDDSL" ]; then
# 		if [ "$option2" = "state" ]; then
# 			IGDDSLLINKstate "$option2"
# 		else
# 			DisplayArguments
# 		fi
# 	elif [ "$option1" = "IGDIP" ]; then
# 		if [ "$option2" = "state" ]; then
# 			IGDIPstate "$option2"
# 		else
# 			DisplayArguments
# 		fi
# 	elif [ "$option1" = "UPNPMetaData" ]; then
# 		UPNPMetaData "$option2"
# 	elif [ "$option1" = "IGDMetaData" ]; then
# 		IGDMetaData "$option2"
# 	elif [ "$option1" = "info" ]; then
# 		Deviceinfo "$option2"
# 	elif [ "$option1" = "LED" ]; then
# 		LEDswitch "$option2"
# 	elif [ "$option1" = "KEYLOCK" ]; then
# 		keyLockSwitch "$option2"

# 	elif [ "$option1" = "REBOOT" ]; then
# 		Reboot "$option2"
# 	else
# 		DisplayArguments
# 	fi
# fi
