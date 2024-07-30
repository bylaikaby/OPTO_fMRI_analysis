CC = mex
CFLAGS = -O
LIBS = $(HOME)/matlab/a/lib/iolib.a $(HOME)/matlab/a/lib/mxlib.a 
MATLABLIBS = -I$$MATLAB/extern/include $$MATLAB/extern/lib/$$ARCH/libmat.a
BASICLIBS = -lm
FULLLIBS =	-I/usr/include/bw -L/lib -L/usr/lib $(HOME)/lib/numerical.a $(HOME)/lib/iolib.a -lm 
LIB5 = -L/usr/i486-linux/libc5 
INSTALL = $(HOME)/matlab/a1/io/
INCLUDE = -I$(HOME)/include
LIBINSTALL = $(HOME)/matlab/a/lib

ALL = 	read_tt

all: $(ALL)

.c:
	$(CC) $(CFLAGS) $< 

read_cr: read_cr.c
	$(CC) $(CFLAGS) read_cr.c $(INCLUDE) $(LIBS) $(LIB5)

read_tt: read_tt.c
	$(CC) $(CFLAGS) read_tt.c $(INCLUDE) $(LIBS) $(LIB5)

list:
	ls -al $(ALL:=.c)  $(ALL:=.mexlx) 

install:
	cp -pv *.mexglx $(INSTALL)
