Import-Module "C:\Users\BTJ\Putty\Connect-Mstsc.ps1" -Verbose -Global
Set-Location "C:\Users\BTJ\Putty"
Set-Alias -Name ch -Value connect-host -Description "RDP and SSH server using script"
$mcmd = "C:\Users\BTJ\Putty\m_file.txt"
$Logpath = "C:\Users\BTJ\Putty\Logs\"
function connect-host{

    param([string]$ostype,
          [string[]]$srvnames,
          [string[]]$getpass)
        $current_Location = Get-Location
        $current_Location.path

#This will check and login to host with credentials passed earlier
        if($getpass -eq "set"){
        "WinUser" | clip
        Read-Host -Prompt "Enter credentials for WinUser " | sc .\w_plist.info
        "UnixUser" | clip
        Read-Host -Prompt "Enter credentials for UnixUser " | sc .\u_plist.info
        "StorUser" | clip
        Read-Host -Prompt "Enter credentials for StorUser " | sc .\wci_plist.info
        "BackupUsr" | clip
        Read-Host -Prompt "Enter credentials for BackupUsr " | sc .\uci_plist.info
        $srvnames = "ignore"
        }elseif($getpass -eq "win"){
			write-host "Copying WinUser to clip"
			gc .\w_plist.info | clip
			$srvnames = "ignore"
        }elseif($getpass -eq "unix"){
			write-host "Copying UnixUser to clip"
			gc .\u_plist.info | clip
			$srvnames = "ignore"
        }elseif($getpass -eq "storage"){
			write-host "Copying BackupUsr to clip"
			gc .\uci_plist.info | clip
			$srvnames = "ignore"
        }elseif($getpass -eq "backup"){
			write-host "Copying StorUser to clip"
			gc .\wci_plist.info | clip
			$srvnames = "ignore"
        }

        set-location -Path "C:\Users\BTJ\Putty"
        if($ostype -eq 'Unix'){
            $usr = 'UnixUser'
            $conn_pw = Get-Content -Path "C:\Users\BTJ\Putty\u_plist.info"
            $conn_pw | clip
        }elseif($ostype -eq 'Win'){
            $usr = 'WinUser'
            $conn_pw = Get-Content -Path "C:\Users\BTJ\Putty\w_plist.info"
        }elseif($ostype -eq 'ciwin'){
            $usr = 'StorUser'
            $conn_pw = Get-Content -Path "C:\Users\BTJ\Putty\wci_plist.info"
        }elseif($ostype -eq 'ciunix'){
            $usr = 'BackupUsr'
            $conn_pw = Get-Content -Path "C:\Users\BTJ\Putty\uci_plist.info"
            $conn_pw | clip
        }elseif($ostype -eq 'Sto'){
            $usr = 'WinUser'
            $conn_pw = Get-Content -Path "C:\Users\BTJ\Putty\w_plist.info"
        }elseif($ostype -eq 'devunix'){
            $usr = 'user'
            $conn_pw = 'pass'
            $conn_pw | clip
        }elseif($ostype -eq 'devwin'){
            $usr = 'user'
            $conn_pw = 'pass'
            $conn_pw | clip
        }elseif($ostype -eq 'putty'){
            $usr = 'WinUser'
            $conn_pw = Get-Content -Path "C:\Users\BTJ\Putty\w_plist.info"
        }
        
        if($srvnames -eq $null){
        $srvnames = Get-Content -Path "C:\Users\BTJ\Putty\Server_List.info"
        }
               
        if($srvnames -ne "ignore"){
                foreach($srv in $srvnames){
                Write-Host "Connecting $srv as $usr using $ostype authentication"
                $conn = Test-Connection $srv -Quiet -Count 1
                    if($conn){
                        if(($ostype -eq "Unix") -or ($ostype -eq "ciunix") -or ($ostype -eq "Sto")-or ($ostype -eq "devunix")){
                            .\putty "$usr@$srv" -pw $conn_pw 
                        }elseif(($ostype -eq "win") -or ($ostype -eq "ciwin")){
                            #Write-Host "$srv and $usr and $conn_pw"
                            Connect-Mstsc -ComputerName $srv -User "BC\$usr" -Password $conn_pw 
                        }elseif($ostype -eq "devwin"){
                           #Write-Host "$srv and $usr and $conn_pw"
                            Connect-Mstsc -ComputerName $srv -User "dev2\$usr" -Password $conn_pw 
                        }elseif($ostype -eq "dev3"){
                            #Write-Host "$srv and $usr and $conn_pw"
                            Connect-Mstsc -ComputerName $srv -User "dev3\$usr" -Password $conn_pw 
                        }elseif($ostype -eq "putty"){
                            $fLogpath = $Logpath + $srv + ".txt"
                            $fLogpath
                            echo y | .\plink "$usr@$srv" -pw $conn_pw -m $mcmd >$fLogpath
                            #$mcmd = Get-Content .\m_file.txt | clip
                        }else{
                        Write-Host "Unknown Host type"
                        }
                     }else{
                        write-host "$srv reachable  Status is $conn"
                     }
            }
        }

$srvnames = $null
Set-Location $current_Location
timeout 5
#cls 
}
