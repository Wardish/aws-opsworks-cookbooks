#
# Cookbook:: aws-opsworks-cookbooks
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
node[:package][:install].each do |package_name|
  package package_name
end
