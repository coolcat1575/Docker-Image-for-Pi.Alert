FROM debian:buster-slim

#Update and reduce image size
RUN apt-get update && apt-get install --no-install-recommends -y && apt-get install apt-utils -y && apt-get install cron -y && apt install sudo -y
# Lighttpd & PHP
RUN apt-get install lighttpd -y && mv /var/www/html/index.lighttpd.html /var/www/html/index.lighttpd.html.old && ln -s ~/pialert/install/index.html /var/www/html/index.html && apt-get install php php-cgi php-fpm php-sqlite3 -y && lighttpd-enable-mod fastcgi-php && service lighttpd restart && apt-get install sqlite3 -y
# arp-scan & Python
RUN apt-get install arp-scan -y && arp-scan -l && apt-get install dnsutils net-tools -y && apt-get install python -y
# Pi.Alert
RUN mkdir /home/pi && cd /home/pi
WORKDIR /home/pi
RUN apt install curl -y && curl -LO https://github.com/pucherot/Pi.Alert/raw/main/tar/pialert_latest.tar && tar xvf pialert_latest.tar && rm pialert_latest.tar 
RUN ln -s /home/pi/pialert/front /var/www/html/pialert  
RUN sudo python /home/pi/pialert/back/pialert.py update_vendors && (crontab -l 2>/dev/null; cat /home/pi/pialert/install/pialert.cron) | crontab - && chgrp -R www-data /home/pi/pialert/db && chmod -R 770 /home/pi/pialert/db

EXPOSE 80

CMD ["lighttpd","-D","-f","/etc/lighttpd/lighttpd.conf"]
