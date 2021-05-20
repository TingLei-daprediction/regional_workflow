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
cp $INPUT_DATA/PRSLEV${fhr}.${tmmark} PRSLEV${fhr}.${tmmark}
cp $INPUT_DATA/NATLEV${fhr}.${tmmark} ${COMOUT}/fv3lam.t${cyc}z.${domain}.natlev.f${fhr}.grib2

if [ $SENDCOM = YES ]
then
  # Generate files for FFaIR
    ${WGRIB2} PRSLEV${fhr}.${tmmark} | grep -F -f ${PARMfv3}/nam_nests.hiresf_testbed.txt | ${WGRIB2} -i -grib PRSLEV${fhr}.${tmmark}_testbed PRSLEV${fhr}.${tmmark}
    mv PRSLEV${fhr}.${tmmark} ${COMOUT}/fv3lam.t${cyc}z.${domain}.f${fhr}.grib2
    mv PRSLEV${fhr}.${tmmark}_testbed ${COMOUT}/fv3lam.t${cyc}z.${domain}.testbed.f${fhr}.grib2
fi

echo done > ${INPUT_DATA}/postdone${fhr}.${tmmark}

exit

