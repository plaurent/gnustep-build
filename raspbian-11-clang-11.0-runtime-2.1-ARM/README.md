builds GNUstep on Raspian 11 (Bullseye) with clang-11 and libobjc2.1

Note: as of Dec 2021, to compile libdispatch file "benchmark.c" with clang-11, the -Wno-implicit-int-float-conversion
flag must be given to avoid exiting with an error.  The two files in this directory, provide a patch
command to add it to the cmake flags.

Also newer PDFKit fixes an error where GWorkspace aborted with an "unknown protocol" message
upon startup.

libojc2.1 is important because 1.9 has some problems with imp_implementationWithBlock(),
at least using those returned IMPs as methods doesn't work.
