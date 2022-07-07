set -x

 fv3_io_layout_nx=2
 fv3_io_layout_ny=2

###############################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exfv3sar_gsianl.sh
# Script description:  Runs FV3SAR GSI analysis for the hourly DA cycle
#                      Uses RAP observations and Fv3GDAS EnKF files for the hybrid
#                      analysis. Create conventional and radiance stat files for monitoring
#
# Script history log:
# 2018-10-30  $USER - Modified based on original GSI script
#

function ncvarlst_noaxis_time { ncks --trd -m ${1} | grep -E ': type' | cut -f 1 -d ' ' | sed 's/://' | sort |grep -v -i -E "axis|time" ;  }
function ncvarlst_noaxis_time_new { ncks -m  ${1} | grep -E 'name.*=' | cut -f 2 -d '=' | grep -o '"*.*"' | sed 's/"//g' | sort |grep -v -i -E "axis|time" ;  }
export  HDF5_USE_FILE_LOCKING=FALSE #clt to avoild recenter's error "NetCDF: HDF error"


   EnKFTracerVars=${EnKFTracerVar:-"sphum,o3mr"}
export ldo_enscalc_option=${ldo_enscalc_option:-1}
machine=DELL


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
NDATE=/scratch2/NCEPDEV/nwprod/NCEPLIBS/utils/prod_util.v1.1.0/exec/ndate
export vlddate=`$NDATE -${offset} $CYCLE`
export SDATE=$vlddate
export cyc=`echo $vlddate | cut -c 9-10`
export cya=`echo $vlddate | cut -c 9-10`
export CYC=`echo $vlddate | cut -c 9-10`
export PDY=`echo $vlddate | cut -c 1-8`
export PDYrun=`echo $CYCLE | cut -c 1-8`
export PDYa=`echo $vlddate | cut -c 1-8`
export CYCrun=`echo $CYCLE | cut -c 9-10`

# Set path/file for gsi executable

 export gsiexec=${gsiexec:-$gsiexec0}

# Set runtime and save directories
export endianness=Big_Endian

# Set variables used in script
#   ncp is cp replacement, currently keep as /bin/cp
ncp=/bin/cp

# setup ensemble filelist03


export HYB_ENS=".true."

# We expect 81 total files to be present (80 enkf + 1 mean)
export nens=${nens:-4}  #tothink

# Not using FGAT or 4DEnVar, so hardwire nhr_assimilation to 3
export nhr_assimilation=03
##typeset -Z2 nhr_assimilation
export EnsMeanDir=$NWGES_ens/enkf_mean${tmmark}/ensmean
mkdir -p $EnsMeanDir
export EnsAnMeanDir=$NWGES_ens/enkf_AnMean${tmmark}/ensmean
mkdir -p $EnsAnMeanDir
cd $DATA
if [ $ldo_enscalc_option -ne 2  ] ; then
   if [ $ldo_enscalc_option -eq 0  ] ; then
   ensmeanchar="ensmean"  #cltthinkto
   EnsMeanDir=$NWGES_ens/${tmmark}/"mem001"
        ii=0
        for j in $(seq 1 $fv3_io_layout_ny); do 
         for i in $(seq 1 $fv3_io_layout_nx);do 
            strsubindex="."$(printf %04i $ii)
#            cp   $EnsMeanDir/${PDY}.${CYC}0000.${ensfiletype:-bg}_ensmean_fv_dynvars$strsubindex fv3sar_tile1_${ensmeanchar}_dynvars$strsubindex
            cp   $EnsMeanDir/${PDY}.${CYC}0000.fv_core.res.tile1.nc$strsubindex fv3sar_tile1_${ensmeanchar}_dynvars$strsubindex
            cp   $EnsMeanDir/${PDY}.${CYC}0000.fv_tracer.res.tile1.nc$strsubindex fv3sar_tile1_${ensmeanchar}_tracer$strsubindex  
	     let ii=ii+1
         done
       done
   elif  [ $ldo_enscalc_option -eq 1 ] ; then 
   memchar="mem001"  #cltthinkto
   ensmeanchar="ensmean"  #cltthinkto
   #clt to use mem001 stuff as the ensmean stuff
       
            export FcstOutDir=$NWGES_ens/${tmmark}/$memchar
        ii=0
        for j in $(seq 1 $fv3_io_layout_ny); do 
         for i in $(seq 1 $fv3_io_layout_nx);do 
            strsubindex="."$(printf %04i $ii)
            cp ${FcstOutDir}/${PDY}.${CYC}0000.${memstr}fv_tracer.res.tile1.nc$strsubindex fv3sar_tile1_${ensmeanchar}_tracer$strsubindex
            cp ${FcstOutDir}/${PDY}.${CYC}0000.${memstr}fv_core.res.tile1.nc$strsubindex fv3sar_tile1_${ensmeanchar}_dynvars$strsubindex
	let ii=ii+1
         done 
       done

   fi  # =0 or 1

       
       for imem in $(seq 1 $nens); do
        ii=0
        for j in $(seq 1 $fv3_io_layout_ny); do 
         for i in $(seq 1 $fv3_io_layout_nx);do 
            strsubindex="."$(printf %04i $ii)
         
            memchar="mem"$(printf %03i $imem)
            export FcstOutDir=$NWGES_ens/${tmmark}"/"$memchar
             cp ${FcstOutDir}/${PDY}.${memstr}*.fv_core.res.nc fv3sar_tile1_akbk.nc #clt fv3_akbk
            if [ $imem -eq 1  ] ; then
                cp ${FcstOutDir}/grid_spec.nc$strsubindex fv3sar_tile1_grid_spec.nc$strsubindex
            fi
            cp ${FcstOutDir}/${PDY}.${CYC}0000.fv_core.res.tile1.nc$strsubindex fv3sar_tile1_${memchar}_dynvars$strsubindex 
            cp ${FcstOutDir}/${PDY}.${CYC}0000.fv_tracer.res.tile1.nc$strsubindex fv3sar_tile1_${memchar}_tracer$strsubindex
	     let ii=ii+1
       done
       done
      done
else
#for recenter  
         cp  $ANLdir/${ctrlstr+_${ctrlstr}_}fv_core.res.nc fv3sar_tile1_akbk.nc 
         cp $ANLdir/${ctrlstr+_${ctrlstr}_}coupler.res  coupler.res
         cp ${ANLdir}/${ctrlstr+_${ctrlstr}_}fv3_grid_spec.nc fv3sar_tile1_grid_spec.nc
         cp $ANLdir/${ctrlstr+_${ctrlstr}_}fv_core.res.tile1.nc fv3sar_tile1_mem001_dynvars
         cp $ANLdir/${ctrlstr+_${ctrlstr}_}fv_tracer.res.tile1.nc fv3sar_tile1_mem001_tracer

         cp  $EnsMeanDir/${PDY}.${CYC}0000.${ensfiletype:-bg}_ensmean_fv_dynvars fv3sar_tile1_ensmean_dynvars
         cp  $EnsMeanDir/${PDY}.${CYC}0000.${ensfiletype:-bg}_ensmean_fv_tracer fv3sar_tile1_ensmean_tracer 
         let "nens0 = $nens "
         let "nens = $nens + 1"
         
         for imem in $(seq 1 $nens0); do
         ( 
         memchar="mem"$(printf %03i $imem)
         let "memin = $imem + 1"
             meminchar="mem"$(printf %03i $memin)
         export EnsAnlDir=$NWGES_ens/enkf_anl${tmmark}/$memchar
#         export EnsRecDir=$NWGES_ens/enkf_rec${tmmark}/$memchar
         cp $EnsAnlDir/${PDY}.${CYC}0000.anl_dynvars_${memchar}_fv_core.res.tile1.nc fv3sar_tile1_${meminchar}_dynvars
         cp $EnsAnlDir/${PDY}.${CYC}0000.anl_tracer_${memchar}_fv_core.res.tile1.nc fv3sar_tile1_${meminchar}_tracer
          ) &
         done
        wait


fi

#clt get diag files

if [ $ldo_enscalc_option -eq 0 ] ; then
memstr=ensmean
RADSTAT=${COMOUT}/${RUN}.t${CYCrun}z.${memstr}_radstat.${tmmark}
CNVSTAT=${COMOUT}/${RUN}.t${CYCrun}z.${memstr}_cnvstat.${tmmark}
cp $RADSTAT . 
tar xvf `basename  $RADSTAT`
cp $CNVSTAT  .  
tar xvf `basename  $CNVSTAT`


for imem in $(seq 1 $nens); do
memstr="mem"$(printf %03i $imem)
RADSTAT=${COMOUT}/${RUN}.t${CYCrun}z.${memstr}_radstat.${tmmark}
CNVSTAT=${COMOUT}/${RUN}.t${CYCrun}z.${memstr}_cnvstat.${tmmark}
cp $RADSTAT . 
tar xvf `basename  $RADSTAT`
cp $CNVSTAT  .  
tar xvf `basename  $CNVSTAT`

done
#the files are like diag_hirs4_metop-b_mem001_ges.2019061218.gz
#  and diag_conv_mem002_ges.2019061218.gz
for gzfile in `ls diag*ges*.gz `; do
gzip -d  $gzfile
rm -fr $gzfile
done
for diagfile in `ls diag*mem*ges*`; do
#for example diagfile is ctrmem005_diag_conv_anl.2019042419
str=$diagfile
str1=${str%mem*}
#   echo "str1 is " $str1 #diag_conv_anl.2019042419
str2=${str##*_}
str3=${str##*mem}
memid=${str3:0:3}
#   echo "str3 is " $str3 #diag_conv_anl.2019042419
#   echo "memid is " $memid

if [[ $str2 == *".nc4" ]]; then
newdiagfile=${str1}${str2%".nc4"*}_mem${memid}.nc4
export netcdf_diag=.true.
else
newdiagfile=${str1}${str2}_mem$memid
fi
#   newdiagfile=${newdiagfile/_ges/.ges} 
#   echo newfile is $newfile
mv $diagfile $newdiagfile

done
for diagfile in `ls diag*ensmean*ges*`; do
#for example diagfile is ctrmem005_diag_conv_anl.2019042419
str=$diagfile
str1=${str%ensmean*}
#   echo "str1 is " $str1 #diag_conv_anl.2019042419
str2=${str##*_}
#   echo "str3 is " $str3 #diag_conv_anl.2019042419
#   echo "memid is " $memid
if [[ $str2 == *".nc4" ]]; then
newdiagfile=${str1}${str2%".nc4"*}_ensmean.nc4
export netcdf_diag=.true.
else
newdiagfile=${str1}${str2}_ensmean
fi
#   newdiagfile=${newdiagfile/_ges/.ges} 
#   echo newfile is $newfile
mv $diagfile $newdiagfile

done
fi






#cltthinkdeb nens=`cat filelist03 | wc -l`
if [ $ldo_enscalc_option -eq 1 -o $ldo_enscalc_option -eq 2 ]; then
anavinfo=$PARMfv3/anavinfo_fv3_enkf_ensmean_${LEVS}
else
anavinfo=$PARMfv3/anavinfo_fv3_enkf_${LEVS}
fi
satinfo=$PARMfv3/fv3sar_satinfo.txt
scaninfo=$fixgsi/global_scaninfo.txt
satangl=$fixgsi/nam_global_satangbias.txt
ozinfo=$fixgsi/nam_global_ozinfo.txt
convinfo=$fixgsi/nam_regional_convinfo.txt

ln -sf  $anavinfo ./anavinfo
# Copy executable and fixed files to $DATA

ln -sf  $satangl  ./satbias_angle
ln -sf  $satinfo  ./satinfo
ln -sf  $scaninfo ./scaninfo
ln -sf  $ozinfo   ./ozinfo
ln -sf  $convinfo ./convinfo

cp $GESROOT_HOLD/satbias_in ./satbias_in

# Set parameters
export USEGFSO3=.false.
export nhr_assimilation=3.
export vs=1.
export fstat=.false.
export i_gsdcldanal_type=0
use_gfs_nemsio=.true.,

# Make enkf namelist
	cat > enkf.nml << EOFnml
	&nam_enkf
	datestring="$vlddate",datapath="$DATA/",
	analpertwtnh=0.85,analpertwtsh=0.85,analpertwttr=0.85,
	covinflatemax=1.e2,covinflatemin=1,pseudo_rh=.true.,iassim_order=0,
	corrlengthnh=400,corrlengthsh=400,corrlengthtr=400,
	lnsigcutoffnh=0.5,lnsigcutoffsh=0.5,lnsigcutofftr=0.5,
	lnsigcutoffpsnh=0.5,lnsigcutoffpssh=0.5,lnsigcutoffpstr=0.5,
	lnsigcutoffsatnh=0.5,lnsigcutoffsatsh=0.5,lnsigcutoffsattr=0.5,
	obtimelnh=1.e30,obtimelsh=1.e30,obtimeltr=1.e30,
	saterrfact=1.0,numiter=1,
	sprd_tol=1.e30,paoverpb_thresh=0.98,
	nlons=${NX_RES},nlats= ${NY_RES}, nlevs= $(( LEVS - 1)),nanals=$nens,
	deterministic=.true.,sortinc=.true.,lupd_satbiasc=.false.,
	reducedgrid=.true.,readin_localization=.false.,
	use_gfs_nemsio=.true.,imp_physics=99,lupp=.false.,
	univaroz=.false.,adp_anglebc=.true.,angord=4,use_edges=.false.,emiss_bc=.true.,
    fv3_native=.true.,paranc=.true.,
	lobsdiag_forenkf=.false.,
	write_spread_diag=.false.,
	netcdf_diag=${netcdf_diag:-.false.},
	$NAM_ENKF
	/
#cltorg	ldo_enscalc_option=${ldo_enscalc_option},
	&satobs_enkf
	sattypes_rad(1) = 'amsua_n15',     dsis(1) = 'amsua_n15',
	sattypes_rad(2) = 'amsua_n18',     dsis(2) = 'amsua_n18',
	sattypes_rad(3) = 'amsua_n19',     dsis(3) = 'amsua_n19',
	sattypes_rad(4) = 'amsub_n16',     dsis(4) = 'amsub_n16',
	sattypes_rad(5) = 'amsub_n17',     dsis(5) = 'amsub_n17',
	sattypes_rad(6) = 'amsua_aqua',    dsis(6) = 'amsua_aqua',
	sattypes_rad(7) = 'amsua_metop-a', dsis(7) = 'amsua_metop-a',
	sattypes_rad(8) = 'airs_aqua',     dsis(8) = 'airs_aqua',
	sattypes_rad(9) = 'hirs3_n17',     dsis(9) = 'hirs3_n17',
	sattypes_rad(10)= 'hirs4_n19',     dsis(10)= 'hirs4_n19',
	sattypes_rad(11)= 'hirs4_metop-a', dsis(11)= 'hirs4_metop-a',
	sattypes_rad(12)= 'mhs_n18',       dsis(12)= 'mhs_n18',
	sattypes_rad(13)= 'mhs_n19',       dsis(13)= 'mhs_n19',
	sattypes_rad(14)= 'mhs_metop-a',   dsis(14)= 'mhs_metop-a',
	sattypes_rad(15)= 'goes_img_g11',  dsis(15)= 'imgr_g11',
	sattypes_rad(16)= 'goes_img_g12',  dsis(16)= 'imgr_g12',
	sattypes_rad(17)= 'goes_img_g13',  dsis(17)= 'imgr_g13',
	sattypes_rad(18)= 'goes_img_g14',  dsis(18)= 'imgr_g14',
	sattypes_rad(19)= 'goes_img_g15',  dsis(19)= 'imgr_g15',
	sattypes_rad(20)= 'avhrr_n18',     dsis(20)= 'avhrr3_n18',
	sattypes_rad(21)= 'avhrr_metop-a', dsis(21)= 'avhrr3_metop-a',
	sattypes_rad(22)= 'avhrr_n19',     dsis(22)= 'avhrr3_n19',
	sattypes_rad(23)= 'amsre_aqua',    dsis(23)= 'amsre_aqua',
	sattypes_rad(24)= 'ssmis_f16',     dsis(24)= 'ssmis_f16',
	sattypes_rad(25)= 'ssmis_f17',     dsis(25)= 'ssmis_f17',
	sattypes_rad(26)= 'ssmis_f18',     dsis(26)= 'ssmis_f18',
	sattypes_rad(27)= 'ssmis_f19',     dsis(27)= 'ssmis_f19',
	sattypes_rad(28)= 'ssmis_f20',     dsis(28)= 'ssmis_f20',
	sattypes_rad(29)= 'sndrd1_g11',    dsis(29)= 'sndrD1_g11',
	sattypes_rad(30)= 'sndrd2_g11',    dsis(30)= 'sndrD2_g11',
	sattypes_rad(31)= 'sndrd3_g11',    dsis(31)= 'sndrD3_g11',
	sattypes_rad(32)= 'sndrd4_g11',    dsis(32)= 'sndrD4_g11',
	sattypes_rad(33)= 'sndrd1_g12',    dsis(33)= 'sndrD1_g12',
	sattypes_rad(34)= 'sndrd2_g12',    dsis(34)= 'sndrD2_g12',
	sattypes_rad(35)= 'sndrd3_g12',    dsis(35)= 'sndrD3_g12',
	sattypes_rad(36)= 'sndrd4_g12',    dsis(36)= 'sndrD4_g12',
	sattypes_rad(37)= 'sndrd1_g13',    dsis(37)= 'sndrD1_g13',
	sattypes_rad(38)= 'sndrd2_g13',    dsis(38)= 'sndrD2_g13',
	sattypes_rad(39)= 'sndrd3_g13',    dsis(39)= 'sndrD3_g13',
	sattypes_rad(40)= 'sndrd4_g13',    dsis(40)= 'sndrD4_g13',
	sattypes_rad(41)= 'sndrd1_g14',    dsis(41)= 'sndrD1_g14',
	sattypes_rad(42)= 'sndrd2_g14',    dsis(42)= 'sndrD2_g14',
	sattypes_rad(43)= 'sndrd3_g14',    dsis(43)= 'sndrD3_g14',
	sattypes_rad(44)= 'sndrd4_g14',    dsis(44)= 'sndrD4_g14',
	sattypes_rad(45)= 'sndrd1_g15',    dsis(45)= 'sndrD1_g15',
	sattypes_rad(46)= 'sndrd2_g15',    dsis(46)= 'sndrD2_g15',
	sattypes_rad(47)= 'sndrd3_g15',    dsis(47)= 'sndrD3_g15',
	sattypes_rad(48)= 'sndrd4_g15',    dsis(48)= 'sndrD4_g15',
	sattypes_rad(49)= 'iasi_metop-a',  dsis(49)= 'iasi_metop-a',
	sattypes_rad(50)= 'seviri_m08',    dsis(50)= 'seviri_m08',
	sattypes_rad(51)= 'seviri_m09',    dsis(51)= 'seviri_m09',
	sattypes_rad(52)= 'seviri_m10',    dsis(52)= 'seviri_m10',
	sattypes_rad(53)= 'amsua_metop-b', dsis(53)= 'amsua_metop-b',
	sattypes_rad(54)= 'hirs4_metop-b', dsis(54)= 'hirs4_metop-b',
	sattypes_rad(55)= 'mhs_metop-b',   dsis(55)= 'mhs_metop-b',
	sattypes_rad(56)= 'iasi_metop-b',  dsis(56)= 'iasi_metop-b',
	sattypes_rad(57)= 'avhrr_metop-b', dsis(57)= 'avhrr3_metop-b',
	sattypes_rad(58)= 'atms_npp',      dsis(58)= 'atms_npp',
	sattypes_rad(59)= 'atms_n20',      dsis(59)= 'atms_n20',
	sattypes_rad(60)= 'cris_npp',      dsis(60)= 'cris_npp',
	sattypes_rad(61)= 'cris-fsr_npp',  dsis(61)= 'cris-fsr_npp',
	sattypes_rad(62)= 'cris-fsr_n20',  dsis(62)= 'cris-fsr_n20',
	sattypes_rad(63)= 'gmi_gpm',       dsis(63)= 'gmi_gpm',
	sattypes_rad(64)= 'saphir_meghat', dsis(64)= 'saphir_meghat',
	$SATOBS_ENKF
	/
	&ozobs_enkf
	sattypes_oz(1) = 'sbuv2_n16',
	sattypes_oz(2) = 'sbuv2_n17',
	sattypes_oz(3) = 'sbuv2_n18',
	sattypes_oz(4) = 'sbuv2_n19',
	sattypes_oz(5) = 'omi_aura',
	sattypes_oz(6) = 'gome_metop-a',
	sattypes_oz(7) = 'gome_metop-b',
	sattypes_oz(8) = 'mls30_aura',
	$OZOBS_ENKF
	/
	&nam_fv3
	fv3fixpath="XXX",nx_res=$NX_RES,ny_res=$NY_RES,ntiles=1,l_fv3reg_filecombined=.false.,
     fv3_io_layout_nx=${fv3_io_layout_nx},fv3_io_layout_ny=${fv3_io_layout_ny}
	/
EOFnml





	export fv3_case=$GUESSdir

#clt to make two  pesudo fv3sar ensembles



	echo 'thinkdeb path is ' $PATH
	echo before ulimit 
	ulimit -a
	ulimit -v unlimited
    ulimit -s unlimited
	echo after  ulimit 
	ulimit -a

#thinkdeb

#cltthinkdeb try /usrx/local/prod/intel/2018UP01/compilers_and_libraries/linux/mpi/bin64/mpirun -l -n 240 gsi.x < gsiparm.anl > $pgmout 2> stderr
	echo pwd is `pwd`
	cd $DATA
	ENKFEXEC=${ENKFEXEC:-$HOMEgsi/exec/global_enkf}
	export pgm=`basename $ENKFEXEC`
#cltthinkdeb	. prep_step

#cltthinkdeb	startmsg
    ENKFEXEC=/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-daprediction-github-GSI/GSI/build/bin/enkf_fv3reg_DBG.x
    ENKFEXEC=/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-daprediction-github-GSI/GSI/build/src/enkf/enkf.x
	cp $ENKFEXEC $DATA/enkf.x
#cltorg mpirun -l -n  240  $DATA/enkf.x < enkf.nml 1>stdout 2>stderr
	if [ $ldo_enscalc_option -ne 0  ] ; then
	let i=1
#cltthink tothink 	for infile in `ls ${anavinfo}_p*`
	for infile in `ls ${anavinfo}`
	do
	cp $infile anavinfo 
	cat anavinfo >anavinfo_part_${i}
	${APRUNC}  $DATA/enkf.x < enkf.nml 1>>part_${i}_$pgmout 2>>part_${i}_stderr
	let i=i+1
	done
	else
	${APRUNC}  $DATA/enkf.x < enkf.nml 1>$pgmout 2>stderr
#cltthinkdeb    srun --label --ntasks=6 --ntasks-per-node=3 $DATA/enkf.x<enkf.nml 1>stdout 2>stderr
fi
rc=$?
exit

export ERR=$rc
export err=$ERR
# Cat runtime output files.


export err=$?;err_chk
if [ $err -ne 0 ]; then
 exit 999
fi
#export ldo_enscalc_option=${ldo_enscalc_option:-0}
if [ $ldo_enscalc_option -eq 0 ] ; then
         for imem in $(seq 1 $nens); do
          ( 
             memchar="mem"$(printf %03i $imem)
             memstr=$memchar
             export EnsAnlDir=$NWGES_ens/enkf_anl${tmmark}/$memchar
             mkdir -p $EnsAnlDir
             cp fv3sar_tile1_${memstr}_dynvars $EnsAnlDir/${PDY}.${CYC}0000.anl_dynvars_${memstr}_fv_core.res.tile1.nc  
             cp fv3sar_tile1_${memstr}_tracer $EnsAnlDir/${PDY}.${CYC}0000.anl_tracer_${memstr}_fv_core.res.tile1.nc  
         ) &
         done
        wait
elif  [ $ldo_enscalc_option -eq 1 ] ; then 
         memstr="ensmean"
         cp fv3sar_tile1_mem001_dynvars  $EnsMeanDir/${PDY}.${CYC}0000.${ensfiletype:-bg}_${memstr}_fv_core.res.tile1.nc  
         cp fv3sar_tile1_mem001_tracer   $EnsMeanDir/${PDY}.${CYC}0000.${ensfiletype:-bg}_${memstr}_fv_tracer.res.tile1.nc 

else
        ln -sf $EnsAnMeanDir/${PDY}.${CYC}0000.anl_ensmean_dynvar $EnsAnMeanDir/fv_core.res.tile1.nc
        cp  $EnsMeanDir/${PDY}.${CYC}0000.${ensfiletype:-bg}_ensmean_fv_tracer.res.tile1.nc tmp_tracer.nc 
        ncks -A -v  $user_nck_tracer_list fv3sar_tile1_mem001_dynvartracer  tmp_tracer.nc
#cltorg        ncrename -d yaxis_2,yaxis_1 -v yaxis_2,yaxis_1 tmp_tracer.nc 
        cp  fv3sar_tile1_mem001_dynvars   $EnsAnMeanDir/${PDY}.${CYC}0000.anl_ensmean_dynvars
        cp  fv3sar_tile1_mem001_tracer   $EnsAnMeanDir/${PDY}.${CYC}0000.anl_ensmean_tracer 
        ln -sf $EnsAnMeanDir/${PDY}.${CYC}0000.anl_ensmean_dynvars $EnsAnMeanDir/fv_core.res.tile1.nc
        ln -sf  $EnsAnMeanDir/${PDY}.${CYC}0000.anl_ensmean_tracer $EnsAnMeanDir/fv_tracer.res.tile1.nc
        cp $ANLdir/{*grid_spec.nc,*sfc_data.nc,*coupler.res,gfs_ctrl.nc,fv_core.res.nc,*bndy*} $EnsAnMeanDir
for imem in $(seq 2 $nens); do
         (
             memstr="mem"$(printf %03i $imem)
         let "memout = $imem - 1"
             memoutchar="mem"$(printf %03i $memout)
         export EnsRecDir=$NWGES_ens/enkf_rec${tmmark}/$memoutchar
         mkdir -p $EnsRecDir
         FileDynvar=${PDY}.${CYC}0000.fv_core.res.tile1.nc
         FileTracer=${PDY}.${CYC}0000.fv_tracer.res.tile1.nc
         FileUpdated=fv3sar_tile1_${memstr}_dynvartracer
         FileUpdatedOut=fv3sar_tile1_${memstr}_dynvars
         (
         
         
         cp  fv3sar_tile1_${memstr}_dynvars  $EnsRecDir/fv_core.res.tile1.nc
         cp  fv3sar_tile1_${memstr}_tracer  $EnsRecDir/fv_tracer.res.tile1.nc
         cp $ANLdir/{*grid_spec.nc,*sfc_data.nc,*coupler.res,gfs_ctrl.nc,fv_core.res.nc}  $EnsRecDir 
         )& 
         done
         wait
fi

exit
