search("aws_opsworks_app").each_with_index do |app, i|
  template "/etc/httpd/conf.d/#{app[:shortname]}.conf" do
    source "app.conf.erb"
    mode "0660"
    group "apache"
    owner "apache"
    variables({
        :shortname => app[:shortname],
        :name => app[:environment][:name],
        :document_root => app[:attributes][:document_root]
        })
  end
end

