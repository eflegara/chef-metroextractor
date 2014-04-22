#
# Cookbook Name:: metroextractor
# Attributes:: default
#

# setup
default[:metroextractor][:setup][:basedir]      = '/mnt/metro'
default[:metroextractor][:setup][:scriptsdir]   = '/opt/metroextractor-scripts'

# user
default[:metroextractor][:user][:id]            = 'metro'
default[:metroextractor][:user][:shell]         = '/bin/bash'
default[:metroextractor][:user][:manage_home]   = false
default[:metroextractor][:user][:create_group]  = true
default[:metroextractor][:user][:ssh_keygen]    = false

# postgres
default[:metroextractor][:postgres][:db]        = 'osm'
default[:metroextractor][:postgres][:user]      = 'osm'
default[:metroextractor][:postgres][:password]  = 'password'

# planet
default[:metroextractor][:planet][:url]  = 'http://ftp.heanet.ie/mirrors/openstreetmap.org/pbf/planet-latest.osm.pbf'
default[:metroextractor][:planet][:file] = node[:metroextractor][:planet][:url].split('/').last

# extracts
default[:metroextractor][:extracts][:osmosis_timeout] = 172_800
default[:metroextractor][:extracts][:osmosis_lock]    = "#{node[:metroextractor][:setup][:basedir]}/.osmosis.lock"

# set osmosis heap to half available ram
heap  = "#{(node[:memory][:total].to_i * 0.6).floor / 1024}M"
default[:metroextractor][:extracts][:osmosis_jvmopts] = "-server -XX:SurvivorRatio=8 -Xms#{heap} -Xmx#{heap}"

# shapes
default[:metroextractor][:shapes][:osm2pgsql_timeout] = 172_800
default[:metroextractor][:shapes][:osm2pgsql_lock]    = "#{node[:metroextractor][:setup][:basedir]}/.osm2pgsql.lock"

# previews
default[:metroextractor][:previews][:lock] = "#{node[:metroextractor][:setup][:basedir]}/.previews.lock"

# osmosis
default[:osmosis][:symlink]      = true
default[:osmosis][:install_type] = 'tgz'
