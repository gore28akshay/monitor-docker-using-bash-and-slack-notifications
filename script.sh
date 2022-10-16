#!/bin/bash

update_status () {
   mysql --login-path=sa status -se "update container_status set status='$1' where id=1"
}

get_status () {
output=$(mysql --login-path=sa status -se "select status from container_status where id=1")
}

update_slack () {
   token_var=$(cat token.txt)
   curl -X POST -H "Content-type: application/json" --data "{'text':'Container synthetic-alerts is $1'}" https://hooks.slack.com/services/T1TP7437D/B03L4QWBMA5/$token_var
}

container_status=$(docker inspect synthetic-alerts) #check if container exists
if [ $? -eq 0 ]; then #if container exists in any form. (running,exited etc)
   container_status=$(docker inspect --format='{{.State.Running}}' synthetic-alerts) #check status of conatiner
   if [ "${container_status}" = true ] ; then #if container is running
      get_status
      if [ "$output" = "up" ]; then
         echo "Status is correct. No further updates up-loop1"
      else
         echo 'Container synthetic-alerts is running'
         update_status "up"
         update_slack "running"
      fi
   else
      echo 'container synthetic-alerts is not running'
      get_status
      if [ "$output" = "down" ]; then
         echo "Status is correct. No further updates up-loop2"
      else
         update_status "down"
         update_slack "dead"
      fi
   fi
else #if container does not exists
   #echo "Container is not running."
   get_status
   if [ "$output" = "down" ]; then
      echo "Status is correct. No further updates up-loop3"
   else
      update_status "down"
      update_slack "dead"
   fi
fi
