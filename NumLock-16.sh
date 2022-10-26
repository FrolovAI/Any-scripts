#!/bin/bash
###   Включение NumLock по умолчанию на  Астра-1.6

##  Выполнить скрипт от пользователя, для которого настраивается включение NumLock по умолчанию,
##  при следующем входе в систему - NumLock будет включена.
##  Для настройки включения NumLock до входа в ОС выполнить скрипт от пользователя правами администратора (sudo),
##  после перезагрузки системы - NumLock будет включена.

# Пользователи без sudo
us-no-sud () {
  # Правка "после входа в систему пользователя"
  grep numLockOn=true ~/.fly/theme/current.themerc &>/dev/null
  if [ $? -ne 0 ]
   then sed -i 's!numLockOn=false!numLockOn=true!' ~/.fly/theme/current.themerc ;
        echo "NumLock включена по умолчанию для пользователя -$USER-"
   else echo "NumLock уже включена по умолчанию для пользователя -$USER-"
  fi
}
# Пользователи с sudo
us-s-sud () {
  # Правка "до входа в систему"
  grep NumLock=On /etc/X11/fly-dm/fly-dmrc &>/dev/null
  if [ $? -ne 0 ]
   then nums=`fgrep -n [X-*-Greeter] /etc/X11/fly-dm/fly-dmrc | cut -d: -f1`;
        sudo sed -i "$nums a\NumLock=On" /etc/X11/fly-dm/fly-dmrc ;
        echo "NumLock включена по умолчанию до входа в систему"
   else echo "NumLock уже включена по умолчанию до входа в систему"
  fi
  # Правка "для вновь создаваемых пользователей"
  grep numLockOn=true /usr/share/fly-wm/theme/default.themerc &>/dev/null
  if [ $? -ne 0 ]
   then sudo sed -i 's!numLockOn=false!numLockOn=true!' /usr/share/fly-wm/theme/default.themerc
  fi
  # Правка "после входа в систему пользователя"
  if [ $USER != root ]
   then us-no-sud
   else
     grep numLockOn=true /home/$SUDO_USER/.fly/theme/current.themerc &>/dev/null
      if [ $? -ne 0 ]
       then sed -i 's!numLockOn=false!numLockOn=true!' /home/$SUDO_USER/.fly/theme/current.themerc
            echo "NumLock включена по умолчанию для пользователя -$SUDO_USER-"
       else echo "NumLock уже включена по умолчанию для пользователя -$SUDO_USER-"
      fi
  fi
}
# Выполнение
  sudo -v &>/dev/null
  if [ $? != 0 ]
   then us-no-sud
   else us-s-sud
  fi
  echo "-----Выполнено-----"
  sleep 2
exit 1