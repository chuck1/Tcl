# Pointwise V17.0 Journal file - Sun Sep 22 15:17:07 2013

package require PWI_Glyph 2.17.0

pw::Application setUndoMaximumLevels 5
pw::Application reset
pw::Application markUndoLevel {Journal Reset}

pw::Application clearModified


source "/nfs/mohr/sva/work/rymalc/bin/pointwise/proc.tcl"

set verbose 0

#
# -----------------------------------------------------------------------------------------------------
#
# number of sections
set n 12
set empty_group [list [list] [list]]
set points [range 0 22]
set cons [range 0 31]
set doms [lfill [range 0 10] [expr $n+1]]
set dom_group [lfill [lfill $empty_group 4] [expr $n+1]]
set blocks [lfill [range 0 10] $n]
set dims [lfill 6 31]

# --------------------
set x [list 0.0 -0.3 -0.5]

set y [list [expr -0.7 - 1.5875] -0.70 -0.50 -0.30 -0.25 -0.125 0.0 0.125 0.25 0.30 0.50 2.45 [expr 2.45 + 1.5875]]

lset dims  0 5
lset dims  4 5
lset dims  5 5
lset dims  6 5
lset dims  7 5
lset dims  8 5
lset dims 18 5
lset dims 19 5
lset dims 20 5
lset dims 25 5

set delta_b_1   0.04
set delta_e_1   0.02

set steps_eighth 4
set angle        180

set axis0 {0 0 0}
set axis1 {0 0 1}

set ext_dist [lfill 1.0 $n]
set ext_step [lfill 20 $n]

# --------------------------------------------------------------------------------
# INIT
# -----------------------------------------------------------------------------------------------------
# calculations
set steps [expr $steps_eighth * 4]

lset dims 24 [expr $steps_eighth + 1]
lset dims 30 [expr [expr $steps_eighth * 2] + 1]
lset dims 26 [expr $steps_eighth + 1]

lset dims 21 [lindex $dims 5]

lset dims  9 [expr [lindex $dims 24] + [lindex $dims 25] - 1]
lset dims 22 [lindex $dims 9]
lset dims 23 [lindex $dims 9]
lset dims 28 [lindex $dims 9]
lset dims 29 [lindex $dims 9]
lset dims 17 [lindex $dims 9]

lset dims 10 [lindex $dims  8]
lset dims 11 [lindex $dims  7]
lset dims 12 [lindex $dims  6]
lset dims 13 [lindex $dims 30]
lset dims 14 [lindex $dims 20]
lset dims 15 [lindex $dims 19]
lset dims 16 [lindex $dims 18]

lset dims 27 [lindex $dims 25]

# ----------------------------------------------------------
# POINTS
lset points 0  [list [lindex $x 0] [lindex $y  7] 0.0]
lset points 1  [list [lindex $x 0] [lindex $y  8] 0.0]
lset points 2  [list [lindex $x 0] [lindex $y  9] 0.0]
lset points 3  [list [lindex $x 0] [lindex $y 10] 0.0]
lset points 4  [list [lindex $x 0] [lindex $y 11] 0.0]
lset points 5  [list [lindex $x 0] [lindex $y 12] 0.0]
lset points 6  [list [lindex $x 2] [lindex $y 12] 0.0]
lset points 7  [list [lindex $x 2] [lindex $y 11] 0.0]
lset points 8  [list [lindex $x 2] [lindex $y 10] 0.0]
lset points 9  [list [lindex $x 2] [lindex $y  9] 0.0]
lset points 10 [list [lindex $x 2] [lindex $y  3] 0.0]
lset points 11 [list [lindex $x 2] [lindex $y  2] 0.0]
lset points 12 [list [lindex $x 2] [lindex $y  1] 0.0]
lset points 13 [list [lindex $x 2] [lindex $y  0] 0.0]
lset points 14 [list [lindex $x 0] [lindex $y  0] 0.0]
lset points 15 [list [lindex $x 0] [lindex $y  1] 0.0]
lset points 16 [list [lindex $x 0] [lindex $y  2] 0.0]
lset points 17 [list [lindex $x 0] [lindex $y  3] 0.0]

lset points 20 [list [lindex $x 1] [lindex $y  9] 0.0]
lset points 21 [list [lindex $x 1] [lindex $y  3] 0.0]

# -------------------------------------------------------------------------------------------------
# connectors
lset cons 0 [createTwoPtLineCon [lindex $points 0] [lindex $points 1] [lindex $dims 0] $delta_b_1 $delta_e_1]


# --------------------------------------------------------------------------------------------------
# extrude rotate
set ret [createExtRot [lindex $cons 0] $axis0 $axis1 $angle $steps]

lset doms 0 1 [lindex $ret 0]
lset cons 1 [lindex $ret 2]
lset cons 2 [lindex $ret 3]
lset cons 3 [lindex $ret 4]

lset points 18 [[lindex $cons 2] getPosition -arc 0]

# -----------------------------------------------
# MORE CONNECTORS
set cons [createTwoPtLineChain $cons 5 [lrange $points 1 18] [lrange $dims 5 21]]

lset cons 4 [createTwoPtLineCon [[lindex $cons 0] getPosition -arc 0] [[lindex $cons 2] getPosition -arc 1] [lindex $dims 4]]

lset cons 22 [createTwoPtLineBetween $cons 7 1 11 0 [lindex $dims 22]]
lset cons 23 [createTwoPtLineBetween $cons 6 1 12 0 [lindex $dims 23]]
lset cons 24 [createTwoPtLineCon [[lindex $cons 5] getPosition -arc 1] [lindex $points 20] [lindex $dims 24]]
lset cons 25 [createTwoPtLineBetween $cons 24 1 13 0 [lindex $dims 25]]
lset cons 26 [createTwoPtLineCon [[lindex $cons 20] getPosition -arc 1] [lindex $points 21] [lindex $dims 26]]
lset cons 27 [createTwoPtLineBetween $cons 26 1 14 0 [lindex $dims 27]]
lset cons 28 [createTwoPtLineBetween $cons 19 1 15 0 [lindex $dims 28]]
lset cons 29 [createTwoPtLineBetween $cons 18 1 16 0 [lindex $dims 29]]
lset cons 30 [createTwoPtLineBetween $cons 24 1 27 0 [lindex $dims 30]]
# -------------------------------------------------
# DOMAINS
lset doms 0 0 [createDomUnstr [lselect $cons [list 3 4]]]

lset doms 0 2 [createDomStr   [lselect $cons [list  1  5 24 30 26 21]]]
lset doms 0 3 [createDomStr   [lselect $cons [list 13 25 27 30]]]
lset doms 0 4 [createDomStr   [lselect $cons [list  8  9 10 22]]]
lset doms 0 5 [createDomStr   [lselect $cons [list  7 11 22 23]]]
lset doms 0 6 [createDomStr   [lselect $cons [list  6 12 23 24 25]]]
lset doms 0 7 [createDomStr   [lselect $cons [list 14 20 26 27 28]]]
lset doms 0 8 [createDomStr   [lselect $cons [list 15 19 28 29]]]
lset doms 0 9 [createDomStr   [lselect $cons [list 16 17 18 29]]]

# DOM_GROUP
lset dom_group 0 0 0 [list [lindex $doms 0 1]]
lset dom_group 0 0 1 [list [lindex $doms 0 0]]
lset dom_group 0 1 0 [list [lindex $doms 0 2] [lindex $doms 0 3] [lindex $doms 0 5] [lindex $doms 0 6] [lindex $doms 0 7] [lindex $doms 0 8]]
lset dom_group 0 2 0 [list [lindex $doms 0 4]]
lset dom_group 0 3 0 [list [lindex $doms 0 9]]


# ----------------------------------------------------------------------------------------------------
# blocks
# initialize bc lists
set pair_symm [list]
set pair_wall [list]
set blck_flui [list]
set blck_sold [list]

puts "[lindex $dom_group 0]"

proc initial {a b} {
	puts "initial -------------------------------------------------------------------------------------------------"
	global blocks doms dom_group pair_symm pair_wall blck_flui blck_sold ext_dist ext_step

	foreach c [range 0 [llength [lindex $dom_group $a]]] {
		puts "[lindex $dom_group $a $c 0]"
		puts "[lindex $dom_group $a $c 1]"
		set ret [createExtTrans [lindex $dom_group $a $c 0] [lindex $dom_group $a $c 1] [list 0 0 1] [lindex $ext_dist $a] [lindex $ext_step $a]] 
	
		
		lset dom_group $b $c 0 [lindex $ret 2]
		lset dom_group $b $c 1 [lindex $ret 3]
	
	}
	
	# initial blocks
	# fluid
	puts "[lindex $dom_group $a 0 0]"
	puts "[lindex $dom_group $a 0 1]"
	set ret [createExtTrans [lindex $dom_group $a 0 0] [lindex $dom_group $a 0 1] [list 0 0 1] [lindex $ext_dist $a] [lindex $ext_step $a]] 
	
	#lset blocks $a 0 [lindex $ret 1 0]
	#lset blocks $a 1 [lindex $ret 0 0]

	lset dom_group $b 0 0 [lindex $ret 2]
	lset dom_group $b 0 1 [lindex $ret 3]
	
	#lset doms $b 0 [lindex [list_block [lindex $ret 1 0]] 3]
	#lset doms $b 1 [lindex [list_block [lindex $ret 0 0]] 5]
	
	#lappend pair_symm [list [lindex $ret 0 0] [lindex [list_block [lindex $ret 0 0 ]] 2]]
	#lappend pair_symm [list [lindex $ret 0 0] [lindex [list_block [lindex $ret 0 0 ]] 4]]
	#lappend pair_symm [list [lindex $ret 1 0] [lindex [list_block [lindex $ret 1 0 ]] 2]]

	#lappend blck_flui [lindex $ret 0 0]
	#lappend blck_flui [lindex $ret 1 0]
	
	# solid 0
	set ret [createExtTrans [lindex $dom_group $a 1 0] [lindex $dom_group $a 1 1] [list 0 0 1] [lindex $ext_dist $a] [lindex $ext_step $a]] 
	lset dom_group $b 1 0 [lindex $ret 2]
	lset dom_group $b 1 1 [lindex $ret 3]
	

	#lset blocks $a 2 [lindex $ret 0 0]
	#lset blocks $a 3 [lindex $ret 0 3]
	#lset blocks $a 5 [lindex $ret 0 2]
	#lset blocks $a 6 [lindex $ret 0 1]
	
	#lset doms $b 2 [lindex [list_block [lindex $ret 0 0]] 7]
	#lset doms $b 3 [lindex [list_block [lindex $ret 0 3]] 5]
	#lset doms $b 5 [lindex [list_block [lindex $ret 0 2]] 9]
	#lset doms $b 6 [lindex [list_block [lindex $ret 0 1]] 9]

	#lappend pair_symm [list [lindex $ret 0 0] [lindex [list_block [lindex $ret 0 0 ]] 1]]
	#lappend pair_symm [list [lindex $ret 0 0] [lindex [list_block [lindex $ret 0 0 ]] 3]]
	#lappend pair_symm [list [lindex $ret 0 1] [lindex [list_block [lindex $ret 0 1 ]] 8]]
	#lappend pair_symm [list [lindex $ret 0 2] [lindex [list_block [lindex $ret 0 2 ]] 4]]
	#lappend pair_symm [list [lindex $ret 0 1] [lindex [list_block [lindex $ret 0 1 ]] 7]]
	#lappend pair_symm [list [lindex $ret 0 2] [lindex [list_block [lindex $ret 0 2 ]] 5]]

	#lappend pair_wall [getPair $ret {0 1} 4]
	#lappend pair_wall [getPair $ret {0 1} 5]
	#lappend pair_wall [getPair $ret {0 2} 7]
	#lappend pair_wall [getPair $ret {0 2} 8]
	#lappend pair_wall [getPair $ret {0 3} 2]

	#lappend blck_sold [lindex $ret 0 0]
	#lappend blck_sold [lindex $ret 0 1]
	#lappend blck_sold [lindex $ret 0 2]
	#lappend blck_sold [lindex $ret 0 3]

	# solid 1
	set ret [createExtTrans [lindex $dom_group $a 2 0] [lindex $dom_group $a 2 1] [list 0 0 1] [lindex $ext_dist $a] [lindex $ext_step $a]] 

	lset dom_group $b 2 0 [lindex $ret 2]
	lset dom_group $b 2 1 [lindex $ret 3]
	

	#lset blocks $a 4 [lindex $ret 0 0]
	
	#lset doms $b 4 [lindex [list_block [lindex $ret 0 0]] 5]

	#lappend pair_symm [getPair $ret {0 0} 2]

	#lappend pair_wall [getPair $ret {0 0} 3]
	#lappend pair_wall [getPair $ret {0 0} 4]

	#lappend blck_sold [lindex $ret 0 0]

	# solid 2
	set ret [createExtTrans [lindex $dom_group $a 3 0] [lindex $dom_group $a 3 1] [list 0 0 1] [lindex $ext_dist $a] [lindex $ext_step $a]] 
	
	lset dom_group $b 3 0 [lindex $ret 2]
	lset dom_group $b 3 1 [lindex $ret 3]
	

	#lset blocks $a 7 [lindex $ret 0 0]
	
	#lset doms $b 7 [lindex [list_block [lindex $ret 0 0]] 5]
	
	#lappend pair_symm [getPair $ret {0 0} 4]

	#lappend pair_wall [getPair $ret {0 0} 2]
	#lappend pair_wall [getPair $ret {0 0} 3]
	
	#lappend blck_sold [lindex $ret 0 0]
	
	#return [list $blocks $doms $pair_symm $blck_flui $blck_sold]
}

proc repeat {a b} {
	puts "repeat a = $a b = $b --------------------------------------------------------------------------------------------------"
	global blocks doms pair_symm pair_wall blck_flui blck_sold ext_dist ext_step
	
	# initial blocks
	# fluid
	set ret [createExtTrans [list [lindex $doms $a 0]] [list [lindex $doms $a 1]] [list 0 0 1] [lindex $ext_dist $a] [lindex $ext_step $a]] 
	
	lset blocks $a 0 [lindex $ret 1 0]
	lset blocks $a 1 [lindex $ret 0 0]
	
	lset doms $b 0 [lindex [list_block [lindex $ret 1 0]] 3]
	lset doms $b 1 [lindex [list_block [lindex $ret 0 0]] 5]
	
	lappend pair_symm [getPair $ret {1 0} 2]
	lappend pair_symm [getPair $ret {0 0} 2]
	lappend pair_symm [getPair $ret {0 0} 4]

	lappend blck_flui [lindex $ret 0 0]
	lappend blck_flui [lindex $ret 1 0]

	# solid 0
	set indices [list [list $a 2] [list $a 3] [list $a 5] [list $a 6]]
	set ret [createExtTrans {} [lselect $doms $indices] [list 0 0 1] [lindex $ext_dist $a] [lindex $ext_step $a]] 
	
	lset blocks $a 2 [lindex $ret 0 0]
	lset blocks $a 3 [lindex $ret 0 3]
	lset blocks $a 5 [lindex $ret 0 2]
	lset blocks $a 6 [lindex $ret 0 1]
	
	lset doms $b 2 [lindex [list_block [lindex $ret 0 0]] 7]
	lset doms $b 3 [lindex [list_block [lindex $ret 0 3]] 8]
	lset doms $b 5 [lindex [list_block [lindex $ret 0 2]] 8]
	lset doms $b 6 [lindex [list_block [lindex $ret 0 1]] 5]
	
	lappend pair_symm [getPair $ret {0 0} 1]
	lappend pair_symm [getPair $ret {0 0} 3]
	lappend pair_symm [getPair $ret {0 2} 6]
	lappend pair_symm [getPair $ret {0 2} 7]
	lappend pair_symm [getPair $ret {0 3} 3]
	lappend pair_symm [getPair $ret {0 3} 4]

	lappend pair_wall [getPair $ret {0 1} 2]
	lappend pair_wall [getPair $ret {0 2} 3]
	lappend pair_wall [getPair $ret {0 2} 4]
	lappend pair_wall [getPair $ret {0 3} 6]
	lappend pair_wall [getPair $ret {0 3} 7]

	lappend blck_sold [lindex $ret 0 0]
	lappend blck_sold [lindex $ret 0 1]
	lappend blck_sold [lindex $ret 0 2]
	lappend blck_sold [lindex $ret 0 3]

	# solid 1
	set indices [list [list $a 4]]
	set ret [createExtTrans {} [lselect $doms $indices] [list 0 0 1] [lindex $ext_dist $a] [lindex $ext_step $a]] 
	
	lset blocks $a 4 [lindex $ret 0 0]
	
	lset doms $b 4 [lindex [list_block [lindex $ret 0 0]] 5]

	lappend pair_symm [getPair $ret {0 0} 2]

	lappend pair_wall [getPair $ret {0 0} 3]
	lappend pair_wall [getPair $ret {0 0} 4]

	lappend blck_sold [lindex $ret 0 0]

	# solid 2
	set indices [list [list $a 7]]
	set ret [createExtTrans {} [lselect $doms $indices] [list 0 0 1] [lindex $ext_dist $a] [lindex $ext_step $a]] 
		
	lset blocks $a 7 [lindex $ret 0 0]
	
	lset doms $b 7 [lindex [list_block [lindex $ret 0 0]] 5]

	lappend pair_symm [getPair $ret {0 0} 4]

	lappend pair_wall [getPair $ret {0 0} 2]
	lappend pair_wall [getPair $ret {0 0} 3]

	lappend blck_sold [lindex $ret 0 0]

	#return [list $blocks $doms $pair_symm $blck_flui $blck_sold]
}

initial 0 1
#set blocks [lindex $ret 0]
#set doms [lindex $ret 1]
#set pair_symm [lindex $ret 2]

#puts "$blocks"
#puts "$doms"
	
# repeated blocks
foreach a [range 1 $n] {
	set b [expr $a + 1]
	
	initial $a $b
	#set blocks [lindex $ret 0]
	#set doms [lindex $ret 1]
	#set pair_symm [lindex $ret 2]
	
}


#----------------------------------
pw::Application setCAESolver {ANSYS FLUENT} 3
#----------------------------------
set a [expr $n - 1]
set pair_inlt [list [list [lindex $blocks 0 0]  [lindex $doms 0 0]]  [list [lindex $blocks 0 1]  [lindex $doms 0 1]]]
set pair_otlt [list [list [lindex $blocks $a 0] [lindex $doms $n 0]] [list [lindex $blocks $a 1] [lindex $doms $n 1]]]

# end walls
lappend pair_wall [list [lindex $blocks 0 2] [lindex $doms 0 2]]
lappend pair_wall [list [lindex $blocks 0 3] [lindex $doms 0 3]]
lappend pair_wall [list [lindex $blocks 0 4] [lindex $doms 0 4]]
lappend pair_wall [list [lindex $blocks 0 5] [lindex $doms 0 5]]
lappend pair_wall [list [lindex $blocks 0 5] [lindex $doms 0 6]]
lappend pair_wall [list [lindex $blocks 0 6] [lindex $doms 0 7]]
lappend pair_wall [list [lindex $blocks 0 6] [lindex $doms 0 8]]
lappend pair_wall [list [lindex $blocks 0 7] [lindex $doms 0 9]]
lappend pair_wall [list [lindex $blocks $a 2] [lindex $doms $n 2]]
lappend pair_wall [list [lindex $blocks $a 3] [lindex $doms $n 3]]
lappend pair_wall [list [lindex $blocks $a 4] [lindex $doms $n 4]]
lappend pair_wall [list [lindex $blocks $a 5] [lindex $doms $n 5]]
lappend pair_wall [list [lindex $blocks $a 6] [lindex $doms $n 6]]
lappend pair_wall [list [lindex $blocks $a 7] [lindex $doms $n 7]]

# create bc
set bc_inlt [createBC "inlet"    {Velocity Inlet}  $pair_inlt]
set bc_otlt [createBC "outlet"   {Pressure Outlet} $pair_otlt]

set bc_symm [createBC "symmetry" Symmetry          $pair_symm]
set bc_wall [createBC "wall"     Wall              $pair_wall]
#----------------------------------
set vc_flui [createVC "fluid" Fluid $blck_flui]
set vc_sold [createVC "solid" Solid $blck_sold]
#----------------------------------

# export
set _TMP(mode_10) [pw::Application begin CaeExport [pw::Entity sort $blck_flui]]
  $_TMP(mode_10) initialize -type CAE {case.cas}
  if {![$_TMP(mode_10) verify]} {
    error "Data verification failed"
  }
  $_TMP(mode_10) write
$_TMP(mode_10) end
unset _TMP(mode_10)

# save
pw::Application save {pw.pw}

# view
pw::Display resetView +Z

