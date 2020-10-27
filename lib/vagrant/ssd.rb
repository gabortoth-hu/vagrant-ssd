require "vagrant/ssd/version"

begin
  require 'vagrant'
rescue LoadError
  raise 'The vagrant-disksize plugin must be run within vagrant.'
end

module Vagrant
  module Ssd
    class Plugin < Vagrant.plugin('2')

      name 'vagrant-ssd'

      description <<-DESC
      Adds 'solid state drive' attribute to virtual disks provided by Virtualbox. 
      DESC

      action_hook(:ssd, :machine_action_up) do |hook|
        require_relative 'ssd/actions'

        hook.before(VagrantPlugins::ProviderVirtualBox::Action::Boot, Action::SsdDisk)
      end
    end
  end
end
