IFS=$'\n'
curl "https://api.proxyscrape.com/?request=getproxies&proxytype=socks4&timeout=1000&country=all" | awk  -F":" '{print "socks4",$1,$2}' > socks4_list
for i in $(cat socks4_list)
do	
	echo "CHANGE PROXYCHAINS"
	echo $i
	head -n 70 proxychains.conf >proxychains_new.conf;
	rm proxychains.conf;
	mv proxychains_new.conf proxychains.conf
	echo "$i" >> proxychains.conf
	echo "CHANGED PROXYCHAINS"
	proxychains megasync 2>&1 | tee result &
	sleep 20;
	echo "CHECK FOR TIMEOUTS"
	if [[ $(tail -n 5 result | grep "timeout\|denied" | wc -l) -gt 4 ]]; then
		echo "MANY TIMEOUTS OR DENIED MESSAGES-KILL MEGASYNC"
		pkill megasync
	else
		if [[ $(cat result | wc -l) -lt 4 ]]; then
			echo "LOOKS BAD-nothing in result=kill megasync"
			pkill megasync
		else
			echo "LOOKS GOOD-DOWNLOAD NEXT"
			echo "TO CHANGE PROXY PRESS Q"
			while true; do
				read -n 1 -t 0.1 input
				if [[ $input = "q" ]] || [[ $input = "Q" ]];then
					echo 
					echo "PRESSED Q-EXIT DOWNLOAD AND CHANGE PROXY"
					break
				fi	
			done
		fi
	fi
pkill megasync
rm result
done
