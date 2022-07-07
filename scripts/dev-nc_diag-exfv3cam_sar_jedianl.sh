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


#cltexport jedi_template_workdir=${jedi_template_workdir:-/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-jedi-internal-new1/fv3-bundle/build/fv3-jedi/test/work-C775}
jedi_exp_output_string=${jedi_exp_output_string:-Ens3dvar-fv3_lam-C775}
export jedi_template_workdir=${jedi_template_workdir:-/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-fork-jedi-internal-devnew/fv3-bundle/build/fv3-jedi/test/work-C775}
export ioda_converted_obs=${COMINrap_user}/ioda.${PDYa}
#clt export jedi_yaml=${jedi_yaml:-$jedi_template_workdir/dev-wf-C775-3densvar.yaml}
#export jedi_yaml=${jedi_yaml:-$jedi_template_workdir/dev-wf-C775-3dhybrid.yaml}
#cltorg export jedi_yaml=${jedi_yaml:-$jedi_template_workdir/Jnewloc1000km-wf-C775-3dhybrid.yaml}
#export jedi_yaml=${jedi_yaml:-$jedi_template_workdir/newloc300km-wf-C775-3dhybrid.yaml}
export jedi_yaml=${jedi_yaml:-$jedi_template_workdir/newloc200km-wf-C775-3densvar.yaml}
export jedi_inc_yaml=${jedi_inc_yaml:-$jedi_template_workdir/C775-jedi-inc.yaml}
export JEDI_DataFix=${JEDI_DataFix:-/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-fork-jedi-internal-devnew/fv3-bundle/build/fv3-jedi/test/work-C775/DataFix}
export JEDI_DataInput=${JEDI_DataInput:-/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-fork-jedi-internal-devnew/fv3-bundle/build/fv3-jedi/test//work-C775/Data/INPUT}

ln -sf $JEDI_DataFix   DataFix
mkdir -p Data/
mkdir -p Data/INPUT
cp $JEDI_DataInput/* Data/INPUT/

ln -sf $ioda_converted_obs/obs Data/obs
mkdir -p Data/hofx
mkdir -p Data/analysis
mkdir -p Data/increment
mkdir -p Data/difffields
cp $jedi_yaml   jedi.yaml
cp $jedi_inc_yaml   jedi_inc.yaml

    str_datetime=$vlddate
    PDY0=`echo $vlddate | cut -c 1-4`
    MON0=`echo $vlddate | cut -c 5-6`
    DAY0=`echo $vlddate | cut -c 7-8`
    HR0=`echo $vlddate | cut -c 9-10`
    str_datetime0=${PDY0}-${MON0}-${DAY0}T${HR0}":00:00Z"
    str_datetime_left="datetime"
    sed -i  -e "/$str_datetime_left.*\:/ s/\:.*/\: ${str_datetime0}/" jedi.yaml

	window_bgn=`$NDATE -1 $vlddate`
    PDYb=`echo $window_bgn | cut -c 1-4`
    MONb=`echo $window_bgn | cut -c 5-6`
    DAYb=`echo $window_bgn | cut -c 7-8`
    HRb=`echo $window_bgn | cut -c 9-10`
    str_window_bgn=${PDYb}-${MONb}-${DAYb}T${HRb}":00:00Z"
    str_window_bgn_left="window begin"
    echo "thinkdeb str_window_bgn is "$str_window_bgn

    sed -i  -e "/$str_window_bgn_left.*\:/ s/\:.*/\: ${str_window_bgn}/" jedi.yaml
    sed -i  -e "s/XTIMESTRX/${PDY}.${CYC}0000/" jedi.yaml  
    sed -i  -e "s/XOBTIMESTRX/${PDY}${CYC}/" jedi.yaml  
    sed -i  -e "s/XX_exp_output_string_XX/${jedi_exp_output_string}/" jedi.yaml  
    cp jedi.yaml jedi_temp.yaml
    for obsfile in `grep -E "obsfile.*Data\/obs" jedi.yaml | sed 's/^.*://'`; do
     if [[ ! -f $obsfile ]]; then     
      echo "the $obsfile doesn t exsit , need remove itsn name in the yaml"
#clt https://stackoverflow.com/questions/33301963/sed-awk-remove-a-multiline-block-if-it-contains-multiple-patterns
      obsfile0=$(basename $obsfile)
 sed -n "/obs space/{ :loop; N; s/\n$/&/; t break; b loop; :break; s/$obsfile0/&/; t dropit; b keep; :dropit; d }; :keep; p" jedi_temp.yaml>jedi_temp1.yaml
      cp jedi_temp1.yaml jedi_temp.yaml
     fi
    done
    mv jedi_temp.yaml jedi.yaml
    


    sed -i  -e "/$str_datetime_left.*\:/ s/\:.*/\: ${str_datetime0}/" jedi_inc.yaml
    sed -i  -e "s/XTIMESTRX/${PDY}.${CYC}0000/" jedi_inc.yaml  


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


#jediexec=${jediexec:-/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-jedi-internal-new1/fv3-bundle/build/bin/fv3jedi_var.x}
#cltorg jediexec=${jediexec:-/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-jedi-internal-new1_deb/fv3-bundle/build/bin/fv3jedi_var.x}
#jediexec=${jediexec:-/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-fork-jedi-internal-devnew1/fv3-bundle/build/bin/fv3jedi_var.x}
jediexec=${jediexec:-/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-fork-jedi-internal-devnew1/fv3-bundle/build_normal/bin/fv3jedi_var.x}
#jediexec=${jediexec:-/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-jedi-internal-dev/fv3-bundle/build/bin/fv3jedi_var.x}
jedi_inc_exec=${jedi_inc_exec:-/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-fork-jedi-internal-devnew/fv3-bundle/build/bin/fv3jedi_diffstates.x}
# Set runtime and save directories
export endianness=Big_Endian

# Set variables used in script
#   ncp is cp replacement, currently keep as /bin/cp
ncp=/bin/cp

if [ ${l_coldstart_anal:-FALSE} = TRUE ]; then
    export L_LBC_UPDATE=FALSE
fi

if [[ ${L_LBC_UPDATE:-FALSE} = TRUE ]];then
   lbcupdt_str="_new"
else
   lbcupdt_str=""
   
fi
# setup ensemble filelist03

# Run gsi under Parallel Operating Environment (poe) on NCEP IBM

echo "thinkdeb"
which python
python -VV
export HYB_ENS=".true."
export HX_ONLY=${HX_ONLY:-FALSE}

DOHYBVAR=${DOHYBVAR:-"YES"}
if [[ ${HX_ONLY} = "TRUE" ]]; then
DOHYBVAR=NO
export HYB_ENS=".false."

fi

 if [[ $l_coldstart_anal == TRUE  &&  $tmmark == tm06  ]]; then
     regional_ensemble_option=1
     l_both_fv3sar_gfs_ens=.false.
     nens_fv3sar=0

 fi
regional_ensemble_option=${regional_ensemble_option:-5}
export nens=${nens:-81}
export nens_gfs=${nens_gfs:-$nens}
export nens_fv3sar=${nens_fv3sar:-$nens}
export l_both_fv3sar_gfs_ens=${l_both_fv3sar_gfs_ens:-.false.}
if [[ $DOHYBVAR = "YES" ]]; then 

 if [[ $regional_ensemble_option -eq 1 ||  $l_both_fv3sar_gfs_ens = '.true.' ]]; then
# We expect 81 total files to be present (80 enkf + 1 mean)

    # Not using FGAT or 4DEnVar, so hardwire nhr_assimilation to 3
    export nhr_assimilation=03
    ##typeset -Z2 nhr_assimilation

    if [ ${l_use_own_glb_ensemble:-.true.} = .true. ] ;then
      if [ ${L_GensExpand_Opt:-0} = 1 ] ;then
	vlddatebgn=`$NDATE -3 $vlddate`
	vlddateend=`$NDATE +3 $vlddate`
	rm -f filelist4d
        python $UTIL/getbest_EnKF_FV3GDAS_v1.py -v $vlddate --exact=yes --minsize=${nens_gfs} -d ${COMINgfs0}/enkfgdas -o filelist4d --o3fname=gfs_sigf${nhr_assimilation} --gfs_netcdfo=yes --4d=[$vlddatebgn,$vlddateend,1]
        
        cat filelist4d* >filelist4d
        numfiles0=`cat filelist4d | wc -l`
	rm -f filelist03
        if [ $numfiles0 -gt ${nens_gfs:-81} ]; then

            grep $vlddate filelist4d > filelist03
	  
            numfiles1=`cat filelist03 | wc -l`

            if [ $numfiles1 -gt 0 ]; then
	      ntmp=41
	   
	     vlddate1=`$NDATE -1 $vlddate`
	     grep $vlddate1 filelist4d > filelisttmp
	     head -$ntmp filelisttmp >> filelist03
	     vlddate2=`$NDATE +1 $vlddate`
	     grep $vlddate2 filelist4d >filelisttmp
	     head -$ntmp filelisttmp >> filelist03

           else
	     tail -162 filelist4d >flielist03

 	   fi

	    

      else 

	cp filelist4d filelist03
      fi  # numfiles0 -gt nens_gfs:-81




      else  #L_GensExpanse_opt
     
        python $UTIL/getbest_EnKF_FV3GDAS.py -v $vlddate --exact=no --minsize=${nens_gfs} -d ${COMINgfs0}/enkfgdas -o filelist${nhr_assimilation} --o3fname=gfs_sigf${nhr_assimilation} --gfs_netcdf=yes
    fi
#cltthink      if [[ $l_both_fv3sar_gfs_ens = ".true."  ]]; then
#cltthink        sed '1d;$d' filelist${nhr_assimilation} > d.txt  #don't use the ensemble mean
#cltthink        cp d.txt filelist${nhr_assimilation}
#cltthink      fi
    ####python $UTIL/getbest_EnKF.py -v $vlddate --exact=no --minsize=${nens} -d ${COMINgfs}/enkf -o filelist${nhr_assimilation} --o3fname=gfs_sigf${nhr_assimilation} --gfs_nemsio=yes

    #Check to see if ensembles were found
    numfiles=`cat filelist03 | wc -l`
    cp filelist${nhr_assimilation} $COMOUT/${RUN}.t${CYCrun}z.filelist03.${tmmark}
          nens_gfs=`cat filelist03 | wc -l`
  else


    cp  $COMOUT_ctrl/${RUN}.t${CYCrun}z.filelist03.${tmmark} tmp_filelist${nhr_assimilation}
        glb_dir=$(dirname $(head -1 tmp_filelist${nhr_assimilation})) 
        echo glbdir is $glb_dir 
        ls $glb_dir 
        if [ !  -d $glb_dir  ]; then
# use different delimiter to handle the slash in the path names
        sed  "s_${COMINgfs}_${global_ens_dir_backup}_g" tmp_filelist${nhr_assimilation} >filelist${nhr_assimilation}
        else
         cp tmp_filelist${nhr_assimilation} filelist${nhr_assimilation}
        fi
    fi
         
       if [[ $regional_ensemble_option -eq 1  ]]; then
        if [ $numfiles -lt 1 ]; then
          echo "Ensembles not found - turning off HYBENS!"
          export HYB_ENS=".false."
 #cltorg       else
          # we have 81 files, figure out if they are all the right size
          # if not, set HYB_ENS=false
#cltorg          . $UTIL/check_enkf_size.sh
        fi
          nens_gfs=`cat filelist03 | wc -l`
          nens=$nens_gfs
        fi


        echo "HYB_ENS=$HYB_ENS" > $COMOUT/${RUN}.t${CYCrun}z.hybens.${tmmark}
     fi
     mkdir -p Data/inputs/
     cd Data/inputs
     if [[ $regional_ensemble_option -eq 5 ]]; then
       for imem in $(seq 1 $nens_fv3sar ); do
             memchar="mem"$(printf %03i $imem)
         mkdir $memchar
#        cp ${COMIN_GES_ENS}/$memchar/${PDY}.${CYC}0000.${memstr}fv_core.res.tile1.nc fv3SAR01_${memchar}-fv3_dynvars
         cp ${COMIN_GES_ENS}/$memchar/${PDY}.${CYC}0000.${memstr}fv_core.res.tile1${lbcupdt_str}.nc $memchar/${PDY}.${CYC}0000.fv_core.res.tile1.nc
         cp ${COMIN_GES_ENS}/$memchar/${PDY}.${CYC}0000.${memstr}fv_tracer.res.tile1${lbcupdt_str}.nc $memchar/${PDY}.${CYC}0000.fv_tracer.res.tile1.nc 
         cp ${COMIN_GES_ENS}/$memchar/${PDY}.${CYC}0000.${memstr}coupler.res $memchar/${PDY}.${CYC}0000.coupler.res 
         cp ${COMIN_GES_ENS}/$memchar/${PDY}.${CYC}0000.${memstr}sfc_data${lbcupdt_str}.nc $memchar/${PDY}.${CYC}0000.sfc_data.nc 
         cp ${COMIN_GES_ENS}/$memchar/${PDY}.${CYC}0000.${memstr}fv_srf_wnd${lbcupdt_str}.res.nc $memchar/${PDY}.${CYC}0000.fv_srf_wnd.res.nc 
         done

     fi
    cd $DATA
fi  # DO_HYB_ENS
nens=$((  $nens_gfs + $nens_fv3sar ))

# Copy executable and fixed files to $DATA



export fv3_case=$GUESSdir

#  INPUT FILES FV3 NEST (single tile)

#   This file contains time information
mkdir -p Data/bkg
cd Data/bkg

if [ ${l_coldstart_anal:-FALSE} != TRUE ]; then
	cp $fv3_case/${PDY}.${CYC}0000.coupler.res coupler.res
	#   This file contains vertical weights for defining hybrid volume hydrostatic pressure interfaces 
	cp $fv3_case/${PDY}.${CYC}0000.fv_core.res.nc fv3_akbk.nc
	#   This file contains horizontal grid information
	cp $fv3_case/grid_spec${lbcupdt_str}.nc fv3_grid_spec.nc
	cp $fv3_case/${PDY}.${CYC}0000.sfc_data${lbcupdt_str}.nc fv3_sfcdata.nc
	cp $fv3_case/${PDY}.${CYC}0000.fv_srf_wnd${lbcupdt_str}.res.tile1.nc fv3_srf_wnd.nc
	#   This file contains 3d fields u,v,w,dz,T,delp, and 2d sfc geopotential phis
	ctrlstrname=${ctrlstr:+_${ctrlstr}_}
	   BgFile4dynvar=${BgFile4dynvar:-$fv3_case/${PDY}.${CYC}0000.${ctrlstrname}fv_core.res.tile1${lbcupdt_str}.nc}
	   BgFile4tracer=${BgFile4tracer:-$fv3_case/${PDY}.${CYC}0000.${ctrlstrname}fv_tracer.res.tile1${lbcupdt_str}.nc}
	   BgFile4dynvarOld=${BgFile4dynvarOld:-$fv3_case/${PDY}.${CYC}0000.${ctrlstrname}fv_core.res.tile1.nc}
	   BgFile4tracerOld=${BgFile4tracerOld:-$fv3_case/${PDY}.${CYC}0000.${ctrlstrname}fv_tracer.res.tile1.nc}
	cp $BgFile4dynvar fv3_dynvars.nc
	#   This file contains 3d tracer fields sphum, liq_wat, o3mr
	cp $BgFile4tracer fv3_tracer.nc
	#   This file contains surface fields (vert dims of 3, 4, and 63)
else
	#   This file contains vertical weights for defining hybrid volume hydrostatic pressure interfaces 
	cp $Fix_temp/${CASE+"${CASE}_"}fv_core.res.nc fv3_akbk.nc
	#   This file contains horizontal grid information
	cp $fv3_case/user_coupler.res coupler.res
	cp $Fix_temp/${CASE+"${CASE}_"}grid_spec${lbcupdt_str}.nc fv3_grid_spec.nc
#cltorg	cp $Fix_temp/grid_spec.nc fv3_grid_spec
        cp $fv3_case/sfc_data.tile7.nc fv3_sfcdata.nc
	    cp $fv3_case/${PDY}.${CYC}0000.fv_srf_wnd${lbcupdt_str}.res.tile1.nc fv3_srf_wnd.nc
        cp $fv3_case/gfs_data.tile7.nc . 
	ln -sf gfs_data.tile7.nc  fv3_dynvars.nc
	ln -sf gfs_data.tile7.nc fv3_tracer.nc
fi
cd $DATA
    ln -sf DataFix/INPUT INPUT #for newer version

export pgm=`basename $jediexec`
#cltorg . prep_step

#cltorg startmsg
###mpirun -l -n 240 $jediexec < gsiparm.anl > $pgmout 2> stderr
#mpirun -l -n 240 gsi.x < gsiparm.anl > $pgmout 2> stderr
#clt${APRUNC} $jediexec  jedi.yaml stdout  
#clt srun -l   -n 80   valgrind --track-origins=yes -s  $jediexec  jedi.yaml analysis.stdout  
export I_MPI_DEBUG=10
#clt srun -l   -n 80   --exclusive    $jediexec  jedi.yaml analysis.stdout  
srun -l   -n 80       $jediexec  jedi.yaml analysis.stdout  
#cltgsitest=/gpfs/hps3/emc/meso/save/Ting.Lei/dr-CAM-new/dr-GSI-RegDA_DZ_update/ProdGSI/exec/global_gsi.x
#${APRUNC} $gsitest < gsiparm.anl > $pgmout 2> stderr
export err=$?  #cltorg ;err_chk
if [ $err -ne 0 ]; then
 exit 999
fi
cd Data/analysis 
ln -sf ${jedi_exp_output_string}.coupler.res ${PDY}.${CYC}0000.coupler.res
ln -sf ${jedi_exp_output_string}.fv_core.res.nc ${PDY}.${CYC}0000.fv_core.res.nc
ln -sf ${jedi_exp_output_string}.fv_tracer.res.nc ${PDY}.${CYC}0000.fv_tracer.res.nc
ln -sf ../bkg/fv3_sfcdata.nc  ${PDY}.${CYC}0000.sfc_data.nc
ln -sf ../bkg/fv3_srf_wnd.nc  ${PDY}.${CYC}0000.fv_srf_wnd.res.nc


cd $DATA
srun -l -n 80   $jedi_inc_exec  jedi_inc.yaml diff.stdout  
echo "XXXXbegin20"

#the following module loading only works for bash, so change to bash and then change back
# If requested, create obsinput tarball from obs_input.* files
#temporay solution
#cat << EOF > temp.sh
#!/bin/bash 
#readlink /proc/$$/exe
#module use /scratch1/NCEPDEV/da/python/hpc-stack/miniconda3/modulefiles/stack/
#module load hpc
#module load miniconda3
#module load iodaconv
#module list
#chsh -s /usr/bin/ksh93
#readlink /proc/$$/exe
#EOF
#chmod +x temp.sh
#source ./temp.sh
source /scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-GFSV16-regional-workflow/regional_workflow/modulefiles/hera/ioda-module_complete.sh


	ls  Data/analysis/*.nc     
	cp Data/analysis/${PDY}.${CYC}0000*.* $JEDI_ANLdir/    
    cd Data/hofx
    filestrings=$(for f in *.nc4; do printf "%s\n" "${f%_*.nc4}"; done   | sort -u)
    echo $filestrings
    exit
    for filestring in $filestrings; do
    python $PYUFOCONCATE -i $filestring -o ${filestring}.nc4 
    cp ${filestring}.nc4  $JEDI_ANLdir/
    done 

	export err=$?;err_chk

	#Put new 000-h BC file and modified original restart files into ANLdir



	# Put analysis files in ANLdir (defined in J-job)

exit
