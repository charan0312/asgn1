import re
import os
import time
import sys
import boto.ec2
import boto.ec2.elb
import subprocess


#Copying files to workspace
os.system("cp /path/to/fabfile.py .")

# EC2 Bonanza
ec2 = boto.ec2.connect_to_region('us-west-1')
inst = boto.ec2.elb.connect_to_region('us-west-1')
#-------------Another way to get instances from ELB---------------------
#print inst
group = inst.get_all_load_balancers(load_balancer_names=['My-lb'])
instance_ids = [str(lb)[13:] for lb in group[0].instances]
#print instance_ids
#reservations = ec2.get_all_instances(instance_ids = instance_ids)
#print reservations
#instances = [i.ip_address for r in reservations for i in r.instances]
#print instances

health = inst.describe_instance_health('My-lb',instances=instance_ids)
print health

OutServiceVar = []
InServiceVar = []

for lb in health:
  if lb.state == 'OutOfService':
    print lb.instance_id 
    OutServiceVar = []   
    OutServiceVar.append(lb.instance_id)
    OutReservations = ec2.get_all_instances(instance_ids = OutServiceVar)
    print OutReservations
    OutInstances = [i.ip_address for r in OutReservations for i in r.instances]
    print OutInstances
    
    for j in OutInstances:
      txt = "sed -i 's/\\b\([0-9]\{1,3\}\.\)\{1,3\}[0-9]\{1,3\}\\b/#/g' /root/.jenkins/jobs/ansibleAssignmnt/workspace/inventory"
      os.system(txt)
      txt1 = "sed -i '2 a "+str(j)+"' /root/.jenkins/jobs/ansibleAssignmnt/workspace/inventory"
      os.system(txt1)
      subprocess.call(['fab','-f','fabfile.py', '-u centos','-i','/path/to/pem/file','-H',j,'passwd'])
      subprocess.call(['ansible-playbook','webserver.yml'])
      subprocess.call(['ansible-playbook','add_health_check.yml'])
  else:
    InServiceVar = []
    InServiceVar.append(lb.instance_id)

    InReservations = ec2.get_all_instances(instance_ids = InServiceVar)
    print "frm inservice var"
    InInstances = [i.ip_address for r in InReservations for i in r.instances]
    print InInstances

    for j in InInstances:
      txt = "sed -i 's/\\b\([0-9]\{1,3\}\.\)\{1,3\}[0-9]\{1,3\}\\b/#/g' /root/.jenkins/jobs/ansibleAssignmnt/workspace/inventory"
      os.system(txt)
      txt1 = "sed -i '2 a "+str(j)+"' /root/.jenkins/jobs/ansibleAssignmnt/workspace/inventory"
      os.system(txt1)
      subprocess.call(['fab','-f','fabfile.py', '-u centos','-i','/path/to/pem/file','-H',j,'passwd'])
      subprocess.call(['ansible-playbook','delete_health_check.yml'])
      time.sleep(20)
      if(lb.state == 'OutOfService'):
            OutServiceVar.append(lb.instance_id)
            OutReservations = ec2.get_all_instances(instance_ids = OutServiceVar)
           # print OutReservations
            OutInstances = [i.ip_address for r in OutReservations for i in r.instances]
           # print OutInstances
            for j in OutInstances:
              txt = "sed -i 's/\\b\([0-9]\{1,3\}\.\)\{1,3\}[0-9]\{1,3\}\\b/#/g' /root/.jenkins/jobs/ansibleAssignmnt/workspace/inventory"
              os.system(txt)
              txt1 = "sed -i '2 a "+str(j)+"' /root/.jenkins/jobs/ansibleAssignmnt/workspace/inventory"
              os.system(txt1)
              subprocess.call(['fab','-f','fabfile.py', '-u centos','-i','/path/to/pem/file','-H',j,'passwd'])
              subprocess.call(['ansible-playbook','webserver.yml'])
              subprocess.call(['ansible-playbook','add_health_check.yml'])
              time.sleep(20)
