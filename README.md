# packexe.pl
Pack shared libraries and linker along with a Linux executable

Did you ever had a Linux executable on one system and need to run
it on another system (with same architecture)? Have you just copied it
over and then got:

> mybin: error while loading shared libraries: libselinux.so.1: cannot open shared object file: No such file or directory

And then you found something like this:

    $ ldd mybin
    mybin: /lib/libc.so.6: version `GLIBC_2.17' not found (required by mybin)
    ...

So then you need to update your target system with new libraries? No, just use packexe:

    $ packexe.pl mybin_pack mybin

Copy the mybin_pack directory to the target system and run it:

    $ ./mybin_pack/mybin

If it is for longer time, create a link somewhere in the search PATH

    $ ln -s /yourdir/mybin_pack/mybin /usr/bin/mybin
    $ mybin

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
