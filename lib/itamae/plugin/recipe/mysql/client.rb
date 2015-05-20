%w(mysql-client libmysqlclient-dev).each do |p|
  package p do
    action :install
  end
end
