#!/usr/bin/env bash

IFACE='eth0'
IP=$(ip -4 address show $IFACE | grep 'inet' | sed 's/.*inet \([0-9\.]\+\).*/\1/')

echo "" >> /etc/hosts

if [ -z "${MESOS_CREDENTIALS_FILE_CONTENTS}" ]; then
    ${MESOS_CREDENTIALS_FILE_CONTENTS} > /etc/mesos/passwd
    AUTH_ARGUMENTS='--authenticate=true --credentials=/etc/mesos/passwd'
else
    AUTH_ARGUMENTS=''
fi

echo "[program:mesos-master]"  >> /etc/supervisor.conf
echo "user=root"  >> /etc/supervisor.conf
echo "command=mesos-master --ip=0.0.0.0 --port=5050 --work_dir=/var/lib/mesos ${AUTH_ARGUMENTS}"  >> /etc/supervisor.conf
echo "redirect_stderr=true"  >> /etc/supervisor.conf
echo ""  >> /etc/supervisor.conf

for i in $(seq 1 $NUMBER_OF_SLAVES)
do
  mkdir -p /var/lib/mesos/$i
  echo "$IP slave$i" >> /etc/hosts

  echo "" >> /etc/supervisor.conf

  echo "[program:mesos-slave$i]"  >> /etc/supervisor.conf
  echo "user=root"  >> /etc/supervisor.conf
  RESOURCES_VARIABLE=ENV_SLAVE${i}_RESOURCES
  echo "command=mesos-slave --port=505$i --master=zk://localhost:2181/mesos --work_dir=/var/lib/mesos/$i --no-switch_user --hostname=slave$i --resources=${!RESOURCES_VARIABLE}"  >> /etc/supervisor.conf
  echo "redirect_stderr=true"  >> /etc/supervisor.conf
  echo "process_name=mesos_slave_$i"  >> /etc/supervisor.conf
  echo "" >> /etc/supervisor.conf

done

sed -i s/@@NUM_SLAVES@@/${NUMBER_OF_SLAVES}/g /etc/supervisor.conf
supervisord -c /etc/supervisor.conf -e error
