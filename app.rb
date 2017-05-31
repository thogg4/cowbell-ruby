require 'bundler'
Bundler.require

ENV['RANCHER_ACCESS_KEY'] = ENV.fetch('CATTLE_ACCESS_KEY')
ENV['RANCHER_SECRET_KEY'] = ENV.fetch('CATTLE_SECRET_KEY')
ENV['RANCHER_URL'] = ENV.fetch('CATTLE_URL').gsub('/v1', '')


Rancher::Api.setup!

set :bind, '0.0.0.0'

def download_config(url)
  say 'downloading rancher-compose config file'
  filename = "config-#{Time.now.strftime('%m%e%y%H%M')}.zip"

  command = [
    'curl',
    '-s',
    "-o #{filename}", 
    "-u '#{ENV.fetch('RANCHER_ACCESS_KEY')}:#{ENV.fetch('RANCHER_SECRET_KEY')}'",
    url
  ].join(' ')
  return nil if !system(command)

  command = "unzip #{filename}"
  return nil if !system(command)

  filename
end

def rc_up(stack, service)
  say "upgrading - stack: #{stack} service: #{service}"
  command = ['rancher-compose', "-p #{stack}", 'up', '--pull', '--force-upgrade', '--confirm-upgrade', '-d', service].join(' ')
  system(command)
end

def say(text)
  puts ["#{'*' * 10}", "[#{text}]", "#{'*' * 10}"].join(' ')
end

get '/' do
  Rancher::Api::Project.all.to_a.first
end

post '/deploy/:stack/:service' do
  stack = Rancher::Api::Environment.where(name: params['stack']).first
  filename = download_config(stack.links['composeConfig'])

  say filename 
  if filename
    service = stack.services.where(name: params['service']).first
    rc_up(stack.name, service.name)
  else
    'Error'
  end
end
