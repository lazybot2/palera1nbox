#!/usr/bin/expect   
set timeout 3000   
spawn bash ./procursus-deploy-linux-macos.sh 
expect {
"*to continue."	{send "\r"; exp_continue}
"*password: "	{send "alpine\r"; exp_continue}
"*password: "	{send "alpine\r"}
}
expect "Done!" 
expect eof
