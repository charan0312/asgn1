Import-Module "sqlps" -DisableNameChecking

$inst = "WIN-5N0KUV614KM"
$svr = new-object ('Microsoft.SqlServer.Management.Smo.Server') $inst

#Creating a Job
$j = new-object ('Microsoft.SqlServer.Management.Smo.Agent.Job') ($svr.JobServer, 'Agent Job 1')

#Defining properties of the job
$j.Description = 'Start SSIS Deployment'
$j.OwnerLoginName = 'Admin'
$j.Create()


#Creating Job Step
$js = new-object ('Microsoft.SqlServer.Management.Smo.Agent.JobStep') ($j, 'Step 01')
$js.SubSystem = 'SSIS'
$js.Command = '/FILE "\"C:\MK_Sample1\MK_Sample1\Package.dtsx\"" /CHECKPOINTING OFF /REPORTING E'
$js.OnSuccessAction = 'QuitWithSuccess'
$js.OnFailAction = 'QuitWithFailure'
$js.Create()



# Applying the specific server to run on 
$jsid = $js.ID
$j.ApplyToTargetServer($s.Name)
$j.StartStepID = $jsid
$j.Alter()

#Scheduling the job

$jsch = new-object ('Microsoft.SqlServer.Management.Smo.Agent.JobSchedule') ($j, 'Sched_01')
$jsch.FrequencyTypes = 'Daily'
$jsch.ActiveStartDate = get-date
$jsch.ActiveEndDate = "2199-12-31 23:59:59"
$jsch.FrequencyInterval = 1
#$jsch.GetType()
$jsch.Create()



