
search("aws_opsworks_app", "deploy:true").each_with_index do |app, i|
 
  module_path = app[:environment][:module_path] ? "#{app[:environment][:module_path]}" : "/"

  template "/var/www/apps/#{app[:shortname]}/application/config/database.php" do
    only_if "test -f /var/www/apps/#{app[:shortname]}/application/config/database.php"
    source "database.php.erb"
    mode "0666"
    group "apache"
    owner "apache"
    variables({
      :db_host => app[:environment][:CI_DB_HOST],
      :db_user => app[:environment][:CI_DB_USER],
      :db_password => app[:environment][:CI_DB_PASSWORD],
      :db_name => app[:environment][:CI_DB_NAME]
    })
  end

end

