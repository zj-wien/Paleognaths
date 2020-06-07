#!/usr/bin/perl -w
use strict;
use File::Basename qw/dirname basename/;
use Data::Dumper;
use Getopt::Long;
use lib "/public/home/wangzj/PaleognathousBirds/09.strata/bin/svg_kit";
use SVG;
use Font;

 die "Usage: perl $0 <configure> <color 1> <color 2> <species name file> <Ref Genome length> <chr> \n" unless @ARGV >= 5;
my ($Line,$Wbar);
GetOptions(
	'L:i'=>\$Line,
	'W:i'=>\$Wbar
);
$Line ||=0;
$Wbar ||=0;

my $file_list=shift;
my $color=shift;
my $color2=shift;
my $name=shift;
my $ref_len=shift;

my %Latin;
LatinCommon($name,\%Latin);
$ref_len=83952565 if(not defined $ref_len);

#Initial SVG plot;
my $spe_line=`wc -l $file_list`;
$spe_line=$1 if($spe_line=~/(\S+)/);
my ($font_family, $font_size, $font_label_size) = ("ArialNarrow", 30, 20);
my $figure_resolution = 1/50000;
my ($left_margin, $right_margin,$top_margin, $button_margin) = (400, 600, 350, 200);
my ($height, $space) = (15, 10);
my $figure_width = $left_margin + 2100 + $right_margin;
my $fig_unit=4*($height+$space)+5;
my $figure_height = $top_margin + $fig_unit*($spe_line+1) + $button_margin;
my $svg = SVG->new('width', $figure_width, 'height', $figure_height);
my ($x, $y, $x1, $y1, $x2, $y2,$x0,$y0);
($x0,$y0)=($left_margin,$top_margin);

# Draw colorful band where color from an input RGB color array.
my ($band_height, $band_width) = (400, 40);
($x, $y) = ($left_margin+2100+250, $figure_height-$button_margin);
my @band_color = ();
my $rgb;
my $line = `wc -l $color`;
$line=$1 if($line=~/(\S+)/);
my $multi = int(400/$line);
open(FH, $color) || die $!;
while(<FH>){
	chomp;
	my($r, $g, $b) = split /\s+/;
	$rgb = "rgb($r,$g,$b)";
	for my $i (0..$multi){
		push @band_color, $rgb;
	}
}
close FH;

my $colorN = $#band_color;
my $arscale = $band_height / $colorN;
my $arrowscale = ($band_width + 16) / $band_width;
my $arrows = $x - 10;
my $argrad = $band_width * 2;
my $artag = $colorN / 5;
my ($artagstep, $arss) = (0.2, 0);
my ($artagstep_iden, $arss_iden) = (0.06, 0.7);          ## identity range, five steps total.
my ($artagstep_density, $arss_density) = (0.2, 0);    ## density range(step,min);
for(my $i = $colorN; $i >= 0; --$i){
	$rgb = $band_color[$i];
	if($i <= $band_width*2){
		$svg->line('x1',$arrows,'y1',$y,'x2',$arrows+$argrad*$arrowscale/2,'y2',$y,'fill',$rgb,'stroke',$rgb);
		$argrad--; $arrows += $arrowscale/4;
	}
	else{
		$svg->line('x1',$x,'y1',$y,'x2',$x+$band_width,'y2',$y,'fill',$rgb,'stroke',$rgb);
	}
	if($i % $artag == 0){
		$svg->text('x',$x+$band_width+20,'y',$y+textHeight($font_size)/2,'-cdata',$arss,'font-size',$font_size,'font-family',$font_family);
		$arss += $artagstep;
		$arss_density += $artagstep_density;
	}
	$y -= $arscale;
}
my ($marker_x, $marker_y);
$marker_x = $x+$band_width+20;
$marker_y = $figure_height-$button_margin + 50;
$svg->text('x',$marker_x,'y',$marker_y,'-cdata','depth','font-size',$font_size,'transform'=>"rotate(90,$marker_x,$marker_y)",'font-family',$font_family);

($x, $y) = ($left_margin+2100+400, $figure_height-$button_margin);
my @band_color2 = ();
$line = `wc -l $color2`;
#chomp($line);
$line=$1 if($line=~/(\S+)/);
$multi = int(400/$line);
open(FH, $color2) || die $!;
while(<FH>){
	chomp;
	my($r, $g, $b) = split /\s+/;
	$rgb = "rgb($r,$g,$b)";
	for my $i (0..$multi){
		push @band_color2, $rgb;
	}
}
close FH;
$colorN = $#band_color2;
$arscale = $band_height / $colorN;
$arrowscale = ($band_width + 16) / $band_width;
$arrows = $x - 10;
$argrad = $band_width * 2;
$artag = $colorN / 5;
($artagstep_iden, $arss_iden) = (0.06,0.7);
for(my $i = $colorN; $i >= 0; --$i){
	$rgb = $band_color2[$i];
	if($i <= $band_width*2){
		$svg->line('x1',$arrows,'y1',$y,'x2',$arrows+$argrad*$arrowscale/2,'y2',$y,'fill',$rgb,'stroke',$rgb);
		$argrad--; $arrows += $arrowscale/4;
	}
	else{
		$svg->line('x1',$x,'y1',$y,'x2',$x+$band_width,'y2',$y,'fill',$rgb,'stroke',$rgb);
	}
	if($i % $artag == 0){
		$svg->text('x',$x+$band_width+20,'y',$y+textHeight($font_size)/2,'-cdata',$arss_iden *100 ."%",'font-size',$font_size,'font-family',$font_family);
		$arss_iden += $artagstep_iden;
	}
	$y -= $arscale;
}

$marker_x = $x+$band_width+20;
$marker_y = $figure_height-$button_margin + 50;
$marker_x = $x+$band_width+20;
$svg->text('x',$marker_x,'y',$marker_y,'-cdata','identity','font-size',$font_size,'transform'=>"rotate(90,$marker_x,$marker_y)",'font-family',$font_family);
$marker_x = $x+$band_width+140;

($arss,$arss_iden)=(0,0.7);

# Draw ruler
$x1 = $x0;
$y1 = $y0 - 100;
$x2 = $x1 + 2100;
$y2 = $y1;
$svg->line('x1', $x1, 'y1', $y1, 'x2', $x2, 'y2', $y2, 'stroke', 'black', 'stroke-width', 2);
for(my $i = 0, my $j = 0; $i <=2100; $i+=10000000*$figure_resolution, $j+=10){
	$x1 = $x0 + $i;
	$y1 = $y0 -100;
	$x2 = $x1;
	$y2 = $y1-10;
	$svg->line('x1', $x1, 'y1', $y1, 'x2', $x2, 'y2', $y2, 'stroke', 'black', 'stroke-width', 1);
	$y = $y2 - textHeight($font_size);
	$svg->text('x',$x1-textWidth($font_family,$font_size,$j."M")*1/2,'y',$y1-10,'-cdata',$j."M",'font-size',$font_size,'font-family',$font_family);
}


my %Gene;
my $spe_count=0;

open ZWF,$file_list;
while(<ZWF>){
	chomp;
	my @t=split /\s+/;
	if(defined $t[6]){
		my $gene_loc=$t[6];
		if($Line>=1){
			my @Gene_loc;
			GeneLocus($gene_loc,\@Gene_loc);
			my $gcount=0;
			foreach(@Gene_loc){
				my $gx=$x0 + $Gene_loc[$gcount][0] * $figure_resolution;
				my $gy=$y0;
				push @{$Gene{$Gene_loc[$gcount][1]}},[$gx,$gy];
				my ($grx,$gry)=($gx-10,$gy-5);
				$svg->text('x',$gx,'y',$y0+$height,'-cdata',$Gene_loc[$gcount][1],'transform'=>"rotate(-90,$grx,$gry)",'font-size',24,'font-family',$font_family) if($spe_count==1 );
				$gcount++;
			}
		}
	}
## Blocks for drawing Lizard and Chicken bar     
	if($t[0]=~/NA/ && $t[1]=~/NA/){
	#	my $pub_len_base=basename $t[2];
		#my $latin_name=$1 if($pub_len_base=~/^([^\.]+)\./);
		my $latin_name= (split /\//,$t[2])[-3];
		if($latin_name=~/Gallus_gallus/){
			my $rgbchick=$band_color[$colorN-int(0.5*($colorN-1)+0.5)];
			$svg->rect('x',$x0,'y',$y0,'width',$ref_len*$figure_resolution,'height',$height,'stroke',"none",'fill',$rgbchick,'stroke',$rgbchick);
			$svg->text('x',$x0+95710792*$figure_resolution+50,'y',$y0+$height+$space+textHeight($font_size)/2,'-cdata',$Latin{$latin_name},'font-family',$font_family,'font-size',$font_size);
			$svg->rect('x',$x0,'y',$y0+2*($height+$space),'width',$ref_len*$figure_resolution,'height',$height,'stroke',"none",'fill',"grey",'opacity',0.05) if($Wbar>=1);
		}
		elsif($latin_name =~/Anolis_carolinensis/){
			my $rgblizard=$band_color[$colorN-int(($colorN-1)+0.5)];
			$svg->rect('x',$x0,'y',$y0,'width',70000000*$figure_resolution,'height',$height,'stroke',"none",'fill',$rgblizard,'stroke',$rgblizard);
			$svg->text('x',$x0+95710792*$figure_resolution+50,'y',$y0+textHeight($font_size)/2,'-cdata',$Latin{$latin_name},'font-family',$font_family,'font-size',$font_size)
		}
		$y0+=4*($height+$space);
		$spe_count++;
		next;
	}
	my ($Znet,$Zscaf,$WSyn,$Zdp,$Wdp_ide,$dpk,$repeat_content,$rmv)=($t[0],$t[1],$t[2],$t[3],$t[4],$t[5],$t[7],$t[8]);
	my $Zscaf_base=basename $Zscaf;
	my $latin_name=$1 if($Zscaf_base=~/^([^\.]+)\./);
	my (%Zscaf,%ZScafCor,%Zdp);
	ZSeq($Zscaf,\%Zscaf);
## W depth and identity    
	my ($spe,$dpk_value);
	open DPK,$dpk;
	while(<DPK>){
		chomp;
		($spe,$dpk_value)=($1,$2) if(/(\S+)\s+(\S+)/);
		last;
	}
	close DPK;
##Max value for specific repeat content (e.g. CR1)
	my ($Spe,$Mrepeat);
	open IN,$rmv;
	while(<IN>){
		chomp;
		($Spe,$Mrepeat)=($1,$2) if(/(\S+)\s+(\S+)/);
		last;
	}
	close IN;

	my %Wdpide;
	open DPIDE,$Wdp_ide;
	while(<DPIDE>){
		chomp;
		my @t=split /\s+/;
		$Wdpide{$t[0]}=[$t[3]/$dpk_value,$t[4]];
	}
	close DPIDE;

## Ostrich Z    
	if($latin_name=~/#Struthio_camelus/){
# Read Z and W depth distribution
		my ($Zlen,$depth_Z,$iden_cov_UM,$peak)=($t[2],$t[3],$t[4],$t[5]);
		my ($chrZ_raw,$chrZ_len);
		open ZLEN,$Zlen;
		while(<ZLEN>){
			chomp;
			$chrZ_raw=$1 if(/\S+\s+(\S+)/);
		}
		close ZLEN;
		$chrZ_len=$chrZ_raw * $figure_resolution;
		my (@depth_Z,@iden_cov_UM);
		DepthDistribution($depth_Z,\@depth_Z,$peak);
		@iden_cov_UM=read_distribution($iden_cov_UM,$peak);
# Draw chrZ depth distribution
		for my $i (0..$#depth_Z){
			my $xdz=$x0+ $depth_Z[$i][0] * $figure_resolution;
			my $ydz =$y0;
			my $widthdz=100000 * $figure_resolution;
			my $rgbdz = $band_color[$colorN-int($depth_Z[$i][1]*($colorN-1)+0.5)];
			$svg->rect('x', $xdz, 'y', $ydz, 'width', $widthdz, 'height', $height, 'stroke', $rgbdz, 'fill', $rgbdz) if($depth_Z[$i][0]<$chrZ_raw);
			if($depth_Z[$i][0]>=$chrZ_raw){
				$svg->rect('x', $xdz, 'y', $ydz,'width', ($chrZ_raw-$depth_Z[$i-1][0])*$figure_resolution, 'height', $height, 'stroke', $rgbdz, 'fill', $rgbdz);
				last;
			}
		}
		$y0+=($height+$space);
		$svg->text('x',$x0+$chrZ_len+50,'y',$y0 + $height,'-cdata',$Latin{$latin_name},'font-size',$font_size,'font-family',$font_family);
#Draw UM identity density distribution
		$svg->rect('x',$x0,'y',$y0+$height+$space,'rx',1,'ry',1,'height',$height,'width',$chrZ_len,'fill',"grey",'opacity',0.05) if($Wbar>=1);
		for my $i (0..$#iden_cov_UM){
			next if($iden_cov_UM[$i][3] <0.70);
			$iden_cov_UM[$i][3] = ($iden_cov_UM[$i][3] - $arss_iden) / 0.3;
			$x = $left_margin + $iden_cov_UM[$i][0] * $figure_resolution;
			my $xdum=$left_margin + $iden_cov_UM[$i][0] * $figure_resolution;
			my $ydum= $y0 + $height+$space;
			my $rgbdum = $band_color[$colorN-int($iden_cov_UM[$i][2]*($colorN-1)+0.5)];
			my $width = $iden_cov_UM[$i][1]* $figure_resolution;
			my $rgb = $band_color2[$colorN-int($iden_cov_UM[$i][3]*($colorN-1)+0.5)];
			$svg->rect('x', $x, 'y', $y0, 'width', $width, 'height', $height, 'stroke', $rgb, 'fill', $rgb) if($Wbar>=1);
			$svg->rect('x', $xdum, 'y', $ydum, 'width', $width, 'height', $height, 'stroke', $rgbdum, 'fill', $rgbdum) if($Wbar>=1);
		}
		$y0 +=3*($height+$space);
		$spe_count++;
		next;
	}

#Z depth disposal
	open ZDP,$Zdp;
	while(<ZDP>){
		chomp;
		my @t=split /\s+/;
		my ($rs,$rp)=($t[0]-100000+1,$t[0]);
		for my $zk( sort {$Zscaf{$a}->[0] <=> $Zscaf{$b}->[0]} keys %Zscaf){
			if($rs <= $Zscaf{$zk}[1] && $rp >=$Zscaf{$zk}[0] ){
				push @{$Zdp{$zk}},[$rs-$Zscaf{$zk}[0]+1,$rp-$Zscaf{$zk}[0]+1,$t[1]] if($rs>=$Zscaf{$zk}[0] && $rp<=$Zscaf{$zk}[1]);
				push @{$Zdp{$zk}},[1,$Zscaf{$zk}[1]-$Zscaf{$zk}[0]+1,$t[1]] if($rs<$Zscaf{$zk}[0] && $rp>$Zscaf{$zk}[1]);
				push @{$Zdp{$zk}},[1,$rp-$Zscaf{$zk}[0]+1,$t[1]] if($rs<$Zscaf{$zk}[0] && $rp<=$Zscaf{$zk}[1]);
				push @{$Zdp{$zk}},[$rs-$Zscaf{$zk}[0]+1,$Zscaf{$zk}[1]-$Zscaf{$zk}[0]+1,$t[1]] if($rs>=$Zscaf{$zk}[0] && $rp>$Zscaf{$zk}[1]);
			}
		}
	}
	close ZDP;
#draw Z background    

	$svg->rect('x',$x0,'y',$y0,'width',$ref_len*$figure_resolution,'height',$height,'stroke',"none",'fill',"grey",'opacity',0.05) if($latin_name !~/Tinamus_guttatus/);

# Z-lined repeat (CR1) By Zongji
	my %repeat;
	open REP, $repeat_content;
	while (<REP>) {
		chomp;
		my @t=split /\s+/;
		my ($rs,$rp)=($t[0]-100000+1,$t[0]);
		for my $zk( sort {$Zscaf{$a}->[0] <=> $Zscaf{$b}->[0]} keys %Zscaf){
			if($rs <= $Zscaf{$zk}[1] && $rp >=$Zscaf{$zk}[0] ){
				push @{$repeat{$zk}},[$rs-$Zscaf{$zk}[0]+1,$rp-$Zscaf{$zk}[0]+1,$t[1]] if($rs>=$Zscaf{$zk}[0] && $rp<=$Zscaf{$zk}[1]);
				push @{$repeat{$zk}},[1,$Zscaf{$zk}[1]-$Zscaf{$zk}[0]+1,$t[1]] if($rs<$Zscaf{$zk}[0] && $rp>$Zscaf{$zk}[1]);
				push @{$repeat{$zk}},[1,$rp-$Zscaf{$zk}[0]+1,$t[1]] if($rs<$Zscaf{$zk}[0] && $rp<=$Zscaf{$zk}[1]);
				push @{$repeat{$zk}},[$rs-$Zscaf{$zk}[0]+1,$Zscaf{$zk}[1]-$Zscaf{$zk}[0]+1,$t[1]] if($rs>=$Zscaf{$zk}[0] && $rp>$Zscaf{$zk}[1]);
			}
		}
		
	}
	close REP;
	#$svg->rect('x',$x0,'y',$y0,'width',95710792*$figure_resolution,'height',$height,'stroke',"none",'fill',"grey",'opacity',0.05) if($latin_name=~/Tinamus_guttatus/ || $latin_name=~/Dromaius_novaehollandiae/ );

## Z scaffold coordinate on Chicken Z && Draw Z linked scaffold aligned blocks
	open ZNET,$Znet;
	while(<ZNET>){
		chomp;
		my @t=split /\s+/;
		next if(not exists $Zscaf{$t[2]});
		push@{$ZScafCor{$t[2]}},[$t[0],$t[1],$t[3],$t[4],$t[5]];
		my $flag=0;
		my $tem_start=$t[4] + 1;
		foreach(@{$Zdp{$t[2]}}){
				##	print STDERR "$flag\t$tem_start\t$Zdp{$t[2]}[$flag][0]\t$Zdp{$t[2]}[$flag][1]\t$t[4],$t[5]\n";
			if($tem_start >=$Zdp{$t[2]}[$flag][0]  && $tem_start <=$Zdp{$t[2]}[$flag][1]){
#		next if(not defined $Zdp{$t[2]}[-1][2] || $Zdp{$t[3]}[-1][2]==0);
				my $dpz_tem=$Zdp{$t[2]}[$flag][2]/$dpk_value;
				$dpz_tem=1 if($dpz_tem >1);
				my $rgbdz=$band_color[$colorN-int($dpz_tem*($colorN-1)+0.5)];
				$svg->rect('x',$x0+($t[0]+$tem_start-$t[4])*$figure_resolution,'y',$y0,'height',$height,'width',($Zdp{$t[2]}[$flag][1]-$tem_start+1)*$figure_resolution,'stroke',$rgbdz,'fill',$rgbdz);
			#	$tem_start=$Zdp{$t[2]}[$flag][1]+1;
			#	$flag++;
			}
			if ($tem_start > $Zdp{$t[2]}[$flag][1]) {
				
			##		print STDERR "$flag\t$tem_start\t$Zdp{$t[2]}[$flag][1]+1\n";
			}
			$tem_start=$Zdp{$t[2]}[$flag][1]+1;
			$flag++;
		##	if($tem_start <=$t[4]+$t[5]){
#		    next if(not defined $Zdp{$t[2]}[-1][2] || $Zdp{$t[3]}[-1][2]==0);
		##		my $dpz_tem=$Zdp{$t[2]}[-1][2]/$dpk_value;
		##		$dpz_tem=1 if($dpz_tem >1);
		##		my $rgbdz=$band_color[$colorN-int($dpz_tem*($colorN-1)+0.5)];
		##		$svg->rect('x',$x0+($t[0]+$tem_start-$t[4])*$figure_resolution,'y',$y0,'height',$height,'width',($t[4]+$t[5]-$tem_start+1)*$figure_resolution,'stroke',$rgbdz,'fill',$rgbdz);
		##	}
		}
	}
	close ZNET;
#print Dumper(%ZScafCor);

## W Synteny table(change W ~pseudoZ to W~Z scaffold coordinate)
	my %W2Zscaf;
	open WSYN,$WSyn;
	while(<WSYN>){
		chomp;
		next if(/^#/);
		my @t=split /\s+/;
		my ($Wcor,$Zscafid)=W2ZScaf($t[1],$t[2],\%Zscaf) if(defined $t[1]);
		push @{$W2Zscaf{$Zscafid}},[$Wcor,$t[4],$t[0],$t[3]] if(defined $t[1]);
	}
	close WSYN;
## W~Z scaffold coordinate to W~chicken Z coordinate and W depth & Strata
	$y0+=2*($space+$height);
#    $svg->text('x',$x0+$ref_len*$figure_resolution+50,'y',$y0-$space+$height-textHeight($font_size)/2,'-cdata',$Latin{$latin_name},'font-family',"ArialNarrow",'font-size',$font_size) if($latin_name !~/Tinamus_guttatus/);
	$svg->text('x',$x0+95710792*$figure_resolution+50,'y',$y0-$space+$height-textHeight($font_size)/2,'-cdata',$Latin{$latin_name},'font-family',$font_family,'font-size',$font_size) ; #if($latin_name =~/Tinamus_guttatus/);
#grey bar for W depth (better not to show this, as  grey bar did not show the real length of ancestor Z)
	$svg->rect('x',$x0,'y',$y0,'width',$ref_len*$figure_resolution,'height',$height,'stroke',"none",'fill',"grey",'opacity',0.05) if($latin_name !~/Tinamus_guttatus/ && $Wbar>=1);

#	$svg->rect('x',$x0,'y',$y0,'width',95710792*$figure_resolution,'height',$height,'stroke',"none",'fill',"grey",'opacity',0.05) if($latin_name =~/Tinamus_guttatus/ && $Wbar>=1);

	open WCOR,">$latin_name.W.cor";
	my %WonZ;

	for my $k(sort {$ZScafCor{$a}->[0][0] <=>$ZScafCor{$b}->[0][0]} keys %ZScafCor){
		if(exists $W2Zscaf{$k}){
			my $flag=0;
			foreach (@{$ZScafCor{$k}}){
				my ($zt,$zp)=($ZScafCor{$k}[$flag][3],$ZScafCor{$k}[$flag][3]+$ZScafCor{$k}[$flag][4]);
				my $count=0;
				foreach (@{$W2Zscaf{$k}}){
					my ($wt,$wp)=($W2Zscaf{$k}[$count][0],$W2Zscaf{$k}[$count][0]+$W2Zscaf{$k}[$count][1]);
					next if ($wp <$zt);
					if($wt<= $zp && $wp >=$zt){
						my $wnt=$ZScafCor{$k}[$flag][0]-$ZScafCor{$k}[$flag][3]+$W2Zscaf{$k}[$count][0];
						if(exists $Wdpide{$W2Zscaf{$k}[$count][2]}){
							my $overlap;
							if($zt<=$wt){
								$overlap=$wp-$wt+1 if($wp<=$zp);
								$overlap=$zp-$wt+1 if($wp>$zp);
							}
							if($zt>$wt){
								$overlap=$wp-$zt+1 if($wp<=$zp);
								$overlap=$zp-$zt+1 if($wp>$zp);
							}
							next if($Wdpide{$W2Zscaf{$k}[$count][2]}[1] <0.7);
							$WonZ{$W2Zscaf{$k}[$count][2]}=[$k,$wnt,$W2Zscaf{$k}[$count][0],$W2Zscaf{$k}[$count][1],$W2Zscaf{$k}[$count][3]] if($wnt>=0 && (not exists $WonZ{$W2Zscaf{$k}[$count][2]} || (exists $WonZ{$W2Zscaf{$k}[$count][2]} && $WonZ{$W2Zscaf{$k}[$count][2]}[0] <=$overlap)));
						}
					}
					$count++;
				}
				$flag++;
			}
		}
	}
	for my $k (keys %WonZ){
		print WCOR "$k\t$WonZ{$k}[1]\t$WonZ{$k}[4]\t$WonZ{$k}[3]\n";
		my $rgbdw = $band_color[$colorN-int($Wdpide{$k}[0]*($colorN-1)+0.5)];
		$Wdpide{$k}[1]=($Wdpide{$k}[1]-$arss_iden)/0.3;
		my $rgbidew=$band_color2[$colorN-int($Wdpide{$k}[1]*($colorN-1)+0.5)];
		$svg->rect('x',$x0+$WonZ{$k}[1]*$figure_resolution,'y',$y0-($height+$space),'width',$WonZ{$k}[3]*$figure_resolution,'height',$height,'stroke',$rgbidew,'fill',$rgbidew) if($Wbar >=1);
		## $svg->rect('x',$x0+$WonZ{$k}[1]*$figure_resolution,'y',$y0,'width',$WonZ{$k}[3]*$figure_resolution,'height',$height,'stroke',$rgbdw,'fill',$rgbdw) if($Wbar >=1);
	}
	close WCOR;

# draw repeat landscape	
	open ZNET,$Znet;
    while(<ZNET>){
		chomp;
		my @t=split /\s+/;
		next if(not exists $Zscaf{$t[2]});
		#push@{$ZScafCor{$t[2]}},[$t[0],$t[1],$t[3],$t[4],$t[5]];
		my $flag=0;
		my $tem_start=$t[4] + 1;
		foreach(@{$repeat{$t[2]}}){
			if($tem_start >=$repeat{$t[2]}[$flag][0]  && $tem_start <=$repeat{$t[2]}[$flag][1]){
				my $dpz_tem=$repeat{$t[2]}[$flag][2]/$Mrepeat;
				$dpz_tem=1 if($dpz_tem >1);
				my $rgbdz=$band_color2[$colorN-int($dpz_tem*($colorN-1)+0.5)];
#				my $rgbdz=$band_color[$colorN-int($dpz_tem*($colorN-1)+0.5)];
				$svg->rect('x',$x0+($t[0]+$tem_start-$t[4])*$figure_resolution,'y',$y0,'height',$height,'width',($repeat{$t[2]}[$flag][1]-$tem_start+1)*$figure_resolution,'stroke',$rgbdz,'fill',$rgbdz);
			#	$tem_start=$repeat{$t[2]}[$flag][1]+1;
			#	$flag++;
			}
			$tem_start=$repeat{$t[2]}[$flag][1]+1;
			$flag++;
		##	if($tem_start <=$t[4]+$t[5]){
		##		my $dpz_tem=$repeat{$t[2]}[-1][2]/$Mrepeat;
		##		$dpz_tem=1 if($dpz_tem >1);
		##		my $rgbdz=$band_color2[$colorN-int($dpz_tem*($colorN-1)+0.5)];
				#my $rgbdz=$band_color[$colorN-int($dpz_tem*($colorN-1)+0.5)];
		##		$svg->rect('x',$x0+($t[0]+$tem_start-$t[4])*$figure_resolution,'y',$y0,'height',$height,'width',($t[4]+$t[5]-$tem_start+1)*$figure_resolution,'stroke',$rgbdz,'fill',$rgbdz);
		##	}
		}
	}
	close ZNET;

	$y0+=2*($space+$height);
	$spe_count++;
}
close ZWF;

# Draw a dashed line between ajacent genes
if($Line >0){
	for my $k (keys %Gene){
		for(my $i=0;$i<$#{$Gene{$k}};$i++){
			my($gx1,$gy1,$gx2,$gy2)=($Gene{$k}[$i][0],$Gene{$k}[$i][1],$Gene{$k}[$i+1][0],$Gene{$k}[$i+1][1]);
			$svg->line('x1', $gx1, 'y1', $gy1+20, 'x2', $gx2, 'y2', $gy2-5, 'style',"stroke-dasharray:9,5",'stroke',"blue", 'stroke-width',2,'stroke-opacity',0.3) if($k !~/DMRT1/);
			$svg->line('x1', $gx1, 'y1', $gy1+20, 'x2', $gx2, 'y2', $gy2-5, 'style',"stroke-dasharray:9,5",'stroke',"red", 'stroke-width',4,'stroke-opacity',0.5) if($k=~/DMRT1/);
		}
	}
}

print $svg->xmlify();


##############
# Subrutines
##############
# loading pseudo ChrZ mapping locate 
sub ZSeq{
	my $f=shift;
	my $h=shift;
	open IN,$f;
	while(<IN>){
		chomp;
		my @t=split /\s+/;
		$h->{$t[2]}=[$t[5],$t[6],$t[4],$t[3]] if($t[1]=~/chrZ/);
	}
	close IN;
}

# loading W Synteny table
sub W2ZScaf{
	my $start=shift;
	my $net_len=shift;
	my $h=shift;

	for my $k (sort {$h->{$a}[0] <=> $h->{$b}[0]} keys %$h ){
		next if($start < $h->{$k}[0]-1);
		if($start >=$h->{$k}[0]-1 &&  $start <= $h->{$k}[1]-1){
			return ($start-$h->{$k}[0]+1,$k) if($h->{$k}[2]=~/\+/);
			return ($h->{$k}[3]-($start-$h->{$k}[0]+1),$k) if($h->{$k}[2]=~/-/);
			last;
		}
	}
}

sub read_distribution
{
	my ($file,$pkfile) = @_;
	my @array = ();
	my $pk;
	open PK,$pkfile;
	while(<PK>){
		my @t=split"\t";
		$pk=$t[1];
		last;
	}
	open(FH, $file) || die $!;
	while(<FH>){
		chomp;
		my @tmp = split /\s+/;
		my $ratio=$tmp[3]/$pk;
		push @array, [$tmp[1],$tmp[2],$ratio,$tmp[4]];
	}
	close FH;
	return @array;
}

sub DepthDistribution{
	my $f=shift;
	my $h=shift;
	my $pkfile=shift;
	my $pk;
	open PK,$pkfile;
	while(<PK>){
		my @t=split"\t";
		$pk=$t[1];
		last;
	}
	close PK;
	open IN,$f;
	while(<IN>){
		chomp;
		my @t=split"\t";
		my $ratio=$t[1]/$pk;
		$ratio=1 if($ratio >=1);
		push @$h,[$t[0],$ratio];
	}
	close IN;
}

sub LatinCommon{
	my $f=shift;
	my $h=shift;
	open IN,$f;
	while(<IN>){
		chomp;
		my @t=split"\t";
		$h->{$t[0]}=$t[1];
	}
	close IN;
}

sub GeneLocus{
	my $f=shift;
	my $a=shift;
	open IN,$f;
	while(<IN>){
		chomp;
		my @t=split /\s+/;
		my $name=$1 if($t[0]=~/^([^\_]+)/);
		push @$a,[$t[1],$name];
	}
	close IN;
}
