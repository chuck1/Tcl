# Pointwise V17.0 Journal file - Sun Sep 22 15:17:07 2013

package require PWI_Glyph 2.17.0

pw::Application setUndoMaximumLevels 5
pw::Application reset
pw::Application markUndoLevel {Journal Reset}

pw::Application clearModified


pw::Database setModelSize 1
pw::Grid setNodeTolerance 1e-07
pw::Grid setConnectorTolerance 1e-07


source "/nfs/mohr/sva/work/rymalc/bin/pointwise/proc.tcl"

set verbose 0
# -----------------------------------------------------------------------------------------------------
set n 14
set empty_group [list [list] [list]]
set points [range 0 22]
set cons [range 0 31]
set doms [lfill [range 0 10] [expr $n+1]]
set dom_group [lfill [lfill $empty_group 4] [expr $n+1]]
set blocks [lfill [range 0 10] $n]
set dims [lfill 6 31]

# --------------------
set x [list 0.0 -0.0003 -0.0005]
set y [list [expr -0.0007 - 0.0015875] -0.00070 -0.00050 -0.00030 -0.00025 -0.000125 0.0 0.000125 0.00025 0.00030 0.00050 0.00245 [expr 0.00245 + 0.0015875]]
set angle        180

set axis0 {0 0 0}
set axis1 {0 0 1}

set ext_dist [list 0.007  0.0005362  0.0049276  0.0005362  0.002  0.002   0.005  0.005  0.002  0.002  0.0005362  0.0049276  0.0005362  0.007]

# ------------------------------------------------------------------------------------------------------------
# ---------------------------------------------VARIABLES------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------

lset dims  0 4
lset dims  4 4
lset dims  5 4
lset dims  6 5
lset dims  7 20
lset dims  8 20
lset dims 18 20
lset dims 19 5
lset dims 20 5
lset dims 25 4

set delta_b_1   0.00006
set delta_e_1   0.000025

set steps_eighth 3

set step_scale [list 10 10 10 20 20 10 10 10 10 20 20 20 20 10]

set ext_setp [list]
foreach i [range 0 [llength $ext_dist]] {
	set dist [lindex $ext_dist $i]
	set scal [lindex $step_scale $i]
	set step [expr {int(ceil($dist * $scal * 1000))}]
	puts "$dist $scal $step"
	lappend ext_step $step
}
puts "$ext_step"

# -----------------------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------------------
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
#puts "[lindex $dom_group 0]"

proc repeat {a b} {
	puts "initial -------------------------------------------------------------------------------------------------"
	global blocks doms dom_group pair_symm pair_wall blck_flui blck_sold ext_dist ext_step

	foreach c [range 0 [llength [lindex $dom_group $a]]] {
		puts "[lindex $dom_group $a $c 0]"
		puts "[lindex $dom_group $a $c 1]"
		set ret [createExtTrans [lindex $dom_group $a $c 0] [lindex $dom_group $a $c 1] [list 0 0 1] [lindex $ext_dist $a] [lindex $ext_step $a]] 
		
		lset dom_group $b $c 0 [lindex $ret 2]
		lset dom_group $b $c 1 [lindex $ret 3]
	}
}

foreach a [range 0 $n] {
	set b [expr $a + 1]
	repeat $a $b
}

#----------------------------------
pw::Application setCAESolver {ANSYS FLUENT} 3
#----------------------------------
# create bc
set bc_inlt [createBC "inlet"    {Velocity Inlet}  [list]]
set bc_otlt [createBC "outlet"   {Pressure Outlet} [list]]

set bc_symm [createBC "symmetry" Symmetry          [list]]
set bc_wall [createBC "wall"     Wall              [list]]
set bc_heat [createBC "heated"   Wall              [list]]
#---------------------------------
set vc_flui [createVC "fluid"    Solid [list]]
set vc_sold [createVC "solid"    Solid [list]]
#----------------------------------

# view
pw::Display resetView +Z

