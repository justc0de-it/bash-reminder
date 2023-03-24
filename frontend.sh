#! /bin/bash

BACKEND=./backend.sh
FPATH=$(readlink -f $BACKEND)
source ./ENV.txt

if [ -f "$FPATH" ]; then
	echo -n "" > $FPATH
fi

echo "#! /bin/bash" > $FPATH
echo "MSG=message" >> $FPATH

echo "Введите дату в формате DD MM:"
read -r DD MM

date "+%Y-%m-%d" -d "$(date +'%Y')-$MM-$DD" > /dev/null 2>&1

if [ $? != 0 ]; then
	echo "Это неправильный формат даты"
	exit 1
else
	DAY=$DD
	MONTH=$MM
fi

echo "Введите время в формате HH MM:"
read -r HH MM

date "+%hh-%mm" -d "$HH:$MM" > /dev/null 2>&1

if [ $? != 0 ]; then
	echo "Это неправильный формат времени"
	exit 1
else
	HOUR=$HH
	MINUTES=$MM
fi

echo "Введите то, что нужно напомнить:"
read -e MSG

sed 's/message/$MSG/' $FPATH > /dev/null 2>&1
echo curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage -d chat_id=$CHAT_ID -d text="$MSG" >> $FPATH
echo "sleep 20" >> $FPATH
echo "crontab -r" >> $FPATH

cronjob="$MINUTES $HOUR $DAY $MONTH * /bin/bash $FPATH > /dev/null 2>&1"
echo "$cronjob" >> foocron
crontab foocron
rm foocron

echo "Напоминание добавлено"

