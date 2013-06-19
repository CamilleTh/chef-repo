#
# Cookbook Name:: haproxy_service
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

case node["platform"]
when "debian", "ubuntu"  
	
	template "service haproxy.conf" do 
		mode "0755"
		owner "root"
		group "root"
		source "haproxy.conf.erb"
		path "#{node['service']['dir']}/haproxy.conf"
	end
end
