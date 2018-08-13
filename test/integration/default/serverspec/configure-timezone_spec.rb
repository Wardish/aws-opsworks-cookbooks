require 'serverspec'

set :backend, :exec

describe command('date') do
  its(:stdout) { should match /JST/ }
end