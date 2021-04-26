Semi-successfully builds GNUstep (base) libraries on Raspian 10 with clang9 and libobjc2.1
libojc2.1 is important because 1.9 has some problems with imp_implementationWithBlock(),
at least using those returned IMPs as methods doesn't work.
Exception handling hasn't worked yet, but that could be a a different problem
