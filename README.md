# vagrant-ssd

A Vagrant plugin to set all virtual disks to nonrotational. Inspired by [vagrant-disksize](https://github.com/sprotheroe/vagrant-disksize).

## Installation / usage

Use the following command:
```
vagrant plugin install vagrant-ssd
```
...or set it in Vagrantfile plugins section:
```
Vagrant.configure("2") do |config|
  config.vagrant.plugins =["vagrant-ssd", ...]
  ...
  end
```

## License

The gem is available as open source under the terms of the MIT License.

