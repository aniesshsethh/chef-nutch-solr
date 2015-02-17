#
# Cookbook Name:: nutch_solr
# Recipe:: default
#
# Copyright 2015, Aniessh Sethh
#
# All rights reserved - Do Not Redistribute

package 'openjdk-7-jdk' do
    action :install
end

package 'tomcat7' do
    action :install
end

package 'ant' do
    action :install
end

package 'ivy' do
    action :install
end

service 'tomcat7' do
    action [ :enable, :start ]
end

directory "/srv/www" do
    owner 'tomcat7'
      group 'tomcat7'
        mode '0644'
          action :create
end

cookbook_file '/srv/www/solr-lucene.tgz' do
    source 'solr-4.10.3-src.tgz'
      mode '0644'
end

execute 'extract solr' do
    cwd '/srv/www/'
      not_if { File.exist?("/srv/www/solr-lucene") }
        command 'tar -zxvf solr-lucene.tgz'
end

execute 'mv solr' do
    cwd '/srv/www/'
      not_if { File.exist?("/srv/www/solr-lucene") }
        command 'mv solr-4.10.3 solr-lucene'
end

execute 'ivy command' do
    cwd '/srv/www/solr-lucene'
      command 'ant ivy-bootstrap'
end

directory '/root/.ivy2/' do
    action :create
      mode '0644'
end

cookbook_file '/root/.ivy2/cache.tar.gz' do
    source 'cache.tar.gz'
      mode '0644'
end

execute 'extract iv2' do
    cwd '/root/.ivy2/'
      command 'tar -zxvf cache.tar.gz'
end

execute 'compile solr' do
    cwd '/srv/www/solr-lucene/solr/'
      command 'ant example -v'
        not_if { File.exist?("/srv/www/solr-lucene/solr/mycore/webapps/solr.war") }
          not_if { File.exist?("/srv/www/solr-lucene/solr/example/webapps/solr.war") }
end

execute 'rename solr instance' do
    cwd '/srv/www/solr-lucene/solr/'
      not_if { File.exist?("/srv/www/solr-lucene/solr/mycore") }
        command 'mv example mycore'
end

cookbook_file '/srv/www/solr-lucene/solr/mycore/solr/collection.tar.gz' do
      source 'collection.tar.gz'
        mode '0644'
end

execute 'extract collection' do
    cwd '/srv/www/solr-lucene/solr/mycore/solr'
      command 'tar -zxvf collection.tar.gz'
end

cookbook_file '/srv/www/apache-nutch-2.3-src.tar.gz' do
    source 'apache-nutch-2.3-src.tar.gz'
      mode '0644'
end

execute 'extract apache nutch' do
    cwd '/srv/www/'
      not_if { File.exist?("/srv/www/nutch") }
        command 'tar -zxvf apache-nutch-2.3-src.tar.gz'
end

execute 'rename folder' do
    cwd '/srv/www/'
      not_if { File.exist?("/srv/www/nutch") }
        command 'mv apache-nutch-2.3 nutch'
end

execute 'compile' do
    not_if { File.exist?("/srv/www/nutch/runtime") }
      cwd '/srv/www/nutch/'
        command 'ant'
end
