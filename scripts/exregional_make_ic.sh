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

# gtype = regional
echo "creating standalone regional ICs"
export ntiles=1
export TILE_NUM=7

if [ $tmmark = tm00 ] ; then
  # input data is FV3GFS (ictype is 'pfv3gfs')
  export ANLDIR=$INIDIR
# input data is FV3GFS (ictype is 'pfv3gfs')
export ATMANL=$INIDIR/${CDUMP}.t${cyc}z.atmanl.nemsio
export SFCANL=$INIDIR/${CDUMP}.t${cyc}z.sfcanl.nemsio
export ANLDIR=$INIDIR
atmfile=${CDUMP}.t${cyc}z.atmanl.nemsio
sfcfile=${CDUMP}.t${cyc}z.sfcanl.nemsio
export input_dir=$INIDIR
monthguess=`echo ${CDATE} | cut -c 5-6`
dayguess=`echo ${CDATE} | cut -c 7-8`
cycleguess=`echo ${CDATE} | cut -c 9-10`
fi
if [ $tmmark = tm12 ] ; then
# input data is FV3GFS (ictype is 'pfv3gfs')
  export ANLDIR=$INIDIRtm12
export ATMANL=$INIDIRtm12/${CDUMP}.t${cycguess}z.atmanl.nemsio
export SFCANL=$INIDIRtm12/${CDUMP}.t${cycguess}z.sfcanl.nemsio
atmfile=${CDUMP}.t${cycguess}z.atmanl.nemsio
sfcfile=${CDUMP}.t${cycguess}z.sfcanl.nemsio
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
cp ${CHGRESEXEC} .
cat <<EOF >fort.41
&config
 mosaic_file_target_grid="$FIXsar/${CASE}_mosaic.nc"
 fix_dir_target_grid="$FIXsar"
 orog_dir_target_grid="$FIXsar"
 orog_files_target_grid="${CASE}_oro_data.tile7.halo4.nc"
 vcoord_file_target_grid="${PARMfv3}/global_hyblev.l${LEVS}.txt"
 mosaic_file_input_grid="NULL"
 orog_dir_input_grid="NULL"
 orog_files_input_grid="NULL"
 data_dir_input_grid="${ANLDIR}"
 atm_files_input_grid="$atmfile"
 sfc_files_input_grid="$sfcfile"
 cycle_mon=$monthguess
 cycle_day=$dayguess
 cycle_hour=$cycguess
 convert_atm=.true.
 convert_sfc=.true.
 convert_nst=.true.
 input_type="gaussian_nemsio"
 tracers="sphum","liq_wat","o3mr","ice_wat","rainwat","snowwat","graupel"
 tracers_input="spfh","clwmr","o3mr","icmr","rwmr","snmr","grle"
 regional=${REGIONAL}
 halo_bndy=${HALO}
 halo_blend=${NROWS_BLEND:-0}
/
EOF

export pgm=regional_chgres_cube.x
. prep_step

startmsg
#cltthinkdeb time ${APRUNC} -l ./regional_chgres_cube.x
time ${APRUNC}  ./regional_chgres_cube.x
export err=$?
###export err=$?;err_chk

if [ $err -ne 0 ] ; then
exit 99
fi

numfiles=`ls -1 gfs_ctrl.nc gfs.bndy.nc out.atm.tile1.nc out.sfc.tile1.nc | wc -l`
if [ $numfiles -ne 4 ] ; then
  export err=4
  echo "Don't have all IC files at ${tmmark}, abort run"
  exit 99
fi

#
# move output files to save directory
#
mv gfs_ctrl.nc $INPdir/.
mv gfs.bndy.nc $INPdir/gfs_bndy.tile7.000.nc
mv out.atm.tile1.nc $INPdir/gfs_data.tile7.nc
mv out.sfc.tile1.nc $INPdir/sfc_data.tile7.nc


exit 0
