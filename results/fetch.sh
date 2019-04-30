#!/bin/bash

echo "tcp measures on container"
sudo docker exec -i brave_heyrovsky sh -c 'timeout 30s python tcpack.py -p 80 -o & timeout 30s python tcp.py -p 80 -o & timeout 30s python tcpsock.py > /usr/local/bcc/tcpsock & ' & sleep 10; sudo docker run --rm jordi/ab -k -c 100 -n 10000 http://172.17.0.3:80/docker.html

sleep 10

sudo docker exec -i brave_heyrovsky sh -c 'pkill -f python'

sudo docker cp brave_heyrovsky:/usr/local/bcc/tcpack .
sudo docker cp brave_heyrovsky:/usr/local/bcc/tcpsock .
sudo docker cp brave_heyrovsky:/usr/local/bcc/tcp .
sed -i '1d' tcpsock
awk '$2==80||$4==80{print}' tcpsock > tcpsock_80

#awk 'BEGIN{rtt=0;cwnd=0;}{rtt=rtt+$7;cwnd=cwnd+$8;}END{print rtt/NR, cwnd/NR}' tcpack >>result

rm result.txt
touch result.txt
echo 'tcpack.py results:' >> result.txt
awk 'BEGIN{for(i=9;i<=NF;i++) {max[i]=0; min[i]=1000000000000000000000}} \
	{for(i=9;i<=NF;i++) {sum[i] += $i; sumsq[i] += ($i)^2; if ($i<min[i]) min[i]=$i; if ($i>max[i]) max[i]=$i}} \
	END {for (i=9;i<=NF;i++) {\
	printf "%f %f %f %f\n", sum[i]/NR, sqrt((sumsq[i]-sum[i]^2/NR)/NR), max[i], min[i]}\
	}' tcpack >> result.txt

echo 'tcp.py results:' >> result.txt
awk 'BEGIN{for(i=9;i<=NF;i++) {max[i]=0; min[i]=1000000000000000000000}} \
	{for(i=1;i<=NF;i++) {sum[i] += $i; sumsq[i] += ($i)^2; if ($i<min[i]) min[i]=$i; if ($i>max[i]) max[i]=$i}} \
	END {for (i=9;i<=NF;i++) {\
	printf "%f %f %f %f\n", sum[i]/NR, sqrt((sumsq[i]-sum[i]^2/NR)/NR), max[i], min[i]}\
	}' tcp >> result.txt

#awk '{for(i=1;i<=NF;i++) {sum[i] += $i; sumsq[i] += ($i)^2}} \
#	END {for (i=1;i<=NF;i++) {\
#	printf "%f %f \n", sum[i]/NR, sqrt((sumsq[i]-sum[i]^2/NR)/NR)}\
#	}' tcp >> result.txt

#awk 'BEGIN{rtt=0;cwnd=0;}{rtt=rtt+$7;cwnd=cwnd+$8;}END{print rtt/NR, cwnd/NR}' tcpack >>result
#awk '{for(i=1;i<=NF;i++) {sum[i] += $i; sumsq[i] += ($i)^2}} \
#	END {for (i=1;i<=NF;i++) {\
#	printf "%f %f \n", sum[i]/NR, sqrt((sumsq[i]-sum[i]^2/NR)/NR)}\
#	}' tcp >> result

#awk 'BEGIN{total=0;macin=0;ipin=0;tcpin=0;app=0;tcpout=0;ipout=0;macout=0}\
#	{total=total+$7;macin=macin+$8;ipin=ipin+$9;tcpin=tcpin+$10;app=app+$11;\
#	tcpout=tcpout+$12;ipout=ipout+$13;macout=macout+$14}\
#	END{print total/NR, macin/NR, ipin/NR, tcpin/NR, app/NR, tcpout/NR, ipout/NR, macout/NR}' tcp >>result
#awk 'BEGIN{write=0;read=0;}{write=write+$5;read=read+$7;}END{print rtt/NR, cwnd/NR}' tcpsock_80 >>result
