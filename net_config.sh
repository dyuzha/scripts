#!/bin/bash

# con - Имя соединения
# ip - адрес/маска 
# gw - адрес шлюза
# dns - адреса DNS (Можно несколько через пробел)
# gwroute - шлюз для статического маршрута 

con="Проводное соединение 1"
ip="192.168.0.183/24"
gw="192.168.0.12"
dns="192.168.0.183 77.88.8.8"
# gwroute=""

# Проверить наличие соединения
if nmcli con show "$con" > /dev/null ; then
        echo "Настраиваем «$con» на работу со статическим адресом $ip gw $gw."

# Задать адрес и адрес шлюза
        nmcli con mod "$con" ip4 $ip gw4 $gw
        echo "IPv4: $ip"
        echo "GW: $gw"

 # Задать адреса DNS
        nmcli con mod "$con" ipv4.dns "$dns"
        echo "DNS: $dns"

#  Добавить статический маршрут
        if [ ! -v "$gwroute" ] ; then
                nmcli con mod "$con" +ipv4.routes "192.168.1.0/24 $gwroute"
                echo "GWroute: $gwroute"
        else
                echo "GWroute: Не задано"
        fi

 # Отключаем DHCP, переводим в "ручной" режим настройки
        nmcli con mod "$con" ipv4.method manual
        echo "Применены следующие настройки:"
        nmcli -p con show "$con" | grep ipv4

 # Перезапустить соединение для применения новых настроек. Лучше всегда делать перезапуск одной командой, чтобы не терять машину при работе через удаленное подключение:

        nmcli con down "$con" ; nmcli con up "$con"
        echo "Соединение перезапущено!"

else
       echo "Соединение «$con» не найдено, настройте адрес вручную."
        exit 1
fi

ping 8.8.8.8 -w 3
