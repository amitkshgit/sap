<?php
$SAPS = "5000";
$GB = "32";
$SAPS = htmlspecialchars($_GET["saps"]);
$GB = htmlspecialchars($_GET["gb"]);

$cmd = "perl newmap.pl $SAPS $GB 0";
$output = shell_exec($cmd);
echo "<pre>$output</pre>";
?>

