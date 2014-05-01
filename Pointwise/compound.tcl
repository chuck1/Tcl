source "/nfs/mohr/sva/work/rymalc/bin/pointwise/grid.tcl"

proc quarter_circle { dist origin x y z {dim 0} {con_x_edge 0} {con_y_edge 0} {con_x_edge_outer 0} {con_y_edge_outer 0}} {
	
	set d [lcumsum $dist]
	
	set point [lfill 0 13]
	set con [lfill 0 20]
	set dom [lfill 0 3]
	
	if { $dim == 0 } {
		set dim [lfill 5 10]
	}
	
	# points
		
	lset point  0 $origin

	lset point  1 [v_add $origin [v_multiply_s $x [lindex $d 0]]]
	lset point  2 [v_add $origin [v_multiply_s $x [lindex $d 1]]]
	lset point  3 [v_add $origin [v_multiply_s $x [lindex $d 2]]]

	lset point  4 [v_add $origin [v_multiply_s $y [lindex $d 0]]]
	lset point  5 [v_add $origin [v_multiply_s $y [lindex $d 1]]]
	lset point  6 [v_add $origin [v_multiply_s $y [lindex $d 2]]]

	lset point  7 [v_add $origin [v_multiply_s [v_norm [v_add $x $y]] [lindex $d 0]]]
	lset point  8 [v_add $origin [v_add [v_multiply_s $x [lindex $d 2]] [v_multiply_s $y [lindex $d 2]]]]
	
	set s [expr [lindex $dist 1] / ( [lindex $dim 1] - 1 )]
	set space [list [expr $s*1.5] [expr $s/2]]
	
	# x edge
	if { $con_x_edge == 0 } {
		lset con  0 [createTwoPtLineCon [lindex $point  0] [lindex $point  1] [lindex $dim 0]]
		lset con  1 [createTwoPtLineCon [lindex $point  1] [lindex $point  2] [lindex $dim 1] $space]
		lset con  2 [createTwoPtLineCon [lindex $point  2] [lindex $point  3] [lindex $dim 2]]
	} else {
		lset con  0 [lindex $con_x_edge 0]
		lset con  1 [lindex $con_x_edge 1]
		lset con  2 [lindex $con_x_edge 2]
	}



	# y edge
	if { $con_y_edge == 0 } {
		lset con  3 [createTwoPtLineCon [lindex $point  0] [lindex $point  4] [lindex $dim 0]]
		lset con  4 [createTwoPtLineCon [lindex $point  4] [lindex $point  5] [lindex $dim 1] $space]
		lset con  5 [createTwoPtLineCon [lindex $point  5] [lindex $point  6] [lindex $dim 2]]
	} else {
		lset con  3 [lindex $con_y_edge 0]
		lset con  4 [lindex $con_y_edge 1]
		lset con  5 [lindex $con_y_edge 2]
	}
	
	
	# outer x edge
	if { $con_x_edge_outer == 0 } {
		lset con 10 [createTwoPtLineCon [lindex $point  6] [lindex $point 8] [lindex $dim 0]]
	} else {
		lset con 10 $con_x_edge_outer
	}
	
	# outer y edge
	if { $con_y_edge_outer == 0 } {
		lset con 9 [createTwoPtLineCon [lindex $point  3] [lindex $point 8] [lindex $dim 0]]
	} else {
		lset con 9 $con_y_edge_outer
	}


	lset con  6 [createTwoPtLineCon [lindex $point  1] [lindex $point  7] [lindex $dim 0]]
	lset con  7 [createTwoPtLineCon [lindex $point  7] [lindex $point  4] [lindex $dim 0]]

	set tmp [expr 2 * [lindex $dim 0] - 1]
	
	lset con  8 [circle_point_center_angle [lindex $point 2] [lindex $point 0] 90 $z $tmp]
	
	lset dom 0 [createDomStr [list [lindex $con 0] [lindex $con 3] [lindex $con 6] [lindex $con 7]]]
	lset dom 1 [createDomStr [list [lindex $con 1] [lindex $con 4] [lindex $con 6] [lindex $con 7] [lindex $con  8]]]
	lset dom 2 [createDomStr [list [lindex $con 2] [lindex $con 5] [lindex $con 8] [lindex $con 9] [lindex $con 10]]]
	
	return [list $point $con $dom]
}
proc tile {v origin d dist tiles dim ori} {
	
	set a [expr [lindex $v 0] + [lindex $ori 0]]
	set b [expr [lindex $v 1] + [lindex $ori 1]]
	
	set r [expr $a % 2]
	set s [expr $b % 2]

	set x {1 0 0}
	set y {0 1 0}
	
	set off_x [v_multiply_s $x [expr [lindex $d 2] * ([lindex $v 0] + $r)]]
	set off_y [v_multiply_s $y [expr [lindex $d 2] * ([lindex $v 1] + $s)]]
	
	set origin [v_add [v_add $origin $off_x] $off_y]
	
	
	if { $r == 0 } {
		set X {1 0 0}
	} else {
		set X {-1 0 0}
	}

	if { $s == 0 } {
		set Y {0 1 0}
	} else {
		set Y {0 -1 0}
	}

	return [quarter_circle $dist $origin $X $Y [v_cross $X $Y] $dim]
}
proc quarter_circle_tile {origin dist n ori {dim 0}} {
	set d [lcumsum $dist]
	
	set tiles [lfill [lfill 0 [lindex $n 1]] [lindex $n 0]]
	
	foreach i [range 0 [lindex $n 0]] {
		foreach j [range 0 [lindex $n 1]] {
			set v [list $i $j]
			lset tiles {*}$v [tile $v $origin $d $dist $tiles $dim $ori]
		}
	}
	
	return $tiles
}

itcl::class quarter_circle_tile_grid {
	
	public variable tiles
	public variable conv
	public variable domv
	public variable block

	public variable n
	
	constructor { grid x y nn dist ori } {
		puts "quarter_circle_tile_grid"
		
		set n $nn
		
		#set grid_info [lindex $grid_output 0]
		set grid_cons [$grid cget -cons]
		set grid_doms [$grid cget -doms]
		set X [$grid cget -X]
		set Y [$grid cget -Y]
		set Z [$grid cget -Z]
		set dims [$grid cget -dims]
		set N [$grid cget -N]
	
		set eighth_dim [lindex $dims 0 $x]
		
			
		set tiles [lfill 0 [lindex $N 2]]
		
		
		foreach a [range 0 [lindex $N 2]] {
			set origin [list [lindex $X [lindex $x 0]] [lindex $Y [lindex $y 0]] [lindex $Z $a]]
			
			lset tiles $a [quarter_circle_tile $origin $dist $n $ori [list $eighth_dim 7 7]]
		}
	
	
		#set n [llength [lindex $tiles 0]]
		set max_a [expr [llength $tiles] - 1]
		
		set conv  [lfill 0 [list $max_a {*}$n 9]]
		set domv  [lfill 0 [list $max_a {*}$n 11]]
		set block [lfill 0 [list $max_a {*}$n 3]]

		# sets of point indices that make the in-plane cons
		set con_indices {{ 0  1} { 1  2} { 2  3} { 0  4} { 4  5} { 5  6} {1  7} {7  4} {2  5} {3 8} {8 6}}
	
		# sets of domv indices that outline blocks
		set block_indices {{0 3 6 7} {1 4 6 7 8} {2 5 8 9 10}}
		
		# create connectors
		puts "connectors"
		foreach a [range 0 [expr [llength $tiles] - 1]] {
			foreach i [range 0 [lindex $n 0]] {
				foreach j [range 0 2] {
				        set v [list $i $j]
	
					set b [expr $a + 1]
	
					set e [expr [lindex $v 0] + [lindex $ori 0]]
					set f [expr [lindex $v 1] + [lindex $ori 1]]
					
					set r [expr $e % 2]
					set s [expr $f % 2]
	
					set direction {{0 1} 1 1 1 0 0 0 -1 -1 -1 -1}
					
					# four corners of tile get their connectors from existing grid
					lset conv $a {*}$v  0 [lindex $grid_cons 2 [expr $x + $i + [expr ($r+0) % 2]] [expr $y + $j + [expr ($s+0) % 2]] $a]
					lset conv $a {*}$v  6 [lindex $grid_cons 2 [expr $x + $i + [expr ($r+0) % 2]] [expr $y + $j + [expr ($s+1) % 2]] $a]
					lset conv $a {*}$v  3 [lindex $grid_cons 2 [expr $x + $i + [expr ($r+1) % 2]] [expr $y + $j + [expr ($s+0) % 2]] $a]
					lset conv $a {*}$v  8 [lindex $grid_cons 2 [expr $x + $i + [expr ($r+1) % 2]] [expr $y + $j + [expr ($s+1) % 2]] $a]
					
					# all other connectors are created
					foreach c {1 2 4 5 7} {
						set p0 [lindex $tiles $a {*}$v 0 $c]
						set p1 [lindex $tiles $b {*}$v 0 $c]
						#puts "$p0 $p1"
						lset conv $a {*}$v $c [createTwoPtLineCon $p0 $p1 [lindex $dims 2 $a]]
						
						# previous and next line appear to be the same!!!!!!!
						
						if { [catch {
							lset conv $a {*}$v $c [createTwoPtLineCon $p0 $p1 [lindex $dims 2 $a]]
						}]} {
							set dir [lindex $direction $c]
							#puts "$c, $dir, $v"
							
							foreach d $dir {
								set v0 $v
								if { [expr ([lindex $v $d]+1) % 2] == 0 } {
									lset v0 $d [expr [lindex $v0 $d] - 1]
								} else {
									lset v0 $d [expr [lindex $v0 $d] + 1]
								}
		
								set tmp [lindex $conv $a {*}$v0 $c]
								
								if {$tmp==0} {
									error "conv not found"
								}
								
								#puts "$a $v $c"
								lset conv $a {*}$v $c $tmp
							}
						}
					}
				}
			}
		}
		
		# create domains
		puts "domains"
		foreach a [range 0 [expr [llength $tiles] - 1]] {
			foreach i [range 0 [lindex $n 0]] {
				foreach j [range 0 2] {
					set direction { 1  1  1  0  0  0 -1 -1 -1 0 1}
					set offset {    0  0  0  0  0  0 -1 -1 -1 1 1}
					set index {     0  1  2  0  1  2 -1 -1 -1 0 0}
					set b [expr $a + 1]
	
					set v [list $i $j]
					
					set e [expr [lindex $v 0] + [lindex $ori 0]]
					set f [expr [lindex $v 1] + [lindex $ori 1]]
					
					set r [list [expr $e % 2] [expr $f % 2]]
				
					#lset domv $a {*}$v  0 [lindex $grid_cons 2 [expr $x + $i + [expr ($r+0) % 2]] [expr $y + $j + [expr ($s+0) % 2]] $a]
	
					foreach c {0 1 2 3 4 5 6 7 8 9 10} {
						set c0 [lindex $conv $a $i $j [lindex $con_indices $c 0]]
						set c1 [lindex $conv $a $i $j [lindex $con_indices $c 1]]
						set c2 [lindex $tiles $a $i $j 1 $c]
						set c3 [lindex $tiles $b $i $j 1 $c]
	
	
						set dir [lindex $direction $c]
						set ind [lindex $index $c]
						set off [lindex $offset $c]
						
						#set v0 [list [expr $x + $i + [expr ([lindex $r 0]+0) % 2]] [expr $y + $j + [expr ([lindex $r 1]+0) % 2]]]
						set v0 [list [expr $x + $i] [expr $y + $j]]
						
						if { $dir != -1 } {
							lset v0 $dir [expr [lindex $v0 $dir] + [expr ($off + [lindex $r $dir])%2]]
						}
						
						#puts "$c, $dir, $v, $v0, $ind, $off"
						
						if { [catch {
							set tmp [createDomStr [list $c0 $c1 $c2 $c3]]						
						}]} {
							set tmp [lindex $grid_doms $dir {*}$v0 $a $ind]
							
							if {[llength $tmp] == 0} {
								error "domv not found"
							}
							
							lset domv $a {*}$v $c $tmp
						} else {
							lset domv $a {*}$v $c $tmp
							
							if { $dir != -1 } {
								set tmp_list [lindex $grid_doms $dir {*}$v0 $a]
								while { [llength $tmp_list] < [expr $ind + 1] } {
									lappend tmp_list 0
								}
								lset tmp_list $ind $tmp
								lset grid_doms $dir {*}$v0 $a $tmp_list
							}
	
						}
					}				
				}
			}
		}
		
		# create blocks
		puts "blocks"
		foreach a [range 0 [expr [llength $tiles] - 1]] {
			foreach i [range 0 [lindex $n 0]] {
				foreach j [range 0 2] {
					set b [expr $a + 1]
					set v [list $i $j]
	
					foreach c {0 1 2} {
						set tmp_dom [list]
						foreach d [lindex $block_indices $c] {
							lappend tmp_dom [lindex $domv $a {*}$v $d]
						}
	
						lappend tmp_dom [lindex $tiles $a {*}$v 2 $c]
						lappend tmp_dom [lindex $tiles $b {*}$v 2 $c]
	
						lset block $a {*}$v $c [create_block_structured $tmp_dom]
					}
				}
			}
		}
	}
	method get_pairs_z { sign a } {
		set lst [list]

		if { $sign == 0 } {
			set b [expr $a + 1]
		} else {
			set b $a
		}
		
	        foreach i [range 0 [lindex $n 0]] {
	                foreach j {0 1} {
	                        foreach c {0 1 2} {
					lappend lst [list [lindex $block $a $i $j $c] [lindex $tiles $b $i $j 2 $c]]
	                        }
	                }
	        }
	        return $lst
	}
	method get_pairs_v { I J A CD } {
		set lst [list]
                foreach i $I {
                        foreach j $J {
				foreach a $A {
					foreach cd $CD {
						set c [lindex $cd 0]
						set d [lindex $cd 1]
						set blk [lindex $block $a $i $j $c]
						set dom [lindex $domv  $a $i $j $d]
						if {$blk==0} {
							puts "$i $j $a $cd"
							error "block==0"
						}
						if {[llength $blk]==0} {
							puts "$i $j $a $cd"
							error "block==0"
						}
						lappend lst [list $blk $dom]
	                                }
	                        }
	                }
	        }
		return $lst
	}
	method get_blocks { ind } {
		set lst [list]
		foreach i [lindex $ind 0] {
			foreach j [lindex $ind 1] {
				foreach k [lindex $ind 2] {
					foreach c [lindex $ind 3] {
						lappend lst [lindex $block $k $i $j $c]
					}
				}
			}
		}
		return $lst
	}
}






