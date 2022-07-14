#Install the Az module if you haven't done so already.
#Install-Module Az
#Login to your Azure account. Connect-AzAccount -TenantId 2786c079-439a-4cd8-b23c-39fa73318b34
#Login-AzAccount
#Define the following parameters for the virtual machine.
#changes added -Enable -ResourceGroupName $azureResourceGroup  -StorageAccountName $azureStorageAccountName Update-AzVM -VM $VirtualMachine -ResourceGroupName $azureResourceGroup to line #39 
# added this to line #16 $azureStorageAccountName	= "fastercloudhosteddiag"
$vmAdminUsername = "fasteradmin"
$vmAdminPassword = ConvertTo-SecureString "aZS1VN9WGy41" -AsPlainText -Force
$vmComputerName = "lakewood"
#Define the following parameters for the Azure resources.
$azureLocation              = "EastUS"
$azureResourceGroup         = "FASTERCloudHosted"
$azureVmName                = "lakewood"
$azureVmOsDiskName          = "lakewoodDisk"
$azureStorageAccountName	= "fastercloudhosteddiag"
$azureVmSize                = "Standard_B2ms"
#Define the networking information.
$azureNicName               = "lakewood-NIC"
$azurePublicIpName          = "lakewood-IP"
#Define the existing VNet information.
$azureVnetName              = "fastercloudhostedpublic"
$azureVnetSubnetName        = "fasterhostedpublic"
#Define the VM marketplace image details.
$azureVmPublisherName = "MicrosoftWindowsServer"
$azureVmOffer = "WindowsServer"
$azureVmSkus = "2019-Datacenter"
#Get the subnet details for the specified virtual network + subnet combination.
$azureVnetSubnet = (Get-AzVirtualNetwork -Name $azureVnetName -ResourceGroupName $azureResourceGroup).Subnets | Where-Object {$_.Name -eq $azureVnetSubnetName}
#Create the public IP address.
$azurePublicIp = New-AzPublicIpAddress -Name $azurePublicIpName -ResourceGroupName $azureResourceGroup -Location $azureLocation -AllocationMethod Static
#Create the NIC and associate the public IpAddress.
$azureNIC = New-AzNetworkInterface -Name $azureNicName -ResourceGroupName $azureResourceGroup -Location $azureLocation -SubnetId $azureVnetSubnet.Id -PublicIpAddressId $azurePublicIp.Id
#Store the credentials for the local admin account.
$vmCredential = New-Object System.Management.Automation.PSCredential ($vmAdminUsername, $vmAdminPassword)
#Define the parameters for the new virtual machine.
$VirtualMachine = New-AzVMConfig -VMName $azureVmName -VMSize $azureVmSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $vmComputerName -Credential $vmCredential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $azureNIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName $azureVmPublisherName -Offer $azureVmOffer -Skus $azureVmSkus -Version "latest"
$VirtualMachine = Set-AzVMBootDiagnostic -VM $VirtualMachine -Enable -ResourceGroupName $azureResourceGroup  -StorageAccountName $azureStorageAccountName Update-AzVM -VM $VirtualMachine -ResourceGroupName $azureResourceGroup
$VirtualMachine = Set-AzVMOSDisk -VM $VirtualMachine -StorageAccountType "Standard_LRS" -Caching ReadWrite -Name $azureVmOsDiskName -CreateOption FromImage
#Create the virtual machine.
New-AzVM -ResourceGroupName $azureResourceGroup -Location $azureLocation -VM $VirtualMachine -Verbose
