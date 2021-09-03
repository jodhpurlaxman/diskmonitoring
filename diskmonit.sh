#!/bin/sh
SENDGRID_API_KEY="SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
EMAIL_TO="youremail@email.com"
EMAIL_CC="youremail@email.com"
EMAIL_BCC="youremail@email.com"
FROM_NAME="ServerAdmin"
SUBJECT="Alert: Disk space low"

df -h -x squashfs -x tmpfs | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $2 " " $4 " " $5 " " $6 }' | while read output;
do
  #echo $output
  #exit 1
  used=$(echo $output | awk '{ print $3}' | cut -d'%' -f1  )
  partition=$(echo $output | awk '{ print $4 }' )
  TotalSize=$(echo $output | awk '{ print $1 }' )
  GbFree=$(echo $output | awk '{ print $2 }' )
  if [ $used -ge 90 ]; then
    MESSAGE=$( echo "<p style='font-size: 18px;'> Hello User,</p><p style='color:red; font-size: 24px;'> The partition "$partition" on $(hostname) has used $used% ($GbFree free of $TotalSize)  at $(date +'%m/%d/%Y')</p><p style='color:red; font-size: 14px;'>Note: This is system generated email, please discuss/forward mail to system admin for increasing/troubleshooting the space issue</p><p style='font-size: 18px;'>Thanks<br>$(hostname)</p>" )
    REQUEST_DATA='{"personalizations": [{ 
               "to": [{ "email": "'"$EMAIL_TO"'" }],
               "cc": [{ "email": "'"$EMAIL_CC"'" }],
               "bcc": [{ "email": "'"$EMAIL_BCC"'" }],
               "subject": "'"$SUBJECT"'" 
            }],
            "from": {
                "email": "'"$FROM_EMAIL"'",
                "name": "'"$FROM_NAME"'" 
            },
            "content": [{
                "type": "text/html",
                "value": "'"$MESSAGE"'"
            }]
}';
    curl --request POST \
  --url https://api.sendgrid.com/v3/mail/send \
  --header 'Authorization: Bearer '$SENDGRID_API_KEY \
  --header 'Content-Type: application/json' \
  --data "'$REQUEST_DATA'"
  fi
done
