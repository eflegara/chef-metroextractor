#
# Cookbook Name:: metroextractor
# Recipe:: setup
#

%w(
  osm2pgsql::default
  osmosis::default
).each do |r|
  include_recipe r
end

# packages
#
%w(
  gdal-bin
  imposm
  libjpeg-dev
  python-dev
  python-pip
  zip
).each do |p|
  package p
end

python_pip 'Image'
python_pip 'ModestMaps'

# scripts
#
directory node[:metroextractor][:setup][:scriptsdir] do
  owner node[:metroextractor][:user][:id]
end

template "#{node[:metroextractor][:setup][:scriptsdir]}/osmosis.sh" do
  owner   node[:metroextractor][:user][:id]
  source  'osmosis.sh.erb'
  mode    0755
end

template "#{node[:metroextractor][:setup][:scriptsdir]}/osm2pgsql.sh" do
  owner   node[:metroextractor][:user][:id]
  source  'osm2pgsql.sh.erb'
  mode    0755
end

cookbook_file "#{node[:metroextractor][:setup][:scriptsdir]}/osm2pgsql.style" do
  owner   node[:metroextractor][:user][:id]
  source  'osm2pgsql.style'
end

cookbook_file "#{node[:metroextractor][:setup][:scriptsdir]}/cities.txt" do
  owner   node[:metroextractor][:user][:id]
  source  'cities.txt'
end

cookbook_file "#{node[:metroextractor][:setup][:scriptsdir]}/compose-city-previews.py" do
  owner   node[:metroextractor][:user][:id]
  source  'compose-city-previews.py'
end

# directories for extracts and logs
#
directory "#{node[:metroextractor][:setup][:basedir]}/ex" do
  owner node[:metroextractor][:user][:id]
end

directory "#{node[:metroextractor][:setup][:basedir]}/logs" do
  owner node[:metroextractor][:user][:id]
end

# directories for shapes
#
directory "#{node[:metroextractor][:setup][:basedir]}/shp" do
  owner node[:metroextractor][:user][:id]
end

# directories for city previews
#
directory "#{node[:metroextractor][:setup][:basedir]}/previews" do
  owner node[:metroextractor][:user][:id]
end
