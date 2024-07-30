#!/bin/sh
#
#
#this script compiles all neuralynx code necessary to read neuralynx files from matlab.
#
#
#
#june 2004, ueli rutishauser, urut@caltech.edu
#

INCLMATLAB="/usr/local/matlab/extern/include/"
BINMATLAB="/usr/local/matlab/bin/"


rm *.o
rm *.mexglx

g++ -Wno-non-template-friend -c -I$INCLMATLAB Nlx_Code.cpp
g++ -Wno-non-template-friend -c -I$INCLMATLAB TimeBuf.cpp

g++ -Wno-non-template-friend -c -I$INCLMATLAB TimeEventBuf.cpp
g++ -Wno-non-template-friend -c -I$INCLMATLAB FileDataBucket.cpp 
g++ -Wno-non-template-friend -c -I$INCLMATLAB GeneralOperations.cpp

g++ -Wno-non-template-friend -c -I$INCLMATLAB ProcessorEV.cpp
g++ -Wno-non-template-friend -c -I$INCLMATLAB ProcessorCSC.cpp

g++ -Wno-non-template-friend -c -I$INCLMATLAB TimeCSCBuf.cpp
g++ -Wno-non-template-friend -c -I$INCLMATLAB TimeMClustTSBuf.cpp
g++ -Wno-non-template-friend -c -I$INCLMATLAB TimeSEBuf.cpp
g++ -Wno-non-template-friend -c -I$INCLMATLAB TimeSTBuf.cpp
g++ -Wno-non-template-friend -c -I$INCLMATLAB TimeTSBuf.cpp
g++ -Wno-non-template-friend -c -I$INCLMATLAB TimeTTBuf.cpp
g++ -Wno-non-template-friend -c -I$INCLMATLAB TimeVideoBuf.cpp


#now make matlab binary
$BINMATLAB/mex -o Nlx2MatEV_v3 Nlx2MatEV.cpp FileDataBucket.o GeneralOperations.o Nlx_Code.o ProcessorEV.o TimeBuf.o TimeEventBuf.o TimeCSCBuf.o TimeMClustTSBuf.o TimeSEBuf.o TimeSTBuf.o TimeTSBuf.o TimeTTBuf.o TimeVideoBuf.o
$BINMATLAB/mex -o Nlx2MatCSC_v3 Nlx2MatCSC.cpp FileDataBucket.o GeneralOperations.o Nlx_Code.o ProcessorCSC.o TimeBuf.o TimeEventBuf.o TimeCSCBuf.o TimeMClustTSBuf.o TimeSEBuf.o TimeSTBuf.o TimeTSBuf.o TimeTTBuf.o TimeVideoBuf.o


