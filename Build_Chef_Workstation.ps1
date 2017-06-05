# Setup my execution policy for both the 64 bit and 32 bit shells
set-executionpolicy remotesigned
start-job -runas32 {set-executionpolicy remotesigned} | receive-job -wait

# Install the latest stable ChefDK
invoke-restmethod 'https://omnitruck.chef.io/install.ps1' | iex
install-project chefdk -verbose

# Install Chocolatey
invoke-expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation

# Get a basic setup recipe
invoke-restmethod 'https://gist.github.com/jasonroth/55516bd4f19adb769572d0e2886df123/raw' | out-file -encoding ascii -FilePath c:/chef_workstation.rb

# Use Chef Apply to setup 
chef-apply c:/chef_workstation.rb
