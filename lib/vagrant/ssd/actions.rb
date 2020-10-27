module Vagrant
    module Ssd
      class Action
  
        class SsdDisk
  
          # inspired by https://github.com/sprotheroe/vagrant-disksize
  
          # Creates infix for VBoxManage commands (driver.execute)
          # according to VirtualBox version
          VB_Meta = VagrantPlugins::ProviderVirtualBox::Driver::Meta.new()
          if VB_Meta.version >= '5.0'
            MEDIUM = 'medium'
          else
            MEDIUM = 'hd'
          end
  
          def initialize(app, env)
            @app = app
            @machine = env[:machine]
            @enabled = true
            if @machine.provider.to_s !~ /VirtualBox/
              @enabled = false
              env[:ui].error "Vagrant-ssd plugin supports VirtualBox only."
            end
          end
  
          def call(env)

            if @enabled
              
              driver = @machine.provider.driver
              disks = identify_disks(driver)
              
              disks.each do | disk |
                attach_disk(driver, disk)
              end
            end
  
            # Allow middleware chain to continue so VM is booted
            @app.call(env)
  
          end
  
          private
  
          def attach_disk(driver, disk)
            parts = disk[:name].split('-')
            controller = parts[0]
            port = parts[1]
            device = parts[2]
            driver.execute('storageattach', @machine.id, '--storagectl', controller, '--port', port, '--device', device, '--type', 'hdd', '--nonrotational', 'on',  '--medium', disk[:file])
          end       
  
          def identify_disks(driver)
            vminfo = get_vminfo(driver)
            disks = []
            disk_keys = vminfo.keys.select { |k| k =~ /-ImageUUID-/ }
            disk_keys.each do |key|
              uuid = vminfo[key]
              if is_disk(driver, uuid)
                disk_name = key.gsub(/-ImageUUID-/,'-')
                disk_file = vminfo[disk_name]
                disks << {
                  uuid: uuid,
                  name: disk_name,
                  file: disk_file
                }
              end
            end
            disks
          end


          def is_disk(driver, uuid)
            begin
              driver.execute("showmediuminfo", 'disk', uuid)
              true
            rescue
              false
            end
          end

          def get_vminfo(driver)
            vminfo = {}
            driver.execute('showvminfo', @machine.id, '--machinereadable', retryable: true).split("\n").each do |line|
              parts = line.partition('=')
              key = unquoted(parts.first)
              value = unquoted(parts.last)
              vminfo[key] = value
            end
            vminfo
          end

          def unquoted(s)
            s.gsub(/\A"(.*)"\Z/,'\1')
          end
        end
      end
    end
  end