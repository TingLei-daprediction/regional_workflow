#!/bin/ksh

###############################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exfv3sar_post.sh
# Script description:  Runs unified post-processor code to convert FV3SAR history files
#                      to GRIB2 on a rotated lat/lon grid. Use special version of wgrib2
#                      to interpolate the GRIB2 rotated lat/lon grid to the 3 km HRRR 
#                      lambert conformal grid.
#
# Script history log:
# 2018-10-30  Eric Rogers - Modified based on original post script
# 2018-11-16  Eric Rogers - Special version for tm06 first guess
#
###############################################################################
set -x

# First guess at tm06 is a 6-h FV3 fcst from tm12

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
domain=${domain:-conus}
mv $INPUT_DATA/PRSLEV${fhr}.${tmmark} PRSLEV${fhr}.${tmmark}
mv $INPUT_DATA/NATLEV${fhr}.${tmmark} ${COMOUT}/fv3lam.t${cyc}z.${domain}.natlev.f${fhr}.grib2

if [ $SENDCOM = YES ]
then
  # Generate files for FFaIR
    ${WGRIB2} PRSLEV${fhr}.${tmmark} | grep -F -f ${PARMfv3}/nam_nests.hiresf_testbed.txt | ${WGRIB2} -i -grib PRSLEV${fhr}.${tmmark}_testbed PRSLEV${fhr}.${tmmark}
    mv PRSLEV${fhr}.${tmmark} ${COMOUT}/fv3lam.t${cyc}z.${domain}.f${fhr}.grib2
    mv PRSLEV${fhr}.${tmmark}_testbed ${COMOUT}/fv3lam.t${cyc}z.${domain}.testbed.f${fhr}.grib2
fi

echo done > ${INPUT_DATA}/postdone${fhr}.${tmmark}


exit
