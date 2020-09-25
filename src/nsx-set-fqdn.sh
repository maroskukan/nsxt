#!/usr/bin/env bash

# Purpose: Enables FQDN usage on NSX Manager
# Author: Maros Kukan

declare -l nsx_path

function get_fqdn() {
    # Verify if NSX FQDN variable is available globally
    # (e.g declare -xl nsx_fqdn=nsxmgr.example.com)
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


function check_api() {
    # Verify if API Service and Credentials are valid
    local fqdn=$1
    local auth=$2
    local response=$(curl "https://${fqdn}/api/v1/cluster/api-service" \
    --insecure \
    --silent \
    --head \
    --header "Authorization: Basic $auth")
    echo $response
    local status_code=$(echo $response | sed -n 's/HTTP.* \(.*\) .*/\1/p')
    if [[ ! $status_code == 200 ]]; then
         echo "API Service is not available. Status code is $status_code"
         exit 1
    else
         echo "API Service is available"
    fi
}




get_fqdn
get_creds
echo $nsx_fqdn
echo $nsx_auth

check_api $nsx_fqdn $nsx_auth