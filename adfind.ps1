#Measure-Command {C:\_limbo\AdFind.exe -b 'DC=corp,DC=local' -gc -f 'sAMAccountType=805306368' -csv -list 'displayname', 'mail', 'employeeid', 'givenname', 'sn', 'samaccountname', 'userprincipalname', 'proxyaddresses'} # | ConvertFrom-String -TemplateContent "CN=RothJ,OU=PDB,OU=Amer,OU=Service Delivery,DC=Global,DC=Corp,DC=Local","Roth, Jessica (IHG)","RothJ@global.corp.local"


$TargetData = @'
"dn","displayname","mail","employeeid","givenname","sn","samaccountname","userprincipalname","proxyaddresses"
"CN=RothJ,OU=PDB,OU=Amer,OU=Service Delivery,DC=Global,DC=Corp,DC=Local","Roth, Jessica (IHG)","nelkins@dmchotels.com ","","Jessica","Roth","RothJ","RothJ@global.corp.local","smtp: nelkins@dmchotels.com "
"CN=testing,OU=Policy Test OU,OU=Service Delivery,DC=Amer,DC=Corp,DC=Local","testing","Jason.Roth3@ihg.com","","Test","Rothtest","RothJ1","RothJ1@Amer.Corp.Local","X400:c=US\;a= \;p=EXCHANGE\;o=Exchange\;s=Rothtest\;g=Test\;;SMTP:Jason.Roth3@ihg.com;smtp:al
ias4@jasonroth.com"
"CN=RothJ10,OU=PDB,OU=Travel Agents,DC=Global,DC=Corp,DC=Local","Roth, Julia (IHG)","julia.roth@aexp.com","","Julia","Roth","RothJ10","RothJ10@global.corp.local","smtp: julia.roth@aexp.com"
"CN=RothJ11,OU=PDB,OU=Travel Agents,DC=Global,DC=Corp,DC=Local","Roth, Julia","julia.roth@amexbarcelo.com","","Julia","Roth","RothJ11","RothJ11@global.corp.local",""
"CN=RothJ2,OU=PDB,OU=Amer,OU=Service Delivery,DC=Global,DC=Corp,DC=Local","Roth, Joy (IHG)","joy.roth1@gmail.com","","Joy","Roth","RothJ2","RothJ2@global.corp.local","smtp: joy.roth1@gmail.com"
"CN=RothJ3,OU=PDB,OU=Travel Agents,DC=Global,DC=Corp,DC=Local","Roth, Jill (IHG)","jilltcb@gmail.com","","Jill","Roth","RothJ3","RothJ3@global.corp.local","smtp: jilltcb@gmail.com"
"CN=RothJ4,OU=PDB,OU=Amer,OU=Service Delivery,DC=Global,DC=Corp,DC=Local","Roth, Joseph (IHG)","Joseph.Roth@hersha.com","","Joseph","Roth","RothJ4","RothJ4@global.corp.local","smtp: Joseph.Roth@hersha.com"
"CN=rothj5,OU=PDB,OU=Travel Agents,DC=Global,DC=Corp,DC=Local","roth, jessica (IHG)","jessica@peerlesstravel.com","","jessica","roth","rothj5","rothj5@global.corp.local","smtp: jessica@peerlesstravel.com"
"CN=RothJ6,OU=PDB,OU=Amer,OU=Service Delivery,DC=Global,DC=Corp,DC=Local","Roth, Jerry (IHG)","jerry_roth@ymail.com","","Jerry","Roth","RothJ6","RothJ6@global.corp.local","smtp: jerry_roth@ymail.com"
"CN=RothJ7,OU=PDB,OU=Travel Agents,DC=Global,DC=Corp,DC=Local","Roth, Jesscia (IHG)","jr.travelangels@gmail.com","","Jesscia","Roth","RothJ7","RothJ7@global.corp.local","smtp: jr.travelangels@gmail.com"
"CN=Testing2,OU=Policy Test OU,OU=Service Delivery,DC=Amer,DC=Corp,DC=Local","Testing2","","","Jason","Roth","RothJ8","RothJ8@Amer.Corp.Local",""
"CN=RothJ9,OU=PDB,OU=Travel Agents,DC=Global,DC=Corp,DC=Local","Roth, Jill (IHG)","travelc@gmail.com","","Jill","Roth","RothJ9","RothJ9@global.corp.local","smtp: travelc@gmail.com"
"CN=Roth\, Jason (IHG),OU=Users,OU=Atlanta,OU=Corp,OU=Service Delivery,DC=Amer,DC=Corp,DC=Local","Roth, Jason (IHG)","Jason.Roth@ihg.com","148290","Jason","Roth","RothJa","RothJa@Amer.Corp.Local","smtp:Jason.Roth@ihg.mail.onmicrosoft.com;smtp:Jason.Roth@ich
otelsgroup.com;X400:c=US\;a= \;p=EXCHANGE\;o=Exchange\;s=Roth\;g=Jason\;;SMTP:Jason.Roth@ihg.com"
"CN=ROTHJA-AMER-W8,OU=Workstations,OU=Computers,OU=Atlanta,OU=Corp,OU=Service Delivery,DC=Amer,DC=Corp,DC=Local","","","","","","ROTHJA-AMER-W8$","",""
"CN=ROTHJA-W8,OU=Workstations,OU=Computers,OU=Atlanta,OU=Corp,OU=Service Delivery,DC=Amer,DC=Corp,DC=Local","","","","","","ROTHJA-W8$","",""
"CN=Jason Roth (test),OU=Users,OU=Atlanta,OU=Corp,OU=Service Delivery,DC=Amer,DC=Corp,DC=Local","Jason Roth (test)","jason.roth1@ihg.com","","Jason","Roth","rothja1","rothja1@Amer.Corp.Local","X400:c=US\;a= \;p=EXCHANGE\;o=Exchange\;s=Roth4\;g=Jason\;;SMTP:
jason.roth1@ihg.com"
"CN=Jason Roth (test2),OU=Policy Test OU,OU=Service Delivery,DC=Amer,DC=Corp,DC=Local","Jason Roth (test2)","jason.roth2@ihg.com","","Jason","Roth","rothja2","rothja2@Amer.Corp.Local","X400:c=US\;a= \;p=EXCHANGE\;o=Exchange\;s=Roth3\;g=Jason\;;SMTP:jason.ro
th2@ihg.com"
"CN=Jason Roth (test3),OU=Policy Test OU,OU=Service Delivery,DC=Amer,DC=Corp,DC=Local","Jason Roth (test3)","","","Jason","Roth","rothjas","rothjas@Amer.Corp.Local",""
"CN=Jason Roth (test4),OU=Policy Test OU,OU=Service Delivery,DC=Amer,DC=Corp,DC=Local","Jason Roth (test4)","","","Jason","Roth","rothjaso","rothjaso@Amer.Corp.Local",""
"CN=Jason Roth (test5),OU=Policy Test OU,OU=Service Delivery,DC=Amer,DC=Corp,DC=Local","Jason Roth (test5)","","","Jason","Roth","rothjason","rothjason@Amer.Corp.Local",""
"CN=Roth\, Joseph (Siemens HD - Tier 1),OU=Corp,OU=Users,OU=zGraveyard,DC=Amer,DC=Corp,DC=Local","Roth, Joseph (Siemens HD - Tier 1)","","","Joseph","Roth","RothJo","RothJo@Amer.Corp.Local",""
"CN=roth\, joseph,OU=PDB,OU=Amer,OU=Service Delivery,DC=Global,DC=Corp,DC=Local","joseph, roth","","374171","joseph","roth","rothjos","rothjos@global.corp.Local",""
'@


$TemplateContent = @'
"{DN*:CN=RothJ10,OU=PDB,OU=Travel Agents,DC=Global,DC=Corp,DC=Local"},{DisplayName*:"Roth, Julia (IHG)"},{Mail*:"julia.roth@aexp.com"},{Givenname*:"Julia"},{Surname*:"Roth"},{SamAccountName*:"RothJ10"},{UniversalPrincipalName*:"RothJ10@global.corp.local"},{ProxyAddresses*:"smtp: julia.roth@aexp.com"}
'@

C:\_limbo\AdFind.exe -b 'DC=corp,DC=local' -gc -f 'sAMAccountName=rothj*' -csv -list 'displayname', 'mail', 'employeeid', 'givenname', 'sn', 'samaccountname', 'userprincipalname', 'proxyaddresses' | ConvertFrom-String -TemplateContent $TemplateContent  #-PropertyNames 'displayname', 'mail', 'employeeid', 'givenname', 'sn', 'samaccountname', 'userprincipalname', 'proxyaddresses'