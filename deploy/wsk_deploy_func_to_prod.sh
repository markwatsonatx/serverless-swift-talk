#!/bin/sh
./wsk_set_env_prod.sh
action=$1
func_name=$2
func_file_name=$3
wsk_cmd=$(echo 'wsk action '$action' --kind swift:3')
while read -r line; do
	param_name=$(echo $line | sed 's/^.*\:[ ]*\(.*\)$/\1/')
	param_value=$(cat ../params/default_params_prod.txt | sed -n 's/^'$param_name'[^=]*=[ ]*\(.*\)$/\1/p')
	param_value=$(echo $param_value | sed "s/\'/\"/g")
	wsk_cmd=$(echo $wsk_cmd" --param "$param_name "'"$param_value"'")
done <<< "$(grep -E '\$DefaultParam\:[ ]*.*' $func_file_name)"
# create temp file for upload
mkdir -p ./release/prod
func_rel_file_name=$(echo $func_file_name | sed 's/.*\///')
func_rel_file_name=$(echo $func_rel_file_name | sed 's/\.[^.]*$//')
func_tmp_file_name=$(echo './release/prod/__'$func_rel_file_name'__.swift')
cp $func_file_name $func_tmp_file_name
./embed_libraries.sh $func_tmp_file_name $func_tmp_file_name
wsk_cmd=$(echo $wsk_cmd $func_name $func_tmp_file_name)
echo $wsk_cmd
eval $wsk_cmd