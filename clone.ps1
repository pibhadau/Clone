#Author: Jason Ho

#Usage: clone VMs from a list
#		.\clone-from-a-single-source.ps1 List-of-VMs.csv

## Attention: Windows use global variables for all shells so don't run multiple PowerCLI and this will mess up the Custom Spec (hostnames / IPs)
##            If you hit "CTRL + C" then you should shutdown the PowerCLI window as well, to clear up variables that still existed in the shell


#You have to connect to vcenter server before running this script 
#connect-viserver csg-sjc-vc1  
#$vc = "csg-sjc-vc1"
 
 

#Specify Cluster name:
#$clusterName = "Selenium"
  
#Customisation settings name  
#	$CustomSpec = "Windows-7-cloning-200VMs"   defined below Already !!
$Filename = $args[0]
  
#Import vm name and ip from csv file  
Import-Csv $Filename |  
foreach {  
    $CustomSpec = $_.customspec
	$myTemplate = $_.template
	$MyNewVM = $_.name  
    $myIP = $_.ip
	$MoveFolderName = $_.folder
	$myDatastoreCluster = $_.datastore
	$myHost = $_.esxiHost
	$myNetmask = $_.netmask
	$myGateway = $_.gateway
	$myDNS1 = $_.dns1
	$myDNS2 = $_.dns2
	$res =$_.resourcepool

	
	# Update the Customization Specification
Get-OSCustomizationSpec $CustomSpec `
| Get-OSCustomizationNicMapping `
| Set-OSCustomizationNicMapping `
-IpMode:UseStaticIP `
-IpAddress $myIP `
-SubnetMask $myNetmask `
-Dns $myDNS1 `
-DefaultGateway $myGateway

$respool = Get-Cluster $res
$vswitch = Get-VirtualSwitch -VMHost $myHost -Name vSwitch0
$portgroup = Get-VirtualPortGroup -VirtualSwitch $vswitch -Name VLAN200

    write-host "Build started ++++++++ $MyNewVM ------ $ip "  
		 

#New-VM -Name $MyNewVM -ResourcePool $respool -VM $myTemplate -Location $folder -Datastore $myDatastoreCluster -DiskStorageFormat Thin -VMHost $myhost | Set-VM -OSCustomizationSpec $CustomSpec -Confirm:$false | Start-VM  #-RunAsync

New-VM -Name $MyNewVM -VM $myTemplate -Portgroup $portgroup -Datastore $myDatastoreCluster -DiskStorageFormat Thin -VMHost $myhost | Set-VM -OSCustomizationSpec $CustomSpec -Confirm:$false | Start-VM -RunAsync

# -RunAsync:$false 		<-- if you want to run one by one
# -RunAsync				<-- if you want to run all at once!

    $Report += "$MyNewVM  " 
#	Move-VM (Get-VM $MyNewVM)  -Destination (Get-Folder $MoveFolderName) 
	
}  
  
write-host "Sleeping ..."  
Sleep 5
  
#Send out an email with the names  

#$emailFrom = "jho2@cisco.com"  
#$emailTo = "jho2@cisco.com"  
#$subject = "List of VMs built"  
#$smtpServer = "outbound.cisco.com"  
#$smtp = new-object Net.Mail.SmtpClient($smtpServer)  
#$smtp.Send($emailFrom, $emailTo, $subject, $Report)  
  
#Disconnect from vcenter server  
#disconnect-viserver $vcenter -Confirm:$false