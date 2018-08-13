os_version = node[:platform_version].split('.')[0].to_i
case node[:platform]
when "centos", "redhat"
  if os_version >= 7
    execute "timedatectl --no-ask-password set-timezone #{node[:tz]}"
  else
    template '/etc/sysconfig/clock' do
      source 'clock.erb'
      owner 'root'
      group 'root'
      mode 0644
    end
    execute 'update' do
      command '/usr/sbin/tzdata-update'
      action :nothing
      only_if { ::File.executable?('/usr/sbin/tzdata-update') }
    end
  end
when "amazon"
  if os_version >= 2020
    execute "timedatectl --no-ask-password set-timezone #{node[:tz]}"
  else
    template '/etc/sysconfig/clock' do
      source 'clock.erb'
      owner 'root'
      group 'root'
      mode 0644
    end
    script "update-tz" do
      interpreter "bash"
      user "root"
      code <<-"EOS"
        cp /usr/share/zoneinfo/#{node[:tz]} /etc/localtime
      EOS
    end
  end
end
