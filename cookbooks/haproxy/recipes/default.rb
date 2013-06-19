#
# Cookbook Name:: haproxy
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

case node["platform"]
when "debian", "ubuntu"  
	
	package "tar"

	directory "#{node['haproxy']['dir']}" do
		  owner "root"
		  group "root"
		  mode 0755
		  action:create
	end	

	remote_file "#{node['haproxy']['dir']}/haproxy-1.4.24.tar.gz" do
		mode "0755"
		owner "root"
	  	group "root"
		source "http://haproxy.1wt.eu/download/1.4/src/haproxy-1.4.24.tar.gz"
		action:create_if_missing
		notifies :run, "execute[tar]", :immediately

	end

	execute "tar" do
		 user "root"
		 group "root"
		 cwd "#{node['haproxy']['dir']}"
		 command "tar -xvzf #{node['haproxy']['dir']}/haproxy-1.4.24.tar.gz"
		 action :nothing
		 notifies :run, "execute[move]", :immediately

	end

	execute "move" do
		 user "root"
		 group "root"
		 cwd "#{node['haproxy']['dir']}"
		 command "mv haproxy-1.4.24/* ."
		 action :nothing
		 notifies :run, "execute[rm]", :immediately

	end

	execute "rm" do
		 user "root"
		 group "root"
		 cwd "#{node['haproxy']['dir']}"
		 command "rm -rf haproxy-1.4.24"
		 action :nothing
	end

	execute 'make TARGET' do
		 user "root"
		 group "root"
		 cwd "#{node['haproxy']['dir']}"
		 command "make TARGET=linux26 "
		 action :run
	end	 

	execute 'make TARGET' do
		 user "root"
		 group "root"
		 cwd "#{node['haproxy']['dir']}"
		 command "make install"
		 action :run
	end	 

	vmList= data_bag("vms")
	ipList = Array.new


	vmList.each do |vm|

		infoVM  = data_bag_item("vms",vm)
		ip  = infoVM['ip']
		port  = infoVM['port']
		name  = infoVM['id']

		log '#'
		log name

		ipList.push({
					:name => name,
					:ip  => ip,
					:port => port
		})

	end

	template "haproxy.cfg" do 
		mode "0755"
		source "haproxy.cfg.erb"
		path "#{node['haproxy']['dir']}/haproxy.cfg"
		variables(:ipList => ipList) 
	end

	execute 'launch haproxy' do
		 user "root"
		 group "root"
		 cwd "#{node['haproxy']['dir']}"
		 command " /usr/share/haproxy/haproxy -D -f  /usr/share/haproxy/haproxy.cfg"
		 action :run
	end	 

end