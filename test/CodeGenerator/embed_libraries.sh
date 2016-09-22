#!/bin/bash
func_src_file_name=$1
func_dest_file_name=$2
func_rel_file_name=$(echo $func_src_file_name | sed 's/.*\///')
func_tmp_file_name=$(echo $KITURA_SAMPLE_HOME'/CodeGenerator/__embed__'$func_rel_file_name)
rm -rf $func_tmp_file_name
cp $func_src_file_name $func_tmp_file_name
# append embedded files
grep -E '\$EmbedFile\:[ ]*.*' $func_tmp_file_name | while read -r line; do
	#if [ $line ]
	#then
		embed_src_file_name=$(echo $line | sed 's/^.*\:[ ]*\(.*\)$/\1/')
		embed_src_file_name=$(echo $SST_LIB_HOME'/'$embed_src_file_name)
		embed_rel_file_name=$(echo $embed_src_file_name | sed 's/.*\///')
		embed_tmp_file_name=$(echo $KITURA_SAMPLE_HOME'/CodeGenerator/__embed__'$embed_rel_file_name'.temp')
		rm -rf $embed_tmp_file_name
		cp $embed_src_file_name $embed_tmp_file_name
		# remove imports
		grep '^import.*$' $embed_src_file_name | while read -r line; do
			sed -i 's/^import.*$//g' $embed_tmp_file_name 
		done
		cat $embed_tmp_file_name >> $func_tmp_file_name
		rm -rf $embed_tmp_file_name
	#fi
done
cat $func_tmp_file_name > $func_dest_file_name
rm -rf $func_tmp_file_name