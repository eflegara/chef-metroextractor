require 'spec_helper'

describe 'metroextractor::setup' do
  before do
    stub_command('pgrep postgres').and_return(true)
    stub_command('test -f /var/lib/postgresql/9.3/main/PG_VERSION').and_return(true)
    stub_command("psql -c \"SELECT rolname FROM pg_roles WHERE rolname='osmuser'\" | grep osmuser").and_return(true)
    stub_command("psql -c \"SELECT datname from pg_database WHERE datname='osm'\" | grep osm").and_return(true)
    stub_command("psql -c 'SELECT lanname FROM pg_catalog.pg_language' osm | grep '^ plpgsql$'").and_return(true)
    stub_command("psql -c \"SELECT rolname FROM pg_roles WHERE rolname='osm'\" | grep osm").and_return(true)
    stub_command("psql -c \"SELECT datname from pg_database WHERE datname='osm'\" postgres | grep osm").and_return(true)
  end

  context 'we are running on Ubuntu 14.04 with defaults' do
    let(:chef_run) do
      ChefSpec::Runner.new do |node|
        node.automatic[:memory][:total]   = '2048kB'
        node.automatic[:platform]         = 'ubuntu'
        node.automatic[:platform_version] = '14.04'
      end.converge(described_recipe)
    end

    %w(
      libprotobuf-c0-dev
      clang
      zlib1g-dev
      build-essential
      gdal-bin
      parallel
      zip
      git
    ).each do |p|
      it "should install package #{p}" do
        expect(chef_run).to install_package p
      end
    end

    it 'should ark install package imposm' do
      expect(chef_run).to install_ark 'imposm3'
    end

    it 'should ark install vex' do
      expect(chef_run).to install_ark 'vex'
    end

    it 'should create cookbook file mapping.json' do
      expect(chef_run).to create_cookbook_file '/opt/metroextractor-scripts/mapping.json'
    end
  end

  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.automatic[:memory][:total] = '2048kB'
    end.converge(described_recipe)
  end

  it 'should create the directory /opt/metroextractor-scripts' do
    expect(chef_run).to create_directory '/opt/metroextractor-scripts'
  end

  it 'should clone metroextractor-cities' do
    expect(chef_run).to sync_git('/opt/metroextractor-scripts/metroextractor-cities').with(
      action:       [:sync],
      repository:   'https://github.com/mapzen/metroextractor-cities.git',
      revision:     'master',
      user:         'metro'
    )
  end

  it 'should symlink cities.json' do
    expect(chef_run).to create_link('/opt/metroextractor-scripts/cities.json').with(
      to: '/opt/metroextractor-scripts/metroextractor-cities/cities.json'
    )
  end

  it 'should create template /opt/metroextractor-scripts/extracts.sh' do
    expect(chef_run).to create_template('/opt/metroextractor-scripts/extracts.sh').with(
      owner:  'metro',
      mode:   0755,
      source: 'extracts.sh.erb'
    )
  end

  it 'should create template /opt/metroextractor-scripts/shapes.sh' do
    expect(chef_run).to create_template('/opt/metroextractor-scripts/shapes.sh').with(
      owner:  'metro',
      mode:   0755,
      source: 'shapes.sh.erb'
    )
  end

  it 'should create template /opt/metroextractor-scripts/coastlines.sh' do
    expect(chef_run).to create_template('/opt/metroextractor-scripts/coastlines.sh').with(
      owner:  'metro',
      mode:   0755,
      source: 'coastlines.sh.erb'
    )
  end

  it 'should create the file /opt/metroextractor-scripts/osm2pgsql.style' do
    expect(chef_run).to create_cookbook_file('/opt/metroextractor-scripts/osm2pgsql.style').with(
      owner:  'metro',
      source: 'osm2pgsql.style'
    )
  end

  it 'should create the file /opt/metroextractor-scripts/merge-geojson.py' do
    expect(chef_run).to create_cookbook_file('/opt/metroextractor-scripts/merge-geojson.py').with(
      owner:  'metro',
      source: 'merge-geojson.py'
    )
  end

  it 'should create /mnt/metro/ex' do
    expect(chef_run).to create_directory '/mnt/metro/ex'
  end

  it 'should create /mnt/metro/coast' do
    expect(chef_run).to create_directory '/mnt/metro/coast'
  end

  it 'should create /mnt/metro/logs' do
    expect(chef_run).to create_directory '/mnt/metro/logs'
  end

  it 'should create /mnt/metro/shp' do
    expect(chef_run).to create_directory '/mnt/metro/shp'
  end
end
