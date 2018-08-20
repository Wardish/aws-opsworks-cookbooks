package "git"

search("aws_opsworks_app", "deploy:true").each_with_index do |app, i|
  file "/root/.ssh/#{app[:shortname]}.pem" do
    owner 'root'
    group 'root'
    mode 0600
    content app[:app_source][:ssh_key]
  end

  file "/root/#{app[:shortname]}-wrapper.sh" do
    mode 0755
    content "#!/bin/sh\nexec /usr/bin/ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /root/.ssh/#{app[:shortname]}.pem \"$@\""
  end
  
  directory "/opt/apps" do
    owner 'apache'
    group 'apache'
    mode 0755
    action :create
    not_if { File.exists?("/opt/apps") }
  end

  git "/opt/apps/#{app[:shortname]}" do
    repository "#{app[:app_source][:url]}"
    action :sync
    revision app[:app_source][:revision]
    ssh_wrapper "/root/#{app[:shortname]}-wrapper.sh"
  end
end