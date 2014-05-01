proc lselect {lst indices} {
	#puts "indices $indices"

	set new [list]
	foreach i $indices {
		lappend new [lindex $lst {*}$i]
	}
	return $new
}
proc range {s n} {
	set ret [list]
	set a $s
	while {$a < $n} {
		lappend ret $a
		set a [expr $a + 1]
	}
	return $ret
}
proc ladd {lst val} {
	set found 0
	if {[lsearch $lst $val] == -1} {
		lappend lst $val
	}
	return $lst
}
proc lmerge {lists} {
	set l [list]
	foreach lst $lists {
		foreach item $lst {
			set l [ladd $l $item]
		}
	}
	return $l
}
proc lfill {value length} {
	
	if {[llength $length] > 1} {
		#error "length is a list: $length"
	}
	
	set length [lreverse $length]
	
	foreach l $length {
		foreach a [range 0 $l] {
			lappend nvalue $value
		}
		set value $nvalue
		set nvalue [list]
	}
	return $value	

	#set ret [list]
	#foreach a [range 0 $length] {
	#	lappend ret $value
	#}
	#return $ret
}
proc lshape {lst} {
	set shape [list]
	
	lappend shape [llength $lst]
	
	set lst [lindex $lst 0]
	
	if {[llength $lst] > 1} {
		lappend shape {*}[lshape $lst]
	}
	return $shape
}
proc lscale {V s} {
	if {[llength $V] > 1} {
		set r [list] 
		foreach v $V {
			lappend r [lscale $v $s]
		}
		return $r
	} else {
		return [expr $V * $s]
	}
}
proc lceil {V} {
	if {[llength $V] > 1} {
		set r [list] 
		foreach v $V {
			lappend r [lceil $v]
		}
		return $r
	} else {
		return [expr {int(ceil($V))}]
	}
}

proc lcumsum {lst {start 0}} {
	set ret [list $start]
	foreach a $lst {
		lappend ret [expr [lindex $ret end] + $a]
	}
	return $ret
}

proc lremove { list_base list_rem } {
	set list_ret [list]
	
	foreach item $list_base {
		if {[lsearch $list_rem $item]==-1} {
			lappend list_ret $item
		}
	}
	
	return $list_ret
}
proc lunion { l0 l1 } {
	set lu [list]
	
	foreach e0 $l0 {
		if { [lsearch $l1 $e0] != -1 } {
			lappend lu $e0
		}
	}
	
	return $lu
}
proc flatten { l {n {}} } {
	
	foreach e $l {
		
		if {[llength $e] == 1} {
			lappend n $e
		} else {
			set n [flatten $e $n]
		}
	}
	
	return $n
}
proc lsum { l } {
	if {![llength $l]} {return 0}
	return [expr [join $l +]]
}
proc filter {l script} {
	set res {}
	foreach e $l {if {[uplevel 1 $script [list $e]]} {lappend res $e}}
	set res
}
proc in {l e} {expr {[lsearch -exact $l $e]>=0}}
proc notin {l e} {expr {[lsearch -exact $l $e]==-1}}





















 
