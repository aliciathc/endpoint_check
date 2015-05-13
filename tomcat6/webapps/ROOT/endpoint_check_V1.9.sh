#! /bin/bash           


#set color
#red='\e[0;31m'
#green='\e[0;32m' 
#yellow='\e[0;33m'
#endColor='\e[0m'


#set gcloud ENV
#gcbin=`which gcloud`

#gcbin for non-docker:
#gcbin="/home/howard/google-cloud-sdk/bin/gcloud"

#gcbin for docker:
gcbin="/root/google-cloud-sdk/bin/gcloud"
echo "gcloud path : $gcbin "
$gcbin config set project studio-csi-prod
#user=`whoami`


#Set ARG
vmgrp=$1


#File setting
check_path="_svc/cnt/status"

 
#declare enpoint port number
declare -A clustername=([assocmeta]=17777 [dispatcher]=11026 [metacrawler]=11027 [imgcrawler]=11029 [dsife]=18081 [ppfe]=18083 [webhook]=18082 [notification]=11035 [sms]=11037 [smscallback]=11038 [docvcs]=11032 [jqmonitor]=11041 [crawlerbackoff]=11040 [fluentdcluster]=14226);



if [ ! -f /tmp/VMALL.txt ]
then
echo "/tmp/VMALL.txt not exits,creating VMALL.txt now..."
$gcbin compute instances list --zone us-central1-f|sort > /tmp/VMALL.txt
fi

if [ `find /tmp/VMALL.txt -mmin +5` ]
then
echo "/tmp/VMALL.txt not exits,creating VMALL.txt now..."
$gcbin compute instances list --zone us-central1-f|sort > /tmp/VMALL.txt
fi


#To output node IP and host
cat /tmp/VMALL.txt | grep -w $vmgrp|grep -v 'haproxy'|awk '{print $1,$5}'|sort > /tmp/nodeip.txt
cat /tmp/VMALL.txt | grep -w $vmgrp|grep -v 'haproxy'|awk '{print $1}'|sort > /tmp/node.txt


#
#Check if argument has been entered.
if  [[ -z "$vmgrp" ]]; then
	echo "Please enter group name with [argument]."
	echo "Example:  ./check_endpoint.sh [group name]"
	echo "Example group name:"
	echo -e "assocmeta\ndispatcher\nmetacrawler\nimgcrawler\ndsife\nppfe\nwebhook\nnotification\nsms\nsmscallback\ndocvcs\fluentdcluster"
	exit 1
fi    



#To check if user key in valid group name
if [[ ! -s "/tmp/nodeip.txt" ]]; then
        echo -e "${red}Group not found, please ensure you have key in the valid group name.${endColor} \n"
		echo "Example group name:"
		echo -e "assocmeta\ndispatcher\nmetacrawler\nimgcrawler\ndsife\nppfe\nwebhook\nnotification\nsms\nsmscallback\ndocvcs"
	
        exit 1
fi

#find if instance file exits to ensure list was clean
if [ -f /tmp/$vmgrp.txt ]
then
	#echo "removing $vmgrp.txt file"
	rm /tmp/$vmgrp.txt	
fi

#Ensure enpoint url has not exits before
if [ -f /tmp/ep-url-$vmgrp.txt ]
then
	echo "/tmp/ep-url-$vmgrp.txt exits, removing /tmp/ep-url-$vmgrp.txt file...."
	rm /tmp/ep-url-$vmgrp.txt
fi




#read node and curl endpoint status 1 by 1	
while read line           
do

     IP=`cat /tmp/nodeip.txt|grep $line|awk '{print$2}'`
	 #echo $IP
	 
	 if [[ $vmgrp != fluentdcluster ]]; then 
	 endpoint="http://$IP:${clustername[$vmgrp]}/$check_path"  
	 echo -e "$line\t$endpoint" 
	 echo -e "$line\t$endpoint" >> /tmp/ep-url-$vmgrp.txt
	 #curlep=`curl -s --connect-timeout 5 $endpoint` 
	 
	 else
	 #for fluentdcluster
	 endpoint2="http://$IP:${clustername[$vmgrp]}/"
	 echo -e "$line\t$endpoint2"
	 echo -e "$line\t$endpoint2" >> /tmp/ep-url-$vmgrp.txt
	 #curlep2=`curl -s --connect-timeout 5 $endpoint2` 
	 fi

    	
	#for fluentd checking
	
<<COMMENT2
	if [[ $vmgrp = fluentdcluster ]]; then 
		
		
		echo "Checking endpoint at $line : $endpoint2"
		
		if [[ -z "$curlep2" ]]; then
			#echo -e "Results:${green} $curlep \n${endColor}"
			echo -e "$vmgrp\t$line\tOK" >> /tmp/$vmgrp-$2.txt
		else
			echo "Checking endpoint at $line : $endpoint2"
			#echo -e "Results: ${red}Endpoint Check FAIL.${endColor}"
			echo -e "$vmgrp\t$line\tNOT_OK" >> /tmp/$vmgrp-$2.txt
			
		fi
	
	
	
	else
	
		
		if [[ -z "$curlep" ]]; then
		
			
			echo "Checking endpoint at $line : $endpoint"
		
			#echo -e "Results: ${red}Endpoint Check FAIL.${endColor}"
			echo -e "$vmgrp\t$line\tNOT_OK" >> /tmp/$vmgrp-$2.txt
		else
			echo "Checking endpoint at $line : $endpoint"
			#echo -e "Results:${green} $curlep \n${endColor}"
			echo -e "$vmgrp\t$line\tOK" >> /tmp/$vmgrp-$2.txt 
	
		fi
		
	fi
   
COMMENT2

done < /tmp/node.txt
 














