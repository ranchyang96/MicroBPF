#!/usr/bin/python3
import paramiko
import threading
import time
import sys
from subprocess import call

def autorun(cmd):
    try:
        call(cmd,shell=True)
    except:
        print(cmd,'error')

def ssh1(ip,username,passwd,cmd):
    try:
        ssh=paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(ip,22,username,passwd,timeout=5)
        for m in cmd:
            print(ip,m)
            stdin,stdout,stderr=ssh.exec_command(m)
            err=stderr.readlines()
            for e in err:
                print(ip,e)
        ssh.close()
    except:
        print(ip,'ssh1 Error')

def ssh2(ip,port,username,passwd,remote_file,local_file):
    try:
        transport=paramiko.Transport((ip,port))
        transport.connect(username=username,password=passwd)
        sftp=paramiko.SFTPClient.from_transport(transport)
        sftp.get(remote_file,local_file)
        sftp.close()
        transport.close()
    except:
        print(ip,'ssh2 Error')

def ssh3(ip,port,username,passwd,local_file,remote_file):
    try:
        transport=paramiko.Transport((ip,port))
        transport.connect(username=username,password=passwd)
        sftp=paramiko.SFTPClient.from_transport(transport)
        sftp.put(local_file,remote_file)
        sftp.close()
        transport.close()
    except:
        print(ip,'ssh3 Error')

if __name__=='__main__':
	vmip = '172.16.222.132'
	localip = '172.16.222.127'

    cmd0 = ['pkill -f ib_send', 'sudo ntpdate ntp.ubuntu.com']
    cmd1 = [
            'for i in {6..7} ; do ib_send_bw -R -x 5 -d mlx5_1 -S 3 -D 20 -p $((10010+i))& done',
            ]
    cmd2 = [
            ['ib_send_bw -R -S 3 -x 3 -d mlx5_1 192.168.33.85 -D 20 -p 10016'],
            ['ib_send_bw -R -S 3 -x 5 -d mlx5_1 192.168.33.85 -D 20 -p 10017'],
            ['ib_send_bw -R -S 3 -x 5 -d mlx5_1 192.168.33.85 -D 20 -p 10018'],
            ['ib_send_bw -R -S 3 -x 5 -d mlx5_1 192.168.33.85 -D 20 -p 10019'],
            ['ib_send_bw -R -S 3 -x 5 -d mlx5_1 192.168.33.85 -D 20 -p 10020'],
            ['ib_send_bw -R -S 3 -x 7 -d mlx5_1 192.168.33.85 -D 20 -p 10021'],
            ['ib_send_bw -R -S 3 -x 5 -d mlx5_1 192.168.33.85 -D 20 -p 10022'],
            ['ib_send_bw -R -S 3 -x 5 -d mlx5_1 192.168.33.85 -D 20 -p 10023'],
            ['ib_send_bw -R -S 3 -x 5 -d mlx5_1 192.168.33.85 -D 20 -p 10024'],
            ['ib_send_bw -R -S 3 -x 5 -d mlx5_1 192.168.33.85 -D 20 -p 10025'],
            ]
    cmd3 = ['sudo tcpdump -c 10000000 -s 60 -B 900000 -i p4p2 -w ~/ycyang/result.pcap']
    cmd4 = ['/home/yangyuchen/Research/automation/CX4/process.py ']

    mac = [86, 87, 88, 90, 91, 92, 93, 94, 95]
    b = [i for i in range(100)]
    j=int(sys.argv[1])

    username="tian"
    passwd="Tiana517"
    port=22
    threads=[]

    print("Phase 0")
    ip='192.168.1.85'
    b[85]=threading.Thread(target=ssh1,args=(ip,username,passwd,cmd0))
    b[85].start()
    for i in mac:
        ip='192.168.1.'+str(i)
        b[i]=threading.Thread(target=ssh1,args=(ip,username,passwd,cmd0))
        b[i].start()

    for i in mac[:j]:
        b[i].join()

    b[85].join()

    str1='for i in {6..'
    str2='} ; do ib_send_bw -R -x 5 -d mlx5_1 -S 3 -D 20 -p $((10010+i))& done'
    cmd1[0] = str1 + str(5+10) + str2

    username="tian"
    passwd="Tiana517"
    port=22
    threads=[]
    print("Begin......")

    ip='192.168.1.85'
    a=threading.Thread(target=ssh1,args=(ip,username,passwd,cmd1))
    a.start()
    time.sleep(3)
    print("Phase 1")
    for i in mac[:j]:
        ip='192.168.1.'+str(i)
        b[i]=threading.Thread(target=ssh1,args=(ip,username,passwd,cmd3))
        b[i].start()

    time.sleep(3)
    print("Phase 2")
    for i in mac[:j]:
        ip='192.168.1.'+str(i)
        a=threading.Thread(target=ssh1,args=(ip,username,passwd,cmd2[i-86]))
        a.start()

    for i in mac[:j]:
        b[i].join()

    print("Phase 3")
    for i in mac[:j]:
        ip='192.168.1.'+str(i)
        b[i]=threading.Thread(target=ssh2,args=(ip,port,username,passwd,'/home/tian/ycyang/result.pcap','/home/ycyang/'+str(i)+'.pcap'))

    for i in mac[:j]:
        b[i].start()

    for i in mac[:j]:
        b[i].join()
    
    ip='114.212.85.240'
    port=22
    username="yangyuchen"
    passwd="3Idiots"
    threads=[]
    print("Phase 4")
    for i in mac[:j]:
         b[i]=threading.Thread(target=ssh3,args=(ip,port,username,passwd,'/home/ycyang/'+str(i)+'.pcap','/home/yangyuchen/Research/automation/CX4/'+str(i)+'.pcap'))

    for i in mac[:j]:
        b[i].start()

    for i in mac[:j]:
        b[i].join()

    print("Phase 5")
    cmd4[0]=cmd4[0]+str(j)
    a=threading.Thread(target=ssh1,args=(ip,username,passwd,cmd4))
    a.start()
    a.join()
    
    print("end")                                                                                       
