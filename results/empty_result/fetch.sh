#!/bin/bash
sudo docker cp brave_heyrovsky:/usr/local/bcc/tcpack .
sudo docker cp brave_heyrovsky:/usr/local/bcc/tcpsock .
sudo docker cp brave_heyrovsky:/usr/local/bcc/tcp .
sed -i '1d' tcpsock
