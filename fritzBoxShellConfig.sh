#!/bin/bash

# Fritz!Box Config
[[ -z "$boxip" ]] && boxip=fritz.box
[[ -z "$BoxUSER" ]] && BoxUSER="YourUser"
[[ -z "$BoxPW" ]] && BoxPW="YourPassword"

# Fritz!Repeater Config
[[ -z "$RepeaterIP" ]] && RepeaterIP="fritz.repeater"
[[ -z "$RepeaterUSER" ]] && RepeaterUSER="" #Usually on Fritz!Repeater no User is existing. Can be left empty.
[[ -z "$RepeaterPW" ]] && RepeaterPW="YourPassword"
