#!/bin/sh
cd $KITURA_SAMPLE_HOME
mkdir -p ./Packages
./CodeGenerator/generate_function_runner.sh
swift build -Xcc -fblocks 
./.build/debug/KituraSample &
while inotifywait -r /usr/functions ./Sources ./Package.swift -e create,modify,delete; do
	pkill KituraSample
	./CodeGenerator/generate_function_runner.sh
	swift build -Xcc -fblocks
	./.build/debug/KituraSample &
done