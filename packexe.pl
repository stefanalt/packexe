#!/usr/bin/perl

# packexe.pl: This is a very simple "packer" for Linux executables.
# All required librabries and the linker are copied into a selected
# package directory, along with a laucher script that runs the linker
# to start the executable with all libraries taken from the package
# directory. Thereby running the executable is not depending to
# the system library and linker.

# Gotchas:
# DLLs that are loaded dynamically are not considered

use strict;
use File::Basename;

sub usage {
    print "usage: packexe.pl destdir exefile1 [exefile2]\n";
    print "Get libraries and linker needed for <exefiles> and\n";
    print "store everyting into <destdir>.\n";
    print "\n";
    print "The executables are renamed to <destdir/exefile_f>, and\n";
    print "a launcher script <destdir/exefile> is created.\n";
    print "\n";
    print "EXAMPLE\n";
    print "packexe.pl /opt/bnxtnvm bnxtnvm\n";
    print "packexe.pl /opt/tools ls cp cat\n";

    exit 1;
}

my $dbg = 0;
sub dbgprint {
    if( $dbg == 1 ){
	print STDERR join("", "dbg: ", @_);
    }
}


my $dir = shift // usage();
my @exes = @ARGV;
if( scalar(@exes) == 0 ){
    usage;
}

print "packing " . join(",",@exes) . " to: $dir\n";

foreach my $exe (@exes) {

    my $exepath = `which $exe`;
    chomp($exepath);

    die "$exe not found" unless -f $exepath;
    die "$exe not binary" unless -B $exepath;
    
    my $dlls = `ldd $exepath`;
    my $linker;
    
    (my $exe) = fileparse($exepath);
    
    dbgprint "processing exe: $exe\n";
    dbgprint "path to exe is: $exepath\n";
   
    if( -e $dir ){
	die "$dir is not a directory" if ! -d $dir;
    } else {
	print "create missing $dir\n";
	mkdir $dir or die "can not create $dir: $!";
    }
    
    # Copy all libraries to destination dir    
    foreach my $line ( split('\n', $dlls)) {
	if( $line =~ /^\s*(\S+)\s+\(/ ){
	    # like: /lib64/ld-linux-x86-64.so.2 (0x00007f377c1e0000)
	    (my $fname, my $fpath) = fileparse($1);
	    if( $fname =~ /^linux-vdso/ ){
		next;
	    }
	    if( $fname =~ /^ld-linux/ ){
		$linker = $fname;
	    }
	    system("cp $fpath$fname $dir");
	}
	if( $line =~ /^\s*(\S+)\s+=>\s+(\S+)\s+\(/ ){
	    # like: libz.so.1 => /lib/x86_64-linux-gnu/libz.so.1 (0x00007f377af81000)
	    if( -l $2 ){
		(my $fname, my $fpath) = fileparse($2);
		my $lname = readlink($2);
		system("cp -dpR $fpath$fname $dir");
		system("cp -dpR $fpath$lname $dir");
	    } else {
		system("cp $2 $dir");
	    }
	}
    }
    
    # Copy the executable to the destination dir with _f suffix
    system("cp $exepath $dir/${exe}_f");
    
    system("strip --strip-unneeded $dir/*.so.*");
    
    # Create launcher to start the *_f file
    my $launcher = << "EOF";
#!/bin/sh
XEXE=`realpath "\$0"` 
XPATH=`dirname "\$XEXE"`
\$XPATH/$linker --library-path \$XPATH \$XPATH/${exe}_f "\$@"
EOF
    dbgprint $launcher;
    open(my $fh, ">", "$dir/$exe");
    print $fh $launcher;
    close $fh;
    chmod 0755, "$dir/$exe" or die "can not set -x permissions";
}

exit 0;
