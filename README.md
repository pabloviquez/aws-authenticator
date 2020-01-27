# AWS Authenticator Helper

This tool is a simple interface that handles the CLI authentication with Amazon Web Services using the Multi-Factor-Authentication (MFA).

## Requirements

The tool requires the AWS CLI and JQ tool.


# Install - Homebrew
```
brew tap pabloviquez/aws-authenticator
brew install aws-authenticator
```

# Install - Manually
```
wget https://github.com/pabloviquez/aws-authenticator/archive/v1.0.3.tar.gz
tar -xzvf v1.0.3.tar.gz
chmod +x v1.0.3/aws-authenticator
sudo cp v1.0.3/aws-authenticator /usr/local/bin
rm -Rf v1.0.3
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

![Simple usage](docs/basic.png)

# TODO
* Load variables in the shell automatically after executing the tool.
* Be able to use different AWS config locations.

