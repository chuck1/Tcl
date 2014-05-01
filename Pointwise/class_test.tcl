#!/bin/tclsh

package require Itcl

itcl::class Foo {
	public variable a

	constructor { {na {}} } {
		set a 1

		do
	}
	
	method do {} {
		puts $a
	}

}

Foo f

f do

puts [f cget -a]

