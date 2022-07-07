#!/bin/ksh

###############################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exfv3sar_gsianl.sh
# Script description:  Runs FV3SAR GSI analysis for the hourly DA cycle
#                      Uses RAP observations and Fv3GDAS EnKF files for the hybrid
#                      analysis. Create conventional and radiance stat files for monitoring
#
# Script history log:
# 2018-10-30  Eric Rogers - Modified based on original GSI script
# 2018-11-09  Ben Blake   - Moved various settings into J-job script
# 2019-07-26  Ting Lei    - combine analysis scripts for tm 12 and others to one  
#                         - modified to be used for the observation operator mode.and fv3sar ensemble based hybrid GSI
##############################################################################
#clt

set -x
export PYUFOCONCATE=${UFOCONCATE:-/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-GFSV16-regional-workflow/regional_workflow/jedi-tools/concat-ufo.py}

export NLN=${NLN:-"/bin/ln -sf"}

export OMP_NUM_THREADS=1
export OOPS_DEBUG=1
export OOPS_TRACE=1


export jedi_template_workdir=${jedi_template_workdir:-/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-jedi-internal-new1/fv3-bundle/build/fv3-jedi/test/work-C775}
export ioda_converted_obs=${COMINrap_user}/ioda.${PDYa}
#clt export jedi_yaml=${jedi_yaml:-$jedi_template_workdir/dev-wf-C775-3densvar.yaml}
#export jedi_yaml=${jedi_yaml:-$jedi_template_workdir/dev-wf-C775-3dhybrid.yaml}
#cltorg export jedi_yaml=${jedi_yaml:-$jedi_template_workdir/Jnewloc1000km-wf-C775-3dhybrid.yaml}
export jedi_yaml=${jedi_yaml:-$jedi_template_workdir/newloc300km-wf-C775-3dhybrid.yaml}
export jedi_inc_yaml=${jedi_inc_yaml:-$jedi_template_workdir/C775-jedi-inc.yaml}
export JEDI_DataFix=${JEDI_DataFix:-/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-jedi-internal-new1/fv3-bundle/build/fv3-jedi/test/work-C775/DataFix}
export jedi_convertstate_yaml=${jedi_convertstate_yaml:-$jedi_template_workdir/convertstate_gfs_D2A_wind.yaml}
export JEDI_DataInput=${JEDI_DataInput:-/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-jedi-internal-new1/fv3-bundle/build/fv3-jedi/test/work-C775/Data/INPUT}

ln -sf $JEDI_DataFix   DataFix
mkdir -p Data/
mkdir -p Data/INPUT
cp $JEDI_DataInput/* Data/INPUT/

ln -sf $ioda_converted_obs/obs Data/obs

offset=`echo $tmmark | cut -c 3-4`

case $tmmark in
  tm06) export tmmark_prev=tm06;;
  tm05) export tmmark_prev=tm06;;
  tm04) export tmmark_prev=tm05;;
  tm03) export tmmark_prev=tm04;;
  tm02) export tmmark_prev=tm03;;
  tm01) export tmmark_prev=tm02;;
  tm00) export tmmark_prev=tm01;;
esac
if [ $tmmark = tm06 ] ; then
  ens_nstarthr="06"  # from tm12 to tm06
else
  ens_nstarthr="01"  # from tm06 to tm05 and so on
fi


#jedi_convertstate_exec=${jedi_convertstate_exec:-/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-jedi-internal-new1_deb/fv3-bundle/build/bin/fv3jedi_convertstate.x}
jedi_convertstate_exec=${jedi_convertstate_exec:-/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-fork-jedi-internal-devnew/fv3-bundle/build/bin/fv3jedi_convertstate.x}
# Set runtime and save directories
export endianness=Big_Endian

# Set variables used in script
#   ncp is cp replacement, currently keep as /bin/cp
ncp=/bin/cp

# Run gsi under Parallel Operating Environment (poe) on NCEP IBM

echo "thinkdeb"
which python
python -VV

# Copy executable and fixed files to $DATA



export fv3_case=$GUESSdir

#  INPUT FILES FV3 NEST (single tile)

#   This file contains time information
cd $DATA
mkdir -p Data/bkg
    AnlSys=GSI
    AnlType=BG
    LocInputDir=Data/inputs/
    mkdir $LocInputDir
     mkdir -p  Data/outputs

	#   This file contains 3d fields u,v,w,dz,T,delp, and 2d sfc geopotential phis
	ctrlstrname=${ctrlstr:+_${ctrlstr}_}
	   File4coupleres=${File4dynvar:-$fv3_case/${PDY}.${CYC}0000.${ctrlstrname}coupler.res}
	   File4akbk=${File4dynvar:-$fv3_case/${PDY}.${CYC}0000.${ctrlstrname}fv_core.res.nc}
	   File4dynvar=${File4dynvar:-$fv3_case/${PDY}.${CYC}0000.${ctrlstrname}fv_core.res.tile1.nc}
	   File4tracer=${File4tracer:-$fv3_case/${PDY}.${CYC}0000.${ctrlstrname}fv_tracer.res.tile1.nc}
	   File4sfcdata=${File4dynvar:-$fv3_case/${PDY}.${CYC}0000.${ctrlstrname}sfc_data.nc}
	   File4srf_wnd=${File4dynvar:-$fv3_case/${PDY}.${CYC}0000.${ctrlstrname}fv_srf_wnd.res.tile1.nc}
 
	cp $fv3_case/${PDY}.${CYC}0000.fv_core.res.nc Data/bkg/fv3_akbk.nc

    cp $File4coupleres $LocInputDir/input.coupler.res
    cp $File4dynvar $LocInputDir/input.fv_core.res.nc
    cp  $File4tracer $LocInputDir/input.fv_tracer.res.nc
    cp  $File4sfcdata  $LocInputDir/input.sfc_data.nc
    cp $File4srf_wnd $LocInputDir/fv_srf_wnd.res.nc
    cp $jedi_convertstate_yaml   jedi_convertstate.yaml
    ln -sf DataFix/INPUT INPUT #for newer version
srun -l -n 10   $jedi_convertstate_exec  jedi_convertstate.yaml  jedi_convertstat.stdout  

exit


module list
export pgm=`basename $jediexec`
. prep_step

startmsg

exit