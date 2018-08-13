node[:service][:on].each do |service_name|
  service service_name do
    action [:enable, :start]
  end
end
