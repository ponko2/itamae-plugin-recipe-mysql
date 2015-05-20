require 'shellwords'

node.validate! do
  {
    mysql: {
      server_root_password: string,
      databases: array_of({
        name: string,
        charset: string,
        collate: string,
        privileges: array_of({
          types: array_of(string),
          user: string,
          host: string,
          password: string
        })
      })
    }
  }
end

template '/etc/mysql_databases.sql' do
  owner 'root'
  group 'root'
  mode '0600'
  notifies :run, 'execute[create databases]', :immediately
end

execute 'create databases' do
  if node[:mysql][:server_root_password].empty?
    password_string = ''
  else
    password_string = '-p' + Shellwords.escape(node[:mysql][:server_root_password])
  end

  cmd = '/bin/cat /etc/mysql_databases.sql | /usr/bin/mysql'
  cmd << " -u root #{password_string}"
  command cmd
  action :nothing
end
