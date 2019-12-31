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

#===================
#start_proc
#===================
touch ${Script_Local_Log}

#===================
#copyToS3_proc
#===================
echo "start :${Script_Name}.sh" >　2>&1 >> ${Script_Local_Log}
while read -a line
do
  


done<${Scr_Local_Conf}

#===================
#end_Proc
#===================
echo "End :${Script_Name}.sh" >　2>&1 >> ${Script_Local_Log}
