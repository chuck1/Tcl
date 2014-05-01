source "/nfs/mohr/sva/work/rymalc/bin/pointwise/proc.tcl"

package require Itcl

proc v_sub { a b } {
	if{ [llength $a] != [llength $b] } {
		error
	}
	
	set c [lfill 0 [llength $a]]
	
	foreach i [range 0 [llength $a]] {
		lset c $i [expr [lindex $a $i] - [lindex $b $i]]
	}
	
	return $c
}
proc xyz { coor v } {
        return [list [lindex $coor 0 [lindex $v 0]] [lindex $coor 1 [lindex $v 1]] [lindex $coor 2 [lindex $v 2]]]
}

itcl::class Grid {

	public variable N
	public variable n
	public variable nb
	public variable ignores [list]
	public variable flags
	public variable X
	public variable Y
	public variable Z
	public variable dims

	public variable cons
	public variable doms
	public variable blocks
	public variable x_minu
	public variable x_plus
	public variable y_minu
	public variable y_plus
	public variable z_minu
	public variable z_plus

	private variable coor
	private variable spaces 0
	private variable option_bc 0
	
	public variable flag_ignore_conn {0 0 0}
	public variable flag_ignore_conn_inc {0 0 0}
	public variable flag_ignore_block 0
	

	constructor { nX nY nZ ndims } {
		# ignores { ignore... }
		# ignore  { {x_start x_end} {y_start z_end} {z_start z_end} }
		
		# dims  { dim(x) dim(y) dim(z) }
		# dim() { dim_element... }
		
		# spaces        { space(x) space(y) space(z) }
		# space()       { space_element... }
		# space_element { begin end }
		
		set X $nX
		set Y $nY
		set Z $nZ
		set dims $ndims

		puts "grid"
		
		set points [list]
		set cons [list]
		set doms [list]
		set blocks [list]
	
		set coor [list $X $Y $Z]
	
		set N  [list [llength $X]            [llength $Y]            [llength $Z]]
		set n  [list [expr [llength $X] - 1] [expr [llength $Y] - 1] [expr [llength $Z] - 1]]
		set nb [list [expr [llength $X] - 2] [expr [llength $Y] - 2] [expr [llength $Z] - 2]]
		
		# init points
		set points [lfill 0 $N]
		
		foreach i [range 0 [lindex $N 0]] {
			foreach j [range 0 [lindex $N 1]] {
				foreach k [range 0 [lindex $N 2]] {
					lset points [list [lindex $X $i] [lindex $Y $j] [lindex $Z $k]]
				}
			}
		}
		
		# init cons
		foreach dir [range 0 3] {
			set a $N
			lset a $dir [expr [lindex $a $dir] - 1]
			
			lappend cons [lfill 0 $a]
		}
		
		# init doms
		foreach dir [range 0 3] {
			set a $n
			lset a $dir [expr [lindex $a $dir] + 1]
			
			lappend doms [lfill [list] $a]
		}
		
		puts "doms 0 shape [lshape [lindex $doms 0]]"
		puts "doms 1 shape [lshape [lindex $doms 1]]"
		puts "doms 2 shape [lshape [lindex $doms 2]]"

		# init blocks
		set blocks [lfill 0 $n]
	}
	method run {} {
		grid_connectors
		grid_domains
		grid_blocks
		
		# x
		set x_plus [list]
		set x_minu [list]
		foreach j [range 0 [expr [llength $Y] - 1]] {
			foreach k [range 0 [expr [llength $Z] - 1]] {
				lappend x_minu [list [lindex $blocks 0    $j $k] [lindex $doms 0 0   $j $k]]
				lappend x_plus [list [lindex $blocks [lindex $nb 0] $j $k] [lindex $doms 0 [lindex $n 0] $j $k]]
			}
		}
		# y
		set y_plus [list]
		set y_minu [list]
	
		foreach i [range 0 [expr [llength $X] - 1]] {
			foreach k [range 0 [expr [llength $Z] - 1]] {
				lappend y_minu [list [lindex $blocks $i 0    $k] [lindex $doms 1 $i 0   $k]]
				lappend y_plus [list [lindex $blocks $i [lindex $nb 1] $k] [lindex $doms 1 $i [lindex $n 1] $k]]
			}
		}
		# z
		set z_plus [list]
		set z_minu [list]
	
		foreach i [range 0 [expr [llength $X] - 1]] {
			foreach j [range 0 [expr [llength $Y] - 1]] {
				lappend z_minu [list [lindex $blocks $i $j 0]    [lindex $doms 2 $i $j 0]]
				lappend z_plus [list [lindex $blocks $i $j [lindex $nb 2]] [lindex $doms 2 $i $j [lindex $n 2]]]
			}
		}
		
		
		# boundary conditions
		if { $option_bc==0 } {
			return
		}
	
		createBC "x_minu" {Unspecified} $x_minu
		createBC "x_plus" {Unspecified} $x_plus
		createBC "y_minu" {Unspecified} $y_minu
		createBC "y_plus" {Unspecified} $y_plus
		createBC "z_minu" {Unspecified} $z_minu
		createBC "z_plus" {Unspecified} $z_plus
		
	}
	method grid_pass_connector_single { v ignore dir } {
		set test {0 0 0}
	
		if { [lindex $flag_ignore_conn $dir] == 0 } {
			return 0
		}
		
		# ignore_inclusive means pass on connectors that are part of the ignored block
		
		foreach i {0 1 2} {
			if {$dir == $i} {
				if { ( [lindex $v $i] >= [lindex $ignore $i 0] ) & ( [lindex $v $i] <= [lindex $ignore $i 1] ) } {
					lset test $i 1
				}
			} else {
				if { [lindex $flag_ignore_conn_inc $dir] == 1 } {
					if { ( [lindex $v $i] >= [lindex $ignore $i 0] ) & ( [lindex $v $i] <= [expr [lindex $ignore $i 1] + 1] ) } {
						lset test $i 1
					}
	
				} else {			
					if { ( [lindex $v $i] > [lindex $ignore $i 0] ) & ( [lindex $v $i] <= [lindex $ignore $i 1] ) } {
						lset test $i 1
					}
				}
			}
		}
		
		
		if { [lindex $test 0] & [lindex $test 1] & [lindex $test 2] } {
			return 1
		} else {
			return 0
		}
	}
	method grid_pass_connector { v dir } {
		
		foreach ignore $ignores {
			if { [grid_pass_connector_single $v $ignore $dir]==1 } {
				return 1
			}
		}
		
		return 0
	}
	method grid_pass_domain_single { v ignore dir } {
		#puts "grid_pass_domain_single"
		
		set test {0 0 0}
		
		foreach i [range 0 3] {
			if {$dir == $i} {
				if { ( [lindex $v $i] > [lindex $ignore $i 0] ) & ( [lindex $v $i] <= [lindex $ignore $i 1] ) } {
					lset test $i 1
				}
			
				if { ( [lindex $v $i] == 0 ) & ( [lindex $ignore $i 0] == 0 ) } {
					
				}
	
			} else {
				if { ( [lindex $v $i] >= [lindex $ignore $i 0] ) & ( [lindex $v $i] <= [lindex $ignore $i 1] ) } {
					lset test $i 1
				}
			}
		}
		
		if { [lindex $test 0] & [lindex $test 1] & [lindex $test 2] } {
			return 1
		} else {
			return 0
		}
	}
	method grid_pass_domain { v dir } {
		#puts "grid_pass_domain"
		
		foreach ignore $ignores {
			if { [grid_pass_domain_single $v $ignore $dir]==1 } {
				return 1
			}
		}
		
		return 0
	}
	method grid_pass_block_single { v ignore } {
		set test {0 0 0}
	
		if { $flag_ignore_block==1 } {
			foreach i [range 0 3] {
				if { ( [lindex $v $i] >= [lindex $ignore $i 0] ) & ( [lindex $v $i] <= [lindex $ignore $i 1] ) } {
					lset test $i 1
				}
			}
		}
		
		if { [lindex $test 0] & [lindex $test 1] & [lindex $test 2] } {
			return 1
		} else {
			return 0
		}
	}
	method grid_pass_block { v } {
		foreach ignore $ignores {
			if { [grid_pass_block_single $v $ignore]==1 } {
				return 1
			}
		}
		
		return 0
	}
	method shift { n d } {
		#puts "shift"
	
		set v [range 0 $n]
		
		foreach i [range 0 $n] {
			lset v $i [expr ([lindex $v $i] + $d) % $n]
		}
		
		return $v
	}
	method grid_connectors {} {
		puts "grid_connectors"
	
		# create cons
		foreach dir [range 0 3] {
			set a $N
			lset a $dir [expr [lindex $a $dir] - 1]
			
			foreach i [range 0 [lindex $a 0]] {
				foreach j [range 0 [lindex $a 1]] {
					foreach k [range 0 [lindex $a 2]] {
						set v0 [list $i $j $k]
						set v1 [list $i $j $k]
						
						if { [grid_pass_connector $v0 $dir]==0 } {
							lset v1 $dir [expr [lindex $v1 $dir] + 1]
							
							set p0 [xyz $coor $v0]
							set p1 [xyz $coor $v1]
							if {$spaces == 0} {
								lset cons $dir {*}$v0 [createTwoPtLineCon $p0 $p1 [lindex $dims $dir [lindex $v0 $dir]]]
							} else {
								lset cons $dir {*}$v0 [createTwoPtLineCon $p0 $p1 [lindex $dims $dir [lindex $v0 $dir]] [lindex $spaces $dir [lindex $v0 $dir]]]
							}
						}
					}
				}
			}
		
		}
	}
	method grid_domains {} {
		puts "grid_domains"
		
		# domains
		# create doms 0
		foreach dir [range 0 3] {
			set a $n
			lset a $dir [expr [lindex $a $dir] + 1]
	
			foreach i [range 0 [lindex $a 0]] {
				foreach j [range 0 [lindex $a 1]] {
					foreach k [range 0 [lindex $a 2]] {
						set v0 [list $i $j $k]
						#puts $v0
						
						if { [llength [lindex $doms $dir {*}$v0]] == 0 } {
							set order [shift 3 $dir]
		
							set v1 [list $i $j $k]
							set v2 [list $i $j $k]
							set v3 [list $i $j $k]
							
							lset v1 [lindex $order 2] [expr [lindex $v1 [lindex $order 2]] + 1]
							lset v3 [lindex $order 1] [expr [lindex $v3 [lindex $order 1]] + 1]
							
							if { [grid_pass_domain $v0 $dir]==0 } {
								set c0 [lindex $cons [lindex $order 1] {*}$v0]
								set c1 [lindex $cons [lindex $order 1] {*}$v1]
								set c2 [lindex $cons [lindex $order 2] {*}$v2]
								set c3 [lindex $cons [lindex $order 2] {*}$v3]
	
								set tmp [lindex $doms $dir {*}$v0]
								catch {
									lappend tmp [createDomStr [list {*}$c0 {*}$c1 {*}$c2 {*}$c3]]
								}
								lset doms $dir {*}$v0 $tmp
								#puts $tmp
								#puts [lindex $doms [list $dir {*}$v0]]
							}
						}
					}
				}
			}
		}
	}
	method grid_blocks {} {
		puts "grid blocks"
		
		# create blocks
		foreach i [range 0 [lindex $n 0]] {
			foreach j [range 0 [lindex $n 1]] {
				foreach k [range 0 [lindex $n 2]] {
					set v [list $i $j $k]
					#puts "block $v"
					if {[lindex $blocks $v]==0} {
						if { [grid_pass_block $v]==0 } {
							set dx0 [lindex $doms 0 $i            $j            $k]
							set dx1 [lindex $doms 0 [expr $i + 1] $j            $k]
							set dy0 [lindex $doms 1 $i            $j            $k]
							set dy1 [lindex $doms 1 $i            [expr $j + 1] $k]
							set dz0 [lindex $doms 2 $i            $j            $k]
							set dz1 [lindex $doms 2 $i            $j            [expr $k+1]]
							
							catch {
								#puts "$i $j $k"
								lset blocks $v [create_block_structured [list {*}$dx0 {*}$dx1 {*}$dy0 {*}$dy1 {*}$dz0 {*}$dz1]]
							}
						}
					}
				}
			}
		}
		
		return $blocks
	}
	method get_pairs { sign dir ind } {
	        # sign = 0 positive
	        # sign = 1 negative     
	
	        # dir - direction of normal vector
	
	        # ind - list of three lists, one for each direction, containing indices for corresonding direction
		set lst [list]
	        foreach i [lindex $ind 0] {
	                foreach j [lindex $ind 1] {
	                        foreach k [lindex $ind 2] {
	                                set a [list $i $j $k]
	                                set b $a
	                                if { $sign == 0 } {
						lset b $dir [expr [lindex $b $dir] + 1]
					}
					set blk [lindex $blocks $a]
					if {$blk==0} {
						error "block==0"
					}
					if {[llength $blk]==0} {
						error "block==0"
					}
					lappend lst [list $blk [lindex $doms $dir {*}$b]]
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
					set blk [lindex $blocks $i $j $k]
					if {$blk==0} {
						error "block==0"
					}
					lappend lst $blk
				}
			}
		}
		return $lst
	}
	method delete_blocks { ind } {
		set lst [get_blocks $ind]
		pw::Entity delete $lst
		return $lst
	}
}



