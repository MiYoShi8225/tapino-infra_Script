#!/usr/bin/env bash

#===================
#Name: Docker_Release.sh
#Author: miyoshi shuntaro
#date: 2020/01/12
#
#===================
#===================
#Variable
#===================
source /home/ec2-user/infra_Script/conf/Env_Valiable.conf

Script_Name=Docker_Release
Script_Local_Conf=${E_script_conf}/${Script_Name}.conf
Script_Local_Log=${E_script_log}/`date '+%Y%m%d'`_${Script_Name}.log
Script_Local_Tmp=${E_script_tmp}/${Script_Name}.tmp

dockerPSdata=${E_script_tmp}/dockerPS.csv
dockerImgdate=${E_script_tmp}/dockerImg.csv

FLG_R=0
FLG_V=0
FLG_N=0
FLG_P=0

#===================
#start_proc
#===================
#logの作成
touch ${Script_Local_Log}

#optionの設定を行う
while getopts "r:v:n:p" OPT
do
  case $OPT in
    "r" )
      FLG_R=1 ; repoName="${OPTARG}" ;;
    "v" )
      FLG_V=1 ; verNum="${OPTARG}" ;;
    "n" )
      FLG_N=1 ;;
    "p" )
      FLG_P=1 ; setOption=${OPTARG} ;;
    * )
      echo "option settings [-r:Input repository name ] [-v:Input repository version] [-n:Make new repository] [-p:Set docker run option When make new repository]" ;
      exit 1 ;;
  esac
done

echo "${FLG_N} ${FLG_R} ${FLG_V}"

#awsECRにログインする
ECR_login=`aws ecr get-login --region ${E_AWS_region} --registry-ids ${E_AWS_registryID} --no-include-email`
${ECR_login}

while read -a line
do
  if [ ${FLG_R} -eq 1 -a ${FLG_V} -eq 1 -a ${FLG_N} -eq 0 ]
  then
    #repositoryのパスを格納する
    repoPath="${E_ECR_root}/${repoName}${verNum}"

    #ECR情報を取得
    docker pull ${repoPath} >> ${Script_Local_Log} 2>&1

    #dockerPSをtmpファイルに格納する
    docker ps >> ${dockerPSdata}

    while read -a line2
    do
      if [ ${line2[1]} == "${E_ECR_root}/${repoName}" ]
      then
        ORGIFS=$IFS
        IFS=,
        echo "${line[0]} ${line[1]} ${line[2]}"
        #dockerプロセスをストップさせる
        docker stop ${line2[6]} >> ${Script_Local_Log} 2>&1

        #dockerスタート
        docker run -d ${line[2]} ${repoPath}${verNum} >> ${Script_Local_Log} 2>&1

        #docker削除
        docker rm ${line2[6]} >> ${Script_Local_Log} 2>&1
        IFS=$ORGIFS
      fi
    done<${dockerPSdata}

    #docker imagesのデータをtmpに格納する
    docker images >> ${dockerImgdate}

    while read -a line2
    do
      if [ ${line2[0]} == "${E_ECR_root}/${repoName}" -a ${line2[1]} == ${line[2]} ]
      then
        docker rmi $line2[2] >> ${Script_Local_Log} 2>&1
      fi
    done<${dockerImgdate}

    #confのバックアップとconfigの更新
    cp -p ${Script_Local_Conf} ${script_log}/${Script_Local_Conf}.`date '+%Y%m%d_%H%M%S'` >> ${Script_Local_Log} 2>&1
    #verの更新を行う
    sed -e 's/${line[0]} ${line[1]} ${line[2]}/${line[0]} ${verNum} ${line[2]}/g'.${Script_Local_Conf} >> ${Script_Local_Log} 2>&1

  elif [ ${FLG_R} -eq 1 -a ${FLG_V} -eq 1 -a ${FLG_N} -eq 1 ]
  then
    if [ ${FLG_P} -eq 0 ]
    then
      echo "${repoName} ${verNum}" >> ${Script_Local_Conf}
    elif [ ${FLG_P} -eq 1 ]
    then
      echo "${repoName} ${verNum} ${setOption}" >> ${Script_Local_Conf}
    fi
  else
    echo "option not setting"
  fi
done<${Script_Local_Conf}

rm -f ${E_script_tmp}/*
