IFS=$'\n'
echo "DOWNLOAD proxy_list"
curl "https://api.proxyscrape.com/?request=getproxies&proxytype=socks4&timeout=1000&country=all" | awk  -F":" '{print "socks4",$1,$2}' >> socks4_list
for i in $(cat socks4_list)
do	
	echo "MAKE PROXYCHAINS.CONF FILE"
	echo -e "strict_chain\\ntcp_read_time_out 15000\\ntcp_connect_time_out 8000\\n[ProxyList]" >proxychains.conf
	echo $i
	echo "ADD PROXY"
	echo "$i" >> proxychains.conf
	echo "CHANGED PROXYCHAINS"
	proxychains megasync 2>&1 2>result &
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
rm proxychains.conf
done
