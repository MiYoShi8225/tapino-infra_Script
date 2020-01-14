#!/usr/bin/env bash

#===================
#Name: XXX.sh
#Author: miyoshi shuntaro
#date: 2019/12/20
#
#===================
#===================
#Variable
#===================
source /home/ec2-user/infra_Script/conf/Env_Valiable.conf

Script_Name=XXX.sh
Script_Local_Conf=${script_conf}/${Script_Name}.conf
Script_Local_Log=${script_log}/`date '+%Y%m%d'`_${Script_Name}.log

#===================
#start_proc
#===================
#logの作成
touch ${Script_Local_Log}
