
#This script will create a new instance, get the password, and send it to the requester via email as discussed in exercise 1 of chapter 3.    

Param(
    [string][Parameter(Mandatory=$false)] $ImageID, 
    [string][Parameter(Mandatory=$false)] $KeyName = 'MyKey',
    [string][Parameter(Mandatory=$false)] $PemFile = 'c:\aws\MyKey.pem',
    [string][Parameter(Mandatory=$false)] $InstanceType = 't1.micro',
    [string][Parameter(Mandatory=$true)] $EmailRecipient 
)

#This function waits for the password and then returns it
Function GetPasswordWhenReady()
{
    Param(
        [string][Parameter(Mandatory=$True)] $InstanceId,
        [string][Parameter(Mandatory=$True)] $PemFile,
        [Int] $TimeOut = 30
    )
        
    $RetryCount = $TimeOut

    Write-Host "Waiting for password" -NoNewline

    While($RetryCount -gt 1) {
        Try {
            $Password = Get-EC2PasswordData -InstanceId $InstanceId -PemFile $PemFile
            Write-Host ""
            Return $Password
        } Catch {
            $RetryCount--
            Start-Sleep -s 60 #It's not ready.  Let's wait for it.
            Write-Host "." -NoNewline #It's nice to give a little feedback now and then
        }
    }
}

#Send an email to the requester including the connection info for the new instance.
Function SendInstanceReadyEmail()
{
    Param(
        [string][Parameter(Mandatory=$True)] $Recipient,
        [string][Parameter(Mandatory=$True)] $InstanceName,
        [string][Parameter(Mandatory=$True)] $Password
     )
     $Message = "You can access the instance at $InstanceName.  The administrator password is $Password."
    
     #Create the message 
     $Email = New-Object Net.Mail.MailMessage
     $Email.From = "admin@brianbeach.com"
     $Email.ReplyTo = "admin@brianbeach.com"
     $Email.To.Add($Recipient)
     $Email.Subject = "Your Instance is Ready"
     $Email.Body = $Message

     #Send the message      
     $SMTP = New-Object Net.Mail.SmtpClient('smtp.brianbeach.com')
     $SMTP.Send($Email)
}

#Create a new instance
If([System.String]::IsNullOrEmpty($ImageID)){ $ImageID = (Get-EC2ImageByName -Name "WINDOWS_2012_BASE")[0].ImageId}
$Reservation = New-EC2Instance -ImageId $ImageID -KeyName $KeyName -InstanceType $InstanceType -MinCount 1 -MaxCount 1
$InstanceId = $Reservation.RunningInstance[0].InstanceId

#Get the password to the new instance
$Password = GetPasswordWhenReady -Instance $InstanceId -PemFile $PemFile

#Get the latest meta-data including the DNS name
$Reservation = Get-EC2Instance –Instance $InstanceId
$InstanceName = $Reservation.RunningInstance[0].PublicDnsName

#Send an email with connection info
SendInstanceReadyEmail -Recipient $EmailRecipient -InstanceName $InstanceName -Password $Password
