#!/bin/bash
# ------------------------------------------------------------------
# -- AWS MFA Authenticator
# --
# -- Handles the authentication for the CLI.
# --
# -- Requires:
# --    aws-cli
# --
# -- @author Pablo Viquez <pviquez@pabloviquez.com>
# ------------------------------------------------------------------

function get_input_data()
{
    local _resultvar=$2
    local usr_input=""

    while [ -z "${usr_input}" ]
    do
        printf "${COLOR_WHITE}${1}${COLOR_NORMAL}"
        read usr_input
    done

    eval ${_resultvar}="'${usr_input}'"
}

function pause()
{
    printf "${COLOR_WHITE}Press any key to continue...${COLOR_NORMAL}"
    read usr_input
}

function print_fail()
{
    let colPos=${COL_POS}-${#1}
    printf '%s%s%*s%s' "${1}" "${COLOR_RED}" $colPos " ☠️  " "${COLOR_NORMAL}"
    echo ""
}

function print_success()
{
    let colPos=${COL_POS}-${#1}
    printf '%s%s%*s%s' "${1}" "${COLOR_GREEN}" $colPos " 👍🏼" "${COLOR_NORMAL}"
    echo ""
}

function get_json_value ()
{
    local _idx=$1
    local _resultVar=$2
    local _jsonValue=""

    _jsonValue=$(echo ${AWS_SESSION_DATA} |grep -oiE "${_idx}\": \"[^\"]*" |sed "s/${_idx}\": \"\([^\"]*\)/\1/")
    eval "${_resultVar}"="'${_jsonValue}'"
}
