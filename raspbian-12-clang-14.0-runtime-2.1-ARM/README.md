builds GNUstep on Raspian 12 (Bookworm) with clang-14 and libobjc2.1

Compiled swift-corelibs-libdispatch - November 2023 with clang-14
  - no patches needed for "benchmark.c" for warnings or errors
  - pulled from the HEAD
  - compiled cleanly

Also newer PDFKit fixes an error where GWorkspace aborted with an "unknown protocol" message upon startup.

libojc2.1 is important because 1.9 has some problems with imp_implementationWithBlock(), at least using those returned IMPs as methods doesn't work.
