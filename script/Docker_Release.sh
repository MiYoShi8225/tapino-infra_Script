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

Script_Name=Dcoker_Release.sh
Script_Local_Conf=${E_script_conf}/${Script_Name}.conf
Script_Local_Log=${E_script_log}/`date '+%Y%m%d'`_${Script_Name}.log
Script_Local_Tmp=${E_script_tmp}/${Script_Name}.tmp

dockerPSdata=${E_script_tmp}/dockerPS.csv
dockerImgdate=${E_script_tmp}/dockerImg.csv

FLG_R=0
FLG_V=0
FLG_N=0
#===================
#start_proc
#===================
#logの作成
touch ${Script_Local_Log}

#optionの設定を行う
while getopts n:v: OPT
do
  case $OPT in
    "r" ) FLG_R=1 ; repoName="${OPTARG}" ;;
    "v" ) FLG_V=1 ; verNum="${OPTARG}" ;;
    "n" ) FLG_N=1 ; newRepo="${OPTARG}" ;;
    * ) echo "option not setting [-r:Input repository name ] [-v:Input repository version] [-n:Make new repository]"
    exit 1 ;;
  esac
done

#awsECRにログインする
ECR_login=`aws ecr get-login --region ${E_AWS_region} --registry-ids ${E_AWS_registryID} --no-include-email`
${ECR_login}

while read -a line
do
  if [ ${FLG_N} == 1 && ${FLG_V} == 1 ]
  then
    #repositoryのパスを格納する
    repoPath="${E_ECR_root}/${repoName}${verNum}"

    if [ ${verNum} == ${line[2]} ]
    then
      #ECR情報を取得
      docker pull ${repoPath} >> ${Script_Local_Log} 2>&1

      #dockerPSをtmpファイルに格納する
      docker ps >> ${dockerPSdata}

      while read -a line2
      do
        if [ ${line2[1]} == "${repoName}"* ]
        then
          #dockerプロセスをストップさせる
          docker stop ${line2[6]}

          #dockerスタート
          docker run -d ${line[1]} ${repoPath}${verNum}
        fi
      done<${dockerPSdata}

      #docker起動(バックグラウンド)
      docker run -d

      #docker imagesのデータをtmpに格納する
      docker images >> ${dockerImgdate}

      while read -a line2
      do
        if [${}]

      done<${dockerImgdate}

      #confのバックアップとconfigの更新
      cp -p ${Script_Local_Conf} ${script_log}/${Script_Local_Conf}.`date '+%Y%m%d_%H%M%S'` >> ${Script_Local_Log} 2>&1
      sed -e 's/${line[0]} ${line[2]}/${line[0]} ${verNum}/g'.${Script_Local_Conf} >> ${Script_Local_Log} 2>&1

  else

  fi
done<${Script_Local_Conf}
