#!/bin/sh
#############################################################################
# Script name:		exfv3cam_cleanup.sh
# Script description:	Scrub old files and directories
# Script history log:
#   1) 2018-04-09	Ben Blake
#			new script
#############################################################################
set -x

# Remove temporary working directories
cd ${DATAROOT}
rm -fr *forecast* 
rm -fr *gsianl* 
rm -fr *post* 
rm -fr *ic* 
rm -fr *bc* 

exit
