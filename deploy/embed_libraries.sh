#!/bin/sh
func_src_file_name=$1
func_dest_file_name=$2
func_rel_file_name=$(echo $func_src_file_name | sed 's/.*\///')
func_rel_file_name=$(echo $func_rel_file_name | sed 's/\.[^.]*$//')
func_tmp_file_name=$(echo './__embed__'$func_rel_file_name'__.swift')
rm -rf $func_tmp_file_name
cp $func_src_file_name $func_tmp_file_name
# append embedded files
while read -r line; do
	embed_src_file_name=$(echo $line | sed 's/^.*\:[ ]*\(.*\)$/\1/')
	embed_src_file_name=$(echo '../lib/'$embed_src_file_name)
	embed_rel_file_name=$(echo $embed_src_file_name | sed 's/.*\///')
	embed_rel_file_name=$(echo $embed_rel_file_name | sed 's/\.[^.]*$//')
	embed_tmp_file_name=$(echo './__embed__'$embed_rel_file_name'__.swift')
	rm -rf $embed_tmp_file_name
	cp $embed_src_file_name $embed_tmp_file_name
	# remove imports
	grep '^import.*$' $embed_src_file_name | while read -r line; do
		sed -i '.bak' 's/^import.*$//g' $embed_tmp_file_name
		$(rm -rf $embed_tmp_file_name'.bak') 
	done
	cat $embed_tmp_file_name >> $func_tmp_file_name
	rm -rf $embed_tmp_file_name
done <<< "$(grep -E '\$EmbedFile\:[ ]*.*' $func_tmp_file_name)"
cat $func_tmp_file_name > $func_dest_file_name
rm -rf $func_tmp_file_name