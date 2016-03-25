from __future__ import with_statement
from fabric.api import *
from fabric.contrib.console import confirm
env.user = 'centos'
#env.hosts = ['54.233.105.100']


def user_create():
	sudo('useradd user1')
	sudo('echo "Welcome@1234" | passwd user1 --stdin')

def user_sudoer():
	sudo('echo "user1	ALL=(ALL)		ALL" | tee -a /etc/sudoers')
	sudo('sed -i "s/Defaults    requiretty/#Defaults    requiretty/g" /etc/sudoers')
	sudo('sed -i "s/requiretty/!requiretty/g" /etc/sudoers')
	


def start_ssh():
	sudo('sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config')
#	sudo('echo -e "\nPasswordAuthentication yes" | tee -a /etc/ssh/sshd_config')
	sudo('service sshd restart', pty=False)


def task1():
	if (run("grep -c 'user1' /etc/passwd") < 1):
		user_create()
	user_sudoer()
	start_ssh()
	


