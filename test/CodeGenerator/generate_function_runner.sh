#!/bin/sh
echo 'Creating FunctionRunner...'
FUNC_RUNNER_FILE_NAME=$(echo $KITURA_SAMPLE_HOME/Sources/__FunctionRunner__.swift)
rm -rf $FUNC_RUNNER_FILE_NAME
cat $KITURA_SAMPLE_HOME/CodeGenerator/__FunctionRunner__.swift.prefix >> $FUNC_RUNNER_FILE_NAME
for i in $(ls $FUNCTIONS_HOME); do
	cd $FUNCTIONS_HOME/$i
	for j in $(ls *.swift); do
		# create class file
		FUNC_CLASS_NAME=$(echo $j | sed 's/\.[^.]*$//')
		FUNC_SRC_FILE_NAME=$(echo $FUNCTIONS_HOME'/'$i'/'$j)
		FUNC_DEST_FILE_NAME=$(echo $KITURA_SAMPLE_HOME'/Sources/__'$FUNC_CLASS_NAME'__.swift')
		echo 'Processing function '$FUNC_CLASS_NAME'; src='$FUNC_SRC_FILE_NAME'; dest='$FUNC_DEST_FILE_NAME
		# remove if exists, then create
		rm -f $FUNC_DEST_FILE_NAME
		touch $FUNC_DEST_FILE_NAME
		# add imports outside of class definition
		grep '^import.*$' $FUNC_SRC_FILE_NAME | while read -r line ; do
    		echo $line >> $FUNC_DEST_FILE_NAME
		done
		# copy to temp file and remove imports
		FUNC_TMP_FILE_NAME=$(echo $KITURA_SAMPLE_HOME'/Sources/__'$FUNC_CLASS_NAME'__.temp')
		cp $FUNC_SRC_FILE_NAME $FUNC_TMP_FILE_NAME
		grep '^import.*$' $FUNC_SRC_FILE_NAME | while read -r line ; do
    		sed -i 's/^import.*$//g' $FUNC_TMP_FILE_NAME
		done
		# create class
		echo '\npublic class '$FUNC_CLASS_NAME' {' >> $FUNC_DEST_FILE_NAME
		cat $FUNC_TMP_FILE_NAME >> $FUNC_DEST_FILE_NAME
		echo '\n}' >> $FUNC_DEST_FILE_NAME
		# remove temp file
		rm $FUNC_TMP_FILE_NAME
		# add to __FunctionRunner.swift
		echo '\n      if (function == "'$FUNC_CLASS_NAME'") {' >> $FUNC_RUNNER_FILE_NAME
		echo '\n         return '$FUNC_CLASS_NAME'().main(args: args)' >> $FUNC_RUNNER_FILE_NAME
		echo '\n      }' >> $FUNC_RUNNER_FILE_NAME
	done
done
cat $KITURA_SAMPLE_HOME/CodeGenerator/__FunctionRunner__.swift.suffix >> $FUNC_RUNNER_FILE_NAME
echo 'FunctionRunner created.'