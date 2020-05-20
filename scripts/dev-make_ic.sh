#!/bin/sh
############################################################################
# Script name:		exfv3cam_sar_chgres.sh
# Script description:	Makes ICs on fv3 stand-alone regional grid 
#                       using FV3GFS initial conditions.
# Script history log:
#   1) 2016-09-30       Fanglin Yang
#   2) 2017-02-08	Fanglin Yang and George Gayno
#			Use the new CHGRES George Gayno developed.
#   3) 2019-05-02	Ben Blake
#			Created exfv3cam_sar_chgres.sh script
#			from global_chgres_driver.sh
############################################################################
set -ax
cd $DATA
pwd
# gtype = regional
echo "creating standalone regional ICs"
export ntiles=1
export TILE_NUM=7

if [ $tmmark = tm00 ] ; then
# input data is FV3GFS (ictype is 'pfv3gfs')
export ATMANL=${ATMANL:-$INIDIR/${CDUMP}.t${cyc}z.atmanl.nemsio}
export SFCANL=${SFCANL:-$INIDIR/${CDUMP}.t${cyc}z.sfcanl.nemsio}
export input_dir=$(dirname ATMANL)
atmfile="$(basename  $ATMANL)"   #${CDUMP}.t${cyc}z.atmanl.nemsio
sfcfile="$(basename  $SFCANL)"   #${CDUMP}.t${cyc}z.sfcanl.nemsio
export input_dir=$ #clt $INIDIR
monthguess=`echo ${CDATE} | cut -c 5-6`
dayguess=`echo ${CDATE} | cut -c 7-8`
cycleguess=`echo ${CDATE} | cut -c 9-10`

elif [ $tmmark = tm12 ] ; then
# input data is FV3GFS (ictype is 'pfv3gfs')
export ATMANL=${ATMANL:-$INIDIRtm12/${CDUMP}.t${cycguess}z.atmanl.nemsio}
export SFCANL=${SFCANL:-$INIDIRtm12/${CDUMP}.t${cycguess}z.sfcanl.nemsio}
export input_dir=$(dirname $ATMANL)
atmfile=$(basename $ATMANL)   #${CDUMP}.t${cycguess}z.atmanl.nemsio
sfcfile=$(basename $SFCANL)   #${CDUMP}.t${cycguess}z.sfcanl.nemsio
monthguess=`echo ${CYCLEguess} | cut -c 5-6`
dayguess=`echo ${CYCLEguess} | cut -c 7-8`
else
export ATMANL=${ATMANL? "ATMANL should be set in advance"}
export SFCANL=${SFCANL?"SFCANL should be set in advance"}
export input_dir=$(dirname $ATMANL)
atmfile=$(basename $ATMANL)   #${CDUMP}.t${cycguess}z.atmanl.nemsio
sfcfile=$(basename $SFCANL)   #${CDUMP}.t${cycguess}z.sfcanl.nemsio
monthguess=`echo ${CYCLEguess} | cut -c 5-6`
dayguess=`echo ${CYCLEguess} | cut -c 7-8`



fi

#
# set the links to use the 4 halo grid and orog files
# these are necessary for creating the boundary data
#
ln -sf $FIXsar/${CASE}_grid.tile7.halo4.nc $FIXsar/${CASE}_grid.tile7.nc 
ln -sf $FIXsar/${CASE}_oro_data.tile7.halo4.nc $FIXsar/${CASE}_oro_data.tile7.nc 
ln -sf $FIXsar/${CASE}.vegetation_greenness.tile7.halo4.nc $FIXsar/${CASE}.vegetation_greenness.tile7.nc
ln -sf $FIXsar/${CASE}.soil_type.tile7.halo4.nc $FIXsar/${CASE}.soil_type.tile7.nc
ln -sf $FIXsar/${CASE}.slope_type.tile7.halo4.nc $FIXsar/${CASE}.slope_type.tile7.nc
ln -sf $FIXsar/${CASE}.substrate_temperature.tile7.halo4.nc $FIXsar/${CASE}.substrate_temperature.tile7.nc
ln -sf $FIXsar/${CASE}.facsf.tile7.halo4.nc $FIXsar/${CASE}.facsf.tile7.nc
ln -sf $FIXsar/${CASE}.maximum_snow_albedo.tile7.halo4.nc $FIXsar/${CASE}.maximum_snow_albedo.tile7.nc
ln -sf $FIXsar/${CASE}.snowfree_albedo.tile7.halo4.nc $FIXsar/${CASE}.snowfree_albedo.tile7.nc
ln -sf $FIXsar/${CASE}.vegetation_type.tile7.halo4.nc $FIXsar/${CASE}.vegetation_type.tile7.nc

#
# create namelist and run chgres cube
#
pwddir=`pwd`
cp ${CHGRESEXEC} $pwddir 
cat <<EOF >fort.41
&config
 mosaic_file_target_grid="$FIXsar/${CASE}_mosaic.nc"
 fix_dir_target_grid="$FIXsar"
 orog_dir_target_grid="$FIXsar"
 orog_files_target_grid="${CASE}_oro_data.tile7.halo4.nc"
 vcoord_file_target_grid="${FIXam}/global_hyblev.l${LEVS}.txt"
 mosaic_file_input_grid="NULL"
 orog_dir_input_grid="NULL"
 orog_files_input_grid="NULL"
 data_dir_input_grid="${input_dir}"
 atm_files_input_grid="$atmfile"
 sfc_files_input_grid="$sfcfile"
 cycle_mon=$monthguess
 cycle_day=$dayguess
 cycle_hour=$cycguess
 convert_atm=.true.
 convert_sfc=${CONVERT_SFC:-.true.}
 convert_nst=.true.
 input_type="gaussian"
 tracers="sphum","liq_wat","o3mr","ice_wat","rainwat","snowwat","graupel"
 tracers_input="spfh","clwmr","o3mr","icmr","rwmr","snmr","grle"
 regional=${REGIONAL}
 halo_bndy=${HALO}
 halo_blend=${NROWS_BLEND:-0}
/
EOF

export pgm=regional_chgres_cube.x
#cltthinkdeb . prep_step

#cltthinkdeb startmsg
time ${APRUNC} ./regional_chgres_cube.x> stdout
export err=$?
###export err=$?;err_chk

if [ $err -ne 0 ] ; then
exit 99
fi

if [ $REGIONAL = 1 ] ; then  
numfiles=`ls -1 gfs_ctrl.nc gfs.bndy.nc out.atm.tile1.nc out.sfc.tile1.nc | wc -l`
if [ $numfiles -ne 4 ] ; then
  export err=4
  echo "Don't have all IC files at ${tmmark} "
fi
else
numfiles=`ls -1 gfs_ctrl.nc gfs.bndy.nc  out.sfc.tile1.nc | wc -l`
if [ $numfiles -ne 3 ] ; then
  export err=5
  echo "Don't have all bc files at ${tmmark}, "
fi
fi

#
# move output files to save directory
#
mv gfs.bndy.nc $OUTDIR/gfs_bndy.tile7.${hour_name:-000}.nc

if [ $REGIONAL = 1 ] ; then  
mv gfs_ctrl.nc $OUTDIR/.
mv out.atm.tile1.nc $OUTDIR/gfs_data.tile7.nc
if [ $CONVERT_SFC != .false. ] ; then
mv out.sfc.tile1.nc $OUTDIR/sfc_data.tile7.nc
fi
fi
