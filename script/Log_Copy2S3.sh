#!/usr/bin/env bash
#===================
#Name: Log_Copy2S3.sh
#Author: miyoshi shuntaro
#date: 2019/12/31
#
#===================
#===================
#Variable
#===================
source /home/ec2-user/infra_Script/conf/Env_Valiable.conf

Script_Name=Log_Copy2S3
Script_Local_Conf=${script_conf}/${Script_Name}.conf
Script_Local_Log=${script_log}/`date '+%Y%m%d'`_${Script_Name}.log

s3bucket=//tapino2logbucket

#===================
#start_proc
#===================
touch ${Script_Local_Log}

#===================
#copyToS3_proc
#===================
echo "start :${Script_Name}.sh" >> ${Script_Local_Log} 2>&1
while read -a line
do
  if [ -e ${script_log}/${line[0]} ]
  then
    echo "${script_log}/${line[0]} : exist"  >> ${Script_Local_Log} 2>&1
    ls ${script_log}/${line[0]} > ${script_tmp}/${line[0]}.tmp

    while read -a line2
    do
      aws s3 mv ${script_log}/${line[0]}/${line2[0]} s3:${s3bucket}/${line[0]}/  >> ${Script_Local_Log} 2>&1
      rm -f ${script_log}/${line[0]}/${line2[0]}  >> ${Script_Local_Log} 2>&1

    done<${script_tmp}/${line[0]}.tmp

    rm -f ${script_tmp}/${line[0]}.tmp

  else
    echo "not directory"

  fi
done<${Script_Local_Conf}

#===================
#end_Proc
#===================
echo "End :${Script_Name}.sh" >> ${Script_Local_Log} 2>&1
