<?php
$vf=file_get_contents("version_t.asm");
$dt=date("y.m.d.H.i");
$vf=str_replace("<VERSION>",$dt,$vf);
echo "---- Updating version.asm to $dt\n";
file_put_contents("version.asm",$vf);
