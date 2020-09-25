#!/usr/bin/env bash

# Purpose: Enables FQDN usage on NSX Manager
# Author: Maros Kukan
#
# The following environment variables can be loaded automatically
# declare -x nsx_fqdn=nsxmgr.example.com
# declare -x nsx_user=admin
# declare -x nsx_pass=VMware1!

declare -l nsx_path

function get_fqdn() {
    if [[ -z $nsx_fqdn ]]; then
        while [[ -z $nsx_fqdn ]]
        do
            read -r -p "Enter the NSX-T Manager FQDN: " nsx_fqdn
        done
    else
        echo "NSX-T Manager FQDN loaded from environment."
    fi
}


function get_creds () {
    # Collect credentials and return Base64 string
    if [[ -z $nsx_user ]]; then
        while [[ -z $nsx_user ]]
        do
            read -r -p "Enter the NSX-T Username: " nsx_user
        done
    else
        echo "NSX-T Username loaded from environment."
    fi
    if [[ -z $nsx_pass ]]; then
        while [[ -z $nsx_pass ]]
        do
            read -r -s -p "Enter the NSX-T Password: " nsx_pass
            echo 
        done
    else
        echo "NSX-T Password loaded from environment."
    fi
    nsx_auth=$(echo -n ${nsx_user}:${nsx_pass} | base64)
}


function set_fqdn() {
    # Verify if API Service and Credentials are valid
    local fqdn=$1
    local auth=$2
    local response=$(curl "https://${fqdn}/api/v1/configs/management" \
    --insecure \
    --silent \
    --request GET \
    --header "Authorization: Basic $auth")

    local publish_fqdns=$(echo $response | jq '.publish_fqdns')
    local revision=$(echo $response | jq '._revision')

    if [[ $publish_fqdns == 'true' ]]; then
        echo "Publish FQDN is enabled."
        exit 0
    elif [[ $publish_fqdns == 'false' ]]; then
        echo "Publis FQDN is not enabled."
        exit 0
    else
        echo "Publish FQDN status is uknown."
        echo $publish_fqdns
        exit 1
    fi
}


# Collect FQDN and Credentials
get_fqdn
get_creds

echo "*********************************************"
# Validate "Publish FQDNs" status

set_fqdn "$nsx_fqdn" "$nsx_auth"