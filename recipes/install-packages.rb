#
# Cookbook:: aws-opsworks-cookbooks
# Recipe:: install-package
#
# Copyright:: 2018, Wardish,LLC. All Rights Reserved.
node[:package][:install].each do |package_name|
  package package_name
end
