#! /bin/bash


proxy="http://prod-proxy.chinacloudapp.cn:4000"
f1="/tmp/vmlist_theme.txt"
f2="/tmp/theme_fe.txt"
f3="/tmp/theme_be.txt"
f4="/tmp/theme_bu.txt"

services=$1

if  [[ -z "$services" ]] ;
then
        echo "Please ensure you have input the right argument."
        echo "for example:  ./[scripts] [Frontend]"
        echo "for example:  ./[scripts] [Backend]"
        echo "for example:  ./[scripts] [Builder]"

	exit 1
fi


#Check vm list exits
if [ ! -f $f1 ] 
then
echo "Creating Full list of VM from Azure,be patient,it will take a while..."
azure vm list|awk 'NR>4'|awk '{print $2}' > $f1
fi

if [ `find $f1 -mmin +5` ]
then
	echo "$f1 was outdated,creating new $f1 now..."
	azure vm list|awk 'NR>4'|awk '{print $2}' > $f1
fi


#Output FE,BE,BU machine
cat $f1|grep prod-fe > $f2

cat $f1|grep prod-be > $f3

cat $f1|grep prod-bu > $f4


#Mapping cluster name
declare -A clustername=([prod-fe]="Frontend" [prod-be]="Backend" [prod-bu]="Builder");


#Output URL for FE
if [ $services = "Frontend" ]
then

	while read fe
	do
		i=`echo $fe|grep -o '[0-9]*'`
		echo -e "$proxy/${clustername[prod-fe]}$i"

	done < $f2


#Output URL for BE
elif [ $services = "Backend" ]
then

while read be
do
	
	j=`echo $be|grep -o '[0-9]*'`
	echo -e "$proxy/${clustername[prod-be]}$j"

done < $f3



#Output URL for BU
elif [ $services = "Builder" ]
then

while read bu
do
	
	k=`echo $bu|grep -o '[0-9]*'`
	echo -e "$proxy/${clustername[prod-bu]}$k"

done < $f4


else  [[ -z "$services" ]]; 

	echo "Please ensure you have input the right argument."
	echo "for example:  ./[scripts] [Frontend]"
	echo "for example:  ./[scripts] [Backend]"
	echo "for example:  ./[scripts] [Builder]"
	
fi



