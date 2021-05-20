#!/bin/csh -f
set targetdir="/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-regional-workflow/regional_workflow/parm"
foreach file (`ls *`)

echo file is $file
diff $file $targetdir/$file
end
