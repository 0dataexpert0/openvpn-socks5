# openvpn-socks5
Docker image with Openvpn and Socks5 Danted server, for access vpn traffic from proxy server.
Using Docker image Alpine:edge


Инструкция для чайника!!!

Исходные данные:
Имеем vds/vps с ubuntu 18 ip: 10.10.10.10
openvpn конфиг файл с названием vpn1.ovpn
На выходе хотим получить:
socks5 прокси вида
anton:pardon02@10.10.10.10:6001
где
10.10.10.10 - айпи нашей впс
6001 - порт socks5 прокси
anton - пользователь прокси
pardon02 - пароль к прокси
------
Установка и настройка:
1. Установка Docker на сервер
подключаемся к ssh и выполняем на сервере от пользователя root
apt-get update && apt-get install curl git socat -y && curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
команду можно просто вставить в консоль она все сделаем
проверяем установился ли докер в консоли
docker -v
должно появится такое сообщение
Docker version 19.03.5, build 633a0ea838
если его нет значит что то у вас сервером не так
------------------
2. Установка docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version
копируем и вставляем
должны получить вывод
docker-compose version 1.24.1, build 4667896b
-------------------------
3.Запуск docker контейнера с openvpn, dante (socks5 proxy) сервером
3.1 копирование файлов нужных для установки
mkdir /docker-vpn-proxy && git clone https://github.com/0dataexpert0/openvpn-socks5.git /docker-vpn-proxy
в данном случае мы копируем файлы для установки в новую папку на сервере /docker-vpn-proxy переходим в нее
cd /docker-vpn-proxy/
дальше нам нужно в этой папке создать или загрузить наш конфиг файл vpn1.ovpn
тут как вам проще или  через nano  или через sftp/scp/ftp
3.1 подготовка до запуска, вписываем настройки
- файл Dockerfile 
в этом файле изменяем значения "ARG user=anton ARG password=pardon02"  на своего юзера и пользователя, эти данные потом будем использовать для подключения к socks5 прокси
- файл start 
тут меняем значение порта, в нашем случае стоит порт 6001
"--publish 0.0.0.0:6001:1080 \" - менять надо в этой строчке
также меняем название контейнера
строчка"--name=vpn-prox1 \" меняем только название "vpn-prox1"  на свое
ПРИ ИЗМЕНЕНИИ НАДО НЕ НАРУШИТЬ КОЛИЧЕСТВО ПРОБЕЛОВ И ПРОЧЕЕ, ИЗМЕНЯЕМ ТОЛЬКО ПОРТ 6001 НА СВОЙ!
3.3 запуск контейнера командой
./start vpn1.ovpn &
где файл vpn1.ovpn - конфиг опенвпн что мы создали или загрузили в нашу папку /docker-vpn-proxy
---
ЗАМЕТКА: для запуска другого контейнера нам понадобится
создать новую папку для контейнера
mkdir /docker-vpn-proxy && git clone https://github.com/0dataexpert0/openvpn-socks5.git /docker-vpn-proxy
в этой команде поменять /docker-vpn-proxy в двух местах на например /docker-vpn-proxy2
и получится
mkdir /docker-vpn-proxy2 && git clone https://github.com/0dataexpert0/openvpn-socks5.git /docker-vpn-proxy2
- файл Dockerfile 
в этом файле изменяем значения "ARG user=anton ARG password=pardon02"  на своего юзера и пользователя, эти данные потом будем использовать для подключения к socks5 прокси
- файл start 
тут меняем значение порта, в нашем случае стоит порт порт 6001 уже занят первым конйнером потому используем порт 6002
и того получится
"--publish 0.0.0.0:6002:1080 \" - менять надо в этой строчке
также меняем название контейнера
строчка "--name=vpn-prox1 \" меняем только название "vpn-prox1"  на свое vpn-prox2
и получится
"--name=vpn-prox2 \"
запуск контейнера командой
./start vpn1.ovpn &
---
проверяем что прокси работает
должен отобразиться айпи впн севрера

curl --socks5-hostname 127.0.0.1:6003 http://ifconfig.io

3.4 делаем проброс портов
socat TCP-LISTEN:6005,fork TCP:127.0.0.1:6003
в данной команде порт 6005 это тот порт что мы будем использовать в браузере или программе для соединения с прокси сервером
порт 6003 это порт который мы меняли или указывали в файле Dockerfile
--------
 Если openvpn конфиг у нас с авторизацией
 нам надо будет изменить наш файл vpn1.ovpn
 изменить или добавить строчку строчку с "auth-user-pass"
 на 
auth-user-pass pass.txt
 в файл pass.txt
 добавить 
 user/password
 например
 anton/pardon02
 
