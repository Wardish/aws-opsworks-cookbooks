#
# Cookbook:: package_installer
# Spec:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

require 'serverspec'

set :backend, :exec

describe package("httpd24") do
  it { should be_installed }
end

describe package("php71") do
  it { should be_installed }
end

describe package("postgresql96-server") do
  it { should be_installed }
end
