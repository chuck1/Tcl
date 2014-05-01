proc get_doms_from_block { block } {
	set doms [list]

	foreach a [range 1 [expr [$block getFaceCount] + 1]] {
		set face [$block getFace $a]
		
		set doms_temp [$face getDomains]
		
		lappend doms {*}$doms_temp
	}
	
	return $doms
}
proc get_cons_from_dom {dom} {
	set cons [list]

	foreach a [range 1 [expr [$dom getEdgeCount] + 1]] {
		set edge [$dom getEdge $a]
		
		foreach b [range 1 [expr [$edge getConnectorCount] + 1]] {
			set con [$edge getConnector $b]

			set cons [ladd $cons $con]
		}
	}
	
	return $cons
}
proc find_doms_adjacent_to_cons {doms cons} {
	set doms_find [list]
	
	foreach dom $doms {
		set found 1

		set cons_temp [get_cons_from_dom $dom]
		
		foreach con $cons {
			if { [lsearch $cons_temp $con] == -1 } {
				set found 0
				break
			}
		}

		if { $found==1 } {
			lappend doms_find $dom
		}
	}
	return $doms_find
}
proc find_doms_adjacent_to_cons_excluding_doms {doms cons doms_exc} {
	set doms_find [list]

	set doms_temp [find_doms_adjacent_to_cons $doms $cons]

	foreach dom $doms_temp {

		#puts [$dom getName]
		
		if { [lsearch $doms_exc $dom] == -1 } {
			lappend doms_find $dom
		}
	}

	#puts [names $doms_find]

	return $doms_find
}
proc first_dom_adjacent_to_cons_excluding_doms {doms cons doms_exc} {
	set doms_find [find_doms_adjacent_to_cons_excluding_doms $doms $cons $doms_exc]

	if { [llength $doms_find] > 0 } {
		#puts [[lindex $doms_find 0] getName]

		return [lindex $doms_find 0]
	}
	
	error "not found"
}
proc find_cons_not_adjacent_to_cons {cons_base cons_exc} {
	set nodes [list]
	foreach c $cons_exc {
		lappend nodes [$c getNode Begin]
		lappend nodes [$c getNode End]
	}
	
	set cons_find [list]
	foreach c $cons_base {
		if {[lsearch $nodes [$c getNode Begin]]==-1} {
			if {[lsearch $nodes [$c getNode End]]==-1} {
				lappend cons_find $c
			}
		}
	}
	
	return $cons_find
}
proc first_con_not_adjacent_to_cons {cons_base cons_exc} {
	set cons_find [find_cons_not_adjacent_to_cons $cons_base $cons_exc]
	
	if { [llength $cons_find] > 0 } {
		return [lindex $cons_find 0]
	}
	
	error "not found"

}
proc find_cons_adjacent_to_cons {cons_base cons_adj} {
	
	set cons_find [list]
	
	set cons_base [lremove $cons_base $cons_adj]
	
	foreach cb $cons_base {
		set nodes [list]
		lappend nodes [$cb getNode Begin]
		lappend nodes [$cb getNode End]
		
		set found 1
		
		foreach ca $cons_adj {
			if {[lsearch $nodes [$ca getNode Begin]]==-1} {
				if {[lsearch $nodes [$ca getNode End]]==-1} {
					set found 0
					break
				}
			}
		}
		
		if {$found==1} {
			lappend cons_find $cb
		}
	}
	
	return $cons_find
}
proc first_con_adjacent_to_cons {cons_base cons_adj} {
	set cons_find [find_cons_adjacent_to_cons $cons_base $cons_adj]
	
	if { [llength $cons_find] > 0 } {
		return [lindex $cons_find 0]
	}
	
	error "not found"

}
proc are_adjacent_doms { d0 d1 } {
	set c0 [get_cons_from_dom $d0]
	set c1 [get_cons_from_dom $d1]
	
	set cu [lunion $c0 $c1]
	
	#puts [names $c0]
	#puts [names $c1]
	#puts [names $cu]
	
	
	if { [llength $cu] == 0 } {
		#puts "false"
		return false
	} else {
		#puts "true"
		return true
	}
}
proc find_doms_not_adjacent_to_doms {doms_base doms_exc} {
	set doms_find [list]
	
	set doms_base [lremove $doms_base $doms_exc]
	
	foreach d_base $doms_base {
		set found 1

		#puts [$d_base getName]

		foreach d_exc $doms_exc {
						
			if {[are_adjacent_doms $d_base $d_exc]} {
				set found 0
				break
			}
		}
		
		if {$found==1} {
			lappend doms_find $d_base
		}
	}
	
	return $doms_find
}
proc first_dom_not_adjacent_to_doms {doms_base doms_exc} {
	set doms_find [find_doms_not_adjacent_to_doms $doms_base $doms_exc]
	if { [llength $doms_find] > 0 } {
		return [lindex $doms_find 0]
	}
	#puts "doms_base [names $doms_base]"
	#puts [names $doms_exc]
	#puts [names $doms_find]
	error "not found"
}
proc common_cons { doms } {
	#puts "common cons"
	
	set cons [list]
	
	set first 1
	
	foreach d $doms {
		set cons_temp [get_cons_from_dom $d]
		
		#puts [names $cons_temp]
		
		if {$first} {
			set first 0
			set cons $cons_temp
		} else {
			set cons [lunion $cons $cons_temp]
		}
	}
	
	return $cons
}
proc first_common_con { doms } {
	set cons [common_cons $doms]
	if { [llength $cons] > 0 } {
		return [lindex $cons 0]
	}
	error "not found"
}








