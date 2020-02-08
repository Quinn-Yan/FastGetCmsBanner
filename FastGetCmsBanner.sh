#!/bin/bash

#####################################################################################################################################
# 
# Author klion
# Use:  # ./FastGetCmsBanner.sh  目标子域列表文件 WhatCMSApiKey 保存探测结果的文件名[随意]
#       # ./FastGetCmsBanner.sh TargetDomain.txt 2008cce12f319c5f2f3269438d50935ce4260d6b59283b6df31d794722ae4769184db3 result.txt
# 
#####################################################################################################################################

if [ $# -ne 3 ];then
    echo -e "\n\e[94m=========================================================================================================\e[0m\n"
    echo -e "\e[91mUse: \e[0m"
    echo -e "\e[91m # ./FastGetCmsBanner.sh TargetDomain.txt YourWhatCMSApiKey result.txt \e[0m"
    echo -e "\e[91m # ./FastGetCmsBanner.sh TargetDomain.txt 2008cce12f319c5f2f3269438d50935ce4260d6b59283b6df31d794722ae4769184db3 result.txt"
    echo -e "\n"
    echo -e "\e[94m=========================================================================================================\e[0m\n"
    exit
fi

echo -e "\n\e[94m=============================================================================================================================================\e[0m"

which "wget" > /dev/null
if [ $? -eq 0 ];then
    echo -e "\033[32m\nWget is Installed ! Jq install Begining ..... !\033[0m"
    wget -O ./jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 >/dev/null 2>&1
    chmod +x ./jq
    cp -f ./jq /usr/bin
    which "jq" > /dev/null
    if [ $? -eq 0 ];then
        echo -e "\033[32mJq install Succeed !\033[0m\n"
    fi
else
    apt-get install wget -y >/dev/null
    if [ $? -eq 0 ];then
        echo -e "\033[32mWget install Succeed !\033[0m\n"
    fi
fi

echo -e "\e[94m=============================================================================================================================================\e[0m\n"

printf "\033[36m%-56s %-38s %-16s %-18s %-10s\033[0m\n\n" TargetDomain CMSName Version ResponseNotice Status | tee -a $3

while read -r TargetDomains
do
    curl -G https://whatcms.org/APIEndpoint --data-urlencode key="$2" --data-urlencode url="$TargetDomains" -o json.txt >/dev/null 2>&1
    if [ $? -eq 0 ];then
        NewName=`jq .result.name json.txt`
        version=`jq .result.version json.txt`
        NewVersion=${version//\"/}
        msg=`jq .result.msg json.txt`
        ReMsg=${msg//\"/}
        if [ "$ReMsg" = "Failed: CMS or Host Not Found" ];then
            NewMsg="NotFound"
        elif [ "$ReMsg" = "Requested Url Was Unavailable" ];then
            NewMsg="Unavailable"
        else
            NewMsg="$ReMsg"
        fi
        code=`jq .result.code json.txt`
        if [ "$NewMsg" = "NotFound" ];then
            printf "\033[31m%-56s %-38s %-16s %-18s %-10s\033[0m\n" ${TargetDomains} ${NewName} ${NewVersion} ${NewMsg} ${code} | tee -a $3
        else
            printf "\033[32m%-56s %-38s %-16s %-18s %-10s\033[0m\n" ${TargetDomains} ${NewName} ${NewVersion} ${NewMsg} ${code} | tee -a $3
        fi
        
        rm -fr json.txt
        # 免费api 默认只能十秒查询一次,每月最多查一千次
        sleep 12
    else
        printf "\033[32m%-56s %-38s %-16s %-18s %-10s\033[0m\n\n" ${TargetDomains} failure failure failure failure | tee -a $3
    fi
    
done < $1

sed -i 's/\"//g' $3
echo -e "\n\e[94m=============================================================================================================================================\e[0m\n"


