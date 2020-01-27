# AWS Authenticator Helper

This is a tool that helps the authentication process with AWS.

# Requirements

The tool requires the AWS CLI tool installed. If you do not have it on your computer, you can easily install it by running:

```
brew install awscli
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

