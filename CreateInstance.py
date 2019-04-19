import boto.ec2
import time
import boto.ec2.blockdevicemapping
import sys
time.sleep(10)

con = boto.ec2.connect_to_region("ap-northeast-2",
                      aws_access_key_id='',
                      aws_secret_access_key='' )


test_script = """<powershell> Set-ExecutionPolicy RemoteSigned -Force
                        Set-item wsman:\localhost\Client\TrustedHosts -value '*' -Force 
                        Set-NetFirewallRule -DisplayName 'Windows Remote Management (HTTP-In)' -RemoteAddress 'Any' 
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
$user = [ADSI]"WinNT://./Administrator,user"
$user.SetPassword("Password@123")

           </powershell>"""

x = int(sys.argv[1])


print "--------creating and storing Instance Id --------"

dev_sda1 = boto.ec2.blockdevicemapping.EBSBlockDeviceType()
dev_sda1.size = 50 
dev_sda1.deleteOnTermination = 'True'
bdm = boto.ec2.blockdevicemapping.BlockDeviceMapping()
bdm['/dev/sda1'] = dev_sda1

var = con.run_instances(
   'ami-c6de16a8',
   min_count=1,
   max_count=x,
   key_name='Rakeshpem',
   placement='ap-northeast-2a',
   instance_type='t2.micro',
   block_device_map = bdm,
   user_data=test_script
)

time.sleep(5)

reservations = con.get_all_instances(filters={'instance-state-name':'pending'})
#instances = [i for r in reservations for i in r.instances]
for r in reservations:
  for i in r.instances:

    i.add_tag('Name', 'webserver')

    while not i.state == "running":
      time.sleep(10)
      i.update()

web = con.get_all_instances(filters={'tag-value' : 'webserver'})
webInst = [j for t in web for j in t.instances]
orig_stdout = sys.stdout
f = file('out.txt','w')
sys.stdout = f

for i in webInst:
  if (i.ip_address != None):
   print(i.id)
   print(i.ip_address) 

sys_stdout = orig_stdout
f.close()


