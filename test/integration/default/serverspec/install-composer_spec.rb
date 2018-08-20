require 'serverspec'

set :backend, :exec

describe 'composer' do
  describe command('/usr/local/bin/composer -V') do
    its(:exit_status) { should eq 0 }
  end
end