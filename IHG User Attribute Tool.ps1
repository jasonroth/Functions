﻿#Generated Form Function
function GenerateForm {
########################################################################
# Code Generated By: SAPIEN Technologies PrimalForms (Community Edition) v1.0.10.0
# Generated On: 9/9/2015 4:31 PM
# Generated By: RothJa
########################################################################

#region Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
#endregion

#region Generated Form Objects
$form1 = New-Object System.Windows.Forms.Form
$checkBox_cea3 = New-Object System.Windows.Forms.CheckBox
$checkBox_cea2 = New-Object System.Windows.Forms.CheckBox
$checkBox_cea1 = New-Object System.Windows.Forms.CheckBox
$textBox_cea3 = New-Object System.Windows.Forms.TextBox
$textBox_cea2 = New-Object System.Windows.Forms.TextBox
$textBox_cea1 = New-Object System.Windows.Forms.TextBox
$label_cea3 = New-Object System.Windows.Forms.Label
$label_cea2 = New-Object System.Windows.Forms.Label
$label_cea1 = New-Object System.Windows.Forms.Label
$button_set = New-Object System.Windows.Forms.Button
$label_location = New-Object System.Windows.Forms.Label
$textBox_location = New-Object System.Windows.Forms.TextBox
$checkBox_cea10 = New-Object System.Windows.Forms.CheckBox
$textBox_search = New-Object System.Windows.Forms.TextBox
$button_search = New-Object System.Windows.Forms.Button
$label_search = New-Object System.Windows.Forms.Label
$checkBox_display = New-Object System.Windows.Forms.CheckBox
$checkBox_last = New-Object System.Windows.Forms.CheckBox
$checkBox_first = New-Object System.Windows.Forms.CheckBox
$richTextBox1 = New-Object System.Windows.Forms.RichTextBox
$textBox_cea10 = New-Object System.Windows.Forms.TextBox
$label_cea10 = New-Object System.Windows.Forms.Label
$textBox_o365 = New-Object System.Windows.Forms.TextBox
$label_o365 = New-Object System.Windows.Forms.Label
$textBox_empid = New-Object System.Windows.Forms.TextBox
$label_empID = New-Object System.Windows.Forms.Label
$textBox_email = New-Object System.Windows.Forms.TextBox
$label_email = New-Object System.Windows.Forms.Label
$textBox_logon = New-Object System.Windows.Forms.TextBox
$label_logon = New-Object System.Windows.Forms.Label
$textBox_display = New-Object System.Windows.Forms.TextBox
$label_display = New-Object System.Windows.Forms.Label
$textBox_last = New-Object System.Windows.Forms.TextBox
$label_last = New-Object System.Windows.Forms.Label
$textBox_first = New-Object System.Windows.Forms.TextBox
$label_first = New-Object System.Windows.Forms.Label
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
#endregion Generated Form Objects

#----------------------------------------------
#Generated Event Script Blocks
#----------------------------------------------
#Provide Custom Code for events specified in PrimalForms.
$Search_AD = {

    Refresh-Form
	
	$richTextBox1.AppendText("Searching AD...`r")

	$Search = $textBox_search.text
	$script:User = 
    Get-ADUser -Server corp.local:3268 -Filter {
        (SamAccountName -like $Search)-or (
        Mail -eq $Search)} -Properties DisplayName, Mail, msDS-cloudExtensionAttribute1, msDS-cloudExtensionAttribute2, msDS-cloudExtensionAttribute3, msDS-cloudExtensionAttribute10,msDS-cloudExtensionAttribute16, EmployeeID, physicalDeliveryOfficeName -ErrorAction Stop

    if (($script:User).Count -gt 1) {
        $script:User | Out-GridView -Title "Duplicate accounts found! Please select target account." -PassThru -OutVariable script:User
    }

    if ($script:User) {
	    $textBox_first.text = $User.GivenName
	    $textBox_last.text = $User.Surname
	    $textBox_display.text = $User.DisplayName
	    $textBox_logon.text = $User.SamAccountName
	    $textBox_email.text = $User.Mail
        $textBox_cea1.text = $User.'msDS-cloudExtensionAttribute1'
        $textBox_cea2.text = $User.'msDS-cloudExtensionAttribute2'
        $textBox_cea3.text = $User.'msDS-cloudExtensionAttribute3'
	    $textBox_cea10.text = $User.'msDS-cloudExtensionAttribute10'
	    $textBox_empid.text = $User.EmployeeID
	    $textBox_o365.text = $User.'msDS-cloudExtensionAttribute16'
        $textBox_location.text = $User.physicalDeliveryOfficeName
        $richTextBox1.clear()	
	}
	else {
	    $ID = $textBox_search.text
	    $richtextbox1.SelectionColor = 'Red'
	    $richTextBox1.AppendText("Could not find user account $ID in AD")
	}

}

$click_first = {

	if ($checkBox_first.Checked){$textBox_first.ReadOnly = $False}
	else {
	    $textBox_first.text = $script:User.GivenName
	    $textBox_first.ReadOnly = $True
	}
}

$click_last = {
	
    if ($checkBox_last.Checked){$textBox_last.ReadOnly = $False}
	else {
	    $textBox_last.text = $script:User.SurName
	    $textBox_last.ReadOnly = $True
	}
}

$click_display = {
	
    if ($checkBox_display.Checked){$textBox_display.ReadOnly = $False}
	else {
	    $textBox_display.text = $script:User.DisplayName
	    $textBox_display.ReadOnly = $True
	}
}

$click_cea1 = {
	
    if ($checkBox_cea1.Checked){$textBox_cea1.ReadOnly = $False}
	else {
	    $textBox_cea1.text = $script:User.'msDS-cloudExtensionAttribute1'
	    $textBox_cea1.ReadOnly = $True
	}
}

$click_cea2 = {
	
    if ($checkBox_cea2.Checked){$textBox_cea2.ReadOnly = $False}
	else {
	    $textBox_cea2.text = $script:User.'msDS-cloudExtensionAttribute2'
	    $textBox_cea2.ReadOnly = $True
	}
}

$click_cea3 = {
	
    if ($checkBox_cea3.Checked){$textBox_cea3.ReadOnly = $False}
	else {
	    $textBox_cea3.text = $script:User.'msDS-cloudExtensionAttribute3'
	    $textBox_cea3.ReadOnly = $True
	}
}

$click_cea10 = {
	
    if ($checkBox_cea10.Checked){$textBox_cea10.ReadOnly = $False}
	else {
	    $textBox_cea10.text = $script:User.'msDS-cloudExtensionAttribute10'
	    $textBox_cea10.ReadOnly = $True
	}
}

$Set_Attributes = {
	
    $Domain = $script:user.UserPrincipalName.Split('@')[1]
	
	if ($checkBox_first.Checked)	{
		[string]$First = $textBox_first.text
	    try	{
	    	Set-ADUser -Server $Domain -Identity $script:User.SamAccountName -GivenName $First
	    	$richTextBox1.AppendText("First Name set to: $First`r")
	    }
	    catch {
	    	$richtextbox1.SelectionColor = 'Red'
	    	$richTextBox1.AppendText("Failed to set First Name to: $First`r")
	    	$richTextBox1.AppendText($Error[0])
	    	$richTextBox1.AppendText("`r`r")
	    }
    }
	
	if ($checkBox_last.Checked)	{
		[string]$Last = $textBox_last.text
		try	{
            Set-ADUser -Server $Domain -Identity $script:User.SamAccountName -Surname $Last	    
		    $richTextBox1.AppendText("Last Name set to: $Last`r")
	    }
	    catch {
		    $richtextbox1.SelectionColor = 'Red'
		    $richTextBox1.AppendText("Failed to set Last Name to: $Last`r")
		    $richTextBox1.AppendText($Error[0])
		    $richTextBox1.AppendText("`r")
	    }	
	}

	if ($checkBox_display.Checked) {
		[string]$Display = $textBox_display.text
	    try	{
		    Set-ADUser -Server $Domain -Identity $script:User.SamAccountName -DisplayName $Display
            $richTextBox1.AppendText("Display Name set to: $Display`r")
	    }
	    catch {
		    $richtextbox1.SelectionColor = 'Red'
		    $richTextBox1.AppendText("Failed to set Display Name to: $Display`r")
		    $richTextBox1.AppendText($Error[0])
		    $richTextBox1.AppendText("`r`r")
	    }
    }

	if ($checkBox_cea1.Checked) {
		[string]$cea1 = $textBox_cea1.text
	    try	{
		    Set-ADUser -Server $Domain -Identity $script:User.SamAccountName -Replace @{'MSDS-CloudExtensionAttribute1'=$cea1}
            $richTextBox1.AppendText("msDS-cloudExtensionAttribute1 set to: $cea1`r")
	    }
	    catch {
		    $richtextbox1.SelectionColor = 'Red'
		    $richTextBox1.AppendText("Failed to set msDS-cloudExtensionAttribute10 to: $cea1`r")
		    $richTextBox1.AppendText($Error[0])
		    $richTextBox1.AppendText("`r`r")
	    }
    }

    if ($checkBox_cea2.Checked) {
		[string]$cea2 = $textBox_cea2.text
	    try	{
		    Set-ADUser -Server $Domain -Identity $script:User.SamAccountName -Replace @{'MSDS-CloudExtensionAttribute2'=$cea2}
            $richTextBox1.AppendText("msDS-cloudExtensionAttribute2 set to: $cea10`r")
	    }
	    catch {
		    $richtextbox1.SelectionColor = 'Red'
		    $richTextBox1.AppendText("Failed to set msDS-cloudExtensionAttribute10 to: $cea2`r")
		    $richTextBox1.AppendText($Error[0])
		    $richTextBox1.AppendText("`r`r")
	    }
    }

    if ($checkBox_cea3.Checked) {
		[string]$cea3 = $textBox_cea3.text
	    try	{
		    Set-ADUser -Server $Domain -Identity $script:User.SamAccountName -Replace @{'MSDS-CloudExtensionAttribute3'=$cea3}
            $richTextBox1.AppendText("msDS-cloudExtensionAttribute3 set to: $cea3`r")
	    }
	    catch {
		    $richtextbox1.SelectionColor = 'Red'
		    $richTextBox1.AppendText("Failed to set msDS-cloudExtensionAttribute3 to: $cea3`r")
		    $richTextBox1.AppendText($Error[0])
		    $richTextBox1.AppendText("`r`r")
	    }
    }

    if ($checkBox_cea10.Checked) {
		[string]$cea10 = $textBox_cea10.text
	    try	{
		    Set-ADUser -Server $Domain -Identity $script:User.SamAccountName -Replace @{'MSDS-CloudExtensionAttribute10'=$cea10}
            $richTextBox1.AppendText("msDS-cloudExtensionAttribute10 set to: $cea10`r")
	    }
	    catch {
		    $richtextbox1.SelectionColor = 'Red'
		    $richTextBox1.AppendText("Failed to set msDS-cloudExtensionAttribute10 to: $cea10`r")
		    $richTextBox1.AppendText($Error[0])
		    $richTextBox1.AppendText("`r`r")
	    }
    }
}

$OnLoadForm_StateCorrection=
{#Correct the initial state of the form to prevent the .Net maximized form issue
	$form1.WindowState = $InitialFormWindowState
}

#----------------------------------------------
#region Generated Form Code
$form1.BackColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 720
$System_Drawing_Size.Width = 692
$form1.ClientSize = $System_Drawing_Size
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$form1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",8.25,1,3,1)
$form1.Name = "form1"
$form1.Text = "IHG User Attribute Tool"


$checkBox_cea3.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 281
$System_Drawing_Point.Y = 427
$checkBox_cea3.Location = $System_Drawing_Point
$checkBox_cea3.Name = "checkBox_cea3"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 16
$checkBox_cea3.Size = $System_Drawing_Size
$checkBox_cea3.TabIndex = 13
$checkBox_cea3.UseVisualStyleBackColor = $True
$checkBox_cea3.add_CheckStateChanged($click_cea3)

$form1.Controls.Add($checkBox_cea3)


$checkBox_cea2.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 281
$System_Drawing_Point.Y = 397
$checkBox_cea2.Location = $System_Drawing_Point
$checkBox_cea2.Name = "checkBox_cea2"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 16
$checkBox_cea2.Size = $System_Drawing_Size
$checkBox_cea2.TabIndex = 11
$checkBox_cea2.UseVisualStyleBackColor = $True
$checkBox_cea2.add_CheckStateChanged($click_cea2)

$form1.Controls.Add($checkBox_cea2)


$checkBox_cea1.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 281
$System_Drawing_Point.Y = 370
$checkBox_cea1.Location = $System_Drawing_Point
$checkBox_cea1.Name = "checkBox_cea1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 16
$checkBox_cea1.Size = $System_Drawing_Size
$checkBox_cea1.TabIndex = 9
$checkBox_cea1.UseVisualStyleBackColor = $True
$checkBox_cea1.add_CheckStateChanged($click_cea1)

$form1.Controls.Add($checkBox_cea1)

$textBox_cea3.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 303
$System_Drawing_Point.Y = 427
$textBox_cea3.Location = $System_Drawing_Point
$textBox_cea3.Name = "textBox_cea3"
$textBox_cea3.ReadOnly = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 367
$textBox_cea3.Size = $System_Drawing_Size
$textBox_cea3.TabIndex = 14

$form1.Controls.Add($textBox_cea3)

$textBox_cea2.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 303
$System_Drawing_Point.Y = 397
$textBox_cea2.Location = $System_Drawing_Point
$textBox_cea2.Name = "textBox_cea2"
$textBox_cea2.ReadOnly = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 367
$textBox_cea2.Size = $System_Drawing_Size
$textBox_cea2.TabIndex = 12

$form1.Controls.Add($textBox_cea2)

$textBox_cea1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 303
$System_Drawing_Point.Y = 370
$textBox_cea1.Location = $System_Drawing_Point
$textBox_cea1.Name = "textBox_cea1"
$textBox_cea1.ReadOnly = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 367
$textBox_cea1.Size = $System_Drawing_Size
$textBox_cea1.TabIndex = 10

$form1.Controls.Add($textBox_cea1)

$label_cea3.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 8
$System_Drawing_Point.Y = 430
$label_cea3.Location = $System_Drawing_Point
$label_cea3.Name = "label_cea3"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 25
$System_Drawing_Size.Width = 212
$label_cea3.Size = $System_Drawing_Size
$label_cea3.TabIndex = 34
$label_cea3.Text = "msDS-CloudExtensionAttribute 3:"

$form1.Controls.Add($label_cea3)

$label_cea2.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 8
$System_Drawing_Point.Y = 400
$label_cea2.Location = $System_Drawing_Point
$label_cea2.Name = "label_cea2"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 30
$System_Drawing_Size.Width = 212
$label_cea2.Size = $System_Drawing_Size
$label_cea2.TabIndex = 33
$label_cea2.Text = "msDS-CloudExtensionAttribute 2:"

$form1.Controls.Add($label_cea2)

$label_cea1.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 8
$System_Drawing_Point.Y = 370
$label_cea1.Location = $System_Drawing_Point
$label_cea1.Name = "label_cea1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 32
$System_Drawing_Size.Width = 212
$label_cea1.Size = $System_Drawing_Size
$label_cea1.TabIndex = 32
$label_cea1.Text = "msDS-CloudExtensionAttribute 1:"

$form1.Controls.Add($label_cea1)


$button_set.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 490
$System_Drawing_Point.Y = 515
$button_set.Location = $System_Drawing_Point
$button_set.Name = "button_set"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 182
$button_set.Size = $System_Drawing_Size
$button_set.TabIndex = 17
$button_set.Text = "Set User Attributes"
$button_set.UseVisualStyleBackColor = $True
$button_set.add_Click($Set_Attributes)

$form1.Controls.Add($button_set)

$label_location.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 8
$System_Drawing_Point.Y = 340
$label_location.Location = $System_Drawing_Point
$label_location.Name = "label_location"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 119
$label_location.Size = $System_Drawing_Size
$label_location.TabIndex = 30
$label_location.Text = "Location:"

$form1.Controls.Add($label_location)

$textBox_location.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 303
$System_Drawing_Point.Y = 340
$textBox_location.Location = $System_Drawing_Point
$textBox_location.Name = "textBox_location"
$textBox_location.ReadOnly = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 367
$textBox_location.Size = $System_Drawing_Size
$textBox_location.TabIndex = 31

$form1.Controls.Add($textBox_location)


$checkBox_cea10.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 281
$System_Drawing_Point.Y = 458
$checkBox_cea10.Location = $System_Drawing_Point
$checkBox_cea10.Name = "checkBox_cea10"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 16
$checkBox_cea10.Size = $System_Drawing_Size
$checkBox_cea10.TabIndex = 15
$checkBox_cea10.UseVisualStyleBackColor = $True
$checkBox_cea10.add_CheckStateChanged($click_cea10)

$form1.Controls.Add($checkBox_cea10)

$textBox_search.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 41
$textBox_search.Location = $System_Drawing_Point
$textBox_search.Name = "textBox_search"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 214
$textBox_search.Size = $System_Drawing_Size
$textBox_search.TabIndex = 1

$form1.Controls.Add($textBox_search)


$button_search.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 259
$System_Drawing_Point.Y = 38
$button_search.Location = $System_Drawing_Point
$button_search.Name = "button_search"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 75
$button_search.Size = $System_Drawing_Size
$button_search.TabIndex = 2
$button_search.Text = "Search"
$button_search.UseVisualStyleBackColor = $True
$button_search.add_Click($Search_AD)

$form1.Controls.Add($button_search)

$label_search.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 17
$label_search.Location = $System_Drawing_Point
$label_search.Name = "label_search"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 244
$label_search.Size = $System_Drawing_Size
$label_search.TabIndex = 0
$label_search.Text = "Search for user by Login Name or Email"

$form1.Controls.Add($label_search)


$checkBox_display.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 162
$System_Drawing_Point.Y = 147
$checkBox_display.Location = $System_Drawing_Point
$checkBox_display.Name = "checkBox_display"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 16
$checkBox_display.Size = $System_Drawing_Size
$checkBox_display.TabIndex = 7
$checkBox_display.UseVisualStyleBackColor = $True
$checkBox_display.add_CheckStateChanged($click_display)

$form1.Controls.Add($checkBox_display)


$checkBox_last.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 162
$System_Drawing_Point.Y = 121
$checkBox_last.Location = $System_Drawing_Point
$checkBox_last.Name = "checkBox_last"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 16
$checkBox_last.Size = $System_Drawing_Size
$checkBox_last.TabIndex = 5
$checkBox_last.UseVisualStyleBackColor = $True
$checkBox_last.add_CheckStateChanged($click_last)

$form1.Controls.Add($checkBox_last)


$checkBox_first.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 162
$System_Drawing_Point.Y = 93
$checkBox_first.Location = $System_Drawing_Point
$checkBox_first.Name = "checkBox_first"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 16
$checkBox_first.Size = $System_Drawing_Size
$checkBox_first.TabIndex = 3
$checkBox_first.UseVisualStyleBackColor = $True
$checkBox_first.add_CheckStateChanged($click_first)

$form1.Controls.Add($checkBox_first)

$richTextBox1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 13
$System_Drawing_Point.Y = 544
$richTextBox1.Location = $System_Drawing_Point
$richTextBox1.Name = "richTextBox1"
$richTextBox1.ReadOnly = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 155
$System_Drawing_Size.Width = 658
$richTextBox1.Size = $System_Drawing_Size
$richTextBox1.TabIndex = 18
$richTextBox1.Text = ""

$form1.Controls.Add($richTextBox1)

$textBox_cea10.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 303
$System_Drawing_Point.Y = 458
$textBox_cea10.Location = $System_Drawing_Point
$textBox_cea10.Name = "textBox_cea10"
$textBox_cea10.ReadOnly = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 368
$textBox_cea10.Size = $System_Drawing_Size
$textBox_cea10.TabIndex = 16

$form1.Controls.Add($textBox_cea10)

$label_cea10.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 8
$System_Drawing_Point.Y = 461
$label_cea10.Location = $System_Drawing_Point
$label_cea10.Name = "label_cea10"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 30
$System_Drawing_Size.Width = 212
$label_cea10.Size = $System_Drawing_Size
$label_cea10.TabIndex = 35
$label_cea10.Text = "msDS-CloudExtensionAttribute10:"
$label_cea10.add_Click($handler_label_cea10_Click)

$form1.Controls.Add($label_cea10)

$textBox_o365.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 303
$System_Drawing_Point.Y = 311
$textBox_o365.Location = $System_Drawing_Point
$textBox_o365.Name = "textBox_o365"
$textBox_o365.ReadOnly = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 367
$textBox_o365.Size = $System_Drawing_Size
$textBox_o365.TabIndex = 29

$form1.Controls.Add($textBox_o365)

$label_o365.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 8
$System_Drawing_Point.Y = 314
$label_o365.Location = $System_Drawing_Point
$label_o365.Name = "label_o365"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 168
$label_o365.Size = $System_Drawing_Size
$label_o365.TabIndex = 28
$label_o365.Text = "Office 365 License Type:"
$label_o365.add_Click($handler_label_o365_Click)

$form1.Controls.Add($label_o365)

$textBox_empid.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 303
$System_Drawing_Point.Y = 284
$textBox_empid.Location = $System_Drawing_Point
$textBox_empid.Name = "textBox_empid"
$textBox_empid.ReadOnly = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 367
$textBox_empid.Size = $System_Drawing_Size
$textBox_empid.TabIndex = 27

$form1.Controls.Add($textBox_empid)

$label_empID.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 10
$System_Drawing_Point.Y = 287
$label_empID.Location = $System_Drawing_Point
$label_empID.Name = "label_empID"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 119
$label_empID.Size = $System_Drawing_Size
$label_empID.TabIndex = 26
$label_empID.Text = "Employee ID:"

$form1.Controls.Add($label_empID)

$textBox_email.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 184
$System_Drawing_Point.Y = 217
$textBox_email.Location = $System_Drawing_Point
$textBox_email.Name = "textBox_email"
$textBox_email.ReadOnly = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 367
$textBox_email.Size = $System_Drawing_Size
$textBox_email.TabIndex = 25

$form1.Controls.Add($textBox_email)

$label_email.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 184
$System_Drawing_Point.Y = 191
$label_email.Location = $System_Drawing_Point
$label_email.Name = "label_email"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 100
$label_email.Size = $System_Drawing_Size
$label_email.TabIndex = 23
$label_email.Text = "E-Mail address:"

$form1.Controls.Add($label_email)

$textBox_logon.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 217
$textBox_logon.Location = $System_Drawing_Point
$textBox_logon.Name = "textBox_logon"
$textBox_logon.ReadOnly = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 144
$textBox_logon.Size = $System_Drawing_Size
$textBox_logon.TabIndex = 24

$form1.Controls.Add($textBox_logon)

$label_logon.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 191
$label_logon.Location = $System_Drawing_Point
$label_logon.Name = "label_logon"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 144
$label_logon.Size = $System_Drawing_Size
$label_logon.TabIndex = 22
$label_logon.Text = "User Logon Name:"

$form1.Controls.Add($label_logon)

$textBox_display.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 184
$System_Drawing_Point.Y = 149
$textBox_display.Location = $System_Drawing_Point
$textBox_display.Name = "textBox_display"
$textBox_display.ReadOnly = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 367
$textBox_display.Size = $System_Drawing_Size
$textBox_display.TabIndex = 8

$form1.Controls.Add($textBox_display)

$label_display.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 146
$label_display.Location = $System_Drawing_Point
$label_display.Name = "label_display"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 100
$label_display.Size = $System_Drawing_Size
$label_display.TabIndex = 21
$label_display.Text = "Display Name:"

$form1.Controls.Add($label_display)

$textBox_last.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 184
$System_Drawing_Point.Y = 123
$textBox_last.Location = $System_Drawing_Point
$textBox_last.Name = "textBox_last"
$textBox_last.ReadOnly = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 367
$textBox_last.Size = $System_Drawing_Size
$textBox_last.TabIndex = 6

$form1.Controls.Add($textBox_last)

$label_last.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 120
$label_last.Location = $System_Drawing_Point
$label_last.Name = "label_last"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 100
$label_last.Size = $System_Drawing_Size
$label_last.TabIndex = 20
$label_last.Text = "Last Name:"

$form1.Controls.Add($label_last)

$textBox_first.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 184
$System_Drawing_Point.Y = 94
$textBox_first.Location = $System_Drawing_Point
$textBox_first.Name = "textBox_first"
$textBox_first.ReadOnly = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 206
$textBox_first.Size = $System_Drawing_Size
$textBox_first.TabIndex = 4

$form1.Controls.Add($textBox_first)

$label_first.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 94
$label_first.Location = $System_Drawing_Point
$label_first.Name = "label_first"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 100
$label_first.Size = $System_Drawing_Size
$label_first.TabIndex = 19
$label_first.Text = "First Name:"

$form1.Controls.Add($label_first)

#endregion Generated Form Code

#Save the initial state of the form
$InitialFormWindowState = $form1.WindowState
#Init the OnLoad event to correct the initial state of the form
$form1.add_Load($OnLoadForm_StateCorrection)
#Show the Form
$form1.ShowDialog()| Out-Null

} #End Function

function Refresh-Form {	
    $Search = ''
    $script:User = ''
    $richTextBox1.clear()
    $textBox_first.clear()
	$textBox_last.clear()
	$textBox_display.clear()
	$textBox_logon.clear()
	$textBox_email.clear()
    $textBox_o365.clear()
    $textBox_location.clear()
    $textBox_empid.clear()
    $textBox_cea1.clear()
    $textBox_cea2.clear()
    $textBox_cea3.clear()
	$textBox_cea10.clear()
    $checkBox_first.Checked = $false
    $checkBox_last.Checked = $false
    $checkBox_display.Checked = $false
    $checkBox_cea1.Checked = $false
    $checkBox_cea2.Checked = $false
    $checkBox_cea3.Checked = $false
    $checkBox_cea10.Checked = $false

    $richTextBox1 = ''
    $textBox_first = ''
	$textBox_last = ''
	$textBox_display = ''
	$textBox_logon = ''
	$textBox_email = ''
    $textBox_o365 = ''
    $textBox_location = ''
    $textBox_empid = ''
    $textBox_cea1 = ''
    $textBox_cea2 = ''
    $textBox_cea3 = ''
	$textBox_cea10 = ''
    $checkBox_first = ''
    $checkBox_last = ''
    $checkBox_display = ''
    $checkBox_cea1 = ''
    $checkBox_cea2 = ''
    $checkBox_cea3 = ''
    $checkBox_cea10 = ''
}

#Call the Function
GenerateForm
