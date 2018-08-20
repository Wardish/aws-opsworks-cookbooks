require 'serverspec'

set :backend, :exec

describe file('/var/www/apps/store/application/config/production/database.php') do
  its(:content) { should match /SERVER/ }
end