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

# Util vars
COLOR_RED=$(tput setaf 1)
COLOR_GREEN=$(tput setaf 2)
COLOR_BLUE=$(tput setaf 4)
COLOR_WHITE=$(tput setaf 7)
COLOR_NORMAL=$(tput sgr0)
COL_POS=80

# Misc vars
IS_AWS_CLI_INSTALLED="0"
IS_VERBOSE="0"

# AWS vars
AWS_DIRECTORY=~/.aws
AWS_SESSION_DATA=""
AWS_MFA_SERIAL_NUMBER_FILE=~/.aws/mfa_serial_number
AWS_MFA_SESSION_FILE=~/.aws/mfa_session
AWS_ACCOUNT_ID=""
AWS_TOKEN_TTL=129600
AWS_FORCE_TOKEN=0
AWS_PROFILE="default"
AWS_USERNAME=""