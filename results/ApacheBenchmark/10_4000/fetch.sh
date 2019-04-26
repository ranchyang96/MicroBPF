#!/bin/bash
sudo docker cp brave_heyrovsky:/usr/local/bcc/tcpack .
sudo docker cp brave_heyrovsky:/usr/local/bcc/tcpsock .
sudo docker cp brave_heyrovsky:/usr/local/bcc/tcp .
sed -i '1d' tcpsock
awk '$2==80||$4==80{print}' tcpsock > tcpsock_80

awk 'BEGIN{rtt=0;cwnd=0;}{rtt=rtt+$7;cwnd=cwnd+$8;}END{print rtt/NR, cwnd/NR}' tcpack >>result
awk 'BEGIN{total=0;macin=0;ipin=0;tcpin=0;app=0;tcpout=0;ipout=0;macout=0}\
	{total=total+$7;macin=macin+$8;ipin=ipin+$9;tcpin=tcpin+$10;app=app+$11;\
		tcpout=tcpout+$12;ipout=ipout+$13;macout=macout+$14}\
		END{print total/NR, macin/NR, ipin/NR, tcpin/NR, app/NR, tcpout/NR, ipout/NR, macout/NR}' tcp >>result
awk 'BEGIN{write=0;read=0;}{write=write+$5;read=read+$7;}END{print rtt/NR, cwnd/NR}' tcpsock_80 >>result
