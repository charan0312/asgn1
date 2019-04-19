from fabric.api import *
def hello(name):
  print "Hello World %s" %name


from fabric.api import *
env.user ='centos'
#env.hosts =['52.79.144.14']

from fabric.api import local

def prepare_deploy():
  local("cd /tmp/fabric-test && touch file1 file2")
  local("cd /tmp/fabric-test && git add . && git commit -m test")
  local("cd /tmp/fabric-test && git push origin master")





#var = raw_input("Enter username")
def passwd():
  sudo("sed -i 's/PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config")
  sudo("sed -i 's/Defaults.*.requiretty/Defaults\t!requiretty/' /etc/sudoers")
  sudo("service sshd restart",pty=False)
 # var = raw_input("Enter username")
 # run("sudo useradd %s" %var)
  run("id -u user1 &>/dev/null || sudo useradd user1")
 # run("sudo echo -e '%s:hello@123' | sudo  chpasswd " %var)
  run("sudo echo -e 'user1:hello@123' |sudo  chpasswd")
  
  sudo("echo 'user1  ALL = (ALL)   ALL' >> /etc/sudoers") 
def sudoersPermission():
  #sudo("echo '%s  ALL = (ALL)   ALL' >> /etc/sudoers" %var) 
  
  sudo("echo 'user1  ALL = (ALL)   ALL' >> /etc/sudoers") 
def passwdAuth():
  sudo("sed -i 's/PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config")
  sudo("service sshd restart")

