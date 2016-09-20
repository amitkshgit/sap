#!/usr/bin/perl
# Comment
# This is in 'Dev' now
# Replies with only RAM Best Match
# Error Messages covered - 
#	No Match for high RAM
# Error Messages WIP
#	Blank Lines
# Feature WIP
#	Cost optimization 
use warnings;
open($fd,"<",sap_hash) or die "cannot open < hashes: $!";
#print("File opened\n");
if($#ARGV < 1){
#print("Usage: perl nearest.pl <SAPS> <RAMGB> {STRICT}\n");
#print("STRICT = 0 or 1\n");
exit;
}

$SAPS = $ARGV[0];
$RAM = $ARGV[1] * 0.93;
#if($ARGV[2] == 1){
#$strict = 1;
#}else{
#$strict = 0;
#}

#print("SAPS: $SAPS, RAM: $RAM (GiB)\n");

while(($line = <$fd>)){
chomp($line);
@info = split(',',$line);
#$CPUHASH{$info[0]} = $info[1];
$RAMHASH{$info[0]} = $info[2];
$SAPSHASH{$info[0]} = $info[3];
$ramdifftmp = ($RAM - $info[2])/$RAM;
$sapsdifftmp = ($SAPS - $info[3])/$SAPS;
if($ramdifftmp > -0.05 && $ramdifftmp < 0.05 && $sapsdifftmp > 0){
#print("Skew it\n");
$sapsdifftmp = $sapsdifftmp - 0.1;
}
if($ramdifftmp > -0.05 && $ramdifftmp < 0.05 && $sapsdifftmp < 0){
#print("Skew it\n");
$sapsdifftmp = $sapsdifftmp + 0.1;
}
if($sapsdifftmp > -0.05 && $sapsdifftmp < 0.05 && $ramdifftmp > 0){
#print("Skew it\n");
$ramdifftmp = $ramdifftmp - 0.1;
}
if($sapsdifftmp > -0.05 && $sapsdifftmp < 0.05 && $ramdifftmp < 0){
#print("Skew it\n");
$ramdifftmp = $ramdifftmp + 0.1;
}
$ramdiff = sprintf("%.3f",abs($ramdifftmp));
$sapsdiff = sprintf("%.3f",abs($sapsdifftmp));
#print("$info[0] -> SAPSDIFF: $sapsdiff\t");
#print("RAMDIFF: $ramdiff\n");
$score = $ramdiff + $sapsdiff;
#print("$info[0] score is $score\n");
$myhash{$info[0]} = abs($score);
}
my @servers = keys %myhash;
$prevserver = '';

#print("\nHardware Compliance\n");
$cnt = 0;
$strict = 1;
foreach my $server (sort { $myhash{$a} <=> $myhash{$b} } keys %myhash) {
    if($strict && ($RAMHASH{$server} < $RAM)){
#       print("Strict ON: Skipping $server\n");
    }else{
    #printf "%-8s(SAPS:%s,GiB:%s) %s\n", $server,$SAPSHASH{$server},$RAMHASH{$server},$myhash{$server};
    printf "%-8s(SAPS:%s,GiB:%s)", $server,$SAPSHASH{$server},$RAMHASH{$server};
    $cnt++;
	$prevserver = $server;
    }
    if($cnt == 1) { last; }
}
if($cnt == 0){
   print "No match";
}
#print("\nCost Optimized\n");
$cnt = 0;
$strict = 0;
foreach my $server (sort { $myhash{$a} <=> $myhash{$b} } keys %myhash) {
    if($strict && ($SAPSHASH{$server} < $SAPS || $RAMHASH{$server} < $RAM)){
#       print("Strict ON: Skipping $server\n");
    }else{
	if($server eq $prevserver){
	#print "\n";
	}else{
#    	#printf "%-8s(SAPS:%s,GiB:%s) %s\n", $server,$SAPSHASH{$server},$RAMHASH{$server},$myhash{$server};
	if(length($prevserver) == 0){
    		#printf "%-8s(SAPS:%s,GiB:%s)\n", $server,$SAPSHASH{$server},$RAMHASH{$server};
    		#printf "%-8s(SAPS:%s,GiB:%s)", $server,$SAPSHASH{$server},$RAMHASH{$server};
	}else{
    		#printf ",%-8s(SAPS:%s,GiB:%s)\n", $server,$SAPSHASH{$server},$RAMHASH{$server};
    		#printf ",%-8s(SAPS:%s,GiB:%s)", $server,$SAPSHASH{$server},$RAMHASH{$server};
	}
	}
    $cnt++;
    }
    if($cnt == 1) { last; }
}

