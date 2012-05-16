#!/bin/bash
#
#
declare -i timeout=$RANDOM%10
sleep $timeout

coffee hermes.coffee
