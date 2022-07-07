#!/bin/ksh
############################################################################
# Script name:		exfv3cam_post.sh
# Script description:	Run the post processor jobs to create grib2 output.
# Script history log:
#   1) 2018-08-20	Eric Aligo / Hui-Ya Chuang
#                       Created script to post process output 
#                       from the SAR-FV3.
#   2) 2018-08-23	Ben Blake
#                       Adapted script into EE2-compliant Rocoto workflow.
############################################################################
set -x

if [ $tmmark = tm00 ] ; then
  export NEWDATE=`${NDATE} +${fhr} $CDATE`
else
  offset=`echo $tmmark | cut -c 3-4`
  export vlddate=`${NDATE} -${offset} $CDATE`
  export NEWDATE=`${NDATE} +${fhr} $vlddate`
fi
export YYYY=`echo $NEWDATE | cut -c1-4`
export MM=`echo $NEWDATE | cut -c5-6`
export DD=`echo $NEWDATE | cut -c7-8`
export HH=`echo $NEWDATE | cut -c9-10`

# Run wgrib2
domain=${dom:-conus}
export EXPTDIR
export MET_INSTALL_DIR 
export MET_BIN_EXEC
export METPLUS_PATH
export METPLUS_CONF  #defined in config file
export MET_CONFIG    #defined 
export OBS_DIR
export MODEL
export NET

${METPLUS_PATH}/ush/master_metplus.py \
  -c ${METPLUS_CONF}/common.conf \
  -c ${METPLUS_CONF}/PointStat_conus_sfc.conf

${METPLUS_PATH}/ush/master_metplus.py \
  -c ${METPLUS_CONF}/common.conf \
  -c ${METPLUS_CONF}/PointStat_upper_air.conf

exit

