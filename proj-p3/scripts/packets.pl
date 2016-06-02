#!/usr/local/bin/perl
use strict;
#use warnings;

my $outFile = '../packets.fill';
my $outFileBin = '../packets_bin.fill';
open(my $OUTRES, ">$outFile" ) || die("Couldn't open $outFile");
open(my $OUTRESBIN, ">$outFileBin" ) || die("Couldn't open $outFileBin");

&main(@ARGV);

sub main
{	
	# packets sent from node 0
	print $OUTRES "\n\nNODE 0 packets: \n";
	print $OUTRESBIN "\n\nNODE 0 packets: \n";
	&formPacket(0, 0, 1, 0, 4);		# node 0 to node 1 - (EV, CW, 1)
	&formPacket(0, 0, 2, 0, 7);		# node 0 to node 2 - (EV, CW, 2)
	&formPacket(0, 1, 1, 0, 10);	# node 0 to node 3 - (EV, CCW, 1)
	
	# packets sent from node 1
	print $OUTRES "\n\nNODE 1 packets: \n";
	print $OUTRESBIN "\n\nNODE 1 packets: \n";
	&formPacket(0, 1, 1, 1, 1);		# node 1 to node 0 - (EV, CCW, 1)
	&formPacket(0, 0, 1, 1, 8);		# node 1 to node 2 - (EV, CW, 1)
	&formPacket(0, 0, 2, 1, 11);	# node 1 to node 3 - (EV, CW, 2)
	
	# packets sent from node 2
	print $OUTRES "\n\nNODE 2 packets: \n";
	print $OUTRESBIN "\n\nNODE 2 packets: \n";
	&formPacket(1, 0, 2, 2, 2);		# node 2 to node 0 - (OD, CW, 2)
	&formPacket(1, 1, 1, 2, 5);		# node 2 to node 1 - (OD, CCW, 1)
	&formPacket(1, 0, 1, 2, 12);	# node 2 to node 3 - (OD, CW, 1)
	
	# packets sent from node 3
	print $OUTRES "\n\nNODE 3 packets: \n";
	print $OUTRESBIN "\n\nNODE 3 packets: \n";
	&formPacket(1, 0, 1, 3, 3);		# node 3 to node 0 - (OD, CW, 1)
	&formPacket(1, 0, 2, 3, 6);		# node 3 to node 1 - (OD, CW, 2)
	&formPacket(1, 1, 1, 3, 9);		# node 3 to node 2 - (OD, CCW, 1)
	
	
}

###########################################################################################


sub formPacket {

	my ($vc) = shift;
	my ($dir) = shift;
	my ($hopcnt) = shift;
	my ($source) = shift;
	my ($payload) = shift;
	
	my ($res);
	my ($res_bin);
	my ($zero) = 0;
	
	$res = join('', $vc, $dir, &dec2bin($zero, 6), &dec2bin($hopcnt, 8), &dec2bin($source, 16), &dec2bin($payload, 32));
	$res_bin = join(' ', $vc, $dir, &dec2bin($zero, 6), &dec2bin($hopcnt, 8), &dec2bin($source, 16), &dec2bin($payload, 32));
	my ($hexRes) = &bin2hex($res);
	
	my ($foo) = sprintf("%016X", hex($hexRes));
	
	print $OUTRES "$foo \n";
	print $OUTRESBIN "$res_bin \n";
}


sub dec2bin {
    my ($dec) = shift;
	my ($width) = shift;
	
    my ($str) = '';
	while ($dec > 1)
	{
		$str = join ('', $str, ($dec % 2));
		$dec = int($dec / 2);
	}
	
	if ($dec > 0)
	{
		$str = join ( '', $str, '1');
	}
	
	my ($zeros) = '';
	if ($width >= length $str)
	{
		foreach (1 .. ($width - (length $str)))
		{
			$zeros = join('', '0', $zeros);
		}
	}
	else 
	{
		print "\nSpecify higher width.";
	}

	my ($fin) = join('', $zeros, scalar reverse $str);
    return $fin;
}

sub hex2bin {
    my ($hex) = shift;
    
    if ($hex eq "0") {
    	return "0000";
    }
    	
    elsif ($hex eq "1") {
    	return "0001";
    }
    	
    elsif ($hex eq "2") {
    	return "0010";
    }
    	    	
    elsif ($hex eq "3") {
    	return "0011";
    }    	
    	
    elsif ($hex eq "4") {
    	return "0100"; 
    }  	
    	
    elsif ($hex eq "5") {
    	return "0101"; 
    }  	
    
    elsif ($hex eq "6") {
    	return "0110"; 
    }  	
    	
    elsif ($hex eq "7") {
    	return "0111"; 
    }  	
    	
    elsif ($hex eq "8") {
    	return "1000";
    }
  
    elsif ($hex eq "9") {
    	return "1001"; 
    }  	
    	
    elsif ($hex eq "A" || $hex eq "a") {
    	return "1010";    	
    }
    	
    elsif ($hex eq "B" || $hex eq "b") {
    	return "1011";   	
    }
    	
    elsif ($hex eq "C" || $hex eq "c") {
    	return "1100";   	
    }
    	
    elsif ($hex eq "D" || $hex eq "d") {
    	return "1101";  	
    }
    	
    elsif ($hex eq "E" || $hex eq "e") {
    	return "1110";  	
    }
    	
    elsif ($hex eq "F" || $hex eq "f") {
    	return "1111";  	
    }
    
    else {
    	return "0000";
    } 	
}

sub bin2hex {
    my $num   = shift;
    my $WIDTH = 64;
    my $index = length($num) - $WIDTH;
    my $hex = '';
    do {
        my $width = $WIDTH;
        if ($index < 0) {
            $width += $index;
            $index = 0;
        }
        my $cut_string = substr($num, $index, $width);
        $hex = sprintf('%X', oct("0b$cut_string")) . $hex;
        $index -= $WIDTH;
    } while ($index > (-1 * $WIDTH));
    return $hex;
}