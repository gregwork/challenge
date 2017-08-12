# Challenge
To complete the challenge, I've prepared tooling to provision VM's from scratch.  This 'bare metal' option will build and install the VMs OS, installs and configures software, validates output and packages the final image for use on other infrastructure such as developer machines, server/datacenter-grade hypervisors or Cloud providers

As a second option, the same software provisioning scripts/manifests can also be run in isolation, on top of existing CentOS 7 machines.

## Bare metal install
This process will provision a VM from scratch, demonstrating an incremental image build where the output of one stage is fed into a later one to further customise or specialise the image.

The tooling used in this demonstration will produce Vagrant Base Boxes for VirtualBox, but can be used to create images for EC2, VMware, Docker [and others](https://www.packer.io/docs/builders/index.html) using the same template files.

### Bare metal install requirements
* [Packer](https://packer.io) (tested with v1.0.3)
* [VirtualBox](https://www.virtualbox.org) (tested with v5.1.26)
* Local clone of the challenge repository
* Internet access

#### Optional
Packer will download a CentOS 7 Minimal install ISO (~700MB) from a mirror server to perform the build.  If you already have a local copy of `CentOS-7-x86_64-Minimal-1611.iso`, it can be reused by placing a copy in the following location inside the challenge repository:

`packer/packer_cache/96cc79956121abb95c33408e5c687fd865f1062df6e0cd911204464c6fffd3ee.iso`

(The hex filename is important; it's a hash of the ISOs URL specified in the configuration)

### Performing the build
#### Setup
* Download and unpack [Packer for your host operating system](https://www.packer.io/downloads.html).  Chmod the `packer` binary to be executable, and place it somewhere in `$PATH`
* Install VirtualBox

#### Phase 1 - Bare metal VM provision
Phase 1 will:
* download install media
* define a VM inside VirtualBox
* attach the media
* start a web server to serve the Kickstart file
* boot the VM
* update the kernel boot line to add the Kickstart file URL
* start the install

Once installation has completed, VM rebooted and capable of booting off it's own disk, the build will then:
* run post-installation customisation
* prepare the image for Vagrant
* shut down the VM
* export the image for later stages to consume.

After the install media is downloaded, this process takes around 10-15 minutes (on a 4Mbps DSL line).

To perform this, from the root of the repository:

    cd packer
    packer build phase-1_centos7.json

After the install media has downloaded and Packer has prepared the VM definition, a VirtualBox video console will appear so the installation can be monitored.

If you wish to use this image to test the standalone execution of the provisioner scripts, add this box to your local cache:

    vagrant box add --name centos7 centos7.box

#### Phase 2 - Image provisioning
Phase 2 builds on top of the Phase 1 image, further specialising the image using '[provisioners](https://www.packer.io/docs/provisioners/index.html)'; these can be as simple as running a script or copying files around, or as complex as running full configuration management systems.

In this case, it implements the remainder of the challenge's requirements via a shell script and Puppet.

After the main provisioner has completed, [Goss](https://github.com/aelsabbahy/goss) is run to test the VM now matches the requirements.  If successful, the VM is shut down, exported, and converted to a Vagrant Base Box image.

##### Phase 2 - Shell provisioning
To perform this, from the root of the repository:

    cd packer
    packer build phase-2_shell.json

This process takes around 5 minutes.

To test via Vagrant, add this box to your local cache

    vagrant box add --name centos7-shell centos7-shell.box

##### Phase 2 - Puppet provisioning
To perform this, from the root of the repository:

    cd packer
    packer build phase-2_puppet.json

This process takes around 5 minutes.

To test via Vagrant, add this box to your local cache

    vagrant box add --name centos7-puppet centos7-puppet.box

#### Vagrant usage
Once you've added the Base Box images to your local cache, there are preconfigured Vagrantfiles to bring the machines up.  Each machine has a port forward set up to access Apache inside.  The 'challenge' repository is mounted inside the VM via Shared Folders; you can access this at `/challenge`.

To use this, you will need [Vagrant](https://vagrantup.com) installed; this was tested with v1.9.7, however anything recent should work.

To bring up and access the VMs:

##### Vanilla CentOS 7
Port 8080: [phpinfo](http://localhost:8080/phpinfo.php):

(note, as this is for simulating running the scripts on existing infrastructure, the port forward has been added, but it won't respond until provisioner scripts are executed)
From the root of the repository:

    cd vagrant/centos7
    vagrant up

##### Shell-provisioned
Port 8081: [phpinfo](http://localhost:8081/phpinfo.php):
From the root of the repository:

    cd vagrant/shell
    vagrant up

##### Puppet-provisioned
Port 8082: [phpinfo](http://localhost:8082/phpinfo.php):
From the root of the repository:

    cd vagrant/puppet
    vagrant up

## Existing Infrastructure
The same shell and Puppet provisioning tools can also be run on top of an existing CentOS 7 machine.

### Shell provisioner
As root:

    yum -y install git
    git clone https://github.com/gregwork/challenge.git
    cd challenge/provisioner/shell
    ./provision.sh

### Puppet provisioner
This has been tested against the version of Puppet currently shipped in EPEL (v3.6.2).  The structure/language features used are quite simple and are expected to work in any recent version; note that the 'puppet apply' command will likely need to change if being run with a Puppet agent v4 or above (replacing `--confdir` with `--codedir` should be enough).

As root:

    yum -y install epel-release git
    yum -y install puppet
    git clone https://github.com/gregwork/challenge.git
    cd challenge/provisioner/puppet
    puppet apply --confdir . manifests/site.pp

## Standalone validation
After the provisioners have finished, you can run the Goss tests to validate the state of the system.  The output is similar to 'rspec' by default; dots are good, letters (signifying different kinds of failures or skipped tests) are bad.  Failed or skipped tests will output more information about the problem.

As root:

    yum -y install git
    git clone https://github.com/gregwork/challenge.git
    cd challenge/validation
    ./goss-linux-amd64 validate

    # Sample output of a successful run:
    ...................

    Total Duration: 0.523s
    Count: 19, Failed: 0, Skipped: 0
