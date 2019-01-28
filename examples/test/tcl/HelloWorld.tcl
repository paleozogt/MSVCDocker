set OS [lindex $tcl_platform(os) 0]
if { $OS == "Windows" } {
    set sharedlibprefix ""
} else {
    set sharedlibprefix "lib"
}
load [file join [pwd] ${sharedlibprefix}HelloWorld[info sharedlibextension]]

puts [helloWorld]
