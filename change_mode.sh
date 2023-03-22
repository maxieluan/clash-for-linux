#!/bin/bash

# check for jq
if ! command -v jq &> /dev/null
then
    echo -e "\n\033[31m[×]\033[0m module jq is not installed, install it first first\n"
    exit
fi

# 自定义action函数，实现通用action功能
success() {
  echo -en "\\033[60G[\\033[1;32m  OK  \\033[0;39m]\r"
  return 0
}

failure() {
  local rc=$?
  echo -en "\\033[60G[\\033[1;31mFAILED\\033[0;39m]\r"
  [ -x /bin/plymouth ] && /bin/plymouth --details
  return $rc
}

action() {
  local STRING rc

  STRING=$1
  echo -n "$STRING "
  shift
  "$@" && success $"$STRING" || failure $"$STRING"
  rc=$?
  echo
  return $rc
}

usage() {
  echo -e "\nCurrent mode: $mode\nUsage: $0 [global|rule|direct]"
  exit 1
}

# 函数，判断命令是否正常执行
if_success() {
  local ReturnStatus=$3
  if [ $ReturnStatus -eq 0 ]; then
          action "$1" /bin/true
  else
          action "$2" /bin/false
          # exit 1
  fi
}

# 定义路劲变量
Server_Dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
source $Server_Dir/.env
Conf_Dir="$Server_Dir/conf"
Log_Dir="$Server_Dir/logs"
SECRET=${SECRET}

# check if clash is running
# check api on http://127.0.0.1:9090/ see if it returns {"hello":"clash"}
curl -X GET -H "Authorization: Bearer ${SECRET}" -s -m 10 --connect-timeout 10 -w %{http_code} "http://127.0.0.1:9090" | grep 'hello' &>/dev/null
ReturnStatus=$?
if [ $ReturnStatus -ne 0 ]; then
        echo -e "\n\033[31m[×]\033[0m Service is not running, run ./shutdown.sh first\n"
        exit 1
fi

# get currect mode using api 
# get http://127.0.0.1:9090/configs
config=$(curl -X GET -H "Authorization: Bearer ${SECRET}" -s -m 10 --connect-timeout 10 "http://127.0.0.1:9090/configs")

# extract mode from config. config is a json string with mode being the key
mode=$(echo $config | jq -r '.mode')

# take arguments from command line
# one global, rule, direct.
# if no argument is provide, show help info
if [ $# -eq 0 ]; then
    usage
    exit 1
fi

# check if the argument is valid
if [ "$1" != "global" ] && [ "$1" != "rule" ] && [ "$1" != "direct" ]; then
    usage
    exit 1
fi

# update config mode key with $1
config=$(echo $config | jq -r --arg mode "$1" '.mode = $mode')

# update the config using patch method on http://127.0.0.1:9090/configs
response_code=$(curl -X PATCH -d "$config" -H "Authorization: Bearer ${SECRET}" -s -m 10 --connect-timeout 10 -w %{http_code} "http://127.0.0.1:9090/configs")
# check response code 
if [[ $response_code -ge 200 && $response_code -lt 300 ]]; then
    echo -e "\n\033[32m[√]\033[0m Mode changed to $1\n"
    exit 0
else
    echo -e "\n\033[31m[×]\033[0m Failed to change mode to $1\n"
    exit 1
fi

