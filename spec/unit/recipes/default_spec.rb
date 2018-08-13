#
# Cookbook:: package_installer
# Spec:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

require 'spec_helper'

describe package("httpd") do
  if { should be_installed }
end