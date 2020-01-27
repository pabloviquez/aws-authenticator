class AwsAuthenticator < Formula
  desc "AWS Authenticator interface"
  homepage "https://github.com/pabloviquez/aws-authenticator"
  url "https://github.com/pabloviquez/aws-authenticator/archive/v1.0.1.tar.gz"
  sha256 "e5116b442d3047f94a4145e223747ab5752412d1bc3ee20e751ced42933b5813"
  desc "Interface to authenticate the CLI using AWS with Multi-Factor-Authentication (MFA)"

  def install
    bin.install "aws-authenticator"
  end
end
