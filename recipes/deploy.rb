
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

  module_path = app[:environment][:module_path] ? app[:environment][:module_path] : "/"
  module_path = ! module_path.end_with?("/") || module_path

  script "app-release" do
    user "root"
    interpreter "bash"
    code <<-"EOS"
      /usr/bin/rsync -a --delete /opt/build/#{app[:shortname]}#{module_path} /var/www/apps/#{app[:shortname]}/
      chown -R ec2-user /var/www/apps/#{app[:shortname]}
    EOS
  end

  data_source = app[:data_sources].first
  if "RdsDbInstance" == data_source[:type] then
    arn = "#{data_source[:arn]}".gsub(/:/, '\:')
    Chef::Log.info("RDS DB Instance #{arn}")
    rds_setting = search("aws_opsworks_rds_db_instance", "rds_db_instance_arn:#{arn}").first
    app[:environment][:WP_DB_NAME] = data_source[:database_name]
    app[:environment][:WP_DB_USER] = rds_setting[:db_user]
    app[:environment][:WP_DB_PASSWORD] = rds_setting[:db_password]
    app[:environment][:WP_DB_HOST] = rds_setting[:address]

    app[:environment][:CI_DB_NAME] = data_source[:database_name]
    app[:environment][:CI_DB_USER] = rds_setting[:db_user]
    app[:environment][:CI_DB_PASSWORD] = rds_setting[:db_password]
    app[:environment][:CI_DB_HOST] = rds_setting[:address]
  end

  template "/var/www/apps/#{app[:shortname]}/#{app[:environment][:CI_PUBLIC]}/.htaccess" do
    only_if "test -d /var/www/apps/#{app[:shortname]}/#{app[:environment][:CI_PUBLIC]}/"
    source "htaccess.erb"
    mode "0660"
    group "ec2-user"
    owner "ec2-user"
    variables({
        :document_root => app[:attributes][:document_root],
    })
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
        :base_dir => "/var/www/apps/#{app[:shortname]}/",
        :public_dir => "/var/www/apps/#{app[:shortname]}/#{app[:environment][:CI_PUBLIC]}/",
        :document_root => app[:attributes][:document_root],
        :ci_params => app[:environment].select {|key, val| key.start_with?("CI_")},
        :wp_params => app[:environment].select {|key, val| key.start_with?("WP_")}
        })
  end

  service "httpd" do
    action [:start]
  end
end