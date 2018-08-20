search("aws_opsworks_app" ,"deploy:true").each_with_index do |app, i|
  Chef::Log.info("create-database-on-local #{app[:name]}")

  data_source = app[:data_sources].first

  if "RdsDbInstance" != data_source[:type] then

    environment = app[:environment]

    psql_list = "/usr/bin/psql -l -h #{environment[:CI_DB_HOST]}"
    create_db = "/usr/bin/createdb -h #{environment[:CI_DB_HOST]} -U '#{environment[:CI_DB_USER]}'"
    create_db_opt = "-E UTF-8 --locale=ja_JP.UTF-8 -T template0"
    create_user = "/usr/bin/createuser"

    script "create-database" do
      interpreter "bash"
      user "postgres"
      code <<-"EOS"
        if ! #{psql_list} | awk '{print $1}' | grep '#{environment[:CI_DB_NAME]}'; then
          psql -c "DROP USER IF EXISTS \\\"#{environment['CI_DB_USER']}\\\""
          psql -c "CREATE USER \\\"#{environment['CI_DB_USER']}\\\" WITH PASSWORD '#{environment['CI_DB_PASSWORD']}'"
          psql -c "CREATE DATABASE #{environment['CI_DB_NAME']} OWNER \\\"#{environment['CI_DB_USER']}\\\" ENCODING 'UTF8' LC_COLLATE 'ja_JP.UTF-8' LC_CTYPE 'ja_JP.UTF-8' TEMPLATE template0"
          psql -c "GRANT CONNECT ON DATABASE #{environment['CI_DB_NAME']} TO #{environment['CI_DB_USER']}"
          psql -c "CREATE EXTENSION pgcrypto" #{environment['CI_DB_NAME']}
        fi
      EOS
    end
  end
  
end