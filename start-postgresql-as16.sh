#!/bin/bash
###   Включение ожидания запуска кластера БД после некорректного выключения сервера.
###   Скрипт необходимо выполнять от пользователя <root>
###   После настройки время ожидания запуска кластера БД по умолчанию - 10 мин.
###   Тестировалось на Астра-1.6-path6, готовность БД к подключению восстанавливается до 8 мин.

  if [ $USER != root ]
    then echo "-----Скрипт необходимо выполнять от пользователя <root> !!!-----" ;
         sleep 2 ;
         exit 1
  fi

ctl_file=/etc/postgresql/9.6/main/pg_ctl.conf
sysd_file=/lib/systemd/system/postgresql@.service

  # Правка postgresql в systemd - ожидание старта БД 10 мин
grep -e 'TimeoutStartSec=10m' $sysd_file &>/dev/null
  if [ $? -ne 0 ]
    then
       grep -e 'TimeoutStartSec' $sysd_file &>/dev/null
         if [ $? -eq 0 ]
           then numsd=`fgrep -n TimeoutStartSec $sysd_file | cut -d: -f1`;
                sudo sed -i "$numsd d" $sysd_file
         fi
       numsv=`fgrep -n [Service] $sysd_file | cut -d: -f1`;
       sudo sed -i "$numsv a\TimeoutStartSec=10m" $sysd_file ;
       sudo systemctl daemon-reload ;
       echo "-----------------------------------------------------
Systemd:    Ожидание старта БД установлено 10 мин"
    else echo "-----------------------------------------------------
Systemd:    Ожидание старта БД УЖЕ установлено 10 мин"
  fi

  # Правка postgresql в  pg_ctl.conf - ожидание старта БД 10 мин
grep -e '-w -t 600' $ctl_file &>/dev/null
  if [ $? -ne 0 ]
    then
       grep -e 'pg_ctl_options' $ctl_file &>/dev/null
         if [ $? -eq 0 ]
           then numsc=`fgrep -n pg_ctl_options $ctl_file | cut -d: -f1` ;
                sudo sed -i "$numsc d" $ctl_file ;
         fi
       sudo echo "pg_ctl_options = '-w -t 600'" >> $ctl_file ;
       sudo systemctl restart postgresql ;
       echo "-------------------------------------------------------
Postgresql: Ожидание старта БД установлено 10 мин"
    else echo "-------------------------------------------------------
Postgresql: Ожидание старта БД УЖЕ установлено 10 мин"
  fi

echo "------------------------------------------------------
               -----Выполнено-----"
  sleep 2
exit 0