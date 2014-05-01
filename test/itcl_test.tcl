#!bin/tclsh/

lappend auto_path [file join $env(HOME) usr lib]

set env(ITCL_LIBRARY) [file join $env(HOME) usr lib itcl3.4]

puts $auto_path

puts [package require Itcl]

itcl::class foo {
	variable a
}



