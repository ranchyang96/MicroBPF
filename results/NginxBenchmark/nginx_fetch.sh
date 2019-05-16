#!/bin/bash

echo "tcp measures on container"
sudo docker exec -i brave_heyrovsky sh -c 'timeout 50s python tcpack.py -p 80 -o & timeout 50s python tcp.py -p 80 -o & timeout 50s python tcpsock.py > /usr/local/bcc/tcpsock & ' & sleep 10; wrk -t 12 -c $1 -d $2 http://172.17.0.5/index.html

sleep 10

echo "docker kill python processes"
sudo docker exec -i brave_heyrovsky sh -c 'pkill -f python'

rm -rf /home/ranchyang96/Research/MicroBPF/results/NginxBenchmark/a$1_$2

mkdir /home/ranchyang96/Research/MicroBPF/results/NginxBenchmark/a$1_$2

echo "copying results from docker"
sudo docker cp brave_heyrovsky:/usr/local/bcc/tcpack /home/ranchyang96/Research/MicroBPF/results/NginxBenchmark/a$1_$2/
sudo docker cp brave_heyrovsky:/usr/local/bcc/tcpsock /home/ranchyang96/Research/MicroBPF/results/NginxBenchmark/a$1_$2/
sudo docker cp brave_heyrovsky:/usr/local/bcc/tcp /home/ranchyang96/Research/MicroBPF/results/NginxBenchmark/a$1_$2/

echo "process tcpsock"
sed -i '1d' /home/ranchyang96/Research/MicroBPF/results/NginxBenchmark/a$1_$2/tcpsock
awk '$2==80||$4==80{print}' /home/ranchyang96/Research/MicroBPF/results/NginxBenchmark/a$1_$2/tcpsock > /home/ranchyang96/Research/MicroBPF/results/NginxBenchmark/a$1_$2/tcpsock_80

echo "write to results"
touch /home/ranchyang96/Research/MicroBPF/results/NginxBenchmark/a$1_$2/result.txt
echo 'tcpack.py results:' >> /home/ranchyang96/Research/MicroBPF/results/NginxBenchmark/a$1_$2/result.txt
awk 'BEGIN{for(i=9;i<=NF;i++) {max[i]=0; min[i]=1000000000000000000000}} \
	{for(i=9;i<=NF;i++) {sum[i] += $i; sumsq[i] += ($i)^2; if ($i<min[i]) min[i]=$i; if ($i>max[i]) max[i]=$i}} \
	END {for (i=9;i<=NF;i++) {\
	printf "%f %f %f %f\n", sum[i]/NR, sqrt((sumsq[i]-sum[i]^2/NR)/NR), max[i], min[i]}\
	}' /home/ranchyang96/Research/MicroBPF/results/NginxBenchmark/a$1_$2/tcpack >> /home/ranchyang96/Research/MicroBPF/results/NginxBenchmark/a$1_$2/result.txt

echo 'tcp.py results:' >> /home/ranchyang96/Research/MicroBPF/results/NginxBenchmark/a$1_$2/result.txt
awk 'BEGIN{for(i=7;i<=NF;i++) {max[i]=0; min[i]=1000000000000000000000}} \
	{for(i=7;i<=NF;i++) {sum[i] += $i; sumsq[i] += ($i)^2; if ($i<min[i]) min[i]=$i; if ($i>max[i]) max[i]=$i}} \
	END {for (i=7;i<=NF;i++) {\
	printf "%f %f %f %f\n", sum[i]/NR, sqrt((sumsq[i]-sum[i]^2/NR)/NR), max[i], min[i]}\
	}' /home/ranchyang96/Research/MicroBPF/results/NginxBenchmark/a$1_$2/tcp >> /home/ranchyang96/Research/MicroBPF/results/NginxBenchmark/a$1_$2/result.txt
