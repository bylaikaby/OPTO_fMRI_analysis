2007.01.17 YM@MPI Tuebingen


[download]
SON Library for Matlab by Malcolm Lidierth
  http://www.kcl.ac.uk/depsta/biomedical/cfnr/lidierth.html
SON Library (DLLs) by CED
  http://www.ced.co.uk

[Install]
- unzip SON Library for Matlab
- copy CED's library into 'son/SON Library'


// COMMENT, no need to do
//- create son32prototypes.m by
//  loadlibrary('son\SON Library\son32.dll','son\SON Library\Son.h','mfilename','son32prototypes.m')
//- correct errors in son32prototypes.m, mostly failed to get argument type.
//  TpCStr --> string,  WORD --> uint16,  BOOLEAN --> int16
//- move son32prototypes.m to 'son/son32'



[Modification to SON Libray for Matlab]
son/SON Libray
 - this directry should have DLL and headers downloaded from CED's site.
son/SON32/son32.m
 - adds following things if needed
-begin----------------------------------
structs.TMarker.packing=8;
structs.TMarker.members=struct('mark', 'int32', 'mvals', 'int8#4');
structs.TAdcMark.packing=8;
structs.TAdcMark.members=struct('m', 'TMarker', 'a', 'int16#4096');
structs.TRealMark.packing=8;
structs.TRealMark.members=struct('m', 'TMarker', 'r', 'single#512');
structs.TTextMark.packing=8;
structs.TTextMark.members=struct('m', 'TMarker', 't', 'int8#2048');
structs.TFilterMask.packing=8;
structs.TFilterMask.members=struct('lFlags', 'int32', 'aMask', 'uint8#32#4');
structs.TSONTimeDate.packing=8;
structs.TSONTimeDate.members=struct('ucHun', 'uint8', 'ucSec', 'uint8', 'ucMin', 'uint8', 'ucHour', 'uint8', 'ucDay', 'uint8', 'ucMon', 'uint8', 'wYear', 'uint16');
structs.TSONCreator.packing=8;
structs.TSONCreator.members=struct('acID', 'int8#8');
-end----------------------------------
son/SON32/SONFindSON32DLL.m
 - new function to find out where is son32.dll
son/SON32/SONLoad.m
 - no need to install Spike2 to PC.
 - load son32.dll with SONFindSON32DLL.m
son/SON32/SONWriteADCBlock.m
 - correct grammer error  (SONWriteADCBock --> SONWriteADCBlock, missing 'l')
son/SON32/C_Sources
 - copy MACHINE.h/Son.h/Sonintl.h/MACHINE.h from "SON Library"
son/SON32/C_Sources/SONLoadLibrary
 - new subfunction to use SONFindSON32DLL.m
son/SON32/C_Sources/SONDef.h
 - add a prototype as "HINSTANCE SONLoadLibrary(char *);"
son/SON32/C_Sources/Compile.m
 - add SONFloadLibrary.c for each line.
son/SON32/C_Sources/*.c
 - replace LoadLibrary(SON32) to SONLoadLibrary(SON32)
 - run "Compile.m" then copy mexw32 to SON32.
 - maybe just gatewaySONWriteExtMarkBlock and SONWriteMarkBlock 
