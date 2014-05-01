

proc v_subtract { a b } {
	if { [llength $a] != [llength $b] } {
		error
	}
	
	foreach i [range 0 [llength $a]] {
		lset a $i [expr [lindex $a $i] - [lindex $b $i]]
	}
	
	return $a
}
proc v_add { a b } {
	if { [llength $a] != [llength $b] } {
		error "dimension mismatch"
	}
	
	foreach i [range 0 [llength $a]] {
		lset a $i [expr [lindex $a $i] + [lindex $b $i]]
	}
	
	return $a
}
proc v_subtract_s { a b } {
	# a vector
	# b scalar
	
	foreach i [range 0 [llength $a]] {
		lset a $i [expr [lindex $a $i] - $b]
	}
	
	return $a
}
proc v_multiply_s { a b } {
	# a vector
	# b scalar
	
	foreach i [range 0 [llength $a]] {
		lset a $i [expr [lindex $a $i] * $b]
	}
	
	return $a
}
proc v_divide_s { a b } {
	# a vector
	# b scalar
	
	foreach i [range 0 [llength $a]] {
		lset a $i [expr [lindex $a $i] / $b]
	}
	
	return $a
}

proc v_pow { a b } {
	foreach i [range 0 [llength $a]] {
		lset a $i [expr pow([lindex $a $i], $b)]
	}
	
	return $a

}
proc v_magn { a } {
	
	return [expr sqrt([lsum [v_pow $a 2]])]
}
proc v_norm { a } {
	return [v_divide_s $a [v_magn $a]]
}

proc v_cross { a b } {
	if { [llength $a] != 3 } {
		error "dimension mismatch"
	}
	if { [llength $b] != 3 } {
		error "dimension mismatch"
	}
	
	set x0 [lindex $a 0]
	set y0 [lindex $a 1]
	set z0 [lindex $a 2]
	set x1 [lindex $b 0]
	set y1 [lindex $b 1]
	set z1 [lindex $b 2]

	set c {0 0 0}
	
	lset c 0 [expr ($y0 * $z1) - ($y1 * $z0)]
	lset c 1 [expr ($x1 * $z0) - ($x0 * $z1)]
	lset c 2 [expr ($x0 * $y1) - ($x1 * $y0)]
	
	return $c
}

