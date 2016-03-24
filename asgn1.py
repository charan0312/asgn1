import boto
import boto.ec2.autoscale


ec2 = boto.ec2.connect_to_region('sa-east-1')

as1 = boto.ec2.autoscale.connect_to_region('sa-east-1')

res = as1.get_all_groups(['ASG2'])[0]
print res
instance_ids = [i.instance_id for i in res.instances]
print instance_ids
reservations = ec2.get_all_instances(instance_ids)
print reservations
instances = [i.ip_address for r in reservations for i in r.instances]
print instances

ip_str1 = '\n'.join(instances)
ip_str2 = ','.join(instances)
print ip_str



import fileinput
import sys
import re
def replace(file,searchExp,replaceExp):
	for line in fileinput.input(file, inplace=1):
		if searchExp in line:
			line = line.replace(searchExp,replaceExp)
		sys.stdout.write(line)

replace("./inventory", "[webservers]", "[webservers]" + "\n" + ip_str)












