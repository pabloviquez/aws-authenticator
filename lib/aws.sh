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

function aws_print_logo ()
{
    clear
    echo ""
    echo ""
    echo " █████╗ ██╗    ██╗███████╗       ██████╗██╗     ██╗"
    echo "██╔══██╗██║    ██║██╔════╝      ██╔════╝██║     ██║"
    echo "███████║██║ █╗ ██║███████╗█████╗██║     ██║     ██║"
    echo "██╔══██║██║███╗██║╚════██║╚════╝██║     ██║     ██║"
    echo "██║  ██║╚███╔███╔╝███████║      ╚██████╗███████╗██║"
    echo "╚═╝  ╚═╝ ╚══╝╚══╝ ╚══════╝       ╚═════╝╚══════╝╚═╝"
    echo "                                                   "
    echo ""
    echo "Amazon Web Services - CLI"
    echo ""
}

function aws_is_aws_cli_installed ()
{
    local _resultvar=$1
    isFail=1

    awscliVer="$(aws 2>&1)"
    if [[ "${awscliVer}" =~ "aws help" ]]; then
        print_success " - AWS Tool Installed"
    else
        print_fail " - AWS Tool Installed"
        isFail=0
    fi
    eval "${_resultvar}"="'${isFail}'"
}


function aws_configure_mfa_serial ()
{
    if [ -e ${AWS_MFA_SERIAL_NUMBER_FILE} ]; then
        source ${AWS_MFA_SERIAL_NUMBER_FILE}
    fi

    if [ -z ${AWS_MFA_SERIAL} ] || [ -z ${AWS_ACCOUNT_ID} ] || [ -z ${AWS_USERNAME} ]; then
        get_input_data "Enter the AWS account number: " AWS_ACCOUNT_ID

        echo ""
        get_input_data "Enter your AWS username: " AWS_USERNAME
        AWS_MFA_SERIAL="arn:aws:iam::${AWS_ACCOUNT_ID}:mfa/${AWS_USERNAME}"
        echo ""
        echo "Your MFA serial number is: ${COLOR_BLUE}${AWS_MFA_SERIAL}${COLOR_NORMAL}"
        echo ""

        if [ ! -d ${AWS_DIRECTORY} ]; then
            mkdir -p ${AWS_DIRECTORY}
        fi

        echo "export AWS_MFA_SERIAL=\"${AWS_MFA_SERIAL}\"" > ${AWS_MFA_SERIAL_NUMBER_FILE}
        echo "export AWS_ACCOUNT_ID=\"${AWS_ACCOUNT_ID}\"" >> ${AWS_MFA_SERIAL_NUMBER_FILE}
        echo "export AWS_USERNAME=\"${AWS_USERNAME}\"" >> ${AWS_MFA_SERIAL_NUMBER_FILE}
    else
        source ${AWS_MFA_SERIAL_NUMBER_FILE}
    fi
}

function reset_aws_session_variables () 
{
    local _isResetMfaRequired=$1
    local _avoidProfileReset=$2

    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
    unset AWS_SESSION_EXPIRATION
    unset AWS_SESSION_TTL

    if [ ! -z ${_avoidProfileReset} ] && [ "${_avoidProfileReset}" ==  "1" ]; then
        unset AWS_PROFILE
    fi

    if [ ! -z ${_isResetMfaRequired} ] && [ "${_isResetMfaRequired}" ==  "1" ]; then
        unset AWS_MFA_SERIAL
        unset AWS_ACCOUNT_ID
        unset AWS_USERNAME
    fi
}

function aws_mfa_authenticate ()
{
    AWS_SESSION_TTL=0
    local _CURRENT_TIMESTAMP=$(date "+%s")
    if [ -e ${AWS_MFA_SESSION_FILE} ]; then
        source ${AWS_MFA_SESSION_FILE}
    fi

    if [ ${AWS_FORCE_TOKEN} == 1 ]; then
        echo ""
        echo "${COLOR_RED}>> Reseting previous token <<${COLOR_NORMAL}"
        echo ""
        reset_aws_session_variables 1
    fi

    local _diff=0
    if [ -z ${AWS_SESSION_TTL} ]; then
        AWS_SESSION_TTL=0
    fi

    _diff=$(expr ${AWS_SESSION_TTL} - ${_CURRENT_TIMESTAMP})
    if [ ${_diff} -ge 60 ]; then
        echo "AWS session still valid for ${_diff} seconds, no need to authenticate"
        echo ""
        return
    fi

    echo ""
    echo "${COLOR_WHITE}Step 1. Checking dependencies${COLOR_NORMAL}"
    echo ""
    aws_is_aws_cli_installed IS_AWS_INSTALLED
    if [ "${IS_AWS_INSTALLED}" == "0" ]; then
        echo "AWS CLI is not installed"
        echo ""
        echo "  Go to: https://docs.aws.amazon.com/cli/latest/userguide/installing.html for more info"
        echo ""
        echo "If using MAC, do: ${COLOR_WHITE}brew install awscli${COLOR_NORMAL}"
        echo ""
        exit 1
        return
    fi

    jqtoolVer="$(jq -h 2>&1)"
    if [[ "${jqtoolVer}" =~ "commandline JSON processor" ]]; then
        print_success " - JQ Utility Installed"
    else
        print_fail " - JQ Utility Installed"
        isFail=0

        echo "To install JQ utility do: "
        echo "${COLOR_WHITE}brew install jq${COLOR_NORMAL}"
        echo ""
    fi

    echo ""
    echo "${COLOR_WHITE}Step 2. Cleaning up previous session data${COLOR_NORMAL}"
    echo ""

    # Cleanup previous session
    cat /dev/null > ${AWS_MFA_SESSION_FILE}
    reset_aws_session_variables

    echo "${COLOR_WHITE}Step 3. Getting MFA Serial${COLOR_NORMAL}"
    aws_configure_mfa_serial

    if [ "${AWS_MFA_SERIAL}" == "" ]; then
        print_fail "Invalid MFA Serial or empty, cannot continue"
        return
    fi

    echo ""
    echo "${COLOR_WHITE}Step 4. Authenticating${COLOR_NORMAL}"
    if [ ${IS_VERBOSE} == "1" ]; then 
        echo "  MFA ARN: ${AWS_MFA_SERIAL}"
    fi
    echo ""
    echo ""
    get_input_data "Enter your Multi-Factor Authentication value: " AWS_MFA_VALUE

    AWS_SESSION_DATA=$(aws sts get-session-token --profile ${AWS_PROFILE} --duration-seconds ${AWS_TOKEN_TTL} --serial-number ${AWS_MFA_SERIAL}  --token-code ${AWS_MFA_VALUE} 2>&1)
    if [ ${IS_VERBOSE} == "1" ]; then
        echo "aws sts get-session-token --profile ${AWS_PROFILE} --duration-seconds ${AWS_TOKEN_TTL} --serial-number ${AWS_MFA_SERIAL}  --token-code ${AWS_MFA_VALUE}"
    fi

    if [ ${AWS_FORCE_TOKEN} == 1 ]; then
        rm -f ${AWS_MFA_SESSION_FILE}
    fi

    echo ""
    echo "${COLOR_WHITE}Step 5. Validating AWS response${COLOR_NORMAL}"
    echo ""
    if [[ ! "${AWS_SESSION_DATA}" =~ "SecretAccessKey" ]]; then
        echo "${COLOR_RED}Error${COLOR_NORMAL} Unable to authenticate with AWS"
        echo "AWS Response: ${AWS_SESSION_DATA}"
        echo ""
        echo "${COLOR_BLUE} >>> Unable to continue <<< ${COLOR_NORMAL}"
        echo ""
        exit 1
    fi

    echo ""
    echo "${COLOR_WHITE}Done! You've succesfully authenticated agains AWS for a period of 36 hours (129,600 seconds)${COLOR_NORMAL}"
    echo ""

    get_json_value "AccessKeyId" AWS_ACCESS_KEY_ID
    get_json_value "SecretAccessKey" AWS_SECRET_ACCESS_KEY
    get_json_value "SessionToken" AWS_SESSION_TOKEN
    get_json_value "Expiration" AWS_SESSION_EXPIRATION
    AWS_SESSION_TTL=$(date -j -u -f "%Y-%m-%dT%TZ" "${AWS_SESSION_EXPIRATION}" "+%s")

    echo "export AWS_ACCESS_KEY_ID=\"${AWS_ACCESS_KEY_ID}\"" > ${AWS_MFA_SESSION_FILE}
    echo "export AWS_SECRET_ACCESS_KEY=\"${AWS_SECRET_ACCESS_KEY}\"" >> ${AWS_MFA_SESSION_FILE}
    echo "export AWS_SESSION_TOKEN=\"${AWS_SESSION_TOKEN}\"" >> ${AWS_MFA_SESSION_FILE}
    echo "export AWS_SESSION_EXPIRATION=\"${AWS_SESSION_EXPIRATION}\"" >> ${AWS_MFA_SESSION_FILE}
    echo "export AWS_SESSION_TTL=${AWS_SESSION_TTL}" >> ${AWS_MFA_SESSION_FILE}
    echo "export AWS_PROFILE=${AWS_PROFILE}" >> ${AWS_MFA_SESSION_FILE}
    source ${AWS_MFA_SESSION_FILE}

    if [[ ! $(grep "${AWS_MFA_SESSION_FILE}" ~/.bash_profile) ]]; then
        echo "source ${AWS_MFA_SESSION_FILE}" >> ~/.bash_profile
    fi
}