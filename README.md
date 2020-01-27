# AWS Authenticator Helper

This tool is a simple interface that handles the CLI authentication with Amazon Web Services using the Multi-Factor-Authentication (MFA).

# Requirements

The tool requires the AWS CLI tool installed. If you do not have it on your computer, you can easily install it by running:

```
brew install awscli
```

# Install - Homebrew
```
brew tap pabloviquez/aws-authenticator
brew install aws-authenticator
```

# Basis Usage

```
aws-authenticator
```

## Force authentication and change the profile used

```
aws-authenticator -f -p MYAWSPROFILE
```

### Note
After running the tool, you need to load the variables as follow:

```
source ~/.aws/mfa-session
```

# Options

The supported options are:

```
Options:
    -h               Help, displays this message.
    -v               Verbose display.
    -a ACCOUNT_ID    Sets a different AWS account ID, also resets the MFA ARN serial.
    -p PROFILE       Uses the given profile for authentication. If not provided, will use the default.
    -f               Forces re-authentication.
    -s               Display all default values and variables loaded in environment.
    -r               Resets the AWS session values and deletes the ARN configured forcing to prompt
                     the username on the next authentication.
```

# TODO
* Load variables in the shell automatically after executing the tool.
* Be able to use different AWS config locations.