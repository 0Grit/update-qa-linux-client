#!/bin/bash
set -x
BASEDIR=$PWD/$(dirname "$0")
VENV=venv
WORKSPACE=$BASEDIR/workspace
mkdir workspace
: ${MANIFESTTOOL_REPO:=manifest-tool-internal}
: ${MANIFESTTOOL_BRANCH:=v1.2rc4}
: ${PYTHON_SDK:=1.2.4}
: ${APP_REPO:=mbed-client-testapp-sources-internal}
: ${APP_BRANCH:=RR1.2.5-RC5}

virtualenv $VENV -p  python2.7 --no-site-packages
source $VENV/bin/activate
pip install -r requirements.txt

git clone https://github.com/ARMmbed/$APP_REPO.git $WORKSPACE/$APP_REPO
cd $WORKSPACE/$APP_REPO
git checkout $APP_BRANCH

git clone https://github.com/ARMmbed/$MANIFESTTOOL_REPO.git $WORKSPACE/manifest-tool
cd $WORKSPACE/manifest-tool
git checkout $MANIFESTTOOL_BRANCH
pip install .

git clone https://github.com/ARMmbed/mbed-cloud-sdk-python.git $WORKSPACE/mbed-cloud-sdk-python
cd $WORKSPACE/mbed-cloud-sdk-python
git checkout $PYTHON_SDK
python setup.py install

cd $WORKSPACE/${APP_REPO}
mbed deploy

# script directory contains firmware metadata header extraction scripts
# replacing header path to $PWD. Every instance of the binary needs to be run from a different path
# scripts should be three levels above the binary - it is as defined in https://github.com/ARMmbed/update-client-pal-linux/blob/master/source/arm_uc_pal_linux_generic.c

SCRIPTS_DIR=$BASEDIR/scripts
mkdir $SCRIPTS_DIR
cp $WORKSPACE/${APP_REPO}/mbed-cloud-client/update-client-hub/modules/pal-linux/scripts/arm_update_cmdline.sh $SCRIPTS_DIR 
cp $WORKSPACE/${APP_REPO}/mbed-cloud-client/update-client-hub/modules/pal-linux/scripts/generic/*.sh $SCRIPTS_DIR
sed -i 's/tmp\/extended/tmp\/$PWD\/extended/g'  $SCRIPTS_DIR/*.sh
