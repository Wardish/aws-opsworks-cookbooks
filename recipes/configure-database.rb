search("aws_opsworks_app").each_with_index do |app, i|
  script "create-database" do
    interpreter "bash"
    user "postgres"
    code <<-"EOS"
      if ! psql -l | grep "#{app[:environment][:database_name]}"; then
        psql -c "CREATE ROLE #{app[:environment][:database_user]}  WITH LOGIN PASSWORD 'app[:environment][:database_password]' CREATEDB"
        psql -c 'ALTER ROLE license_usr WITH LOGIN;'
        createdb -O #{app[:environment][:database_user]} -E UTF-8 --lc-collate=ja_JP.UTF-8 --lc-ctype=ja_JP.UTF-8 -T template0 #{app[:environment][:database_name]}
      fi
    EOS
  end
end
