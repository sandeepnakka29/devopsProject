#
# Cookbook:: firstcookbook
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
include_recipe 'chef-sugar::default'
include_recipe 'firewall::default'
include_recipe 'firstcookbook::tomcatInstall'
