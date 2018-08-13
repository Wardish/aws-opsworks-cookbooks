
search("aws_opsworks_app", "deploy:true").each_with_index do |app, i|
  directory "/var/www/apps" do
    owner 'apache'
    group 'apache'
    mode 0755
    action :create
    not_if { File.exists?("/var/www/apps") }
  end

  service "httpd" do
    action [:stop]
  end

  module_path = app[:environment][:module_name] ? app[:environment][:module_name] : "/"

  script "app-release" do
    user "root"
    interpreter "bash"
    code <<-"EOS"
      /usr/bin/rsync -a --delete /opt/apps/#{app[:shortname]}#{module_path} /var/www/apps/#{app[:shortname]}/
      chown -R ec2-user /var/www/apps/#{app[:shortname]}
    EOS
  end

  script "owner-change" do
    user "root"
    interpreter "bash"
    code <<-"EOS"
      chown -R apache:apache /var/www/apps/#{app[:shortname]}
    EOS
  end

  template "/etc/httpd/conf.d/#{app[:shortname]}.conf" do
    source "app.conf.erb"
    mode "0660"
    group "apache"
    owner "apache"
    variables({
        :base_dir => "/var/www/apps/#{app[:shortname]}#{module_path}",
        :document_root => app[:attributes][:document_root]
        })
  end

  service "httpd" do
    action [:start]
  end
end