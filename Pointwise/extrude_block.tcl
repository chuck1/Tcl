source "/nfs/mohr/sva/work/rymalc/bin/pointwise/proc.tcl"

# xDom data structure
# --- domain
# --- con list
# ------- 0
# ------- 1
# ------- ...

# xExtBlk data structure
# -0- block
# -1- xDom begin
# -2- dom side list
# -----0- 0
# -----1- 1
# -----2- ...
# -3- dom end
# -4- con side list
# -5- con end list

proc xDom_new_structured { con } {
	set dom [createDomStr $con]
	set x [list $dom $con]
	return $x
}
proc XDom_ctor_existing { dom } {
	set x [list $dom [list]]
	return $x
}
proc xDom_get_domain { x } {
	return [lindex $x 0]
}
proc xDom_get_cons { x } {
	return [lindex $x 1]
}
proc xDom_get_connector { x a } {
	return [lindex $x 1 $a]
}

proc xBlkExt_get_block { x } {
	return [lindex $x 0]
}
proc xBlkExt_get_begin { x } {
	return [lindex $x 1]
}
proc xBlkExt_get_domain_end { x } {
	return [lindex $x 3]
}
proc xBlkExt_get_domain_begin { x } {
	return [xDom_get_domain [lindex $x 1]]
}
proc xBlkExt_get_side_domain { x a } {
	return [lindex $x 2 $a]
}
proc xBlkExt_get_begin_connector { x a } {
	return [xDom_get_connector [lindex $x 1] $a]
}
proc xBlkExt_get_side_connector { x a } {
	return [lindex $x 4 $a]
}
proc xBlkExt_get_end_connector { x a } {
	return [lindex $x 5 $a]
}
proc xBlkExt_init { x } {
	#puts "xBlkExt_init"
	
	set blk  [xBlkExt_get_block $x]
	set xdom_begin [xBlkExt_get_begin $x]

	#puts $xdom_begin	
	
	set con_begin [xDom_get_cons $xdom_begin]
	set con_side [list]
	set con_end [list]


	set dom_all [get_doms_from_block $blk]
	set dom_begin [xDom_get_domain $xdom_begin]
	set dom_side [list]

	#puts "dom_all=[names $dom_all]"
	#puts "dom_begin=[names $dom_begin]"

	set dom_end [first_dom_not_adjacent_to_doms $dom_all $dom_begin]

	#puts "dom_end=[$dom_end getName]"
		
	set n [llength $con_begin]
	
	# find sides
	foreach c $con_begin {
		lappend dom_side [first_dom_adjacent_to_cons_excluding_doms $dom_all $c $dom_begin]
	}

	#puts "dom_side=[names $dom_side]"
	
	foreach a [range 0 $n] {
		if { $a==[expr $n-1] } {
			set b 0
		} else {
			set b [expr $a + 1]
		}
		lappend con_side [first_common_con [list [lindex $dom_side $a] [lindex $dom_side $b]]]
	}

	#puts "con_side=[names $con_side]"
	
	foreach d $dom_side {
		lappend con_end [first_common_con [list $d $dom_end]]
	}

	#puts "con_end=[names $con_end]"
	
	lset x 2 $dom_side
	lset x 3 $dom_end
	lset x 4 $con_side
	lset x 5 $con_end
	
	return $x
}
proc xBlkExt_new_rotate {xdom center axis angle steps} {
	#puts "xBlkExt_new_rotate"

	set dom [xDom_get_domain $xdom]
	
	#puts $xdom
	#puts $dom
	
	set block [create_extrude_rotate_domain $dom $center $axis $angle $steps]	
	
	set x [list $block $xdom 0 0 0 0]
	
	set x [xBlkExt_init $x]
	
	return $x
}


