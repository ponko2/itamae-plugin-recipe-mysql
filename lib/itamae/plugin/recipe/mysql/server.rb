require 'shellwords'

node.validate! do
  {
    mysql: {
      server_root_password: string,
      server_repl_password: optional(string),
      allow_remote_root: optional(boolean),
      remove_anonymous_users: optional(boolean),
      remove_test_database: optional(boolean),
      root_network_acl: optional(array_of(string))
    }
  }
end

node.reverse_merge!(
  mysql: {
    allow_remote_root: false,
    remove_anonymous_users: false,
    remove_test_database: false,
    root_network_acl: []
  }
)

package 'mysql-server'

service 'mysql' do
  action [:start, :enable]
end

execute 'assign root password' do
  cmd = '/usr/bin/mysqladmin'
  cmd << ' -u root password '
  cmd << Shellwords.escape(node[:mysql][:server_root_password])
  command cmd
  only_if "/usr/bin/mysql -u root -e 'show databases;'"
end

template '/etc/mysql_grant.sql' do
  owner 'root'
  group 'root'
  mode '0600'
  notifies :run, 'execute[install grants]'
end

execute 'install grants' do
  if node[:mysql][:server_root_password].empty?
    password_string = ''
  else
    password_string = '-p' + Shellwords.escape(node[:mysql][:server_root_password])
  end

  cmd = '/bin/cat /etc/mysql_grants.sql | /usr/bin/mysql'
  cmd << " -u root #{password_string}"
  command cmd
  action :nothing
end
