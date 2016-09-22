#!/bin/bash
echo 'Creating FunctionRunner...'
func_runner_file_name=$(echo $KITURA_SAMPLE_HOME/Sources/__FunctionRunner__.swift)
rm -rf $func_runner_file_name
cat $KITURA_SAMPLE_HOME/CodeGenerator/__FunctionRunner__.swift.prefix >> $func_runner_file_name
echo '' >> $func_runner_file_name
for i in $(ls $SST_FUNCTIONS_HOME); do
	cd $SST_FUNCTIONS_HOME/$i
	for j in $(ls *.swift); do
		# create class file
		func_class_name=$(echo $j | sed 's/\.[^.]*$//')
		func_src_file_name=$(echo $SST_FUNCTIONS_HOME'/'$i'/'$j)
		func_dest_file_name=$(echo $KITURA_SAMPLE_HOME'/Sources/__'$func_class_name'__.swift')
		echo 'Processing function '$func_class_name'; src='$func_src_file_name'; dest='$func_dest_file_name
		# remove if exists, then create
		rm -f $func_dest_file_name
		touch $func_dest_file_name
		# add imports outside of class definition
		grep '^import.*$' $func_src_file_name | while read -r line; do
    		echo $line >> $func_dest_file_name
		done
		# copy to temp file and remove imports
		func_tmp_file_name=$(echo $KITURA_SAMPLE_HOME'/CodeGenerator/__'$func_class_name'__.temp')
		cp $func_src_file_name $func_tmp_file_name
		grep '^import.*$' $func_src_file_name | while read -r line ; do
    		sed -i 's/^import.*$//g' $func_tmp_file_name
		done
		# embed libraries
		$KITURA_SAMPLE_HOME/CodeGenerator/embed_libraries.sh $func_tmp_file_name $func_tmp_file_name
		# create class
		echo 'public class '$func_class_name' {' >> $func_dest_file_name
		cat $func_tmp_file_name >> $func_dest_file_name
		echo '}' >> $func_dest_file_name
		# remove temp file
		rm $func_tmp_file_name
		# add to __FunctionRunner.swift
		echo '      if (function == "'$func_class_name'") {' >> $func_runner_file_name
		echo '         var params = args' >> $func_runner_file_name
		grep -E '\$DefaultParam\:[ ]*.*' $func_src_file_name | while read -r line; do
			param_name=$(echo $line | sed 's/^.*\:[ ]*\(.*\)$/\1/')
			param_value=$(cat $SST_PARAMS_HOME/default_params_test.txt | sed -n 's/^'$param_name'[^=]*=[ ]*\(.*\)$/\1/p')
			param_value=$(echo $param_value | sed 's/\"/\\\"/g')
			echo '         params["'$param_name'"] = JSON.parse(string:"'$param_value'").dictionaryObject' >> $func_runner_file_name
		done
		echo '         return '$func_class_name'().main(args: params)' >> $func_runner_file_name
		echo '      }' >> $func_runner_file_name
	done
done
cat $KITURA_SAMPLE_HOME/CodeGenerator/__FunctionRunner__.swift.suffix >> $func_runner_file_name
echo 'FunctionRunner created.'