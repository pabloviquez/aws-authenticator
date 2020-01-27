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

source ./lib/variables.sh
source ./lib/common.sh
source ./lib/aws.sh

aws_print_logo

if [ -e ${AWS_MFA_SESSION_FILE} ]; then
    source ${AWS_MFA_SESSION_FILE}
fi

if [ -e ${AWS_MFA_SERIAL_NUMBER_FILE} ]; then
    source ${AWS_MFA_SERIAL_NUMBER_FILE}
fi

_OPTIONS="frsvp:a:"
while getopts "${_OPTIONS}h?" OPTIONPARAM
do
    case "${OPTIONPARAM}" in
        h)
            printf "%-20s %-50s\n" \
                "" "" \
                "${COLOR_BLUE}AWS Authenticator Help${COLOR_NORMAL} - Script usage and options" "" \
                "" "" \
                "Resets values:" "aws-authenticator -r" \
                "Force authentication:" "aws-authenticator -f" \
                "Other combinations:" " aws-authenticator [-s] [-p XX] [-a XX] [-f]" \
                "" "" \
                "Options:" "" \
                "    -h" "Help, displays this message." \
                "    -v" "Verbose display." \
                "    -a ACCOUNT_ID" "Sets a different AWS account ID, also resets the MFA ARN serial." \
                "    -p PROFILE" "Uses the given profile for authentication. If not provided, will use the default." \
                "    -f" "Forces re-authentication." \
                "    -s" "Display all default values and variables loaded in environment." \
                "    -r" "Resets the AWS session values and deletes the ARN configured forcing to prompt" \
                "" "the username on the next authentication." \
                "" ""

            if [ -e ~/.aws/config ]; then
                echo "Profiles available in configuration:"
                echo ${COLOR_RED}
                cat ~/.aws/config |grep -oE '([a-zA-Z0-9]*)]' |awk -F"]" '{ print $1 }'
                echo ${COLOR_NORMAL}
            else
                echo ""
                echo "${COLOR_RED}>> WARNING <<${COLOR_NORMAL}"
                echo ""
                echo "No AWS configuration set."
                echo "Run first: ${COLOR_WHITE}aws configure${COLOR_NORMAL}"
                echo ""
            fi

            exit
            ;;
    esac
done
OPTIND=1

while getopts "${_OPTIONS}" OPTIONPARAM
do
    case "${OPTIONPARAM}" in
        v)
            IS_VERBOSE="1"
            ;;
        f)
            AWS_FORCE_TOKEN=1
            ;;
        a)
            echo ""
            echo "${COLOR_BLUE} >>> Using account ID: ${OPTARG} <<< ${COLOR_NORMAL}"
            echo ""
            AWS_ACCOUNT_ID="${OPTARG}"
            ;;
        r)
            echo "Resetting account authentication..."
            reset_aws_session_variables 1 1
            rm -f ${AWS_MFA_SESSION_FILE}
            rm -f ${AWS_MFA_SERIAL_NUMBER_FILE}
            echo "Complete"
            exit
            ;;
        p)
            echo ""
            echo "${COLOR_BLUE} >>> Using profile: ${OPTARG} <<< ${COLOR_NORMAL}"
            echo ""
            AWS_PROFILE="${OPTARG}"
            ;;
        s)
            _CURRENT_TIMESTAMP=$(date "+%s")
            _diff="NA"
            if [ ! -z ${AWS_SESSION_TTL} ]; then
                _diff=$(expr ${AWS_SESSION_TTL} - ${_CURRENT_TIMESTAMP})
            fi

            _CURRENT_DATETIME=$(TZ=UTC date "+%FT%TZ")
            printf "%-30s %-50s\n" \
                "Current session values and default variables" "" \
                "Account ID:" "${AWS_ACCOUNT_ID}" \
                "Profile:" "${AWS_PROFILE}" \
                "Access Key:" "${AWS_ACCESS_KEY_ID:0:3}******************${AWS_ACCESS_KEY_ID:(-3)}" \
                "Secret:" "${AWS_SECRET_ACCESS_KEY:0:3}******************${AWS_SECRET_ACCESS_KEY:(-3)}" \
                "Session token:" "${AWS_SESSION_TOKEN:0:30}..." \
                "Session TTL:" "${AWS_SESSION_TTL}" \
                "Seconds left in session:" "${_diff}" \
                "Session expiration:" "${AWS_SESSION_EXPIRATION}" \
                "Current datetime:" "${_CURRENT_DATETIME}" \
                "Username" "${AWS_USERNAME}" \
                "MFA ARN:" "${AWS_MFA_SERIAL}" \
                "" ""

            if [ -e ~/.aws/config ]; then
                echo "Profiles available in configuration"
                echo ${COLOR_RED}
                cat ~/.aws/config |grep -oE '([a-zA-Z0-9]*)]' |awk -F"]" '{ print $1 }'
                echo ${COLOR_NORMAL}
            else
                echo "No profiles set."
                echo "Run first: ${COLOR_WHITE}aws configure${COLOR_NORMAL}"
            fi

            ;;
    esac
done

if [ -z ${AWS_PROFILE} ]; then
    echo "Profile not set, using default AWS profile"
    AWS_PROFILE="default"
fi


aws_mfa_authenticate
