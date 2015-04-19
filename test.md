Updating the devopsdays.org website using Windows
---------------------------------------------------------------------------------
Unfortunately the devopsdays.org website and webby aren't friendly to use on Microsoft Windows. This guide will help you setup an environment so you can clone, edit and test the devopsdays.org website.  The guide could also be used for Mac and Linux operating systems but the focus is on Windows.


#### Why doesn't it work on Windows already?

 - Installing Ruby and all of the required gems can be hard
 - There are files in the repository which contain invalid characters e.g. colon ':' or question mark '?'. These are seen by git as a file delete.


#### How do we it edit then?

To edit devopsdays.org we need to create a Virtual Machine running Linux and then edit the files in the virtual filesystem.  Fortunately most of the work has already been done as the project maintainers have created a Vagrant build for it.  

#### What do I need to know?
- Basic Linux skills (How to login, basic shell commands)
- Basic VirtualBox skills (Start/Stop VM, edit VM settings)
- Basic git skills (Clone, branch and commit from command line)


## Setting up the environment

The guide below uses `C:\DevOpsDays` as a working directory, but you can use something different.

If you intend to submit a Pull Request (PR) with changes, make sure you fork the repository first (https://github.com/jedi4ever/devopsdays-webby)  and use that as the Git source.

### Install the prerequisites
- Install Vagrant (https://www.vagrantup.com/)
- Install git client (http://git-scm.com/downloads)
- Install VirtualBox (https://www.virtualbox.org/)
- Install SSH Client (http://www.putty.org/)

You can install these easily with Chocolatey
```
choco install vagrant git virtualbox putty
```

Optionally you can install an FTP client or text editor with FTP support e.g. Filezilla or Notepad++ with NppFTP plugin.
```
choco install filezilla
choco install notepadplusplus
```

### Create the Virtual Machine

- Clone the repository on Windows. 
```
git clone <git source URL> c:\DevOpsDays
```
**Ignore the file errors as we really only the need the Vagrant setup and support files.**

Open an administrator command prompt and start the Vagrant process
```
CD /D C:\DevOpsDays
vagrant up
```
... and now wait while your Virtual Machine is created

Once the build process has finished try the website by browsing to `http://127.0.0.1:8000`

### Install an FTP server in the Virtual Machine

5. Install an FTP server in the vm
SSH into the vm (127.0.0.1:2222)
sudo apt-get install vsftpd
sudo nano /etc/vsftpd.conf
local_enable=YES
write_enable=YES
pasv_enable=Yes
pasv_max_port=10100
pasv_min_port=10100
pasv_address=127.0.0.1
sudo service vsftpd restart

Try an ftp connection to 127.0.0.1 port 2021

6. Remove the Vagrant shared/sync folder and restart the VM In Virtualbox edit the settings for the virtual machine Remove the vagrant shared folder

In the SSH session
sudo shutdown -r now

7. Clone the repository
SSH into the VM

sudo chown vagrant /vagrant

git clone <clone url> /vagrant

Note - remember to checkout the appropriate branches too

8. Do a Webby build
SSH into the VM

cd /vagrant/site
webby build

or to build continuously

cd /vagrant/site
webby autobuild

Browse to http://127.0.0.1:8000 to see your handy work

9. Update the files in /vagrant using an FTP client or FTP plugin (e.g.
NppFTP in Notepad++)

Remember to do a Webby build to see the results of the changes


10. Use the standard git commands to push your changes back to your repo.

Don't forget to setup git for the first time http://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup
https://help.github.com/articles/keeping-your-email-address-private/



