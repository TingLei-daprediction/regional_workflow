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
#############################################################################

set -x

export NLN=${NLN:-"/bin/ln -sf"}


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


gsiexec=${gsiexec:-$gsiexec0}
# Set runtime and save directories
export endianness=Big_Endian

# Set variables used in script
#   ncp is cp replacement, currently keep as /bin/cp
ncp=/bin/cp


if [[ ${L_LBC_UPDATE:-FALSE} = TRUE ]];then
   lbcupdt_str="_new"
else
   lbcupdt_str=""
   
fi
# setup ensemble filelist03

# Run gsi under Parallel Operating Environment (poe) on NCEP IBM


export HYB_ENS=".true."
export HX_ONLY=${HX_ONLY:-FALSE}

DOHYBVAR=${DOHYBVAR:-"YES"}
if [[ ${HX_ONLY} = "TRUE" ]]; then
DOHYBVAR=NO
export HYB_ENS=".false."

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
    python $UTIL/getbest_EnKF_FV3GDAS.py -v $vlddate --exact=no --minsize=${nens_gfs} -d ${COMINgfs}/enkfgdas -o filelist${nhr_assimilation} --o3fname=gfs_sigf${nhr_assimilation} --gfs_nemsio=yes
#cltthink      if [[ $l_both_fv3sar_gfs_ens = ".true."  ]]; then
#cltthink        sed '1d;$d' filelist${nhr_assimilation} > d.txt  #don't use the ensemble mean
#cltthink        cp d.txt filelist${nhr_assimilation}
#cltthink      fi
    ####python $UTIL/getbest_EnKF.py -v $vlddate --exact=no --minsize=${nens} -d ${COMINgfs}/enkf -o filelist${nhr_assimilation} --o3fname=gfs_sigf${nhr_assimilation} --gfs_nemsio=yes

    #Check to see if ensembles were found
    numfiles=`cat filelist03 | wc -l`
    cp filelist${nhr_assimilation} $COMOUT/${RUN}.t${CYCrun}z.filelist03.${tmmark}
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
        if [ $numfiles -ne $nens_gfs ]; then
          echo "Ensembles not found - turning off HYBENS!"
          export HYB_ENS=".false."
        else
          # we have 81 files, figure out if they are all the right size
          # if not, set HYB_ENS=false
          . $UTIL/check_enkf_size.sh
        fi
          nens_gfs=`cat filelist03 | wc -l`
          nens=$nens_gfs
        fi

        echo "HYB_ENS=$HYB_ENS" > $COMOUT/${RUN}.t${CYCrun}z.hybens.${tmmark}
     fi
     if [[ $regional_ensemble_option -eq 5 ]]; then
       for imem in $(seq 1 $nens_fv3sar ); do
             memchar="mem"$(printf %03i $imem)
#        cp ${COMIN_GES_ENS}/$memchar/${PDY}.${CYC}0000.${memstr}fv_core.res.tile1.nc fv3SAR01_${memchar}-fv3_dynvars
         cp ${COMIN_GES_ENS}/$memchar/${PDY}.${CYC}0000.${memstr}fv_core.res.tile1${lbcupdt_str}.nc fv3SAR${ens_nstarthr}_ens_${memchar}-fv3_dynvars
         cp ${COMIN_GES_ENS}/$memchar/${PDY}.${CYC}0000.${memstr}fv_tracer.res.tile1${lbcupdt_str}.nc fv3SAR${ens_nstarthr}_ens_${memchar}-fv3_tracer
         done

     fi

 
fi  # DO_HYB_ENS

# Set parameters
export USEGFSO3=.false.
export nhr_assimilation=3
export vs=1.
export fstat=.false.
export i_gsdcldanal_type=0
use_gfs_nemsio=.true.,

export SETUP_part1=${SETUP_part1:-"miter=2,niter(1)=50,niter(2)=50"}
if [ ${l_both_fv3sar_gfs_ens:-.false.} = ".true." ]; then  #regular  run
export HybParam_part2="l_both_fv3sar_gfs_ens=$l_both_fv3sar_gfs_ens,n_ens_gfs=$nens_gfs,n_ens_fv3sar=$nens_fv3sar,"
else
export HybParam_part2=" "

fi


# Make gsi namelist
echo "current dir is" 
pwd 
cat << EOF > gsiparm.anl

 &SETUP
   $SETUP_part1,niter_no_qc(1)=20,
   write_diag(1)=.true.,write_diag(2)=.false.,write_diag(3)=.true.,
   gencode=78,qoption=2,
   factqmin=0.0,factqmax=0.0,
   iguess=-1,use_gfs_ozone=${USEGFSO3},
   oneobtest=.false.,retrieval=.false.,
   nhr_assimilation=${nhr_assimilation},l_foto=.false.,
   use_pbl=.false.,gpstop=30.,
   use_gfs_nemsio=.true.,
   print_diag_pcg=.true.,
   newpc4pred=.true., adp_anglebc=.true., angord=4,
   passive_bc=.true., use_edges=.false., emiss_bc=.true.,
   diag_precon=.true., step_start=1.e-3,
   lread_obs_save=${lread_obs_save:-".true."}, 
   lread_obs_skip=${lread_obs_skip:-".false."}, 
   ens_nstarthr=$ens_nstarthr,
   $SETUP
 /
 &GRIDOPTS
   fv3_regional=.true.,grid_ratio_fv3_regional=3.0,nvege_type=20,
 /
 &BKGERR
   hzscl=0.373,0.746,1.50,
   vs=${vs},bw=0.,fstat=${fstat},
 /
 &ANBKGERR
   anisotropic=.false.,
 /
 &JCOPTS
 /
 &STRONGOPTS
   nstrong=0,
 /
 &OBSQC
   dfact=0.75,dfact1=3.0,noiqc=.false.,c_varqc=0.02,
   vadfile='prepbufr',njqc=.false.,vqc=.true.,
   aircraft_t_bc=.true.,biaspredt=1000.0,upd_aircraft=.true.,cleanup_tail=.true.,
 /
 &OBS_INPUT
   dmesh(1)=120.0,dmesh(2)=60.0,time_window_max=1.5,ext_sonde=.true.,
 /
OBS_INPUT::
!  dfile          dtype       dplat     dsis                 dval    dthin dsfcalc
   prepbufr       ps          null      ps                   1.0     0     0
   prepbufr       t           null      t                    1.0     0     0
   prepbufr       q           null      q                    1.0     0     0
   prepbufr       pw          null      pw                   1.0     0     0
   satwndbufr     uv          null      uv                   1.0     0     0
   prepbufr       uv          null      uv                   1.0     0     0
   prepbufr       spd         null      spd                  1.0     0     0
   prepbufr       dw          null      dw                   1.0     0     0
   l2rwbufr       rw          null      l2rw                 1.0     0     0
   prepbufr       sst         null      sst                  1.0     0     0
   gpsrobufr      gps_ref     null      gps                  1.0     0     0
   ssmirrbufr     pcp_ssmi    dmsp      pcp_ssmi             1.0    -1     0
   tmirrbufr      pcp_tmi     trmm      pcp_tmi              1.0    -1     0
   sbuvbufr       sbuv2       n16       sbuv8_n16            0.0     0     0
   sbuvbufr       sbuv2       n17       sbuv8_n17            0.0     0     0
   sbuvbufr       sbuv2       n18       sbuv8_n18            0.0     0     0
   hirs3bufr      hirs3       n16       hirs3_n16            0.0     1     0
   hirs3bufr      hirs3       n17       hirs3_n17            0.0     1     0
   hirs4bufr      hirs4       metop-a   hirs4_metop-a        0.0     2     0
   hirs4bufr      hirs4       n18       hirs4_n18            0.0     1     0
   hirs4bufr      hirs4       n19       hirs4_n19            0.0     2     0
   hirs4bufr      hirs4       metop-b   hirs4_metop-b        0.0     2     0
   gimgrbufr      goes_img    g11       imgr_g11             0.0     1     0
   gimgrbufr      goes_img    g12       imgr_g12             0.0     1     0
   airsbufr       airs        aqua      airs_aqua            0.0     2     0
   amsuabufr      amsua       n15       amsua_n15            0.0     2     0
   amsuabufr      amsua       n18       amsua_n18            0.0     2     0
   amsuabufr      amsua       n19       amsua_n19            0.0     2     0
   amsuabufr      amsua       metop-a   amsua_metop-a        0.0     2     0
   amsuabufr      amsua       metop-b   amsua_metop-b        0.0     2     0
   airsbufr       amsua       aqua      amsua_aqua           0.0     2     0
   amsubbufr      amsub       n17       amsub_n17            0.0     1     0
   mhsbufr        mhs         n18       mhs_n18              0.0     2     0
   mhsbufr        mhs         n19       mhs_n19              0.0     2     0
   mhsbufr        mhs         metop-a   mhs_metop-a          0.0     2     0
   mhsbufr        mhs         metop-b   mhs_metop-b          0.0     2     0
   ssmitbufr      ssmi        f13       ssmi_f13             0.0     2     0
   ssmitbufr      ssmi        f14       ssmi_f14             0.0     2     0
   ssmitbufr      ssmi        f15       ssmi_f15             0.0     2     0
   amsrebufr      amsre_low   aqua      amsre_aqua           0.0     2     0
   amsrebufr      amsre_mid   aqua      amsre_aqua           0.0     2     0
   amsrebufr      amsre_hig   aqua      amsre_aqua           0.0     2     0
   ssmisbufr      ssmis       f16       ssmis_f16            0.0     2     0
   ssmisbufr      ssmis       f17       ssmis_f17            0.0     2     0
   ssmisbufr      ssmis       f18       ssmis_f18            0.0     2     0
   ssmisbufr      ssmis       f19       ssmis_f19            0.0     2     0
   gsnd1bufr      sndrd1      g12       sndrD1_g12           0.0     1     0
   gsnd1bufr      sndrd2      g12       sndrD2_g12           0.0     1     0
   gsnd1bufr      sndrd3      g12       sndrD3_g12           0.0     1     0
   gsnd1bufr      sndrd4      g12       sndrD4_g12           0.0     1     0
   gsnd1bufr      sndrd1      g11       sndrD1_g11           0.0     1     0
   gsnd1bufr      sndrd2      g11       sndrD2_g11           0.0     1     0
   gsnd1bufr      sndrd3      g11       sndrD3_g11           0.0     1     0
   gsnd1bufr      sndrd4      g11       sndrD4_g11           0.0     1     0
   gsnd1bufr      sndrd1      g13       sndrD1_g13           0.0     1     0
   gsnd1bufr      sndrd2      g13       sndrD2_g13           0.0     1     0
   gsnd1bufr      sndrd3      g13       sndrD3_g13           0.0     1     0
   gsnd1bufr      sndrd4      g13       sndrD4_g13           0.0     1     0
   gsnd1bufr      sndrd1      g15       sndrD1_g15           0.0     2     0
   gsnd1bufr      sndrd2      g15       sndrD2_g15           0.0     2     0
   gsnd1bufr      sndrd3      g15       sndrD3_g15           0.0     2     0
   gsnd1bufr      sndrd4      g15       sndrD4_g15           0.0     2     0
   iasibufr       iasi        metop-a   iasi_metop-a         0.0     2     0
   gomebufr       gome        metop-a   gome_metop-a         0.0     2     0
   omibufr        omi         aura      omi_aura             0.0     2     0
   sbuvbufr       sbuv2       n19       sbuv8_n19            0.0     0     0
   tcvitl         tcp         null      tcp                  0.0     0     0
   seviribufr     seviri      m08       seviri_m08           0.0     2     0
   seviribufr     seviri      m09       seviri_m09           0.0     2     0
   seviribufr     seviri      m10       seviri_m10           0.0     2     0
   iasibufr       iasi        metop-b   iasi_metop-b         0.0     2     0
   gomebufr       gome        metop-b   gome_metop-b         0.0     2     0
   atmsbufr       atms        npp       atms_npp             0.0     2     0
   atmsbufr       atms        n20       atms_n20             0.0     2     0
   crisbufr       cris        npp       cris_npp             0.0     2     0
   crisfsbufr     cris-fsr    npp       cris-fsr_npp         0.0     2     0 
   crisfsbufr     cris-fsr    n20       cris-fsr_n20         0.0     2     0 
   abibufr        abi         g16       abi_g16              0.0     2     0
   abibufr        abi         g17       abi_g17              0.0     2     0
   mlsbufr        mls30       aura      mls30_aura           0.0     0     0
   oscatbufr      uv          null      uv                   0.0     0     0
   prepbufr       mta_cld     null      mta_cld              1.0     0     0
   prepbufr       gos_ctp     null      gos_ctp              1.0     0     0
   refInGSI       rad_ref     null      rad_ref              1.0     0     0
   lghtInGSI      lghtn       null      lghtn                1.0     0     0
   larcInGSI      larccld     null      larccld              1.0     0     0
::
 &SUPEROB_RADAR
   del_azimuth=5.,del_elev=.25,del_range=5000.,del_time=.5,elev_angle_max=5.,minnum=50,range_max=100000.,
   l2superob_only=.false.,
 /
 &LAG_DATA
 /
 &HYBRID_ENSEMBLE
   l_hyb_ens=$HYB_ENS,
   n_ens=$nens,
   uv_hyb_ens=.true.,
   beta_s0=0.25,
   s_ens_h=110,
   s_ens_v=3,
   generate_ens=.false.,
   regional_ensemble_option=${regional_ensemble_option},
   aniso_a_en=.false.,
   nlon_ens=0,
   nlat_ens=0,
   jcap_ens=574,
   l_ens_in_diff_time=.true.,
   jcap_ens_test=0,
   full_ensemble=.true.,pwgtflg=.true.,
   ensemble_path="",
   ${HybParam_part2}
 /
 &RAPIDREFRESH_CLDSURF
   i_gsdcldanal_type=${i_gsdcldanal_type},
   dfi_radar_latent_heat_time_period=20.0,
   l_use_hydroretrieval_all=.false.,
   metar_impact_radius=10.0,
   metar_impact_radius_lowCloud=4.0,
   l_gsd_terrain_match_surfTobs=.false.,
   l_sfcobserror_ramp_t=.false.,
   l_sfcobserror_ramp_q=.false.,
   l_PBL_pseudo_SurfobsT=.false.,
   l_PBL_pseudo_SurfobsQ=.false.,
   l_PBL_pseudo_SurfobsUV=.false.,
   pblH_ration=0.75,
   pps_press_incr=20.0,
   l_gsd_limit_ocean_q=.false.,
   l_pw_hgt_adjust=.false.,
   l_limit_pw_innov=.false.,
   max_innov_pct=0.1,
   l_cleanSnow_WarmTs=.false.,
   r_cleanSnow_WarmTs_threshold=5.0,
   l_conserve_thetaV=.false.,
   i_conserve_thetaV_iternum=3,
   l_cld_bld=.false.,
   cld_bld_hgt=1200.0,
   build_cloud_frac_p=0.50,
   clear_cloud_frac_p=0.1,
   iclean_hydro_withRef=1,
   iclean_hydro_withRef_allcol=0,
 /
 &CHEM
 /
 &SINGLEOB_TEST
 /
 &NST
 /

EOF
anavinfo=${anavinfo:-$PARMfv3/anavinfo_fv3_64}
berror=${berror:-$fixgsi/$endianness/nam_glb_berror.f77.gcv}
emiscoef_IRwater=$fixcrtm/Nalli.IRwater.EmisCoeff.bin
emiscoef_IRice=$fixcrtm/NPOESS.IRice.EmisCoeff.bin
emiscoef_IRland=$fixcrtm/NPOESS.IRland.EmisCoeff.bin
emiscoef_IRsnow=$fixcrtm/NPOESS.IRsnow.EmisCoeff.bin
emiscoef_VISice=$fixcrtm/NPOESS.VISice.EmisCoeff.bin
emiscoef_VISland=$fixcrtm/NPOESS.VISland.EmisCoeff.bin
emiscoef_VISsnow=$fixcrtm/NPOESS.VISsnow.EmisCoeff.bin
emiscoef_VISwater=$fixcrtm/NPOESS.VISwater.EmisCoeff.bin
emiscoef_MWwater=$fixcrtm/FASTEM6.MWwater.EmisCoeff.bin
aercoef=$fixcrtm/AerosolCoeff.bin
cldcoef=$fixcrtm/CloudCoeff.bin
#satinfo=$fixgsi/nam_regional_satinfo.txt
satinfo=$PARMfv3/fv3sar_satinfo.txt
scaninfo=$fixgsi/global_scaninfo.txt
satangl=$fixgsi/nam_global_satangbias.txt
atmsbeamdat=$fixgsi/atms_beamwidth.txt
pcpinfo=$fixgsi/nam_global_pcpinfo.txt
ozinfo=$fixgsi/nam_global_ozinfo.txt
errtable=$fixgsi/nam_errtable.r3dv
convinfo=$fixgsi/nam_regional_convinfo.txt
mesonetuselist=$fixgsi/nam_mesonet_uselist.txt
stnuselist=$fixgsi/nam_mesonet_stnuselist.txt

# Copy executable and fixed files to $DATA
$ncp $gsiexec ./regional_gsi.x

$ncp $anavinfo ./anavinfo
$ncp $berror   ./berror_stats
$ncp $emiscoef_IRwater ./Nalli.IRwater.EmisCoeff.bin
$ncp $emiscoef_IRice ./NPOESS.IRice.EmisCoeff.bin
$ncp $emiscoef_IRsnow ./NPOESS.IRsnow.EmisCoeff.bin
$ncp $emiscoef_IRland ./NPOESS.IRland.EmisCoeff.bin
$ncp $emiscoef_VISice ./NPOESS.VISice.EmisCoeff.bin
$ncp $emiscoef_VISland ./NPOESS.VISland.EmisCoeff.bin
$ncp $emiscoef_VISsnow ./NPOESS.VISsnow.EmisCoeff.bin
$ncp $emiscoef_VISwater ./NPOESS.VISwater.EmisCoeff.bin
$ncp $emiscoef_MWwater ./FASTEM6.MWwater.EmisCoeff.bin
$ncp $aercoef  ./AerosolCoeff.bin
$ncp $cldcoef  ./CloudCoeff.bin
$ncp $satangl  ./satbias_angle
$ncp $atmsbeamdat  ./atms_beamwidth.txt
$ncp $satinfo  ./satinfo
$ncp $scaninfo ./scaninfo
$ncp $pcpinfo  ./pcpinfo
$ncp $ozinfo   ./ozinfo
$ncp $convinfo ./convinfo
$ncp $errtable ./errtable
$ncp $mesonetuselist ./mesonetuselist
$ncp $stnuselist ./mesonet_stnuselist
$ncp $fixgsi/prepobs_prep.bufrtable ./prepobs_prep.bufrtable



# Copy CRTM coefficient files based on entries in satinfo file
for file in `awk '{if($1!~"!"){print $1}}' ./satinfo | sort | uniq` ;do
    $ncp $fixcrtm/${file}.SpcCoeff.bin ./
    $ncp $fixcrtm/${file}.TauCoeff.bin ./
done

# If requested, link (and if tarred, de-tar obsinput.tar) into obs_input.* files
if [ ${USE_SELECT:-NO} = "YES" ]; then
   rm obs_input.*
   nl=$(file $SELECT_OBS | cut -d: -f2 | grep tar | wc -l)
   if [ $nl -eq 1 ]; then
      rm obsinput.tar
      $NLN $SELECT_OBS obsinput.tar
      tar -xvf obsinput.tar
      rm obsinput.tar
   else
      for filetop in $(ls $SELECT_OBS/obs_input.*); do
         fileloc=$(basename $filetop)
         $NLN $filetop $fileloc
      done
   fi
fi





###export nmmb_nems_obs=${COMINnam}/nam.${PDYrun}
export nmmb_nems_obs=${COMINrap}/rap.${PDYa}

export nmmb_nems_bias=${COMINbias}

if [ ${USE_SELECT:-NO} != "YES" ]; then  #regular  run
   if [ ! -d $nmmb_nems_obs  ]; then
     export nmmb_nems_obs=${COMINrap_user}/rap.${PDYa}
     if [ ! -d $nmmb_nems_obs  ]; then
       echo "there are no obs needed, exit"
       exit 250
     fi
   fi
     

# Try para RAP first
export g1617_rad_obs=/gpfs/dell2/emc/obsproc/noscrub/Steve.Stegall/DUMPDIR/GOES_CSR_baseline.v2/com/prod/rap/rap.${PDYa}
export nmmb_nems_obs=${COMINpararap}/rap.${PDYa}
$ncp $nmmb_nems_obs/rap.t${cya}z.prepbufr.tm00  ./prepbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.prepbufr.acft_profiles.tm00 prepbufr_profl
$ncp $nmmb_nems_obs/rap.t${cya}z.satwnd.tm00.bufr_d ./satwndbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.1bhrs3.tm00.bufr_d ./hirs3bufr
$ncp $nmmb_nems_obs/rap.t${cya}z.1bhrs4.tm00.bufr_d ./hirs4bufr
$ncp $nmmb_nems_obs/rap.t${cya}z.mtiasi.tm00.bufr_d ./iasibufr
$ncp $nmmb_nems_obs/rap.t${cya}z.1bamua.tm00.bufr_d ./amsuabufr
$ncp $nmmb_nems_obs/rap.t${cya}z.esamua.tm00.bufr_d ./amsuabufrears
$ncp $nmmb_nems_obs/rap.t${cya}z.1bamub.tm00.bufr_d ./amsubbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.1bmhs.tm00.bufr_d  ./mhsbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.goesnd.tm00.bufr_d ./gsnd1bufr
$ncp $nmmb_nems_obs/rap.t${cya}z.airsev.tm00.bufr_d ./airsbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.cris.tm00.bufr_d ./crisbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.atms.tm00.bufr_d ./atmsbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.sevcsr.tm00.bufr_d ./seviribufr
$ncp $nmmb_nems_obs/rap.t${cya}z.radwnd.tm00.bufr_d ./radarbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.nexrad.tm00.bufr_d ./l2rwbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.crisf4.tm00.bufr_d ./crisfsbufr
$ncp $g1617_rad_obs/rap.t${cya}z.gsrcsr.tm00.bufr_d ./abibufr
#$ncp $nmmb_nems_obs/rap.t${cya}z.gsrcsr.tm00.bufr_d ./abibufr
#new directbroadcast
#$ncp $nmmb_nems_obs/rap.t${cya}z.escrsf.tm00.bufr_d ./crisfsbufrears
#$ncp $nmmb_nems_obs/rap.t${cya}z.crsfdb.tm00.bufr_d ./crisfsbufr_db
#$ncp $nmmb_nems_obs/rap.t${cya}z.atmsdb.tm00.bufr_d ./atmsbufr_db
#$ncp $nmmb_nems_obs/rap.t${cya}z.iasidb.tm00.bufr_d ./iasibufr_db

ls -1 prepbufr
err0=$?

#No paraRAP obs, get ops RAP data
if [ $err0 -ne 0 ] ; then
export nmmb_nems_obs=${COMINrap}/rap.${PDYa}
$ncp $nmmb_nems_obs/rap.t${cya}z.prepbufr.tm00  ./prepbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.prepbufr.acft_profiles.tm00 prepbufr_profl
$ncp $nmmb_nems_obs/rap.t${cya}z.satwnd.tm00.bufr_d ./satwndbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.1bhrs3.tm00.bufr_d ./hirs3bufr
$ncp $nmmb_nems_obs/rap.t${cya}z.1bhrs4.tm00.bufr_d ./hirs4bufr
$ncp $nmmb_nems_obs/rap.t${cya}z.mtiasi.tm00.bufr_d ./iasibufr
$ncp $nmmb_nems_obs/rap.t${cya}z.1bamua.tm00.bufr_d ./amsuabufr
$ncp $nmmb_nems_obs/rap.t${cya}z.esamua.tm00.bufr_d ./amsuabufrears
$ncp $nmmb_nems_obs/rap.t${cya}z.1bamub.tm00.bufr_d ./amsubbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.1bmhs.tm00.bufr_d  ./mhsbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.goesnd.tm00.bufr_d ./gsnd1bufr
$ncp $nmmb_nems_obs/rap.t${cya}z.airsev.tm00.bufr_d ./airsbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.cris.tm00.bufr_d ./crisbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.atms.tm00.bufr_d ./atmsbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.sevcsr.tm00.bufr_d ./seviribufr
$ncp $nmmb_nems_obs/rap.t${cya}z.radwnd.tm00.bufr_d ./radarbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.nexrad.tm00.bufr_d ./l2rwbufr
fi

ls -1 prepbufr
err1=$?

#No RAP obs, get NAM data
if [ $err1 -ne 0 ] ; then
export nmmb_nems_obs=${COMINnam}/nam.${PDYrun}
$ncp $nmmb_nems_obs/nam.t${cya}z.prepbufr.${tmmark}  ./prepbufr
$ncp $nmmb_nems_obs/nam.t${cya}z.prepbufr.acft_profiles.${tmmark} prepbufr_profl
$ncp $nmmb_nems_obs/nam.t${cya}z.satwnd.${tmmark}.bufr_d ./satwndbufr
$ncp $nmmb_nems_obs/nam.t${cya}z.1bhrs3.${tmmark}.bufr_d ./hirs3bufr
$ncp $nmmb_nems_obs/nam.t${cya}z.1bhrs4.${tmmark}.bufr_d ./hirs4bufr
$ncp $nmmb_nems_obs/nam.t${cya}z.mtiasi.${tmmark}.bufr_d ./iasibufr
$ncp $nmmb_nems_obs/nam.t${cya}z.1bamua.${tmmark}.bufr_d ./amsuabufr
$ncp $nmmb_nems_obs/nam.t${cya}z.esamua.${tmmark}.bufr_d ./amsuabufrears
$ncp $nmmb_nems_obs/nam.t${cya}z.1bamub.${tmmark}.bufr_d ./amsubbufr
$ncp $nmmb_nems_obs/nam.t${cya}z.1bmhs.${tmmark}.bufr_d  ./mhsbufr
$ncp $nmmb_nems_obs/nam.t${cya}z.goesnd.${tmmark}.bufr_d ./gsnd1bufr
$ncp $nmmb_nems_obs/nam.t${cya}z.airsev.${tmmark}.bufr_d ./airsbufr
$ncp $nmmb_nems_obs/nam.t${cya}z.cris.${tmmark}.bufr_d ./crisbufr
$ncp $nmmb_nems_obs/nam.t${cya}z.atms.${tmmark}.bufr_d ./atmsbufr
$ncp $nmmb_nems_obs/nam.t${cya}z.sevcsr.${tmmark}.bufr_d ./seviribufr
$ncp $nmmb_nems_obs/nam.t${cya}z.radwnd.${tmmark}.bufr_d ./radarbufr
$ncp $nmmb_nems_obs/nam.t${cya}z.nexrad.${tmmark}.bufr_d ./l2rwbufr
fi


fi #USE_SELECT
export GDAS_SATBIAS=NO

if [ $GDAS_SATBIAS = NO ] ; then

$ncp $nmmb_nems_bias/fv3sar.t${CYCrun}z.satbias.${tmmark_prev} ./satbias_in
err1=$?
if [ $err1 -ne 0 ] ; then
  cp $GESROOT_HOLD/satbias_in ./satbias_in
fi
$ncp $nmmb_nems_bias/fv3sar.t${CYCrun}z.satbias_pc.${tmmark_prev} ./satbias_pc
err2=$?
if [ $err2 -ne 0 ] ; then
  cp $GESROOT_HOLD/satbias_pc ./satbias_pc
fi
$ncp $nmmb_nems_bias/fv3sar.t${CYCrun}z.radstat.${tmmark_prev}    ./radstat.gdas
err3=$?
if [ $err3 -ne 0 ] ; then
  cp $GESROOT_HOLD/radstat.nam ./radstat.gdas
fi

else

cp $GESROOT_HOLD/gdas.satbias_out ./satbias_in
cp $GESROOT_HOLD/gdas.satbias_pc ./satbias_pc
cp $GESROOT_HOLD/gdas.radstat_out ./radstat.gdas

fi

#for new type satellite to build the bias coreection file
USE_RADSTAT=${USE_RADSTAT:-"YES"}
USE_CFP=${USE_CFP:-"NO"}
##############################################################
# If requested, copy and de-tar guess radstat file
if [ $USE_RADSTAT = "YES" ]; then
   if [ $USE_CFP = "YES" ]; then
     rm $DATA/unzip.sh $DATA/mp_unzip.sh
     cat > $DATA/unzip.sh << EOFunzip
#!/bin/sh
   diag_file=\$1
   fname=\$(echo \$diag_file | cut -d'.' -f1)
   fdate=\$(echo \$diag_file | cut -d'.' -f2)
   #$UNCOMPRESS \$diag_file
   gunzip \$diag_file
   fnameges=\$(echo \$fname | sed 's/_ges//g')
   $NMV \$fname.\$fdate \$fnameges
EOFunzip
     chmod 755 $DATA/unzip.sh
   fi

listdiag=$(tar xvf radstat.gdas | cut -d' ' -f2 | grep _ges)
   for type in $listdiag; do
      diag_file=$(echo $type | cut -d',' -f1)
      if [ $USE_CFP = "YES" ] ; then
         echo "$DATA/unzip.sh $diag_file" | tee -a $DATA/mp_unzip.sh
      else
         fname=$(echo $diag_file | cut -d'.' -f1)
         date=$(echo $diag_file | cut -d'.' -f2)
         #$UNCOMPRESS $diag_file
         gunzip $diag_file
         fnameges=$(echo $fname|sed 's/_ges//g')
         #$NMV $fname.$date $fnameges
         mv $fname.$date $fnameges
      fi
   done
   if [ $USE_CFP = "YES" ] ; then
      chmod 755 $DATA/mp_unzip.sh
      ncmd=$(cat $DATA/mp_unzip.sh | wc -l)
      if [ $ncmd -gt 0 ]; then
         ncmd_max=$((ncmd < npe_node_max ? ncmd : npe_node_max))
         APRUNCFP_UNZIP=$(eval echo $APRUNCFP)
         $APRUNCFP_UNZIP $DATA/mp_unzip.sh
      fi
   fi
fi # if [ $USE_RADSTAT = "YES" ]
#Aircraft bias corrections always cycled through 6-h DA
 if [ $tmmark = "tm06" ]; then  #regular  run
   $ncp $MYGDAS/gdas.t${cya}z.abias_air ./aircftbias_in
    err4=$?
    if [ $err4 -ne 0 ] ; then
       $ncp $GBGDAS/gdas.t${cya}z.abias_air ./aircftbias_in
     fi
    err3=$?

  else
    $ncp $nmmb_nems_bias/${RUN}.t${CYCrun}z.abias_air.${tmmark_prev} ./aircftbias_in
   err3=$?
  fi
if [ $err3 -ne 0 ] ; then
  cp $GESROOT_HOLD/gdas.airbias ./aircftbias_in
fi

cp $COMINrtma/rtma2p5.${PDYa}/rtma2p5.t${cya}z.w_rejectlist ./w_rejectlist
cp $COMINrtma/rtma2p5.${PDYa}/rtma2p5.t${cya}z.t_rejectlist ./t_rejectlist
cp $COMINrtma/rtma2p5.${PDYa}/rtma2p5.t${cya}z.p_rejectlist ./p_rejectlist
cp $COMINrtma/rtma2p5.${PDYa}/rtma2p5.t${cya}z.q_rejectlist ./q_rejectlist
#clt export ctrlstr=${ctrlstr:-control}

export fv3_case=$GUESSdir

#  INPUT FILES FV3 NEST (single tile)

#   This file contains time information
cp $fv3_case/${PDY}.${CYC}0000.coupler.res coupler.res
#   This file contains vertical weights for defining hybrid volume hydrostatic pressure interfaces 
cp $fv3_case/${PDY}.${CYC}0000.fv_core.res.nc fv3_akbk
#   This file contains horizontal grid information
cp $fv3_case/grid_spec${lbcupdt_str}.nc fv3_grid_spec
cp $fv3_case/${PDY}.${CYC}0000.sfc_data${lbcupdt_str}.nc fv3_sfcdata
#   This file contains 3d fields u,v,w,dz,T,delp, and 2d sfc geopotential phis
ctrlstrname=${ctrlstr:+_${ctrlstr}_}
   BgFile4dynvar=${BgFile4dynvar:-$fv3_case/${PDY}.${CYC}0000.${ctrlstrname}fv_core.res.tile1${lbcupdt_str}.nc}
   BgFile4tracer=${BgFile4tracer:-$fv3_case/${PDY}.${CYC}0000.${ctrlstrname}fv_tracer.res.tile1${lbcupdt_str}.nc}
   BgFile4dynvarOld=${BgFile4dynvar:-$fv3_case/${PDY}.${CYC}0000.${ctrlstrname}fv_core.res.tile1.nc}
   BgFile4tracerOld=${BgFile4tracer:-$fv3_case/${PDY}.${CYC}0000.${ctrlstrname}fv_tracer.res.tile1.nc}
cp $BgFile4dynvar fv3_dynvars
#   This file contains 3d tracer fields sphum, liq_wat, o3mr
cp $BgFile4tracer fv3_tracer
#   This file contains surface fields (vert dims of 3, 4, and 63)

export pgm=`basename $gsiexec`
. prep_step

startmsg
###mpirun -l -n 240 $gsiexec < gsiparm.anl > $pgmout 2> stderr
#mpirun -l -n 240 gsi.x < gsiparm.anl > $pgmout 2> stderr
${APRUNC} ./regional_gsi.x < gsiparm.anl > $pgmout 2> stderr
export err=$?;err_chk
if [ $err -ne 0 ]; then
 exit 999
fi


# If requested, create obsinput tarball from obs_input.* files
if [ ${RUN_SELECT:-NO} = "YES" ]; then
  echo $(date) START tar obs_input >&2
  rm obsinput.tar
  $NLN $SELECT_OBS obsinput.tar
  tar -cvf obsinput.tar obs_input.*
  chmod 750 $SELECT_OBS
#cltthink   ${CHGRP_CMD} $SELECT_OBS
  rm obsinput.tar
  echo $(date) END tar obs_input >&2
fi



mv fort.201 fit_p1
mv fort.202 fit_w1
mv fort.203 fit_t1
mv fort.204 fit_q1
mv fort.205 fit_pw1
mv fort.207 fit_rad1
mv fort.209 fit_rw1
if [[ $HX_ONLY != TRUE ]];then
cat fit_p1 fit_w1 fit_t1 fit_q1 fit_pw1 fit_rad1 fit_rw1 > $COMOUT/${RUN}.t${CYCrun}z.${ctrlstr}fits.${tmmark}
cat fort.208 fort.210 fort.211 fort.212 fort.213 fort.220 > $COMOUT/${RUN}.t${CYCrun}z.${ctrlstr}fits2.${tmmark}

#clt cp satbias_out $GESROOT_HOLD/satbias_in
 cp satbias_out $COMOUT/${RUN}.t${CYCrun}z.satbias.${tmmark}
#cltthink cp satbias_pc.out $GESROOT_HOLD/satbias_pc
 cp satbias_pc.out $COMOUT/${RUN}.t${CYCrun}z.satbias_pc.${tmmark}

 cp aircftbias_out $COMOUT/${RUN}.t${CYCrun}z.abias_air.${tmmark}
#cp aircftbias_out $GESROOT_HOLD/gdas.airbias
fi 

RADSTAT=${COMOUT}/${RUN}.t${CYCrun}z.${ctrlstr+${ctrlstr}_}radstat.${tmmark}
CNVSTAT=${COMOUT}/${RUN}.t${CYCrun}z.${ctrlstr+${ctrlstr}_}cnvstat.${tmmark}

# Set up lists and variables for various types of diagnostic files.
ntype=1

diagtype[0]="conv"
diagtype[1]="hirs2_n14 msu_n14 sndr_g08 sndr_g11 sndr_g12 sndr_g13 sndr_g08_prep sndr_g11_prep sndr_g12_prep sndr_g13_prep sndrd1_g11 sndrd2_g11 sndrd3_g11 sndrd4_g11 sndrd1_g12 sndrd2_g12 sndrd3_g12 sndrd4_g12 sndrd1_g13 sndrd2_g13 sndrd3_g13 sndrd4_g13 sndrd1_g14 sndrd2_g14 sndrd3_g14 sndrd4_g14 sndrd1_g15 sndrd2_g15 sndrd3_g15 sndrd4_g15 hirs3_n15 hirs3_n16 hirs3_n17 amsua_n15 amsua_n16 amsua_n17 amsub_n15 amsub_n16 amsub_n17 hsb_aqua airs_aqua amsua_aqua imgr_g08 imgr_g11 imgr_g12 imgr_g14 imgr_g15 ssmi_f13 ssmi_f14 ssmi_f15 hirs4_n18 hirs4_metop-a amsua_n18 amsua_metop-a mhs_n18 mhs_metop-a amsre_low_aqua amsre_mid_aqua amsre_hig_aqua ssmis_las_f16 ssmis_uas_f16 ssmis_img_f16 ssmis_env_f16 ssmis_las_f17 ssmis_uas_f17 ssmis_img_f17 ssmis_env_f17 ssmis_las_f18 ssmis_uas_f18 ssmis_img_f18 ssmis_env_f18 ssmis_las_f19 ssmis_uas_f19 ssmis_img_f19 ssmis_env_f19 ssmis_las_f20 ssmis_uas_f20 ssmis_img_f20 ssmis_env_f20 iasi_metop-a hirs4_n19 amsua_n19 mhs_n19 seviri_m08 seviri_m09 seviri_m10 cris_npp atms_npp hirs4_metop-b amsua_metop-b mhs_metop-b iasi_metop-b gome_metop-b"

diaglist[0]=listcnv
diaglist[1]=listrad

diagfile[0]=$CNVSTAT
diagfile[1]=$RADSTAT

numfile[0]=0
numfile[1]=0

# Set diagnostic file prefix based on lrun_subdirs variable
   prefix="pe*"

# Compress and tar diagnostic files.
if [[ $HX_ONLY != TRUE ]];then
loops="01 03"
else
loops="01 "
fi
for loop in $loops; do
   case $loop in
     01) string=ges;;
     03) string=anl;;
      *) string=$loop;;
   esac
   n=-1
   while [ $((n+=1)) -le $ntype ] ;do
      for type in `echo ${diagtype[n]}`; do
         count=`ls ${prefix}${type}_${loop}* | wc -l`
         if [ $count -gt 0 ]; then
            cat ${prefix}${type}_${loop}* > diag_${type}${ctrlstr+_${ctrlstr}_}${string}.${SDATE}
            echo "diag_${type}${ctrlstr+_${ctrlstr}_}${string}.${SDATE}*" >> ${diaglist[n]}
            numfile[n]=`expr ${numfile[n]} + 1`
         fi
      done
   done
done


#  compress diagnostic files
   for file in `ls diag_*${SDATE}`; do
      gzip $file
   done

# If requested, create diagnostic file tarballs
   n=-1
   while [ $((n+=1)) -le $ntype ] ;do
      TAROPTS="-uvf"
      if [ ! -s ${diagfile[n]} ]; then
         TAROPTS="-cvf"
      fi
      if [ ${numfile[n]} -gt 0 ]; then
         tar $TAROPTS ${diagfile[n]} `cat ${diaglist[n]}`
      fi
   done

#  Restrict CNVSTAT
   chmod 750 $CNVSTAT
   chgrp rstprod $CNVSTAT

if [[ $HX_ONLY != TRUE ]];then
if [ $tmmark != tm00 ] ; then 
echo 'do nothing for being now'
#  cp $RADSTAT ${GESROOT_HOLD}/radstat.nam
fi

cp fv3_dynvars $ANLdir/${ctrlstr+_${ctrlstr}_}fv_core.res.tile1${lbcupdt_str}.nc
cp fv3_tracer $ANLdir/${ctrlstr+_${ctrlstr}_}fv_tracer.res.tile1${lbcupdt_str}.nc


if [[ ${L_LBC_UPDATE:-FALSE} = TRUE ]];then
mv fv3_dynvars fv_core.res.tile1${lbcupdt_str}.nc
mv fv3_tracer fv_tracer.res.tile1${lbcupdt_str}.nc
# Get orig restart files and 00-h bndy file for move_DA_update code
#clt cp $GUESSdir/fv_core.res.tile1.nc fv_core.res.tile1.nc
cp $BgFile4dynvarOld fv_core.res.tile1.nc
#clt cp $GUESSdir/fv_tracer.res.tile1.nc fv_tracer.res.tile1.nc
cp $BgFile4tracerOld fv_tracer.res.tile1.nc
cp $ANLdir/gfs_bndy.tile7.000.nc .

# run move_DA_update code

cp $HOMEfv3/regional_da_imbalance/move_DA_update_data.x .

export pgm=move_DA_update_data.x
. prep_step

startmsg
./move_DA_update_data.x 000
export err=$?;err_chk

#Put new 000-h BC file and modified original restart files into ANLdir
cp gfs_bndy.tile7.000_gsi.nc $ANLdir/
mv fv_core.res.tile1.nc $ANLdir/${ctrlstr+_${ctrlstr}_}fv_core.res.tile1.nc
mv fv_tracer.res.tile1.nc $ANLdir/${ctrlstr+_${ctrlstr}_}fv_tracer.res.tile1.nc

fi



# Put analysis files in ANLdir (defined in J-job)
mv fv3_akbk $ANLdir/${ctrlstr+_${ctrlstr}_}fv_core.res.nc
mv coupler.res $ANLdir/${ctrlstr+_${ctrlstr}_}coupler.res
mv fv3_sfcdata $ANLdir/${ctrlstr+_${ctrlstr}_}sfc_data${lbcupdt_str}.nc
mv fv3_grid_spec $ANLdir/${ctrlstr+_${ctrlstr}_}fv3_grid_spec${lbcupdt_str}.nc
if [[ ${L_LBC_UPDATE:-FALSE} = TRUE ]];then
cp $fv3_case/${PDY}.${CYC}0000.sfc_data.nc $ANLdir/${ctrlstr+_${ctrlstr}_}sfc_data.nc 
cp $fv3_case/grid_spec.nc   $ANLdir/${ctrlstr+_${ctrlstr}_}fv3_grid_spec.nc
fi



cp $COMOUT/gfsanl.tm12/gfs_ctrl.nc $ANLdir/.  #tothink
fi #if != tm00

exit
