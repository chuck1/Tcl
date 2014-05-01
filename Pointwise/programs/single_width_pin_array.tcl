package require PWI_Glyph 2.17.0

pw::Application reset

pw::Application setCAESolver {ANSYS FLUENT} 3

pw::Database setModelSize 1e-01
pw::Grid setNodeTolerance 1e-07
pw::Grid setConnectorTolerance 1e-07

source "/nfs/mohr/sva/work/rymalc/bin/pointwise/grid.tcl"
source "/nfs/mohr/sva/work/rymalc/bin/pointwise/extrude_block.tcl"

# -------------------------------------------

itcl::class Pin {
	public variable steps
	public variable steps_sixth
	public variable var_d
	public variable var_scale

	public variable n
	#public variable d
	#public variable e
	public variable a_end
	public variable var_space
	
	public variable PL
	public variable PT
	public variable R
	public variable r
	public variable H
	public variable h
	public variable t
	public variable gap
	
	public variable y_m
	public variable y_p
	public variable z_m
	public variable z_p
	public variable dimy_m
	public variable dimy_p
	public variable dimz_m
	public variable dimz_p


	public variable dim			[lfill  2 100]
	public variable dimv			[lfill  2 100]
	public variable diml			[lfill  2 100]
	
	public variable con_outer_x		[lfill [list] 100]
	public variable con_outer_x_pair	[lfill [list] 100]
	
	public variable dom_inner	 	[list]
	public variable dom_outer		[list]
	
	public variable pairs_xm_fluid		[list]
	public variable pairs_xp_fluid		[list]
	
	public variable blk_inner		[list]
	public variable blk_outer		[list]
	
	public variable con			[lfill [lfill             0 100] 100]
	public variable conl			[lfill [lfill [lfill 0 100]  10] 100]

	# conv (hexagon index) (vertial layer index???) (point_vertical index)
	public variable conv			[lfill [lfill [lfill 0 100]  10] 100]
	
	public variable xdom			[lfill [lfill             0 100] 100]
	public variable dom			[lfill [lfill             0 100] 100]
	public variable domv			[lfill [lfill [lfill 0  20] 100] 100]
	public variable doml			[lfill [lfill [lfill 0 100] 100] 100]
	public variable blk			[lfill [lfill             0 100] 100]
	public variable xblk			[lfill [lfill             0 100] 100]
	public variable blkl			[lfill [lfill [lfill 0 100] 100] 100]
	
	public variable Z_space			[lfill {0 0} 3]
	
	public variable grid			grid1
	public variable grid_cons
	public variable grid_doms

	method a_to_grid_z {a} {
		return [expr ($a-($a%2))/2]
	}
	method coordinates { x y z } {
		#global PT PL R r t h var_d e con dom blk dim
		#puts "coordinates"
		
		set X [lfill 0 100]
		set Y [lfill 0 100]
		set Z [lfill 0 100]
			
		if {$x==0} {
			set direction -1
			
			lset X 0 0
			lset X 1 $var_d
			lset X 2 [expr $PT - $var_d]
			lset X 3 $PT
			
			lset X 20 [expr $var_d * 0.7]
			lset X 30 $var_d	
			
		} elseif {$x==1} {
			set direction 1
			
			lset X 0 $PT
			lset X 1 [expr $PT - $var_d]
			lset X 2 $var_d
			lset X 3 0
	
			lset X 20 [expr $PT - $var_d * 0.7]
			lset X 30 [expr $PT - $var_d]
		} else {
			error "invalid x"
		}
		
		if {$y==0} {
			lset Y 0 0
			lset Y 1 $h
			lset Y 2 [expr $h + $t]
			lset Y 3 [expr $h + $r]
		} elseif {$y==1} {
			lset Y 0 [expr $PL - 2 * $R + 2 * $h]
			lset Y 1 [expr [lindex $Y 0] - $h]
			lset Y 2 [expr [lindex $Y 0] - $h - $t]
			lset Y 3 [expr [lindex $Y 0] - $h - $r]
		} else {
			error "invalid y"
		}
	
		set base [expr $PL * $z]
		
		lset Z 0 [expr $base + $PL / 2.0 ]
		lset Z 1 [expr $base + $R + $r]
		lset Z 2 [expr $base + $R + $t]
		lset Z 3 [expr $base + $R]
		lset Z 4 [expr $base]
		lset Z 5 [expr $base - $R]
		lset Z 6 [expr $base - $R - $t]
		lset Z 7 [expr $base - $R - $r]
		lset Z 8 [expr $base - $PL / 2.0 ]
		
		lset Z 20 [expr $base + $PL/4.0]
		lset Z 30 [expr $base - $PL/4.0]
		
		#puts $X
		
		return [list $X $Y $Z $direction]
	}
	method xyz { coor x y z } {
		set X [lindex $coor 0]
		set Y [lindex $coor 1]
		set Z [lindex $coor 2]
		
		set v [list [lindex $X $x] [lindex $Y $y] [lindex $Z $z]]
		#puts $v
		return $v
	}
	method rim_extra {a x y z} {
		set b [expr $a + 2]
		
		set coor [coordinates $x $y $z]
		set X [lindex $coor 0]
		set Y [lindex $coor 1]
		set Z [lindex $coor 2]
		set direction [lindex $coor 3]
		
		# hex
		lset conl $a 1 3 [createTwoPtLineCon [xyz $coor 0 1 8] [xyz $coor 1 1 8] [lindex $diml 3]]
		lset conl $a 1 4 [createTwoPtLineCon [xyz $coor 1 1 8] [xyz $coor 2 1 4] [lindex $diml 4]]
		
		lset conl $a 2 3 [createTwoPtLineCon [xyz $coor 0 2 8] [xyz $coor 1 2 8] [lindex $diml 3]]
		lset conl $a 2 4 [createTwoPtLineCon [xyz $coor 1 2 8] [xyz $coor 2 2 4] [lindex $diml 4]]
	
		# hex for b
		lset conl $b 1 3 [createTwoPtLineCon [xyz $coor 3 1 4] [[lindex $conl $a 1 4] getPosition -arc 1] [lindex $diml 3]]
		lset conl $b 2 3 [createTwoPtLineCon [xyz $coor 3 2 4] [[lindex $conl $a 2 4] getPosition -arc 1] [lindex $diml 3]]
		
		# vertical
		lset conv $a 1 2 [createTwoPtLineCon [[lindex $conl $a 1 3] getPosition -arc 0] [[lindex $conl $a 2 3] getPosition -arc 0] [lindex $dim 1]]
		lset conv $a 1 3 [createTwoPtLineCon [[lindex $conl $a 1 4] getPosition -arc 0] [[lindex $conl $a 2 4] getPosition -arc 0] [lindex $dim 1]]
		lset conv $a 0 2 [createTwoPtLineCon [xyz $coor 0 0 8] [xyz $coor 0 1 8] [lindex $dimv 0]]
	
		
		# vertical for b
		#lset conv $b 1 2 [createTwoPtLineCon [[lindex $conl $b 1 3] getPosition -arc 0] [[lindex $conl $b 2 3] getPosition -arc 0] [lindex $dim 1]]
		#lset conv $b 1 3 [createTwoPtLineCon [[lindex $conl $b 1 3] getPosition -arc 1] [[lindex $conl $b 2 3] getPosition -arc 1] [lindex $dim 1]]
		set j [expr (($y==0)?2:4)]
		set k [a_to_grid_z $b]
		set i [expr (($x==1)?0:3)]
		lset conv $b 1 2 [lindex $grid_cons 1 $i $j $k]
		set i [expr (($x==1)?1:2)]
		lset conv $b 1 3 [lindex $grid_cons 1 $i $j $k]
		#puts "[lindex $conv $b 1 2] [lindex $conv $b 1 3]"
		
		# the x if statement is flipped because b = a + 2 so b is on the opposite side
		set i [expr (($x==1)?0:3)]
		set j [expr (($y==0)?1:5)]
		set k [a_to_grid_z $b]
		#lset conv $b 0 2 [createTwoPtLineCon [xyz $coor 3 0 4] [xyz $coor 3 1 4] [lindex $dimv 0]]
		lset conv $b 0 2 [lindex $grid_cons 1 $i $j $k]
		
	}
	method rim { a x y z } {
		#puts "rim"
		#puts "dim = $dim"
		
		set c [expr $a + 4]
		
		set coor [coordinates $x $y $z]
		set direction [lindex $coor 3]
	
		lset con $a  0 [createPointPointCenterCircle [xyz $coor 0 3 5] [xyz $coor 0 1 7] [xyz $coor 0 3 7] [lindex $dim 0]]
		lset con $a  2 [createPointPointCenterCircle [xyz $coor 0 3 6] [xyz $coor 0 2 7] [xyz $coor 0 3 7] [lindex $dim 0]]
		
		lset con $a  1 [createTwoPtLineCon [[lindex $con $a 0] getPosition -arc 0] [[lindex $con $a 2] getPosition -arc 0] [lindex $dim 1] $var_space]
		lset con $a  3 [createTwoPtLineCon [[lindex $con $a 0] getPosition -arc 1] [[lindex $con $a 2] getPosition -arc 1] [lindex $dim 1] $var_space]
		
		# spoke 1
		lset conl $a 1 2 [createTwoPtLineCon [xyz $coor 0 1 7] [xyz $coor 0 1 8] [lindex $diml 2]]
		lset conl $a 2 2 [createTwoPtLineCon [xyz $coor 0 2 7] [xyz $coor 0 2 8] [lindex $diml 2]]
		
		# domain
		lset xdom $a 0 [xDom_new_structured [lrange [lindex $con $a] 0 3]]
		lset dom $a 0 [xDom_get_domain [lindex $xdom $a 0]]
		
	
		# block
		lset xblk $a 0 [xBlkExt_new_rotate [lindex $xdom $a 0] [xyz $coor 0 1 4] [list 0 $direction 0] 180 $steps]
		
		# spoke 2
		lset conl $a 1 0 [createTwoPtLineCon [xyz $coor 0 1 1] [xyz $coor 0 1 0] [lindex $diml 0]]
		lset conl $a 2 0 [createTwoPtLineCon [xyz $coor 0 2 1] [xyz $coor 0 2 0] [lindex $diml 0]]
		
		
		# hexagon
		lset conl $a 1 3 [createTwoPtLineCon [[lindex $conl $a 1 2] getPosition -arc 1] [xyz $coor 1 1 8] [lindex $diml 3]]
		lset conl $a 1 4 [createTwoPtLineCon [[lindex $conl $a 1 3] getPosition -arc 1] [xyz $coor 2 1 4] [lindex $diml 4]]
		lset conl $a 2 3 [createTwoPtLineCon [[lindex $conl $a 2 2] getPosition -arc 1] [xyz $coor 1 2 8] [lindex $diml 3]]
		lset conl $a 2 4 [createTwoPtLineCon [[lindex $conl $a 2 3] getPosition -arc 1] [xyz $coor 2 2 4] [lindex $diml 4]]
	
		# z
		#lset conl $a 0 12 [createTwoPtLineCon [xyz $coor 0 0 0] [xyz $coor 0 0 8] [lindex $diml 12]]
		set i [expr (($x==1)?3:0)]
		set j [expr (($y==0)?1:6)]
		set k [a_to_grid_z $a]
		lset conl $a 0 12 [lindex $grid_cons 2 $i $j $k]
		incr k
		lset conl $a 0 15 [lindex $grid_cons 2 $i $j $k]
		
		# vertical
		
		
		
		if {$a==2 || $a==3} {
			set i [expr (($x==0)?0:3)]
			set j [expr (($y==0)?1:5)]
			lset conv $a 0 2 [lindex $grid_cons 1 $i $j 1]


			set j [expr (($y==0)?2:4)]
			set k [a_to_grid_z $a]
			set i [expr (($x==0)?0:3)]
			lset conv $a 1 2 [lindex $grid_cons 1 $i $j $k]
			set i [expr (($x==0)?1:2)]
			lset conv $a 1 3 [lindex $grid_cons 1 $i $j $k]
		} else {
			lset conv $a 1 2 [createTwoPtLineCon [[lindex $conl $a 1 2] getPosition -arc 1] [[lindex $conl $a 2 2] getPosition -arc 1] [lindex $dim 1]]
			lset conv $a 1 3 [createTwoPtLineCon [[lindex $conl $a 1 3] getPosition -arc 1] [[lindex $conl $a 2 3] getPosition -arc 1] [lindex $dim 1]]


			lset conv $a 0 2 [createTwoPtLineCon [xyz $coor 0 0 8] [xyz $coor 0 1 8] [lindex $dimv 0]]
		}
		
		
		# reference
		set tmp [list]
		lappend tmp [xBlkExt_get_begin_connector [lindex $xblk $a 0] 0]
		lappend tmp [xBlkExt_get_end_connector [lindex $xblk $a 0] 0]
		lappend tmp [lindex $conv $a 0  2]
		lappend tmp [lindex $conl $a 1  0]
		lappend tmp [lindex $conl $a 1  2]
		
		#lappend tmp [lindex $conl $a 0 12]
		lappend tmp [lindex $conl $a 0 12]
		lappend tmp [lindex $conl $a 0 15]
		
		lset con_outer_x $a $tmp
		#puts [lindex $con_outer_x $a]
		
		lappend_dom_inner [xBlkExt_get_side_domain [lindex $xblk $a 0] 2]
		lappend_dom_outer [xBlkExt_get_side_domain [lindex $xblk $a 0] 0]
		
		lappend blk_inner [xBlkExt_get_block [lindex $xblk $a 0]]
	}
	method rim_domain { a x y z } {
		#global PT PL R r t d e steps con conl conv dom doml domv blk xblk dim
		set b [expr $a + 2]
		set c [expr $a + 4]
		
		set coor [coordinates $x $y $z]
		set direction [lindex $coor 3]
	
		# vertical domains
		# spokes
		lset domv $a 1 2 [createDomStr [list [lindex $conl $a 1 2] [lindex $conl $a 2 2] [lindex $conv $a 1 2] [xBlkExt_get_begin_connector [lindex $xblk $a 0] 3]]]
		
		lset domv $a 1 0 [createDomStr [list [lindex $conl $a 1 0] [lindex $conl $a 2 0] [lindex $conv $c 1 2] [xBlkExt_get_end_connector   [lindex $xblk $a 0] 3]]]
	}
	method rim_domain_hex_1 { a x y z } {
		#global PT PL R r t d e steps con conl conv dom domv blk dim
		set b [expr $a + 2]
		set c [expr $a + 4]
		
		set coor [coordinates $x $y $z]
		
		# hex
		
		#puts "a=$a a_end=$a_end"
		if {$a==2 || $a==3 || $a==$a_end || $a==($a_end+1)} {
			set i [expr (($x==1)?2:0)]
			set j [expr (($y==0)?2:4)]
			set k [expr [a_to_grid_z $a]]
			
			set tmpdom [lindex $grid_doms 2 $i $j $k]
			#puts "tmpdom=$tmpdom"			
			
			lset domv $a 1 3 $tmpdom
			if {$tmpdom==0 || [llength $tmpdom]==0} {
				puts "i j k $i $j $k"
				error "augh!!"
			}
		} else {
			lset domv $a 1 3 [createDomStr [list [lindex $conl $a 1 3] [lindex $conl $a 2 3] [lindex $conv $a 1 2] [lindex $conv $a 1 3]]]
		}
	}
	method rim_domain_hex_2 { a x y z } {
		#global PT PL R r t d e steps con conl conv dom domv blk dim
		set b [expr $a + 2]
		set c [expr $a + 4]
		
		set coor [coordinates $x $y $z]
	
		# hex
		lset domv $a 1 4 [createDomStr [list [lindex $conl $a 1 4] [lindex $conl $a 2 4] [lindex $conv $a 1 3] [lindex $conv $b 1 3]]]
	}
	method rim_pair { a x z } {
		#global PT PL R r t con conv con_outer_x con_outer_x_pair dom dom_inner dom_outer blk xblk blk_inner dimv
		
		set coor0 [coordinates $x 0 $z]
		set coor1 [coordinates $x 1 $z]
		
		set b [expr $a + 1]
		
		rim $a $x 0 $z
		rim $b $x 1 $z
		
		lset conv $a 3 11 [createTwoPtLineCon [xyz $coor0 0 3  2] [xyz $coor1 0 3  2] [lindex $dimv 3]]
		lset conv $a 3 12 [createTwoPtLineCon [xyz $coor0 0 3  3] [xyz $coor1 0 3  3] [lindex $dimv 3]]
		lset conv $a 3 13 [createTwoPtLineCon [xyz $coor0 0 3  5] [xyz $coor1 0 3  5] [lindex $dimv 3]]
		lset conv $a 3 14 [createTwoPtLineCon [xyz $coor0 0 3  6] [xyz $coor1 0 3  6] [lindex $dimv 3]]
	
	
		lset conv $a 2  2 [createTwoPtLineCon [xyz $coor0 0 2  8] [xyz $coor1 0 2  8] [lindex $dimv 2]]
		lset conv $a 2  3 [createTwoPtLineCon [xyz $coor0 1 2  8] [xyz $coor1 1 2  8] [lindex $dimv 2]]
		
		set tmp_xblk_a [lindex $xblk $a 0]
		set tmp_xblk_b [lindex $xblk $b 0]
		
		#puts "tmp_xblk_a=$tmp_xblk_a"
		#puts "tmp_xblk_b=$tmp_xblk_b"
		
		lset dom $a  7 [createDomStr [list [xBlkExt_get_side_connector [lindex $xblk $a 0] 0] [xBlkExt_get_side_connector [lindex $xblk $b 0] 0] [lindex $conv $a 3 12] [lindex $conv $a 3 13]]]
		lset dom $a  8 [createDomStr [list [xBlkExt_get_side_connector [lindex $xblk $a 0] 1] [xBlkExt_get_side_connector [lindex $xblk $b 0] 1] [lindex $conv $a 3 11] [lindex $conv $a 3 14]]]
	
		lset dom $a  9 [createDomStr [list [lindex $conv $a 3 11] [lindex $conv $a 3 12] [xBlkExt_get_end_connector $tmp_xblk_a 1] [xBlkExt_get_end_connector $tmp_xblk_b 1]]]
		lset dom $a 10 [createDomStr [list [lindex $conv $a 3 13] [lindex $conv $a 3 14] [xBlkExt_get_begin_connector $tmp_xblk_a 1] [xBlkExt_get_begin_connector $tmp_xblk_b 1]]]
		
		lset blk $a  1 [create_block_structured [list {*}[lrange [lindex $dom $a] 7 10] [xBlkExt_get_side_domain $tmp_xblk_a 1] [xBlkExt_get_side_domain $tmp_xblk_b 1]]]
	
		# reference
		lset con_outer_x_pair $a [list {*}[lindex $con_outer_x $a] {*}[lindex $con_outer_x $b] [lindex $conv $a 3 12] [lindex $conv $a 3 13]]
		#puts [lindex $con_outer_x_pair $a]
		
		lappend_dom_inner [lindex $dom $a 8]
		lappend_dom_outer [lindex $dom $a 7]
		
		lappend blk_inner [lindex $blk $a 1]
	}
	method rim_domain_pair {a x z} {
		#global conv conl con_outer_x con_outer_x_pair dom dom_inner dom_outer xblk
		set b [expr $a + 1]
		set d [expr $a + 4]
		set e [expr $a + 5]
		
		rim_domain $a $x 0 $z
		rim_domain $b $x 1 $z
		rim_domain_hex_1 $a $x 0 $z
		rim_domain_hex_1 $b $x 1 $z
		rim_domain_hex_2 $a $x 0 $z
		rim_domain_hex_2 $b $x 1 $z
		
		# domains
		set tmp [list]
		lappend tmp [xBlkExt_get_begin_connector [lindex $xblk $a 0] 2]
		lappend tmp [lindex $conl $a 2 2]
		lappend tmp [xBlkExt_get_begin_connector [lindex $xblk $b 0] 2]
		lappend tmp [lindex $conl $b 2 2]
	
		lappend tmp [lindex $conv $a 2  2]
		lappend tmp [lindex $conv $a 3 14]
	
		lset dom $a 11 [createDomUnstr $tmp]
		
		set tmp [list]
		lappend tmp [xBlkExt_get_end_connector [lindex $xblk $a 0] 2]
		lappend tmp [lindex $conl $a 2 0]
		lappend tmp [xBlkExt_get_end_connector [lindex $xblk $b 0] 2]
		lappend tmp [lindex $conl $b 2 0]
	
		lappend tmp [lindex $conv $d 2  2]
		lappend tmp [lindex $conv $a 3 11]
	
		lset dom $a 12 [createDomUnstr $tmp]
		
		# x domain
		set tmp [list]
		lappend tmp [lindex $conv $d 0 2]
		lappend tmp [lindex $conv $e 0 2]
		lset con_outer_x_pair $a [list {*}[lindex $con_outer_x_pair $a] {*}$tmp]
	
		set tmp_dom3 [createDomUnstr [lindex $con_outer_x_pair $a]]
		
		# reference
		lappend_dom_inner [lindex $dom $a 11]
		lappend_dom_inner [lindex $dom $a 12]
		
		lappend_dom_outer $tmp_dom3
		
	}
	method rim_domain_extra_pair { a x z } {
		set b [expr $a + 1]
		set c [expr $a + 2]
		set d [expr $a + 3]
		
		rim_domain_hex_1 $a $x 0 $z
		rim_domain_hex_1 $b $x 1 $z
		rim_domain_hex_2 $a $x 0 $z
		rim_domain_hex_2 $b $x 1 $z
		
		rim_domain_hex_1 $c [expr ($x+1)%2] 0 $z
		rim_domain_hex_1 $d [expr ($x+1)%2] 1 $z
	}
	method rim_extra_pair {a x z} {
		#global PT PL R r t d e con conv dom blk dim dimv
		
		set b [expr $a + 1]
		set c [expr $a + 2]
		set d [expr $a + 3]
		
		#set coor [coordinates $x $y $z]
		#set X [lindex $coor 0]
		#set Y [lindex $coor 1]
		#set Z [lindex $coor 2]
		#set direction [lindex $coor 3]
		
		rim_extra $a $x 0 $z
		rim_extra $b $x 1 $z
	
		lset conv $a 2 2 [createTwoPtLineCon [[lindex $conv $a 1 2] getPosition -arc 1] [[lindex $conv $b 1 2] getPosition -arc 1] [lindex $dimv 2]]
		lset conv $a 2 3 [createTwoPtLineCon [[lindex $conv $a 1 3] getPosition -arc 1] [[lindex $conv $b 1 3] getPosition -arc 1] [lindex $dimv 2]]
		

			
		#lset conv $c 2 2 [createTwoPtLineCon [[lindex $conv $c 1 2] getPosition -arc 1] [[lindex $conv $d 1 2] getPosition -arc 1] [lindex $dimv 2]]
		#lset conv $c 2 3 [createTwoPtLineCon [[lindex $conv $c 1 3] getPosition -arc 1] [[lindex $conv $d 1 3] getPosition -arc 1] [lindex $dimv 2]]
		
		set k [a_to_grid_z $c]
		set i [expr (($x==1)?0:3)]
		lset conv $c 2 2 [lindex $grid_cons 1 $i 3 $k]
		set i [expr (($x==1)?1:2)]
		lset conv $c 2 3 [lindex $grid_cons 1 $i 3 $k]
	}
	method terminate { a x Y Z z_direction} {
		#global PT PL R r t d e con conl conv dom domv doml dom_inner dom_outer dim dimv diml con_outer_x
		#puts "terminate"
		# called for a = 0,1,e,f
		
		set coor [coordinates $x $Y $Z]
		
		if {$z_direction==1} {
			set z0  0
			set z1 20
			
			set b [expr $a + 2]
			set c [expr $a + 4]
			set d [expr $a + 2]
		} elseif {$z_direction==-1} {
			set z0  8
			set z1 30
			
			set b [expr $a - 0]
			set c [expr $a - 0]
			set d [expr $a + 2]
		} else {
			error "invalid direction"
		}
	
		#puts [xyz $coor 0 1 4]
		#puts [xyz $coor 2 1 4]
	
		set tmp_domv [lfill 0 100]
		set tmp_doml [lfill 0 100]
	
		
	
		foreach y {1 2} {	
			lset conl $a $y  5 [createTwoPtLineCon [xyz $coor   0 $y $z0] [xyz $coor   0 $y $z1] [lindex $diml  5]]
			lset conl $a $y  6 [createTwoPtLineCon [xyz $coor   0 $y $z1] [xyz $coor   0 $y   4] [lindex $diml  6]]

			#lset conl $a $y  7 [createTwoPtLineCon [xyz $coor   0 $y   4] [xyz $coor  30 $y   4] [lindex $diml  7]]
			#lset conl $a $y  8 [createTwoPtLineCon [xyz $coor  30 $y   4] [xyz $coor   2 $y   4] [lindex $diml  8]]

			set i [expr (($x==1)?2:0)]
			if {$y==2} {
				set j [expr (($Y==0)?3:4)]
			} else {
				set j [expr (($Y==0)?2:5)]
			}
			set k [expr [a_to_grid_z $a] + 1]
			lset conl $a $y 7 [lindex $grid_cons 0 $i $j $k]
			lset conl $a $y 8 [lindex $grid_cons 0 1 $j $k]


			lset conl $a $y  9 [createTwoPtLineCon [xyz $coor  20 $y $z1] [xyz $coor  30 $y   4] [lindex $diml  9]]
			lset conl $a $y 10 [createTwoPtLineCon [xyz $coor  20 $y $z1] [xyz $coor   0 $y $z1] [lindex $diml 10]]
			lset conl $a $y 11 [createTwoPtLineCon [xyz $coor  20 $y $z1] [xyz $coor   1 $y $z0] [lindex $diml 11]]
	
			# domains
			lset doml $a $y 1 [createDomStr [list [lindex $conl $a $y  5] [lindex $conl $a $y 10] [lindex $conl $a $y 11] [lindex $conl $c $y  3]]]
			lset doml $a $y 2 [createDomStr [list [lindex $conl $a $y  6] [lindex $conl $a $y  7] [lindex $conl $a $y  9] [lindex $conl $a $y 10]]]
			lset doml $a $y 3 [createDomStr [list [lindex $conl $a $y  8] [lindex $conl $a $y  9] [lindex $conl $a $y 11] [lindex $conl $b $y  4]]]
	
		}
		

		lset conl $a 0 13 [createTwoPtLineCon [xyz $coor 0 0 4] [xyz $coor 0 0 $z0] [lindex $diml 13]]
		
		# vertical
		#lset conv $a 1  7 [createTwoPtLineCon [xyz $coor  0 1   4] [xyz $coor  0 2   4] [lindex $dim 1]]
		#lset conv $a 1  8 [createTwoPtLineCon [xyz $coor 30 1   4] [xyz $coor 30 2   4] [lindex $dim 1]]
		set i [expr (($x==0)?0:3)]
		set j [expr (($Y==0)?2:4)]
		set k [expr (($a<=1)?1:(2*$n+2))]
		lset conv $a 1 7 [lindex $grid_cons 1 $i $j $k]
		set i [expr (($x==0)?1:2)]
		lset conv $a 1 8 [lindex $grid_cons 1 $i $j $k]
	

	
		lset conv $a 1  9 [createTwoPtLineCon [xyz $coor 20 1 $z1] [xyz $coor 20 2 $z1] [lindex $dim 1]]
		lset conv $a 1 10 [createTwoPtLineCon [xyz $coor  0 1 $z1] [xyz $coor  0 2 $z1] [lindex $dim 1]]
		
		# extension
		#lset conv $a 0 7 [createTwoPtLineCon [xyz $coor  0 0   4] [xyz $coor  0 1   4] [lindex $dimv 0]]
		set i [expr (($x==1)?3:0)]
		set j [expr (($Y==0)?1:5)]
		set k [expr (($a<=1)?1:(2*$n+2))]
		lset conv $a 0 7 [lindex $grid_cons 1 $i $j $k]
		
		# vertical domains
		lset domv $a 1  5 [createDomStr [list [lindex $conl $a 1  5] [lindex $conl $a 2  5] [lindex $conv $a 1 10] [lindex $conv $c 1  2]]]
		lset domv $a 1  6 [createDomStr [list [lindex $conl $a 1  6] [lindex $conl $a 2  6] [lindex $conv $a 1  7] [lindex $conv $a 1 10]]]





		#lset domv $a 1  7 [createDomStr [list [lindex $conl $a 1  7] [lindex $conl $a 2  7] [lindex $conv $a 1  7] [lindex $conv $a 1  8]]]
		#lset domv $a 1  8 [createDomStr [list [lindex $conl $a 1  8] [lindex $conl $a 2  8] [lindex $conv $a 1  8] [lindex $conv $d 1  3]]]
		
		lset domv $a 0 13 [createDomStr [list [lindex $conl $a 0 13] [lindex $conl $a 1  5] [lindex $conl $a 1  6] [lindex $conv $a 0 7] [lindex $conv $c 0 2]]]
		


		
		set i [expr (($x==1)?2:0)]
		set j [expr (($Y==0)?2:4)]
		set k [expr [a_to_grid_z $a] + 1]
		lset domv $a 1 7 [lindex $grid_doms 2 $i $j $k]
		lset domv $a 1 8 [lindex $grid_doms 2 1 $j $k]

		set i [expr (($x==1)?2:0)]
		set j [expr (($Y==0)?1:5)]
		set k [expr [a_to_grid_z $a] + 1]
		lset domv $a 0 7 [lindex $grid_doms 2 $i $j $k]
		lset domv $a 0 8 [lindex $grid_doms 2 2 $j $k]





		lset domv $a 1  9 [createDomStr [list [lindex $conl $a 1  9] [lindex $conl $a 2  9] [lindex $conv $a 1  8] [lindex $conv $a 1  9]]]
		lset domv $a 1 10 [createDomStr [list [lindex $conl $a 1 10] [lindex $conl $a 2 10] [lindex $conv $a 1  9] [lindex $conv $a 1 10]]]
		lset domv $a 1 11 [createDomStr [list [lindex $conl $a 1 11] [lindex $conl $a 2 11] [lindex $conv $a 1  9] [lindex $conv $c 1  3]]]
		
		
		# reference
		lset con_outer_x $a [list [lindex $conl $a 1 5] [lindex $conl $a 1 6]]
		#puts [lindex $con_outer_x $a]
		
		lappend_dom_inner [lindex $doml $a 2  1]
		lappend_dom_inner [lindex $doml $a 2  2]
		lappend_dom_inner [lindex $doml $a 2  3]
		
		lappend_dom_outer [lindex $doml $a 1  1]
		lappend_dom_outer [lindex $doml $a 1  2]
		lappend_dom_outer [lindex $doml $a 1  3]
		lappend_dom_outer [lindex $domv $a 0 13]
	}
	method terminate_block { a x Y Z direction } {
		#global PT PL R r t d e con conl dom domv doml blkl blk_inner dim
		puts "terminate"
		
		set coor [coordinates $x $Y $Z]
		
		if {$direction==1} {
			set z0  0
			set z1 20
			
			set b [expr $a + 2]
			set c [expr $a + 4]
			set d [expr $a + 2]
		} elseif {$direction==-1} {
			set z0  8
			set z1 30
			
			set b [expr $a - 0]
			set c [expr $a - 0]
			set d [expr $a + 2]
		} else {
			error "invalid direction"
		}
		
		# blocks
		lset blkl $a 1 1 [create_block_structured [list [lindex $domv $a 1 5] [lindex $domv $a 1 10] [lindex $domv $a 1 11] [lindex $domv $c 1  3] [lindex $doml $a 1 1] [lindex $doml $a 2 1]]]
		
		
		lset blkl $a 1 2 [create_block_structured [list [lindex $domv $a 1 6] [lindex $domv $a 1  7] [lindex $domv $a 1  9] [lindex $domv $a 1 10] [lindex $doml $a 1 2] [lindex $doml $a 2 2]]]
		lset blkl $a 1 3 [create_block_structured [list [lindex $domv $a 1 8] [lindex $domv $a 1  9] [lindex $domv $a 1 11] [lindex $domv $b 1  4] [lindex $doml $a 1 3] [lindex $doml $a 2 3]]]
		
		# reference
		lappend blk_inner {*}[lrange [lindex $blkl $a 1] 1 3]
	}
	method terminate_pair { a x z direction } {
		#global conl conv con_outer_x con_outer_x_pair domv dom_inner dimv
		set b [expr $a + 1]
		
		if {$direction==1} {
			set c [expr $a + 2]
			set d [expr $a + 4]
			set e [expr $a + 2]
		} elseif {$direction==-1} {
			set c [expr $a + 0]
			set d [expr $a + 0]
			set e [expr $a + 2]
		} else {
			error "invalid direction"
		}
		
		terminate $a $x 0 $z $direction
		terminate $b $x 1 $z $direction
		
		set coor0 [coordinates $x 0 $z]
		set coor1 [coordinates $x 1 $z]
	
		
		#lset conv $a 2 7 [createTwoPtLineCon [xyz $coor0 0 2 4] [xyz $coor1 0 2 4] [lindex $dimv 2]]
		set i [expr (($x==0)?0:3)]
		set k [expr [a_to_grid_z $a] + 1]
		lset conv $a 2 7 [lindex $grid_cons 1 $i 3 $k]
	
		lset con_outer_x_pair $a [list {*}[lindex $con_outer_x $a] {*}[lindex $con_outer_x $b]]
		
		# domains
		lset domv $a 2 13 [createDomStr [list [lindex $conl $a 2 5] [lindex $conl $a 2 6] [lindex $conl $b 2 5] [lindex $conl $b 2 6] [lindex $conv $a 2 7] [lindex $conv $d 2 2]]]
		
		
		#lset domv $a 2 14 [createDomStr [list [lindex $conl $a 2 7] [lindex $conl $a 2 8] [lindex $conl $b 2 7] [lindex $conl $b 2 8] [lindex $conv $a 2 7] [lindex $conv $e 2 3]]]
		
		set i [expr (($x==1)?2:0)]
		set k [expr [a_to_grid_z $a] + 1]
		lset domv $a 2 7 [lindex $grid_doms 2 $i 3 $k]
		lset domv $a 2 8 [lindex $grid_doms 2 1 3 $k]
		
		# reference
		lappend_dom_inner [lindex $domv $a 2 13]
		lappend_dom_inner [lindex $domv $a 2 7]
		lappend_dom_inner [lindex $domv $a 2 8]
	}
	method terminate_block_pair { a x z direction } {
		set b [expr $a + 1]
		terminate_block $a $x 0 $z $direction	
		terminate_block $b $x 1 $z $direction
	}
	method patch { a } {
		#global con conl conv doml dom_inner dom_outer xblk
		
		set b [expr $a + 2]
		set c [expr $a + 4]
		
		set tmp_xblk_a [lindex $xblk $a 0]
		
		set cons [list]
		# hex
		lappend cons [lindex $conl $a 1 3]
		lappend cons [lindex $conl $a 1 4]
		lappend cons [lindex $conl $b 1 4]
		lappend cons [lindex $conl $c 1 3]
		# arc
		lappend cons [xBlkExt_get_side_connector $tmp_xblk_a 3]
		# spoke
		lappend cons [lindex $conl $a 1 2]
		lappend cons [lindex $conl $a 1 0]
		
		lset doml $a 1 0 [createDomStr $cons]
		
		set cons [list]
		# hex
		lappend cons [lindex $conl $a 2 3]
		lappend cons [lindex $conl $a 2 4]
		lappend cons [lindex $conl $b 2 4]
		lappend cons [lindex $conl $c 2 3]
		# arc
		lappend cons [xBlkExt_get_side_connector $tmp_xblk_a 2]
		# spoke
		lappend cons [lindex $conl $a 2 2]
		lappend cons [lindex $conl $a 2 0]
		
		lset doml $a 2 0 [createDomStr $cons]
	
		# reference
		lappend_dom_inner [lindex $doml $a 2 0]
		lappend_dom_outer [lindex $doml $a 1 0]
	}
	method patch_blk { a } {
		#global con conl domv doml blkl xblk blk_inner
		
		set b [expr $a + 2]
		set c [expr $a + 4]
	
		set tmp_dom [list]
		lappend tmp_dom [lindex $doml $a 1 0]
		lappend tmp_dom [lindex $doml $a 2 0]
		lappend tmp_dom [lindex $domv $a 1 0]
		lappend tmp_dom [xBlkExt_get_side_domain [lindex $xblk $a 0] 3]
		lappend tmp_dom [lindex $domv $a 1 2]

		lappend tmp_dom [lindex $domv $a 1 3]

		lappend tmp_dom [lindex $domv $a 1 4]
		lappend tmp_dom [lindex $domv $b 1 4]
		lappend tmp_dom [lindex $domv $c 1 3]
	
		lset blkl $a 1 0 [create_block_structured $tmp_dom]
		
		# reference
		lappend blk_inner [lindex $blkl $a 1 0]
	}
	method exten { a x y z } {
		#global PT PL R r t d e steps con conl conv dom domv blk dim
	
		set c [expr $a + 4]
		
		set coor [coordinates $x $y $z]
		set direction [lindex $coor 3]
	
		#lset conv $a 0 2 [createTwoPtLineCon [xyz $coor 0 0 8] [xyz $coor 0 1 8] 10]
		
		
		lset conv $a 0 2 [lindex $grid_cons 1 
	}
	method rim_domain_pair_z { a } {
		#global conl conv domv dom_inner
		
		set b [expr $a + 1]
		
		if { $a==2 || $a==$a_end } {
			set i [expr ((($a%4)==0)?2:0)]
			set k [a_to_grid_z $a]
			lset domv $a 2 3 [lindex $grid_doms 2 $i 3 $k]
			
		} else {
			lset domv $a 2 3 [createDomStr [list [lindex $conl $a 2 3] [lindex $conl $b 2 3] [lindex $conv $a 2 2] [lindex $conv $a 2 3]]]
		}
		
		
		lappend_dom_inner [lindex $domv $a 2 3]
	}
	method scal { s } {
		#global dimy_m dimy_p dimz_m dimz_p dim dimv diml Z_space var_space steps_sixth
		
		set dim    [lceil [lscale $dim    $s]]
		set dimv   [lceil [lscale $dimv   $s]]
		set diml   [lceil [lscale $diml   $s]]
		set dimy_m [lceil [lscale $dimy_m $s]]
		set dimy_p [lceil [lscale $dimy_p $s]]
		set dimz_m [lceil [lscale $dimz_m $s]]
		set dimz_p [lceil [lscale $dimz_p $s]]
		
		set Z_space   [lscale $Z_space   [expr 1.0/$s]]
		set var_space [lscale $var_space [expr 1.0/$s]]
		
		puts "steps_sixth=$steps_sixth"
		set steps_sixth [expr ceil( $steps_sixth * $s )]
		
	}
	method create_grid {} {
		set H [expr $gap]
		
		#set X [list 0 $PT]
		set X [lcumsum [list $var_d [expr $PT - 2 * $var_d] $var_d]]
		
		# set Y [lcumsum [list $y_m $h $H $h $y_p] -$y_m]
		set Y [lcumsum [list $y_m $h $t [expr $H - 2 * $t] $t $h $y_p] -$y_m]
		
		#set Z [list [expr 0.5 * $PL - $z_m] [expr 0.5 * $PL] [expr $z*$PL] [expr $PL*$z + $z_p]]
		#set Z [lcumsum [list $z_m [expr ($z - 0.5) * $PL] $z_p] [expr 0.5 * $PL - $z_m]]
		set Z_interior [lfill [expr ($PL * 0.5)] [expr (2 * $n) + 1]]
		set Z [lcumsum [list $z_m {*}$Z_interior $z_p] [expr 0.5 * $PL - $z_m]]
		
		set coor [list $X $Y $Z]
	
		set grid_dim {0 0 0}
			
		lset grid_dim 0 [list [lindex $diml 7] [lindex $diml 8] [lindex $diml 7]]

		lset grid_dim 1 [list $dimy_m [lindex $dimv 0] [lindex $dim 1] [lindex $dimv 2] [lindex $dim 1] [lindex $dimv 0] $dimy_p]

		set Z_dim_interior [lfill [lindex $diml 13] [expr (2 * $n) + 1]]
		lset grid_dim 2 [list $dimz_m {*}$Z_dim_interior $dimz_p]
		
		# spacing	
		set X_space [lfill {0 0} 1]
		set Y_space [lfill {0 0} 5]
		
		set space [list $X_space $Y_space $Z_space]
		
		set ignores [list [list {-1 3} {1 5} [list 1 [expr (2 * $n) + 1]]]]
		
		Grid $grid $X $Y $Z $grid_dim
		$grid configure -ignores $ignores
		$grid configure -flag_ignore_conn {1 1 1}
		$grid run

		set grid_cons [$grid cget -cons]
		set grid_doms [$grid cget -doms]

	}
	method make_grid { z tmpc c d e f tmp_dom } {
		puts "make grid"
		error "hello"
		#global PL PT R h y_m y_p z_m z_p dimy_m dimy_p dimz_m dimz_p con conv conl dom doml domv blk blkl xblk dim dimv diml
		#global dom_inner dom_outer blk_inner blk_outer Z_space n pairs_xm_fluid pairs_xp_fluid
		
		set o [expr $n * 4]
		
		# 8 9
		set c [expr $o + 4]
		set d [expr $o + 4 + 1]
	
		
		#set grid_output [grid $X $Y $Z $dim $space 0 ]
		
		#round 1
		#create_grid
		
		# round 2
		#set grid_cons [$grid lindex $grid_output 1]
		
		
		#lset grid_cons 0 0 1 1 [lindex $tmpc 4]
		#lset grid_cons 0 0 4 1 [lindex $tmpc 5]
		#lset grid_cons 0 0 1 2 [lindex $tmpc 6]
		#lset grid_cons 0 0 4 2 [lindex $tmpc 7]
		
		lset grid_cons 1 0 1 1 [lindex $conv  2 0 2]
		lset grid_cons 1 0 3 1 [lindex $conv  3 0 2]
		#lset grid_cons 1 1 1 1 [lindex $conv  0 0 7]
		#lset grid_cons 1 1 3 1 [lindex $conv  1 0 7]
		
		#lset grid_cons 1 0 1 2 [lindex $conv $e 0 7]
		#lset grid_cons 1 0 3 2 [lindex $conv $f 0 7]
		#lset grid_cons 1 1 1 2 [lindex $conv $c 0 2]
		#lset grid_cons 1 1 3 2 [lindex $conv $d 0 2]
		
		set grid_output [grid_domains_and_blocks [lindex $grid_output 0] $cons [lindex $grid_output 2] [lindex $grid_output 3]]
		
		# round 3
		
		#set grid_cons [lindex $grid_output 1]
		#set doms [lindex $grid_output 2]
		
		lset doms 1 0 2 0 [createDomStr [list [lindex $grid_cons 0 0 2 0] [lindex $grid_cons 2 0 2 0] [lindex $grid_cons 2 1 2 0] [lindex $conl 0 1 7] [lindex $conl 0 1 8] [lindex $conl 2 1 3]]]
		lset doms 1 0 3 0 [createDomStr [list [lindex $grid_cons 0 0 3 0] [lindex $grid_cons 2 0 3 0] [lindex $grid_cons 2 1 3 0] [lindex $conl 1 1 7] [lindex $conl 1 1 8] [lindex $conl 3 1 3]]]
		
		lset doms 1 0 2 2 [createDomStr [list [lindex $grid_cons 0 0 2 3] [lindex $grid_cons 2 0 2 2] [lindex $grid_cons 2 1 2 2] [lindex $conl $e 1 7] [lindex $conl $e 1 8] [lindex $conl $c 1 3]]]
		lset doms 1 0 3 2 [createDomStr [list [lindex $grid_cons 0 0 3 3] [lindex $grid_cons 2 0 3 2] [lindex $grid_cons 2 1 3 2] [lindex $conl $f 1 7] [lindex $conl $f 1 8] [lindex $conl $d 1 3]]]
		
		lset doms 1 0 1 1 [lindex $tmp_dom 6]
		lset doms 1 0 4 1 [lindex $tmp_dom 7]
		
		lset doms 2 0 1 1 [lindex $tmp_dom 2]
		lset doms 2 0 3 1 [lindex $tmp_dom 3]
		lset doms 2 0 1 2 [lindex $tmp_dom 4]
		lset doms 2 0 3 2 [lindex $tmp_dom 5]
		
		
		set tmp0 [list]
		set tmp1 [list]
		set tmp2 [list]
		set tmp3 [list]
		
		foreach a [range 0 $n] {
			# 2 6 10...
			set t0 [expr $a * 4 + 2]
			# 4 8 12...
			set u0 [expr $t0 + 2]
			# 3 7 11...
			set t1 [expr $t0 + 1]
			# 5 8 13...
			set u1 [expr $u0 + 1]
			
			lappend tmp0 [lindex $conl $t0 0 12]
			lappend tmp2 [lindex $conl $t1 0 12]
			
			lappend tmp1 [lindex $conl $u0 0 12]
			lappend tmp3 [lindex $conl $u1 0 12]
		}
		lappend tmp0 [lindex $conl $e 0 13]
		lappend tmp2 [lindex $conl $f 0 13]
		
		lappend tmp0 [lindex $cons 1 0 0 1]
		lappend tmp0 [lindex $cons 1 0 0 2]
		lappend tmp0 [lindex $cons 2 0 0 1]
		
		lappend tmp2 [lindex $cons 1 0 4 1]
		lappend tmp2 [lindex $cons 1 0 4 2]
		lappend tmp2 [lindex $cons 2 0 5 1]
		
		
		lappend tmp1 [lindex $conl  0 0 13]
		lappend tmp3 [lindex $conl  1 0 13]
		
		lappend tmp1 [lindex $cons 1 1 0 1]
		lappend tmp1 [lindex $cons 1 1 0 2]
		lappend tmp1 [lindex $cons 2 1 0 1]
		
		lappend tmp3 [lindex $cons 1 1 4 1]
		lappend tmp3 [lindex $cons 1 1 4 2]
		lappend tmp3 [lindex $cons 2 1 5 1]
		
		
		lset doms 0 0 0 1 [createDomStr $tmp0]
		lset doms 0 1 0 1 [createDomStr $tmp1]
		lset doms 0 0 4 1 [createDomStr $tmp2]
		lset doms 0 1 4 1 [createDomStr $tmp3]
		
		
		set grid_output [grid_domains_and_blocks [lindex $grid_output 0] $cons $doms [lindex $grid_output 3]]
		
		# manual
		
		set cons   [lindex $grid_output 1]
		set doms   [lindex $grid_output 2]
		set blocks [lindex $grid_output 3]
		
		lset doms 0 0 2 0 [createDomStr [list [lindex $cons 1 0 2 0] [lindex $cons 2 0 2 0] [lindex $cons 2 0 3 0] [lindex $conv 2 1 2] [lindex $conv 3 1 2] [lindex $conv 2 2 2]]]
		lset doms 0 1 2 0 [createDomStr [list [lindex $cons 1 1 2 0] [lindex $cons 2 1 2 0] [lindex $cons 2 1 3 0] [lindex $conv 0 1 7] [lindex $conv 1 1 7] [lindex $conv 0 2 7]]]
		
		lset doms 0 0 2 2 [createDomStr [list [lindex $cons 1 0 2 3] [lindex $cons 2 0 2 2] [lindex $cons 2 0 3 2] [lindex $conv $e 1 7] [lindex $conv $f 1 7] [lindex $conv $e 2 7]]]
		lset doms 0 1 2 2 [createDomStr [list [lindex $cons 1 1 2 3] [lindex $cons 2 1 2 2] [lindex $cons 2 1 3 2] [lindex $conv $c 1 2] [lindex $conv $d 1 2] [lindex $conv $c 2 2]]]
		
		# manual block
		set tmp [list]
		lappend tmp [lindex $doms 0 0 2 0]
		lappend tmp [lindex $doms 0 1 2 0]
		lappend tmp [lindex $doms 1 0 2 0]
		lappend tmp [lindex $doms 1 0 3 0]
		lappend tmp [lindex $doms 2 0 2 0]
		
		lappend tmp [lindex $domv 0 1 7]
		lappend tmp [lindex $domv 0 1 8]
		lappend tmp [lindex $domv 2 1 3]
		
		lappend tmp [lindex $domv 1 1 7]
		lappend tmp [lindex $domv 1 1 8]
		lappend tmp [lindex $domv 3 1 3]
		
		lappend tmp [lindex $domv 0 2 14]
		lappend tmp [lindex $domv 2 2  3]
		
		lset blocks 0 2 0 [create_block_structured $tmp]
		
		set tmp [list]
		lappend tmp [lindex $doms 0 0 2 2]
		lappend tmp [lindex $doms 0 1 2 2]
		lappend tmp [lindex $doms 1 0 2 2]
		lappend tmp [lindex $doms 1 0 3 2]
		lappend tmp [lindex $doms 2 0 2 3]
		
		lappend tmp [lindex $domv $e 1 7]
		lappend tmp [lindex $domv $e 1 8]
		lappend tmp [lindex $domv $c 1 3]
		
		lappend tmp [lindex $domv $f 1 7]
		lappend tmp [lindex $domv $f 1 8]
		lappend tmp [lindex $domv $d 1 3]
		
		lappend tmp [lindex $domv $e 2 14]
		lappend tmp [lindex $domv $c 2  3]
		
		lset blocks 0 2 2 [create_block_structured $tmp]
	
		# --------------------------------------
		
		lappend pairs_xm_fluid [list [lindex $blocks 0 2 0] [lindex $doms 0 0 2 0]]
		lappend pairs_xm_fluid [list [lindex $blocks 0 3 0] [lindex $doms 0 0 3 0]]
		lappend pairs_xm_fluid [list [lindex $blocks 0 4 0] [lindex $doms 0 0 4 0]]
		lappend pairs_xm_fluid [list [lindex $blocks 0 2 2] [lindex $doms 0 0 2 2]]
		lappend pairs_xm_fluid [list [lindex $blocks 0 3 2] [lindex $doms 0 0 3 2]]
		lappend pairs_xm_fluid [list [lindex $blocks 0 4 2] [lindex $doms 0 0 4 2]]
		
		lappend pairs_xp_fluid [list [lindex $blocks 0 2 0] [lindex $doms 0 1 2 0]]
		lappend pairs_xp_fluid [list [lindex $blocks 0 3 0] [lindex $doms 0 1 3 0]]
		lappend pairs_xp_fluid [list [lindex $blocks 0 4 0] [lindex $doms 0 1 4 0]]
		lappend pairs_xp_fluid [list [lindex $blocks 0 2 2] [lindex $doms 0 1 2 2]]
		lappend pairs_xp_fluid [list [lindex $blocks 0 3 2] [lindex $doms 0 1 3 2]]
		lappend pairs_xp_fluid [list [lindex $blocks 0 4 2] [lindex $doms 0 1 4 2]]
	
		# ------------------------------
		
		lappend pairs_sym [list [lindex $blocks 0 2 2] [lindex $doms 2 0 2 3]]
		lappend pairs_sym [list [lindex $blocks 0 3 2] [lindex $doms 2 0 3 3]]
		lappend pairs_sym [list [lindex $blocks 0 4 2] [lindex $doms 2 0 4 3]]
	
		# -----------------------------
		
		lappend pairs_sym {*}$pairs_xm_fluid
		lappend pairs_sym {*}$pairs_xp_fluid
		
		# --------------------------------------------
			
		createBC "symetry" Symmetry $pairs_sym
		
		set pairs_inlet  [list [list [lindex $blocks 0 4 0] [lindex $doms 1 0 5 0]]]
		set pairs_outlet [list [list [lindex $blocks 0 4 2] [lindex $doms 1 0 5 2]]]
		
		lappend pairs_heated [list [lindex $blocks 0 0 0] [lindex $doms 1 0 0 0]]
		lappend pairs_heated [list [lindex $blocks 0 0 1] [lindex $doms 1 0 0 1]]
		lappend pairs_heated [list [lindex $blocks 0 0 2] [lindex $doms 1 0 0 2]]
	
		createBC "inlet"  {Velocity Inlet}  $pairs_inlet
		createBC "outlet" {Pressure Outlet} $pairs_outlet
	
		createBC "heated" Wall $pairs_heated
		
		# -------------------------------------
	
		lappend blk_fluid {*}$blk_inner
		
		lappend blk_fluid [lindex $blocks 0 2 0]
		lappend blk_fluid [lindex $blocks 0 3 0]
		lappend blk_fluid [lindex $blocks 0 4 0]
		lappend blk_fluid [lindex $blocks 0 2 2]
		lappend blk_fluid [lindex $blocks 0 3 2]
		lappend blk_fluid [lindex $blocks 0 4 2]
	
		lappend blk_solid {*}$blk_outer
	
		lappend blk_solid [lindex $blocks 0 0 0]
		lappend blk_solid [lindex $blocks 0 0 1]
		lappend blk_solid [lindex $blocks 0 0 2]
		lappend blk_solid [lindex $blocks 0 1 0]
		lappend blk_solid [lindex $blocks 0 1 2]
		lappend blk_solid [lindex $blocks 0 4 1]
	
		
		createVC "fluid" Solid $blk_fluid
		createVC "solid" Solid $blk_solid
	
	}	
	method main {} {
		set gap [expr $PL - 2 * $R]
		
		set var_d  [expr ( $PL / 2 ) / sqrt(3) ]
	
		scal $var_scale
		
		set steps [expr round($steps_sixth * 6)]
		puts "steps = $steps"
		
		# ------------------------------------------------------------------------
		# calculate dims
		lset dim   2 [lindex $dim   0]
		lset dim   3 [lindex $dim   1]
		
		lset diml  2 [lindex $diml  0]
		lset diml  3 [expr ( $steps / 6 ) + 1]
		lset diml  4 [expr ( $steps / 3 ) + 1]
		lset diml  6 [lindex $diml  4]
		lset diml  7 [lindex $diml  3]
		lset diml  8 [lindex $diml  5]
		lset diml  9 [lindex $diml  4]
		lset diml 10 [lindex $diml  3]
		lset diml 11 [lindex $diml  5]
		
		lset diml 13 [expr [lindex $diml 5] + [lindex $diml 6] - 1]
		lset diml 15 [expr [lindex $diml 3] + [lindex $diml 7] + [lindex $diml 8] - 2]
		
		# ----------------------------------------------------------
		
		set o [expr $n * 4]
		
		# 8 9
		set c [expr $o + 4]
		set a_end [expr $o + 4]
		set d [expr $o + 4 + 1]
		# 6 7
		set e [expr $o + 2]
		set f [expr $o + 2 + 1]
		
		set z [expr $n + 1.0]
		
		puts "c = $c"
		puts "d = $d"
		puts "e = $e"
		puts "f = $f"
		
		puts "n = $n"
		puts "o = $o"
		puts "z = $z"
		
		# -----------------------------------------------------------
		# run
		# -----------------------------------------------------------


		create_grid
	

		puts "rim pair ------------------------"
		foreach a [range 0 $n] {
			set t0 [expr $a * 4]
			
			rim_pair [expr 2 + $t0] 0 [expr $a + 1.0 ]
			rim_pair [expr 4 + $t0] 1 [expr $a + 1.5 ]
		}
		
		puts "rim extra pair-------------------"
		rim_extra_pair [expr $o + 2] 0 [expr $n + 1.0]
		
		puts "terminate------------------------"
		
		# terminate
		terminate_pair  0 1 0.5  1
		terminate_pair $e 0  $z -1
		
		# rim domain
		foreach a [range 0 $n] {
			set t0 [expr $a * 4]
			
			rim_domain_pair [expr 2 + $t0] 0 [expr $a + 1.0]
			rim_domain_pair [expr 4 + $t0] 1 [expr $a + 1.5]
		}
		
		rim_domain_extra_pair $e 0 [expr $n + 1.0]
		
		# terminate block
		terminate_block_pair  0 1 0.5  1
		terminate_block_pair $e 0  $z -1
		
		foreach a [range 0 $n] {
			set b [expr $a*4]
		
			patch [expr $b + 2]
			patch [expr $b + 3]
			patch [expr $b + 4]
			patch [expr $b + 5]
		}
		foreach a [range 0 $n] {
			set b [expr $a*4]
		
			patch_blk [expr $b + 2]
			patch_blk [expr $b + 3]
			patch_blk [expr $b + 4]
			patch_blk [expr $b + 5]
		}
		
		#exten 2 0 0 1.0
		#exten 3 0 1 1.0
		#exten $c 1 0 [expr $z + 0.5]
		#exten $d 1 1 [expr $z + 0.5]
		
		
		set tmpc [lfill 0 10]
		
		
		#foreach y {0 1} {
			#lset tmpc [expr 4 + $y] [createTwoPtLineCon [[lindex $conv [expr  0 + $y] 0 7] getPosition -arc 0] [[lindex $conv [expr  2 + $y] 0 2] getPosition -arc 0] [lindex $diml 15]]
			#lset tmpc [expr 6 + $y] [createTwoPtLineCon [[lindex $conv [expr $c + $y] 0 2] getPosition -arc 0] [[lindex $conv [expr $e + $y] 0 7] getPosition -arc 0] [lindex $diml 15]]
		#}
		


		
		# z domain
		
		rim_domain_pair_z 2
		rim_domain_pair_z $c
		
		foreach y {0 1} {
			set tmp [list]
			lappend tmp [lindex $conl [expr 0 + $y] 1 7]
			lappend tmp [lindex $conl [expr 0 + $y] 1 8]
			lappend tmp [lindex $conl [expr 2 + $y] 1 3]
			
			lappend tmp [lindex $conv [expr 0 + $y] 0 7]
			lappend tmp [lindex $conv [expr 2 + $y] 0 2]
			
			#lappend tmp [lindex $tmpc [expr 4 + $y]]
			
			#lset tmp_dom  [expr 2 + $y] [createDomStr $tmp]
		}
		
		foreach i {0 1 2} {
			foreach j {1 5} {
				foreach k {1 [a_to_grid_z $a_end]} {
					#lappend tmp_dom [lindex $grid_doms 2 0 1 1]
				}
			}
		}
		#puts $tmp_dom


		foreach y {0 1} {
			set tmp [list]
			lappend tmp [lindex $conl [expr $e + $y] 1 7]
			lappend tmp [lindex $conl [expr $e + $y] 1 8]
			lappend tmp [lindex $conl [expr $c + $y] 1 3]
			
			lappend tmp [lindex $conv [expr $e + $y] 0 7]
			lappend tmp [lindex $conv [expr $c + $y] 0 2]
			
			#lappend tmp [lindex $tmpc [expr 6 + $y]]
			
			#lset tmp_dom  [expr 4 + $y] [createDomStr $tmp]
		}
		
		
		# y domain
		set tmp0 [list]
		set tmp1 [list]


		foreach i {0 1 2} {
			lappend tmp0 [lindex $grid_cons 0 $i 1 1]
			lappend tmp0 [lindex $grid_cons 0 $i 1 [expr 2 * $n + 2]]
			
			lappend tmp1 [lindex $grid_cons 0 $i 6 1]	
			lappend tmp1 [lindex $grid_cons 0 $i 6 [expr 2 * $n + 2]]
		}



		foreach a [range 0 $n] {
			# 2 6 10...
			set t0 [expr $a * 4 + 2]
			# 4 8 12...
			set u0 [expr $t0 + 2]
			# 3 7 11...
			set t1 [expr $t0 + 1]
			# 5 8 13...
			set u1 [expr $u0 + 1]
			
			foreach i {12 15} {
			lappend tmp0 [lindex $conl $t0 0 $i]
			lappend tmp0 [lindex $conl $u0 0 $i]
			
			lappend tmp1 [lindex $conl $t1 0 $i]
			lappend tmp1 [lindex $conl $u1 0 $i]
			}
		
		
		}
		lappend tmp0 [lindex $conl $e 0 13]
		lappend tmp0 [lindex $conl  0 0 13]
		#lappend tmp0 [lindex $tmpc 4]
		#lappend tmp0 [lindex $tmpc 6]
		
		lappend tmp1 [lindex $conl $f 0 13]
		lappend tmp1 [lindex $conl  1 0 13]
		#lappend tmp1 [lindex $tmpc 5]
		#lappend tmp1 [lindex $tmpc 7]
		
		
		#lappend tmp_dom [createDomStr $tmp0]
		#lappend tmp_dom [createDomStr $tmp1]
		
		foreach i {0 1 2} {
			foreach j {1 6} {
				foreach k [range 1 [a_to_grid_z $a_end]] {
					set td [lindex $grid_doms 1 $i $j $k]
					#puts "$i $j $k $td"
					lappend tmp_dom $td
				}
			}
		}
		foreach i {0 1 2} {
			foreach j {1 5} {
				foreach k [list 1 [a_to_grid_z $a_end]] {
					set td [lindex $grid_doms 2 $i $j $k]
					#puts "[names $$td]"
					lappend_dom_outer $td
				}
			}
		}

		#puts "$tmp_dom"
		
		lappend_dom_outer $tmp_dom
		
		# blocks
		
		foreach tmp_d $dom_outer {
			#puts "    $d"
		}
		
		set tmp_blk1 [create_block_unstructured $dom_inner]
		set tmp_blk2 [create_block_unstructured $dom_outer]
	
		set solver [pw::Application begin UnstructuredSolver [list $tmp_blk1 $tmp_blk2]]
		$solver run Initialize
		$solver end
		
		# reference
		
		lappend blk_inner $tmp_blk1
		lappend blk_outer $tmp_blk2
		
		
		puts "[llength $blk_inner] inner blocks"
		puts "[llength $blk_outer] outer blocks"
		# -----------------------------------------------------------------------------------------------------------------------------------
		# collecting boundary faces
		foreach a [range 0 $n] {
			# 2 6 10...
			set t0 [expr $a * 4 + 2]
			# 4 8 12...
			set u0 [expr $t0 + 2]
			# 3 7 11...
			set t1 [expr $t0 + 1]
			# 5 8 13...
			set u1 [expr $u0 + 1]
			
			# per rim
			lappend pairs_xm_fluid [list [xBlkExt_get_block [lindex $xblk $t0 0]] [xBlkExt_get_domain_begin [lindex $xblk $t0 0]]]
			lappend pairs_xm_fluid [list [xBlkExt_get_block [lindex $xblk $t0 0]] [xBlkExt_get_domain_end [lindex $xblk $t0 0]]]
			lappend pairs_xm_fluid [list [xBlkExt_get_block [lindex $xblk $t1 0]] [xBlkExt_get_domain_begin [lindex $xblk $t1 0]]]
			lappend pairs_xm_fluid [list [xBlkExt_get_block [lindex $xblk $t1 0]] [xBlkExt_get_domain_end [lindex $xblk $t1 0]]]
		
		
			lappend pairs_xm_fluid [list [lindex $blkl $t0 1 0] [lindex $domv $t0 1 0]]
			lappend pairs_xm_fluid [list [lindex $blkl $t0 1 0] [lindex $domv $t0 1 2]]
			lappend pairs_xm_fluid [list [lindex $blkl $t1 1 0] [lindex $domv $t1 1 0]]
			lappend pairs_xm_fluid [list [lindex $blkl $t1 1 0] [lindex $domv $t1 1 2]]
		
			
			lappend pairs_xp_fluid [list [xBlkExt_get_block [lindex $xblk $u0 0]] [xBlkExt_get_domain_begin [lindex $xblk $u0 0]]]
			lappend pairs_xp_fluid [list [xBlkExt_get_block [lindex $xblk $u0 0]] [xBlkExt_get_domain_end [lindex $xblk $u0 0]]]
			lappend pairs_xp_fluid [list [xBlkExt_get_block [lindex $xblk $u1 0]] [xBlkExt_get_domain_begin [lindex $xblk $u1 0]]]
			lappend pairs_xp_fluid [list [xBlkExt_get_block [lindex $xblk $u1 0]] [xBlkExt_get_domain_end [lindex $xblk $u1 0]]]
		
		
			lappend pairs_xp_fluid [list [lindex $blkl $u0 1 0] [lindex $domv $u0 1 0]]
			lappend pairs_xp_fluid [list [lindex $blkl $u0 1 0] [lindex $domv $u0 1 2]]
			lappend pairs_xp_fluid [list [lindex $blkl $u1 1 0] [lindex $domv $u1 1 0]]
			lappend pairs_xp_fluid [list [lindex $blkl $u1 1 0] [lindex $domv $u1 1 2]]
		
			# per rim pair
			lappend pairs_xm_fluid [list $tmp_blk1 [lindex $dom $t0 11]]
			lappend pairs_xm_fluid [list $tmp_blk1 [lindex $dom $t0 12]]
			
			lappend pairs_xm_fluid [list [lindex $blk $t0 1] [lindex $dom $t0  9]]
			lappend pairs_xm_fluid [list [lindex $blk $t0 1] [lindex $dom $t0 10]]
			
			lappend pairs_xp_fluid [list $tmp_blk1 [lindex $dom $u0 11]]
			lappend pairs_xp_fluid [list $tmp_blk1 [lindex $dom $u0 12]]
		
			lappend pairs_xp_fluid [list [lindex $blk $u0 1] [lindex $dom $u0  9]]
			lappend pairs_xp_fluid [list [lindex $blk $u0 1] [lindex $dom $u0 10]]
		}
		
		lappend pairs_xp_fluid [list $tmp_blk1 [lindex $domv  0 2 13]]
		lappend pairs_xm_fluid [list $tmp_blk1 [lindex $domv $e 2 13]]
		
		lappend pairs_xp_fluid [list [lindex $blkl  0 1 1] [lindex $domv  0 1  5]]
		lappend pairs_xp_fluid [list [lindex $blkl  1 1 1] [lindex $domv  1 1  5]]
		lappend pairs_xm_fluid [list [lindex $blkl $e 1 1] [lindex $domv $e 1  5]]
		lappend pairs_xm_fluid [list [lindex $blkl $f 1 1] [lindex $domv $f 1  5]]
	
		lappend pairs_xp_fluid [list [lindex $blkl  0 1 2] [lindex $domv  0 1  6]]
		lappend pairs_xp_fluid [list [lindex $blkl  1 1 2] [lindex $domv  1 1  6]]
		lappend pairs_xm_fluid [list [lindex $blkl $e 1 2] [lindex $domv $e 1  6]]
		lappend pairs_xm_fluid [list [lindex $blkl $f 1 2] [lindex $domv $f 1  6]]
	
		#make_grid $z $tmpc $c $d $e $f $tmp_dom
	}
	method set_dim {i v} {
		lset dim $i $v
	}
	method set_dimv {i v} {
		lset dimv $i $v
	}
	method set_diml {i v} {
		lset diml $i $v
	}
	method set_Z_space {i v} {
		lset Z_space $i $v
	}
	method lappend_dom_inner {temp_domain} {
		if { $temp_domain==0 } {
			error "bad"
		}
		lappend dom_inner $temp_domain
	}
	method lappend_dom_outer {temp_domains} {
		foreach temp_domain $temp_domains {
			if { $temp_domain==0 } {	
				error "bad"
			}
			#puts "append dom_outer $temp_domain"
			lappend dom_outer $temp_domain
		}
	}
}



