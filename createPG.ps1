$Filename = $args[0]
Import-Csv $Filename |  
foreach {  
	$myHost = $_.Name

	$vswitch = Get-VirtualSwitch -VMHost $myHost -Name vSwitch0
	#New-VirtualPortGroup -VirtualSwitch $vswitch -Name VLAN200 -VLanId 200
	Get-VirtualPortGroup -VirtualSwitch $vswitch -Name VLAN200

}