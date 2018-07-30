script "setup-postgresql96" do
  not_if "test -f /var/lib/pgsql96/data/postgresql.conf"
  interpreter "bash"
  user        "root"
  code <<-"EOS"
    service postgresql96 initdb
  EOS
end

template "/var/lib/pgsql96/data/pg_hba.conf" do
  source 'pg_hba.conf.erb'
  owner 'postgres'
  group 'postgres'
  mode 0600
end

service "postgresql96" do
  action [:restart]
end