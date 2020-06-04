set -x

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
export nens=${nens:-8}  #tothink

# Not using FGAT or 4DEnVar, so hardwire nhr_assimilation to 3
export nhr_assimilation=03
##typeset -Z2 nhr_assimilation
export EnsMeanDir=$NWGES_ens/enkf_mean${tmmark}/ensmean
mkdir -p $EnsMeanDir
export EnsAnMeanDir=$NWGES_ens/enkf_AnMean${tmmark}/ensmean
mkdir -p $EnsAnMeanDir

if [ $ldo_enscalc_option -ne 2  ] ; then
memchar="mem001"  #cltthinkto
ensmeanchar="ensmean"  #cltthinkto
#clt to use mem001 stuff as the ensmean stuff
         export FcstOutDir=$NWGES_ens/${tmmark}/$memchar
         cp ${FcstOutDir}/${PDY}.${CYC}0000.${memstr}fv_tracer.res.tile1.nc fv3sar_tile1_${ensmeanchar}_tracer
         cp ${FcstOutDir}/${PDY}.${CYC}0000.${memstr}fv_core.res.tile1.nc fv3sar_tile1_${ensmeanchar}_dynvars 

         rm -f tmp.txt 
         echo Time >tmp.txt
         echo axis >>tmp.txt
#cltNote:  for newer nco pacakge , should add --trd option
#cltorg          ncks --trd -m fv3sar_tile1_${ensmeanchar}_dynvars | grep -E ': type' | cut -f 1 -d ' ' | sed 's/://' | sort |grep -v -f tmp.txt> nck_dynvar_list.txt
         ncks  -m fv3sar_tile1_${ensmeanchar}_dynvars | grep -E ': type' | cut -f 1 -d ' ' | sed 's/://' | sort |grep -v -f tmp.txt> nck_dynvar_list.txt
#clt          ncks --trd -m fv3sar_tile1_${ensmeanchar}_tracer | grep -E ': type' | cut -f 1 -d ' ' | sed 's/://' | sort |grep -v -f tmp.txt> nck_tracer_list.txt
         ncks  -m fv3sar_tile1_${ensmeanchar}_tracer | grep -E ': type' | cut -f 1 -d ' ' | sed 's/://' | sort |grep -v -f tmp.txt> nck_tracer_list.txt
         user_nck_dynvar_list=`cat nck_dynvar_list.txt|paste -sd "," - `
         user_nck_tracer_list=`cat nck_tracer_list.txt |paste -sd "," - ` 


         ncrename -d yaxis_1,yaxis_2 -v  yaxis_1,yaxis_2  fv3sar_tile1_${ensmeanchar}_tracer
         ncks -A -v ${user_nck_tracer_list} fv3sar_tile1_${ensmeanchar}_tracer fv3sar_tile1_${ensmeanchar}_dynvars #cltthinkto some twits should be done on dimension names and to be split later 
         cp fv3sar_tile1_${ensmeanchar}_dynvars fv3sar_tile1_${ensmeanchar}_dynvartracer
         cp ${FcstOutDir}/${PDY}.${memstr}*.fv_core.res.nc fv3sar_tile1_akbk.nc #clt fv3_akbk
#   This file contains horizontal grid information
         cp ${FcstOutDir}/grid_spec.nc fv3sar_tile1_grid_spec.nc
         cp ${FcstOutDir}/${PDY}.*0000.sfc_data.nc fv3_sfcdata
    
	for imem in $(seq 1 $nens); do
		     memchar="mem"$(printf %03i $imem)
                 export FcstOutDir=$NWGES_ens/${tmmark}/$memchar
		 cp ${FcstOutDir}/${PDY}.${CYC}0000.fv_core.res.tile1.nc fv3sar_tile1_${memchar}_dynvars 
		 cp ${FcstOutDir}/${PDY}.${CYC}0000.fv_tracer.res.tile1.nc fv3sar_tile1_${memchar}_tracer
                 ncrename -d yaxis_1,yaxis_2 -v yaxis_1,yaxis_2 fv3sar_tile1_${memchar}_tracer
                 ncks -A -v $user_nck_tracer_list fv3sar_tile1_${memchar}_tracer fv3sar_tile1_${memchar}_dynvars
                 mv fv3sar_tile1_${memchar}_dynvars fv3sar_tile1_${memchar}_dynvartracer
         done
else
#for recenter  
         cp  $ANLdir/${ctrlstr+_${ctrlstr}_}fv_core.res.nc fv3sar_tile1_akbk.nc 
         cp $ANLdir/${ctrlstr+_${ctrlstr}_}coupler.res  coupler.res
         cp ${ANLdir}/${ctrlstr+_${ctrlstr}_}fv3_grid_spec.nc fv3sar_tile1_grid_spec.nc
         cp $ANLdir/${ctrlstr+_${ctrlstr}_}fv_core.res.tile1.nc fv3_dynvars
         cp $ANLdir/${ctrlstr+_${ctrlstr}_}fv_tracer.res.tile1.nc fv3_tracer
         rm -f tmp.txt 
         echo Time >tmp.txt
         echo axis >>tmp.txt

         ncks  -m fv3_dynvars | grep -E ': type' | cut -f 1 -d ' ' | sed 's/://' | sort |grep -v -f tmp.txt> nck_dynvar_list.txt
         ncks  -m fv3_tracer | grep -E ': type' | cut -f 1 -d ' ' | sed 's/://' | sort |grep -v -f tmp.txt> nck_tracer_list.txt
         user_nck_dynvar_list=`cat nck_dynvar_list.txt|paste -sd "," - `
         user_nck_tracer_list=`cat nck_tracer_list.txt |paste -sd "," - ` 
         ncrename -d yaxis_1,yaxis_2 -v yaxis_1,yaxis_2 fv3_tracer
         ncks -A -v ${user_nck_tracer_list} fv3_tracer  fv3_dynvars 
         mv fv3_dynvars fv3sar_tile1_mem001_dynvartracer 
         cp  $EnsMeanDir/${PDY}.${CYC}0000.${ensfiletype:-bg}_ensmean_fv_dyntracer fv3sar_tile1_ensmean_dynvartracer 
         let "nens0 = $nens "
         let "nens = $nens + 1"
         
         for imem in $(seq 1 $nens0); do
             memchar="mem"$(printf %03i $imem)
         let "memin = $imem + 1"
             meminchar="mem"$(printf %03i $memin)
         export EnsAnlDir=$NWGES_ens/enkf_anl${tmmark}/$memchar
#         export EnsRecDir=$NWGES_ens/enkf_rec${tmmark}/$memchar
         cp $EnsAnlDir/${PDY}.${CYC}0000.anl_dynvartracer_${memchar}_fv_core.res.tile1.nc fv3sar_tile1_${meminchar}_dynvartracer
         done


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
newdiagfile=${str1}${str2}_mem$memid
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
newdiagfile=${str1}${str2}_ensmean
#   newdiagfile=${newdiagfile/_ges/.ges} 
#   echo newfile is $newfile
mv $diagfile $newdiagfile

done
fi






#cltthinkdeb nens=`cat filelist03 | wc -l`
if [ $ldo_enscalc_option -eq 1 -o $ldo_enscalc_option -eq 2 ]; then
tothink
anavinfo=$PARMfv3/anavinfo_fv3_enkf_ensmean_64
else
anavinfo=$PARMfv3/anavinfo_fv3_enkf_64
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
	nlons=1920,nlats=1296,nlevs=64,nanals=$nens,
	deterministic=.true.,sortinc=.true.,lupd_satbiasc=.false.,
	reducedgrid=.true.,readin_localization=.false.,
	use_gfs_nemsio=.true.,imp_physics=99,lupp=.false.,
	univaroz=.false.,adp_anglebc=.true.,angord=4,use_edges=.false.,emiss_bc=.true.,
	lobsdiag_forenkf=.false.,
	write_spread_diag=.false.,
	netcdf_diag=.false.,
	ldo_enscalc_option=${ldo_enscalc_option},
	$NAM_ENKF
	/
	&nam_fv3
	nx_res=1920,ny_res=1296,ntiles=1,
	/
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
EOFnml





	export fv3_case=$GUESSdir

#clt to make two  pesudo fv3sar ensembles



	echo 'thinkdeb path is ' $PATH
	echo before ulimit 
	ulimit -a
	ulimit -v unlimited
	echo after  ulimit 
	ulimit -a


#cltthinkdeb try /usrx/local/prod/intel/2018UP01/compilers_and_libraries/linux/mpi/bin64/mpirun -l -n 240 gsi.x < gsiparm.anl > $pgmout 2> stderr
	echo pwd is `pwd`
	cd $DATA
	ENKFEXEC=${ENKFEXEC:-$HOMEgsi/exec/global_enkf}
	export pgm=`basename $ENKFEXEC`
	. prep_step

	startmsg
	cp $ENKFEXEC $DATA/enkf.x
#cltorg mpirun -l -n  240  $DATA/enkf.x < enkf.nml 1>stdout 2>stderr
	if [ $ldo_enscalc_option -ne 0  ] ; then
	let i=1
	for infile in `ls ${anavinfo}_p*`
	do
	cp $infile anavinfo 
	cat anavinfo >>$pgmout
	${APRUNC}  $DATA/enkf.x < enkf.nml 1>>part_${i}_$pgmout 2>>part_${i}_stderr
	let i=i+1
	done
	else
	${APRUNC}  $DATA/enkf.x < enkf.nml 1>$pgmout 2>stderr
fi
rc=$?

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
             memchar="mem"$(printf %03i $imem)
             memstr=$memchar
#cltorg         cp fv3sar_tile1_${memstr}_dynvartracer fv3sar_tile1_${memstr}_tracer #cltthinkto split using nck and accordingly change something
             export EnsAnlDir=$NWGES_ens/enkf_anl${tmmark}/$memchar
             mkdir -p $EnsAnlDir
             cp fv3sar_tile1_${memstr}_dynvartracer $EnsAnlDir/${PDY}.${CYC}0000.anl_dynvartracer_${memstr}_fv_core.res.tile1.nc  
#clt         cp fv3sar_tile1_${memstr}_tracer  $EnsAnlDir/${PDY}.${CYC}0000.anl_${memstr}_fv_tracer.res.tile1.nc 
         done
elif  [ $ldo_enscalc_option -eq 1 ] ; then 
         memstr="ensmean"
         ncks -A -v $user_nck_dynvar_list fv3sar_tile1_mem001_dynvartracer fv3sar_tile1_${memstr}_dynvars
#clttothink 
         ncks -A -v $user_nck_tracer_list  fv3sar_tile1_mem001_dynvartracer fv3sar_tile1_${memstr}_tracer #cltthinkto split using nck and accordingly change something
         ncks -x -O  -v $user_nck_tracer_list  fv3sar_tile1_mem001_dynvartracer fv3sar_tile1_${memstr}_dynvar #cltthinkto split using nck and accordingly change something
         ncks -x -O -v $user_nck_dynvar_list  fv3sar_tile1_mem001_dynvartracer fv3sar_tile1_${memstr}_tracer #cltthinkto split using nck and accordingly change something
         ncrename -d yaxis_2,yaxis_1 -v yaxis_2,yaxis_1  fv3sar_tile1_${memstr}_tracer 
         ensfiletype=${enfiletype:-bg}
         cp fv3sar_tile1_${memstr}_dynvars  $EnsMeanDir/${PDY}.${CYC}0000.${ensfiletype}_${memstr}_fv_core.res.tile1.nc  
         cp fv3sar_tile1_${memstr}_tracer   $EnsMeanDir/${PDY}.${CYC}0000.${ensfiletype}_${memstr}_fv_tracer.res.tile1.nc 
         cp fv3sar_tile1_mem001_dynvartracer   $EnsMeanDir/${PDY}.${CYC}0000.${ensfiletype}_${memstr}_fv_dyntracer # used by recenter 

else
        cp $EnsMeanDir/${PDY}.${CYC}0000.${ensfiletype:-bg}_ensmean_fv_core.res.tile1.nc tmp_dynvar.nc
        ncks -x  -O -v $user_nck_tracer_list  fv3sar_tile1_mem001_dynvartracer tmp_dynvar.nc
        cp tmp_dynvar.nc  $EnsAnMeanDir/${PDY}.${CYC}0000.anl_ensmean_dynvar
        ln -sf $EnsAnMeanDir/${PDY}.${CYC}0000.anl_ensmean_dynvar $EnsAnMeanDir/fv_core.res.tile1.nc
        cp  $EnsMeanDir/${PDY}.${CYC}0000.${ensfiletype:-bg}_ensmean_fv_tracer.res.tile1.nc tmp_tracer.nc 
        ncks -A -v  $user_nck_tracer_list fv3sar_tile1_mem001_dynvartracer  tmp_tracer.nc
#cltorg        ncrename -d yaxis_2,yaxis_1 -v yaxis_2,yaxis_1 tmp_tracer.nc 
        cp tmp_tracer.nc  $EnsAnMeanDir/${PDY}.${CYC}0000.anl_ensmean_tracer 
        ln -sf  $EnsAnMeanDir/${PDY}.${CYC}0000.anl_ensmean_tracer $EnsAnMeanDir/fv_tracer.res.tile1.nc
        cp $ANLdir/{*grid_spec.nc,*sfc_data.nc,*coupler.res,gfs_ctrl.nc,fv_core.res.nc,*bndy*} $EnsAnMeanDir
for imem in $(seq 2 $nens); do
             memstr="mem"$(printf %03i $imem)
         let "memout = $imem - 1"
             memoutchar="mem"$(printf %03i $memout)
         export EnsRecDir=$NWGES_ens/enkf_rec${tmmark}/$memoutchar
         mkdir -p $EnsRecDir
         export bg_FcstOutDir=$NWGES_ens/${tmmark}/$memchar
         FileDynvar=${PDY}.${CYC}0000.fv_core.res.tile1.nc
         FileTracer=${PDY}.${CYC}0000.fv_tracer.res.tile1.nc
         FileUpdated=fv3sar_tile1_${memstr}_dynvartracer
         FileUpdatedOut=fv3sar_tile1_${memstr}_dynvars
#clt         cp $FcstOutDir/$FileDynvar ./${memoutchar}_fv_core.res.tile1.nc 
         cp $bg_FcstOutDir/$FileTracer ./${memoutchar}_fv_tracer.res.tile1.nc 
         cp $bg_FcstOutDir/$FileDynvar ./${memoutchar}_fv_dynvar.res.tile1.nc 
#clt         cp $ANLdir/{*grid_spec.nc,*sfc_data.nc,phy_data.nc,*coupler.res,gfs_ctrl.nc,fv_core.res.nc}  $EnsRecDir
         
         
#clt         ncks -x -O -v   $user_nck_tracer_list $FileUpdated $FileUpdatedOut
         ncks -A -v $user_nck_dynvar_list $FileUpdated  ${memoutchar}_fv_dynvar.res.tile1.nc
         cp  ${memoutchar}_fv_dynvar.res.tile1.nc  $EnsRecDir/fv_core.res.tile1.nc
         ncks -A -v  $user_nck_tracer_list $FileUpdated ${memoutchar}_fv_tracer.res.tile1.nc 
         ncks --abc -O -x -v yaxis_2  ${memoutchar}_fv_tracer.res.tile1.nc tmp_${memoutchar}_tracer.nc
         cp  tmp_${memoutchar}_tracer.nc  $EnsRecDir/fv_tracer.res.tile1.nc
         cp $ANLdir/{*grid_spec.nc,*sfc_data.nc,*coupler.res,gfs_ctrl.nc,fv_core.res.nc}  $EnsRecDir
         
#         cp fv3sar_tile1_${memstr}_dynvartracer fv3sar_tile1_${memstr}_dynvars  #tothinktracer
#         cp fv3sar_tile1_${memstr}_dynvartracer fv3sar_tile1_${memstr}_dynvars  #tothinktracer
#         cp fv3sar_tile1_${memstr}_dynvartracer fv3sar_tile1_${memstr}_tracer #cltthinkto split using nck and accordingly change something
#clttothink
#         cp fv3sar_tile1_${memstr}_dynvars ${EnsRecDir}/${PDY}.${CYC}0000.rec_${memoutstr}_fv_core.res.tile1.nc  
#         cp fv3sar_tile1_${memstr}_tracer  ${EnsRecDir}/${PDY}.${CYC}0000.rec_${memoutstr}_fv_tracer.res.tile1.nc 
         done
fi

exit
