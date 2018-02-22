# update-qa-linux-client
This is an example project created to demonstrate how linux client can be built and run.

## How the update work
_Binaries are built using generic pal implementation : https://github.com/ARMmbed/update-client-pal-linux/blob/master/source/arm_uc_pal_linux_generic.c_

When a firmware is downloaded, update client extracts the firmware metadata and stores the information in a path known to it. This path is provided by a few shell scripts. This is referenced in the .c file mentioned above - these scripts are:

mbed-cloud-client/update-client-hub/modules/pal-linux/scripts/arm_update_cmdline.sh
mbed-cloud-client/update-client-hub/modules/pal-linux/scripts/generic/*.sh

In normal RPi, after a successful firmware is download, device will reboot and hence providing the metadata information back to the service. In this case, there could be a "bootloader" like script which can check the console log for succesful completion, exits the current binary, and then runs the downloaded one. run_app.py provides an example for this.

_download location of the firmware is provided in the define_app.txt_


## Running the virtual client
*  docker-compose build
*  docker run
    _provide api_gw and key. By default it is running against saheer-uqa sandbox_
    docker run --name virtual-linux -it -e API_GW=<api_gw> -e API_KEY=<api_key> --rm update-qa/virtual-client:latest  bash
    
*  ./build.sh
    _this creates a 'template device' in 'app_dir_template'. Multiple devices can be created by copying the directory_

*  Run the client. 
    *   source venv/bin/activate [ TODO: Remove venv from container ]
    *   create new device from template: cp -r app_dir_template 01
    *   cd to directory where the binary is. This is an important step as update expects the shell scripts to be 3 level up  and firmware is downloaded in the $PWD
        
        cd 01/00/00/00/
    
    *   Run the "wrapper script" ./run_app.py
        _this registers the device and wait for 7 days for update_
    
    *   At this point device is ready, you may create the manifest, campaign etc by hand or script it!


## Next Steps
This is an example work, needs to be moved to clitest (for SyTe) and update-service-integration. 

* The setup.sh and build.sh should be moved to update-service-integration repo as a python script. When running for multiple devices, making update campaign device filter on vendor id could be the easier way to target multiple deivces.

* Liase with https://github.com/ARMmbed/mbed-client-service and possibly add this in RAAS.

## known issues/investigation needed
* More than 10 devices often had network timeout after registration. This made campaign to wait in publishing mode.
* More than 100 devices will need BYOC flow. But, it most probably means compiling the binary for as many times as devices needed as one certificate can be used only for one. May be the 100 device limit can be overriden by some setting in admin portal
* currently tests using this running in jenkins is not connecting to sandbox. Looks like a network issue.


