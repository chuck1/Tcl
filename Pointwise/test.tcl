
package require PWI_Glyph 2.17.0

pw::Application reset

source "/nfs/mohr/sva/work/rymalc/bin/pointwise/compound.tcl"



set dims {{10 17 10} {10 17 10} {10 10 10}}
set ignores {{{1 1} {1 1} {-1 3}}}
set flags {0 0 0 0 0 0 0 1 1 0}
set Z {0 1 2 3}

set grid_output [grid {-6 -3 3 6} {-6 -3 3 6} $Z $dims 0 0 $ignores $flags]

set grid_info [lindex $grid_output 0]
set cons [lindex $grid_output 1]
set doms [lindex $grid_output 2]
set blocks [lindex $grid_output 3]

set tiles [lfill 0 4]


foreach a [range 0 4] {
	lset tiles $a [quarter_circle_tile [list -3 0 [lindex $Z $a]] {1 1 1} 2]
}

set tile_output [quarter_circle_tile_grid $tiles [lindex $dims 2]]
set conv [lindex $tile_output 0]
set domv [lindex $tile_output 1]

foreach a [range 0 4] {

	lset cons 0 1 1 $a [list [lindex $tiles $a 0 0 1 10] [lindex $tiles $a 1 0 1 10]]
	lset cons 0 1 2 $a [list [lindex $tiles $a 0 1 1 10] [lindex $tiles $a 1 1 1 10]]
	lset cons 1 1 1 $a [list [lindex $tiles $a 0 0 1  9] [lindex $tiles $a 0 1 1  9]]
	lset cons 1 2 1 $a [list [lindex $tiles $a 1 0 1  9] [lindex $tiles $a 1 1 1  9]]

}
foreach a [range 0 3] {
 	lset doms 0 1 1 $a [list [lindex $domv $a 0 0 9] [lindex $domv $a 0 1 9]]
	lset doms 0 2 1 $a [list [lindex $domv $a 1 0 9] [lindex $domv $a 1 1 9]]
	lset doms 1 1 1 $a [list [lindex $domv $a 0 0 10] [lindex $domv $a 1 0 10]]
	lset doms 1 1 2 $a [list [lindex $domv $a 0 1 10] [lindex $domv $a 1 1 10]]
}

set grid_output [grid_domains_and_blocks $grid_info $cons $doms $blocks]



