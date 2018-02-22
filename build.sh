#!/bin/bash
set -x
BASEDIR=$PWD/$(dirname "$0")
VENV=venv
WORKSPACE=$BASEDIR/workspace

source $VENV/bin/activate

: ${API_GW:=https://api-saheer-uqa.mbedcloudintegration.net/}
: ${API_KEY:=ak_1MDE2MTdiOTRiNDYwMGE1ODBhMDEwMjJmMDAwMDAwMDA01617c5a68850a580a01022f00000000at7glnjtAwmts89dDB1J4NIdxcnw7M7q}
: ${APP_REPO:=mbed-client-testapp-sources-internal}


export API_GW=$API_GW
export API_KEY=$API_KEY

# create device certificate
python create_certificate.py
mv device_certificate.c $WORKSPACE/${APP_REPO}/source/mbed_cloud_dev_credentials.c

# create update certificate
cd $WORKSPACE/${APP_REPO}
# in one app  (source ??) repo file is in not so common place
rm $WORKSPACE/${APP_REPO}/update_default_resources.c
manifest-tool init -q -V 111dbc9a171011e882570242ac110001  -m K64F
cp $WORKSPACE/${APP_REPO}/update_default_resources.c $WORKSPACE/${APP_REPO}/source

# generic update configs
echo '
include(${CMAKE_SOURCE_DIR}/define.txt)
add_definitions(-DPAL_FS_MOUNT_POINT_PRIMARY="\\"./config\\"")
add_definitions(-DPAL_FS_MOUNT_POINT_SECONDARY="\\"./config\\"")
add_definitions(-DPAL_UPDATE_FIRMWARE_DIR="\\"./firmware\\"")
add_definitions(-DMBED_CLOUD_CLIENT_UPDATE_STORAGE=ARM_UCP_LINUX_GENERIC)
add_definitions(-DARM_UC_SOCKET_TIMEOUT_MS=5*60*1000)
' > define-app.txt

# build the linux binaries
# binaries must be in a specified path
# for running multiple binaries, copy app_dir_template to another directory, cd to dir  and run the binary
DIR_TEMPLATE=$BASEDIR/app_dir_template/00/00/00
mkdir -p $DIR_TEMPLATE
python pal-platform/pal-platform.py deploy --target=x86_x64_NativeLinux_mbedtls generate
PLATFORM_DIR="__x86_x64_NativeLinux_mbedtls"
cd $PLATFORM_DIR
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE=./../pal-platform/Toolchain/GCC/GCC.cmake -DEXTARNAL_DEFINE_FILE=./../define-app.txt
make mbedClientTestapp.elf -j10
mv Debug/mbedClientTestapp.elf $DIR_TEMPLATE/firmware.elf

make mbedClientTestapp.elf -j10
mv Debug/mbedClientTestapp.elf $DIR_TEMPLATE/payload.elf
cp $BASEDIR/run_app.py $DIR_TEMPLATE

# these are the scripts which performs firmware metadata header extraction
SCRIPTS_DIR=$BASEDIR/scripts
cp $SCRIPTS_DIR/*.sh $BASEDIR/app_dir_template


