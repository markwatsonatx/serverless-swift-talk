#!/bin/sh
./wsk_set_env_prod.sh
action=$1
func_name=$2
func_file_name=$3
wsk_cmd=$(echo 'wsk action '$action' --kind swift:3')
while read -r line; do
	param_name=$(echo $line | sed 's/^.*\:[ ]*\(.*\)$/\1/')
	param_value=$(cat ../params/default_params_prod.txt | sed -n 's/^'$param_name'[^=]*=[ ]*\(.*\)$/\1/p')
	wsk_cmd=$(echo $wsk_cmd' --param '$param_name $param_value)
done <<< "$(grep -E '\$DefaultParam\:[ ]*.*' $func_file_name)"
echo $wsk_cmd