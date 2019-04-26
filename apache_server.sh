#!/bin/bash
sudo docker run -dit --name tecmint-web -p 80:80 -v /home/user/website/:/usr/local/apache2/htdocs/ httpd:2.4
