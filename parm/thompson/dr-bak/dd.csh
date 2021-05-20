#!/bin/csh -f
 foreach file (*input*)
   echo file is $file
    sed -i  -e "/fhcyc.*=/ s/=.*/= 0/"  $file 
 end 
