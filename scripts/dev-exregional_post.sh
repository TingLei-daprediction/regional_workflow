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

cat > itag <<EOF
${INPUT_DATA}/dynf0${fhr}.nc
netcdf
grib2
${YYYY}-${MM}-${DD}_${HH}:00:00
FV3R
${INPUT_DATA}/phyf0${fhr}.nc

 &NAMPGB
 KPO=47,PO=1000.,975.,950.,925.,900.,875.,850.,825.,800.,775.,750.,725.,700.,675.,650.,625.,600.,575.,550.,525.,500.,475.,450.,425.,400.,375.,350.,325.,300.,275.,250.,225.,200.,175.,150.,125.,100.,70.,50.,30.,20.,10.,7.,5.,3.,2.,1.,
 /
EOF

rm -f fort.*

# copy flat files
cp ${PARMfv3}/nam_micro_lookup.dat      ./eta_micro_lookup.dat
cp ${PARMfv3}/postxconfig-NT-fv3sar.txt ./postxconfig-NT.txt
cp ${PARMfv3}/params_grib2_tbl_new      ./params_grib2_tbl_new

# Run the post processor
export pgm=regional_post.x
. prep_step

startmsg
#export POSTGPEXEC=/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-wen/EMC_post/sorc/ncep_post.fd/ncep_post
export POSTGPEXEC=$EXECfv3/regional_post.x
${APRUNC} ${POSTGPEXEC} < itag > $pgmout 2> err
export err=$?; err_chk

# Run wgrib2
domain=${dom:-conus}

if [ ${domain:-conus} = conus ]
then
gridspecs="lambert:262.5:38.5:38.5 237.280:1799:3000 21.138:1059:3000"
elif [ $domain = "ak" ]
then
gridspecs="nps:210:60 185.5:825:5000 44.8:603:5000"
elif [ $domain = pr ]
then
gridspecs="latlon 283.41:340:.045 13.5:208:.045"
elif [ $domain = hi  ]
then
gridspecs="latlon 197.65:223:.045 16.4:170:.045"
elif [ $domain = guam  ]
then
gridspecs="latlon 141.0:223:.045 11.7:170:.045"
fi

compress_type=c3

if [ $fhr -eq 00 ] ; then
  ${WGRIB2} BGDAWP${fhr}.${tmmark} | grep -F -f ${PARMfv3}/nam_nests.hiresf_inst.txt  | ${WGRIB2} -i -grib BGDAWP${fhr}.${tmmark}_testbed  BGDAWP${fhr}.${tmmark}
    mv BGDAWP${fhr}.${tmmark} ${COMOUT}/${RUN}.t${cyc}z.${domain+${domain}.}f${fhr}.${memchar:+${memchar}.}grib2
    mv BGDAWP${fhr}.${tmmark}_testbed ${COMOUT}/${RUN}.t${cyc}z.${domain+${domain}.}.testbed.f${fhr}.${memchar:+${memchar}.}grib2
    mv BGRD3D${fhr}.${tmmark} ${COMOUT}/${RUN}.t${cyc}z.${domain+${domain}.}natlev.f${fhr}.${memchar:+${memchar}.}grib2
else
    mv BGDAWP${fhr}.${tmmark} ${COMOUT}/${RUN}.t${cyc}z.${domain+${domain}.}f${fhr}.${tmmark}.${memchar:+${memchar}.}grib2
    mv BGRD3D${fhr}.${tmmark} ${COMOUT}/${RUN}.t${cyc}z.${domain+${domain}.}natlev.f${fhr}.${tmmark}.${memchar:+${memchar}.}grib2

fi

echo done > ${INPUT_DATA}/postdone${fhr}.${tmmark}

exit
