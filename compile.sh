#!/bin/bash

# build.sh uses a risc5 emulator and 'oxfstool' to generate the Oberon core payload
# required by assemble.sh. The emulator must support powering off via an Oberon system command.
#
# An Oberon image containing a multi-target compiler and batch execution is also required.
#
# This script creates a new Oberon image from the base image and updated sources and a set of
# batch commands that compiles the updated sources and then commands the system to shut down.
# The new binaries are then extracted from the image for use in assemble.sh.

EMULATOR=risc
OXFSTOOL=oxfstool

IOROOT=`cd ..;git rev-parse --show-toplevel;cd Boot`
SUBMODULEROOT=`cd ..;pwd;cd Boot`

BASEIMAGE=$IOROOT/images/io.img
OBERONBLDSRC=$SUBMODULEROOT/Build/
OBERONHALSRC=$SUBMODULEROOT/Boot/
OBERONDRAWSRC=$SUBMODULEROOT/Draw/
OBERONEDITSRC=$SUBMODULEROOT/Edit/
OBERONTESTSRC=$SUBMODULEROOT/Test/
OBERONFILESSRC=$SUBMODULEROOT/Files/
OBERONSYSTEMSRC=$SUBMODULEROOT/System/
OBERONKERNELSRC=$SUBMODULEROOT/Kernel/
OBERONMODULESSRC=$SUBMODULEROOT/Modules/
OBERONNODESSRC=$SUBMODULEROOT/Nodes/
OBERONOBERONSRC=$SUBMODULEROOT/Oberon/
OBERONBASICSRC=$SUBMODULEROOT/BASIC/
OBERONPASCALSRC=$SUBMODULEROOT/Pascal/
OBERONGOSRC=$SUBMODULEROOT/Go/
OBERONCSRC=$SUBMODULEROOT/C/
OBERONARGPARSESRC=$SUBMODULEROOT/ArgParse/

tools="available"

EMV=`${EMULATOR} --version`
OTV=`${OXFSTOOL} -V`

if [ ! ${EMV} == "2021.8.31" ] ; then
	echo "A risc5 emulator is required and EMULATOR must be set correctly"
	tools="unavailable"
fi

if [ ! ${OTV} == "0.1.2" ] ; then
	echo "oxfstool is required and OXFSTOOL must be set correctly"
	tools="unavailable"
fi

if [ ! -f ${BASEIMAGE} ] ; then
	echo "A risc5 Oberon base image is required and BASEIMAGE must be set correctly"
	tools="unavailable"
fi

if [ "$tools" == "available" ] ; then

  if [ ! -f ./Startup.Job ] ; then
	echo "Need a Startup.Job file to generate binaries from Oberon sources. Please provide."
  else
	echo "Building Oberon Core for supported architectures."
	mkdir -p ./build
	rm -rf ./build/*
	echo "Extracting files from ${BASEIMAGE}"
	${OXFSTOOL} -o2f -i ${BASEIMAGE} -o ./build

        rm ./build/x[987].txt
	cp ./Startup.Job ./build/
	cp ./Build.Tool  ./build/
	cp ./BASIC.Tool  ./build/
	cp ./Port.Tool   ./build/
	cp ./System.Tool ./build/

	

	cp ${OBERONHALSRC}HAL.*.Mod ./build/

	cp ${OBERONBLDSRC}OXP.Mod ./build/
	cp ${OBERONBLDSRC}OXP.Mod ./build/
	cp ${OBERONBLDSRC}OXG.Mod ./build/
	cp ${OBERONBLDSRC}OXX.Mod ./build/
	cp ${OBERONBLDSRC}OXT.Mod ./build/
	cp ${OBERONBLDSRC}OXB.Mod ./build/
	cp ${OBERONBLDSRC}OXS.Mod ./build/
	cp ${OBERONBLDSRC}ORDis.Mod ./build/
	cp ${OBERONBLDSRC}OIDis.Mod ./build/
	cp ${OBERONBLDSRC}OADis.Mod ./build/
	cp ${OBERONBLDSRC}OaDis.Mod ./build/
	cp ${OBERONBLDSRC}OvDis.Mod ./build/
	cp ${OBERONBLDSRC}OXDis.Mod ./build/

	cp ${OBERONBLDSRC}OXLinker.Mod ./build/
	cp ${OBERONBLDSRC}OXTool.Mod ./build/
#	cp ${OBERONBLDSRC}O.Dis.Mod ./build/


	cp ${OBERONPASCALSRC}*.Mod ./build/
	cp ${OBERONBASICSRC}*.Mod ./build/
	cp ${OBERONGOSRC}*.Mod ./build/
	cp ${OBERONCSRC}*.Mod ./build/
	cp ${OBERONEDITSRC}*.Mod ./build/
	cp ${OBERONDRAWSRC}*.Mod ./build/
	cp ${OBERONTESTSRC}*.Mod ./build/
	cp ${OBERONFILESSRC}*.Mod ./build/
	cp ${OBERONSYSTEMSRC}*.Mod ./build/
	cp ${OBERONKERNELSRC}*.Mod ./build/
	cp ${OBERONMODULESSRC}*.Mod ./build/
	cp ${OBERONOBERONSRC}*.Mod ./build/
	cp ${OBERONNODESSRC}*.Mod ./build/
	cp ${OBERONBASICSRC}Test.Bas ./build/
	cp ${OBERONGOSRC}GXP.go ./build/
	cp ${OBERONCSRC}CXP.c ./build/
	cp ${OBERONARGPARSESRC}*.Mod ./build/

	mkdir -p ./result
	rm -rf ./result/*
	rm ./work.img
	rm ./result.img
	${OXFSTOOL} -f2o -i build -o ./work.img -s 8M  > /dev/null
	echo "launching emulator"
	${EMULATOR} --mem 10 --size 1600x864x1 --leds  ./work.img
	echo "extracting produced files"
	${OXFSTOOL} -o2f -i ./work.img -o result  > /dev/null
        mv result/Modules.bin result/_BOOTIMAGE_
	echo "building result image"
	${OXFSTOOL} -f2o -i build -o ./result.img -s 8M > /dev/null
        echo "cleaning up"
	
	mv result/Core.* bin/

#	rm -rf result
#	rm -rf build
#	rm work.img
  fi

fi
