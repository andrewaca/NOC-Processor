#!/usr/local/bin/perl
use strict;
#use warnings;

#--------------------------------------------------------------
# Perl script to convert gold processor instructions to binary
# - Program file name is argument to main.
# - Comments should be followed by a semi-colon (;)
#--------------------------------------------------------------

my $outFile = '../imem.fill';
my $outFileBin = '../imem_bin.fill';
open(my $OUTRES, ">$outFile" ) || die("Couldn't open $outFile");
open(my $OUTRESBIN, ">$outFileBin" ) || die("Couldn't open $outFileBin");

&main(@ARGV);

sub main
{	
	# reading program
	my ($inpCmdFile);
	if ($#ARGV >= 0) {
        ($inpCmdFile) = $ARGV[0];
    } else {
		($inpCmdFile) = '../include/program.txt';
	}
	open(my $IN, "$inpCmdFile" ) || die("Couldn't open $inpCmdFile");
	my @origCmds = <$IN>;
	close($IN);
	
	my @cmdsArray;
	my $noOfCmds = 0;
	for (my $loop = 0; $loop < @origCmds; $loop++)
	{
		my $line = $origCmds[$loop];
		chomp($line);
		
		my ($codeLine);
		if ($line ne "" && $line =~ /;/)
		{
			my (@statement) = split(';', $line);
			if (@statement > 0 && ($statement[0] ne ""))
			{
				$codeLine = $statement[0];
			}
			else
			{
				$line =~ s/;//g;
				$codeLine = $line;
			}
		}
		elsif ($line ne "")
		{
			$codeLine = $line;
		}
		else 
		{
			$codeLine = '';
		}
		
		if ($codeLine ne "")
		{
			my ($space) = ' ';
			$codeLine =~ s/,/$space/g;
			#print "\n$codeLine";
			
			my (@lineData) = split(' ', $codeLine);
			if (@lineData > 0 && ($lineData[0] ne ""))
			{
				#print "\n@lineData";
				$cmdsArray[$noOfCmds++] = [@lineData];
			}		
		}	
	}
	
	my ($x);
	for $x (0 .. $noOfCmds) 
	{ 
		&readCmd($cmdsArray[$x], $x);
	}
	
	print $OUTRESBIN "0000 0000 0000 0000 0000 0000 0000 0000\n";
	print $OUTRES "00000000\n";
	
	close($OUTRES);
	close($OUTRESBIN);
}

###########################################################################################

sub readCmd
{
	my (@subArray, $x) = @_;
	my ($arrayLength) = scalar @subArray;
	my ($op) = $subArray[$x][0];
	my (@operands);
	
	if (length $subArray[$x] > 1)
	{
		foreach my $q (1 .. length $subArray[$x]) 
		{ 
			if ($subArray[$x][$q] ne "")
			{	
				#print "\n$subArray[$x][$q]";
				push @operands, $subArray[$x][$q];}
		}
	}
	
	my ($numOps) = scalar @operands;

	#my ($x);
	#for $x (0 .. $numOps) 
	#{ 
	#	print $operands[$x];
	#}

	if ($arrayLength > 0 && ($op ne ""))
	{
		if ( $op =~ /VAND/)
		{
			&regType($op, '000001', 0, @operands);
		}
		
		elsif ($op =~ /VOR/)
		{
			&regType($op, '000010', 0, @operands);
		}
		
		elsif ($op =~ /VXOR/)
		{
			&regType($op, '000011', 0, @operands);		
		}
		
		elsif ($op =~ /VNOT/)
		{
			&regType($op, '000100', 0, @operands);
		}
		
		elsif ($op =~ /VMOV/)
		{
			&regType($op, '000101', 0, @operands);
		}
		
		elsif ($op =~ /VADD/)
		{
			&regType($op, '000110', 0, @operands);
		}
		
		elsif ($op =~ /VSUB/)
		{
			&regType($op, '000111', 0, @operands);
		}
		
		elsif ($op =~ /VMULEU/)
		{
			&regType($op, '001000', 0, @operands);
		}
		
		elsif ($op =~ /VMULOU/)
		{
			&regType($op, '001001', 0, @operands);
		}
		
		elsif ($op =~ /VSQEU/)
		{
			&regType($op, '001010', 0, @operands);
		}
		
		elsif ($op =~ /VSQOU/)
		{
			&regType($op, '001011', 0, @operands);
		}
		
		elsif ($op =~ /VRTTH/)
		{
			&regType($op, '001100', 0, @operands);
		}
		
		elsif ($op =~ /VSLL/)
		{
			if ($op =~ /VSLLI/)
			{
				&regType($op, '001110', 1, @operands);
			}
			else
			{
				&regType($op, '001101', 0, @operands);
			}
		}
		
		elsif ($op =~ /VSRL/)
		{
			if ($op =~ /VSRLI/)
			{
				&regType($op, '010000', 1, @operands);
			}
			else
			{
				&regType($op, '001111', 0, @operands);
			}
		}
		
		elsif ($op =~ /VSRA/)
		{
			if ($op =~ /VSRAI/)
			{
				&regType($op, '010010', 1, @operands);
			}
			else
			{
				&regType($op, '010001', 0, @operands);
			}
		}
		
		elsif ($op =~ /VLD/)
		{
			&memType($op, '100000', @operands);
		}
		
		elsif ($op =~ /VSD/)
		{
			&memType($op, '100001', @operands);
		}
		
		elsif ($op =~ /VBEZ/)
		{
			&memType($op, '100010', @operands);
		}
		
		elsif ($op =~ /VBNEZ/)
		{
			&memType($op, '100011', @operands);
		}
		
		elsif ($op =~ /VNOP/)
		{
			print $OUTRESBIN "1111 0000 0000 0000 0000 0000 0000 0000 // $op\n";
			print $OUTRES "F0000000 // $op\n";
		}
		
		else
		{
			print "FUBAR: $op\n";
		}
	}
}

sub regType
{
	my ($op, $code, $isImm, @subArray) = @_;
	
	#print "\n>>$op, $code, $isImm";
	
	foreach my $loopx (0 .. (scalar @subArray - 1))
	{
		$subArray[$loopx] =~ s/[#\$]//g;
		#print "\n>>$subArray[$loopx]";
	}
	
	my ($numOperands) = scalar @subArray;
	
	my ($w) = '00';
	my ($p) = '000';
	
	my (@split_op) = split('', $op);
	my ($numChars) = scalar @split_op;
	my ($p_field) = $split_op[$numChars - 2];
	my ($w_field) = $split_op[$numChars - 1];
	
	#print "@split_op - p = $p_field, w=$w_field\n";
	
	if ($p_field =~ /a/)
	{	$p = '000';	}
	elsif ($p_field =~ /u/)
	{	$p = '001'; }
	elsif ($p_field =~ /d/)
	{	$p = '010'; }
	elsif ($p_field =~ /e/)
	{	$p = '011'; }
	elsif ($p_field =~ /o/)
	{	$p = '100'; }
		
	if ($w_field =~ /b/)
	{	$w = '00'; }
	elsif ($w_field =~ /h/)
	{	$w = '01'; }
	elsif ($w_field =~ /w/)
	{	$w = '10'; }
	elsif ($w_field =~ /d/)
	{	$w = '11'; }
	
	my ($res);
	my ($res_bin);
	if ($numOperands == 3)
	{
		$res = join('', '101010', dec2bin($subArray[0], 5), dec2bin($subArray[1], 5), dec2bin($subArray[2], 5), $p, $w, $code);
		$res_bin = join(' ', '101010', dec2bin($subArray[0], 5), dec2bin($subArray[1], 5), dec2bin($subArray[2], 5), $p, $w, $code);
	}
	elsif ($numOperands == 2)
	{
		$res = join('', '101010', dec2bin($subArray[0], 5), dec2bin($subArray[1], 5), '00000',$p, $w, $code);
		$res_bin = join(' ', '101010', dec2bin($subArray[0], 5), dec2bin($subArray[1], 5), '00000',$p, $w, $code);
	}
	
	my ($hexRes) = &bin2hex($res);
	print $OUTRES "$hexRes // $op\n";
	print $OUTRESBIN "$res_bin // $op\n";
}

sub memType
{
	my ($op, $code, @subArray) = @_;
	
	#print "\n>>$op, $code";
	
	foreach my $loopx (0 .. (scalar @subArray - 1))
	{
		$subArray[$loopx] =~ s/[#\$]//g;
		#print "\n>>$subArray[$loopx]";
	}
	
	my ($numOperands) = scalar @subArray;
	
	my ($res);
	my ($res_bin);
	my ($foo) = sprintf("%04X", hex($subArray[1]));
	
	if ($numOperands == 2)
	{
		$res = join('', $code, dec2bin($subArray[0], 5), '00000', hex2bin( substr($foo, 0, 1)), hex2bin(substr($foo, 1, 1)), hex2bin(substr($foo, 2, 1)), hex2bin(substr($foo, 3, 1)));
		$res_bin = join(' ', $code, dec2bin($subArray[0], 5), '00000', hex2bin( substr($foo, 0, 1)), hex2bin(substr($foo, 1, 1)), hex2bin(substr($foo, 2, 1)), hex2bin(substr($foo, 3, 1)));
	}
	
	my ($hexRes) = &bin2hex($res);
	print $OUTRES "$hexRes // $op\n";
	print $OUTRESBIN "$res_bin // $op\n";
}

###########################################################################################

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
    my $WIDTH = 32;
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