#!/usr/bin/env bash

#===================
#Name: Log_Copy.sh
#Author: miyoshi shuntaro
#date: 2019/12/20
#
#===================
#===================
#Variable
#===================
source /home/ec2-user/infra_Script/conf/Env_Valiable.conf

Script_Name=Docker_Log_Del
Script_Local_Conf=${E_script_conf}/${Script_Name}.conf
Script_Local_Log=${E_script_log}/`date '+%Y%m%d'`_${Script_Name}.log

#===================
#start_proc
#===================
#logの作成
touch ${Script_Local_Log}


#===================
#copy_proc
#===================
#dockerのプロセス確認
dockerPSdata=${E_script_tmp}/dockerPS.csv
echo "start :${Script_Name}.sh" >> ${Script_Local_Log} 2>&1
docker ps >> ${dockerPSdata}

#dockerのプロセス確認のconfの読み取り
while read -a line
do

  #Docker_Log_Delのconfファイルの読み取り
  while read -a line2
  do
    Docker_imgname=${ECR_root}/${line2[0]}
    if [[ "${line[1]}" == *"${Docker_imgname}"* ]]
    then
      #dockerからログをコピーする
      echo "del [ ${line2[3]}_LogDel ] that exists in [ ${line2[0]} ]" >> ${Script_Local_Log} 2>&1

      #dockerLogin
      echo ${line[11]}
      docker exec -it ${line[11]} >> ${Script_Local_Log} 2>&1
      rm -f ${line2[1]}${line2[2]}/${line2[3]}
      #dockerLogout
      exit

      #dockerからコピーしたファイルを別の場所に移す
    fi
  done<${Script_Local_Conf}
done<${dockerPSdata}

#===================
#check_Proc
#===================

#===================
#end_Proc
#===================
echo "tmp File Delet" >> ${Script_Local_Log} 2>&1
rm -f ${dockerPSdata} >> ${Script_Local_Log} 2>&1
rm -fr ${E_script_tmp}/* >> ${Script_Local_Log} 2>&1
echo "End :${Script_Name}.sh" >> ${Script_Local_Log} 2>&1
