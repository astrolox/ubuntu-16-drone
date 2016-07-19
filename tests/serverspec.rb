require "serverspec"
require "docker"

DRONE_PORT = 8000

describe "Dockerfile" do
  before(:all) do
    @image = Docker::Image.get(ENV['IMAGE'])
    
    set :backend, :docker
    set :docker_image, @image.id
  end
  
  it 'exposes the drone port' do
    expect(@image.json['ContainerConfig']['ExposedPorts']).to include("#{DRONE_PORT}/tcp")
  end
    
  describe "Container" do
    before(:all) do
      @container = Docker::Container.create(
        'Image'      => @image.id,
        'HostConfig' => {
          'PortBindings' => { "#{DRONE_PORT}/tcp" => [{ 'HostPort' => "#{DRONE_PORT}" }] }
        },
        'Cmd' => ['/bin/bash']
      )
      set :docker_container, @container.id
    end
    after(:all) do
      @container.delete(:force => true)
    end
    
#    describe file('/opt/drone/drone_static') do
#      it { should exist }
#    end
  end
end
