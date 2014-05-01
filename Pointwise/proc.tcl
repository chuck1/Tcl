source "/nfs/mohr/sva/work/rymalc/bin/pointwise/list.tcl"
source "/nfs/mohr/sva/work/rymalc/bin/pointwise/search.tcl"
source "/nfs/mohr/sva/work/rymalc/bin/pointwise/vector.tcl"


proc createExtRot {con axis0 axis1 angle steps} {
	puts "create from connector $con"
	
	set creator [pw::Application begin Create]
	set edgelist [pw::Edge createFromConnectors [list $con]]
	set edge [lindex $edgelist 0]
	
	puts "create from edge $edge"
	
	set dom [pw::DomainStructured create]
	$dom addEdge $edge
	
	$creator end

	set extruder [pw::Application begin ExtrusionSolver [list $dom]]
	
	$extruder setKeepFailingStep true

	$dom setExtrusionSolverAttribute Mode Rotate
	$dom setExtrusionSolverAttribute RotateAxisStart $axis0
	$dom setExtrusionSolverAttribute RotateAxisEnd [pwu::Vector3 add $axis0 $axis1]
	$dom setExtrusionSolverAttribute RotateAngle $angle
	
	$extruder run $steps
	
	$extruder end
	
	set ret [list $dom]
	
	set a 1
	while {$a <= [$dom getEdgeCount]} {
		set edge [$dom getEdge $a]
	
		#puts "edge $edge"
	
		set b 1
		while {$b <= [$edge getConnectorCount]} {
			set con [$edge getConnector $b]
			
			lappend ret {*}$con
			
			#puts "  connector $con"
			
			set c 1
			while {$c <= [$con getSegmentCount]} {
				set seg [$con getSegment $c]

				#puts "    segment $seg"

				set c [expr $c + 1]
			}
			
			set begin [$con getNode Begin]
			set end [$con getNode End]
			
			set point [$begin getPoint]			

			#puts "    begin $begin"
			#puts "      point $point"
			#puts "    end $end"
			
			set b [expr $b + 1]
		}
		
		set a [expr $a + 1]
	}
	
	return $ret
}
proc createDomUnstr { conlist } {
	#puts "domain unstructured"
	#puts $conlist
	#puts [names $conlist]

	pw::Application setGridPreference Unstructured
	set dom [pw::DomainUnstructured createFromConnectors -manifold -reject unused_cons -solid $conlist]
	
	
	if {[llength $unused_cons] != 0} {
		puts [names $conlist]
		error "[llength $unused_cons] connectors unused"
	}
	
	return $dom
}
proc createDomStr { conlist } {
	#puts "create domain structured"
	#puts $conlist
	#puts [names $conlist]
	pw::Application setGridPreference Structured
	
	if { [catch {
		set dom [pw::DomainStructured createFromConnectors -reject unused_cons -solid $conlist]
	}]} {
		puts "create dom str: $conlist"
		error "error occured"
	}
	
	if {[llength $unused_cons] != 0} {
		puts [names $conlist]
		error "[llength $unused_cons] connectors unused"
	}

	return $dom
}
proc circle_point_center_angle { point center angle axis {dim 5} {space {0 0}} } {
	set creator [pw::Application begin Create]
	
	set seg [pw::SegmentCircle create]
	
	$seg addPoint $point
	$seg addPoint $center
	$seg setEndAngle $angle $axis
	
	set con [pw::Connector create]
	$con addSegment $seg
	
	$con setDimension $dim
	$con calculateDimension

	$creator end
	
	if {[lindex $space 0] > 0} {
		#puts "[lindex $delta 0]"
		[$con getDistribution 1] setBeginSpacing [lindex $space 0]
	}

	if {[lindex $space 1] > 0} {
		#puts "[lindex $delta 1]"
		[$con getDistribution 1] setEndSpacing [lindex $space 1]
	}
	
	return $con
}
proc createTwoPtLineCon {pt0 pt1 {dim 5} {delta {0 0}}} {
	#puts "pt0 $pt0"
	#puts "pt1 $pt1"

	set creator [pw::Application begin Create]
	set con [pw::Connector create]
	
	set seg [pw::SegmentSpline create]
	$seg addPoint $pt0
	$seg addPoint $pt1
  	
	$con addSegment $seg

	$con setDimension $dim
	$con setRenderAttribute PointMode All

	if {[lindex $delta 0] > 0.0} {
		#puts "[lindex $delta 0]"
		[$con getDistribution 1] setBeginSpacing [lindex $delta 0]
	}

	if {[lindex $delta 1] > 0.0} {
		#puts "[lindex $delta 1]"
		[$con getDistribution 1] setEndSpacing [lindex $delta 1]
	}

	$creator end
	return $con
}
proc createTwoPtLineBetween {cons ind0 arc0 ind1 arc1 dim {delta0 0.0} {delta1 0.0}} {
	set creator [pw::Application begin Create]
	set con [pw::Connector create]
	
	set seg [pw::SegmentSpline create]
	$seg addPoint [[lindex $cons $ind0] getPosition -arc $arc0]
	$seg addPoint [[lindex $cons $ind1] getPosition -arc $arc1]
  	
	$con addSegment $seg

	$con setDimension $dim
	$con setRenderAttribute PointMode All

	if {$delta0 > 0.0} {
		[$con getDistribution 1] setBeginSpacing $delta0
	}

	if {$delta1 > 0.0} {
		[$con getDistribution 1] setEndSpacing $delta1
	}

	$creator end
	return $con
}
proc createTwoPtLineChain {cons index points dims} {
	#puts "points $points"
	#puts "dims $dims"
	
	foreach a [range 0 [llength $dims]] {
		set ind_rep [expr $index + $a]
		#puts "a $a ind_rep $ind_rep"
		
		if { $a == 0 } {
			set point_0 [lindex $points $a]
			set point_1 [lindex $points [expr $a + 1]]
			set dim [lindex $dims $a]
			
			lset cons $ind_rep [createTwoPtLineCon $point_0 $point_1 $dim]
		} else {
			set point_0 [[lindex $cons [expr $ind_rep - 1]] getPosition -arc 1]
			set point_1 [lindex $points [expr $a + 1]]
			set dim [lindex $dims $a]

			lset cons $ind_rep [createTwoPtLineCon $point_0 $point_1 $dim]
		}
	}
	
	return $cons
}
proc createTwoPtLineChain2 {points dims spaces} {
	#puts "points $points"
	#puts "dims $dims"
	
	set cons [list]
	
	foreach a [range 0 [llength $dims]] {
		
		if { $a == 0 } {
			set point_0 [lindex $points $a]
			set point_1 [lindex $points [expr $a + 1]]
		} else {
			set point_0 [[lindex $cons [expr $a - 1]] getPosition -arc 1]
			set point_1 [lindex $points [expr $a + 1]]
		}
		set dim [lindex $dims $a]
		set space [lindex $spaces $a]
		
		#puts "$point_0 $point_1"
		lappend cons [createTwoPtLineCon $point_0 $point_1 $dim $space]
	}
	
	return $cons
}
proc names { entities } {
	set ret [list]
	
	foreach e $entities {
		if {[catch {
			set s [$e getName]
		}]} {
			set s 0
		}
		lappend ret $s
	}
	
	return $ret
}
proc getPair {ret b d} {
	set block [lindex $ret {*}$b]
	return [list $block [lindex [list_block $block] $d]]
}
proc createExtTrans { dom_list_str dom_list_unstr direction distance steps } {
	puts "createExtTrans ---------------------------------------------------------------------------------------"
	
	#puts "$dom_list_str"

	
	puts "structured domains:"
	puts "[names $dom_list_str]"
	puts "unstructured domains:"
	puts "[names $dom_list_unstr]"
	
	set creator [pw::Application begin Create]
		# unstructured
		set block_ext_list [list]

	        if { [llength $dom_list_unstr] > 0 } {
			set face_list_unstr [pw::FaceUnstructured createFromDomains $dom_list_unstr]
		
			foreach face $face_list_unstr {
				set block_ext [pw::BlockExtruded create]
				$block_ext addFace $face
				lappend block_ext_list $block_ext
			}
		}
		
		# structured
		set face_list_str   [pw::FaceStructured createFromDomains $dom_list_str]
		
		set block_str_list  [list]
		
		foreach face $face_list_str {
			set block_str [pw::BlockStructured create]
			$block_str addFace $face
			lappend block_str_list $block_str
		}
		
	$creator end
	
	set extruder [pw::Application begin ExtrusionSolver [list {*}$block_str_list {*}$block_ext_list]]
	        
		$extruder setKeepFailingStep true
		
		foreach block $block_ext_list {
	        	$block setExtrusionSolverAttribute Mode Translate
       	        	$block setExtrusionSolverAttribute TranslateDirection $direction
			$block setExtrusionSolverAttribute TranslateDistance $distance
		}
		
		foreach block $block_str_list {
		        $block setExtrusionSolverAttribute Mode Translate
			$block setExtrusionSolverAttribute TranslateDirection $direction
			$block setExtrusionSolverAttribute TranslateDistance $distance
		}
		
		$extruder run $steps
	
	$extruder end
	
	
#	set dom_list_str [list_block $extStrBlock]
#	set dom_list_ext [list_block $extExtBlock]
	
#	puts "[names $dom_list_str]"
#	puts "[names $dom_list_ext]"

	#---------------------------------------------------
	# find domains not adjacent to starting domains

	proc sub1 {blocks doms} {
		# general
		# cons0 = list of all cons adjacent to starting domains
		set temp [list]
		foreach dom $doms {
			lappend temp [getConnectors $dom]
		}
		set cons0 [lmerge $temp]
		puts "cons0=[names $cons0]"
		
		# doms = list of all domains
		set temp [list]
		foreach block $blocks {
			lappend temp [list_block $block]
		}
		set doms [lmerge $temp]
		
		# doms1 = domains not adjacent to starting domains
		# remove domains adjacent to any of cons0
		set doms1 [list]
		
		foreach dom $doms {
			set cons [getConnectors $dom]
			set add 1
			# search for starting cons
			foreach c $cons0 {
				if {[lsearch $cons $c] > -1} {
					set add 0
				}
			}
	
			if {$add == 1} {
				lappend doms1 $dom
			}
		}
		
		puts "doms1=[names $doms1]"

		return $doms1
	}
	
	# for structured
	set dom_str_1 [sub1 $block_str_list $dom_list_str]

	# for unstructured
	set dom_uns_1 [sub1 $block_ext_list $dom_list_unstr]
	
	#------------------------------------------------
	set a 0
	set b 0
	puts "structured blocks:"
	foreach block $block_str_list {
		set c 0
		#puts "    [names $block]"
		set doms [list_block $block]
		foreach dom $doms {
			#puts "       {$a $b} $c [names $dom]"
			set c [expr $c + 1]
			
			set cons [getConnectors $dom]
			
			foreach con $cons {
				#puts "            [names $con]"
			}
		}
		set b [expr $b + 1]
	}
	
	set a 1
	set b 0
	puts "extruded blocks:"
	foreach block $block_ext_list {
		set c 0
		#puts "    [names $block]"
		set dom_names [names [list_block $block]]
		foreach dom_name $dom_names {
			#puts "        {$a $b} $c $dom_name"
			set c [expr $c + 1]
		}
		set b [expr $b + 1]
	}
	
	set ret [list $block_str_list $block_ext_list $dom_str_1 $dom_uns_1]
	
	return $ret
}	
proc createBC {name type dom} {
	set bc [pw::BoundaryCondition create]
	$bc setName $name
	$bc setPhysicalType $type
	$bc apply $dom
	return $bc
}
proc createVC {name type blk} {
	set vc [pw::VolumeCondition create]
	$vc setName $name
	$vc setPhysicalType $type
	$vc apply $blk
	return $vc
}
proc create_block_structured {domains} {
	#puts $domains
	#puts [names $domains]

	if {[catch {
		set block [pw::BlockStructured createFromDomains -reject unused_domains $domains]
	}]} {
		puts "create_block_structured [names $domains]"
		error "error"
	}
	
	if {[llength $unused_domains] != 0} {
		puts [names $unused_domains]
		error "[llength $unused_domains] unused domains"
	}

	return $block
}
proc create_block_unstructured { dom } {
	#puts $dom
	#puts [names $dom]

	if {[catch {
		set block [pw::BlockUnstructured createFromDomains -reject unused_domains $dom]
	}]} {
		puts "create_block_structured [names $dom]"
		error "error"
	}

	if {[llength $unused_domains] != 0} {
		puts [names $unused_domains]
		error "[llength $unused_domains] unused domains"
	}

	return $block
}
proc createPointPointCenterCircle { p1 p2 c {dim 11} {delta {0 0}}} {
	
	set creator [pw::Application begin Create]
	
	set segment [pw::SegmentCircle create]
	
	$segment addPoint $p1
	$segment addPoint $p2
	$segment setCenterPoint $c
	
	set con [pw::Connector create]
	
	$con addSegment $segment
	
	puts "dim = $dim"
	
	$con setDimension $dim
	
	
	if {[lindex $delta 0] > 0.0} {
		#puts "[lindex $delta 0]"
		[$con getDistribution 1] setBeginSpacing [lindex $delta 0]
	}

	if {[lindex $delta 1] > 0.0} {
		#puts "[lindex $delta 1]"
		[$con getDistribution 1] setEndSpacing [lindex $delta 1]
	}

	$creator end
	
	return $con
}
proc create_extrude_rotate_domain {doms center axis angle steps} {

	set creator [pw::Application begin Create]
	
	set faces [pw::FaceStructured createFromDomains $doms]
	
	set block [pw::BlockStructured create]
	
	foreach face $faces {
		$block addFace $face
	}
		
	$creator end

	set extruder [pw::Application begin ExtrusionSolver [list $block]]
	
	$extruder setKeepFailingStep true

	$block setExtrusionSolverAttribute Mode Rotate

	$block setExtrusionSolverAttribute RotateAxisStart $center
	$block setExtrusionSolverAttribute RotateAxisEnd [pwu::Vector3 add $center $axis]
	$block setExtrusionSolverAttribute RotateAngle $angle
	
	$extruder run $steps

	$extruder end

	return $block
}




