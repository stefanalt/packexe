# packexe
Packexe.pl packs a shared linux executable, together with it's libraries and the corresponding linker.

Have you ever had a Linux executable on one system, and want to run
it on another system (with same architecture)? 

Have you just copied it over, and then got:

    $ mybin
    mybin: error while loading shared libraries: libselinux.so.1: cannot open shared object file: No such file or directory

Or did you discover something like this:

    $ ldd mybin
    mybin: /lib/libc.so.6: version `GLIBC_2.17' not found (required by mybin)
    ...

So then, do you need to update your target system with new libraries? Not at all, you can use packexe:

    $ packexe.pl mybin_pack mybin

Copy the `mybin_pack` directory to the target system and run it:

    $ ./mybin_pack/mybin

For convenience, create a link somewhere in the search PATH:

    $ ln -s /yourdir/mybin_pack/mybin /usr/bin/mybin
    $ mybin

Alrough packexe is written in perl, you do not need perl on the system that runs the packed executable.

# packexe.pl Documentation

```
usage: packexe.pl destdir exefile1 [exefile2]
Get libraries and linker needed for <exefiles> and
store everyting into <destdir>.

The executables are renamed to <destdir/exefile_f>, and
a launcher script <destdir/exefile> is created.

EXAMPLE
packexe.pl /opt/bnxtnvm bnxtnvm
packexe.pl /opt/tools ls cp cat
``` 
