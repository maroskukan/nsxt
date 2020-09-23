#!/usr/bin/env bash

# Purpose: Enables FQDN usage on NSX Manager
# Author: Maros Kukan

declare nsx_user
declare nsx_pass
declare nsx_auth
declare -l nsx_fqdn
declare -l nsx_path

#
# Verify if NSX FQDN variable is available globally
# (e.g declare -xl nsx_fqdn=nsxmgr.example.com)
#
if [[ -z $nsx_fqdn ]]; then
    echo -n "Enter the NSX-T Manager FQDN: "
    declare -l nsx_fqdn
    read nsx_fqdn
else
    echo "NSX-T Manager FQDN loaded from environment"
fi
#
# Collect credentials
#
while [[ -z $nsx_user ]]
do
    read -r -p "Enter the NSX-T Username: " nsx_user
done

while [[ -z $nsx_pass ]]
do
    read -r -s -p "Enter the NSX-T Password: " nsx_pass
    echo 
done

#
# Convert credentials to Base64
#
nsx_auth=$(echo -n ${nsx_user}:${nsx_pass} | base64)
