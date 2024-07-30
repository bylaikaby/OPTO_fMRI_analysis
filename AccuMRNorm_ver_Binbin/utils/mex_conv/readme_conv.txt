


The .zip file contains:
1) this file readme_conv.txt   
2) mcgo_conv.c
3) prova.m       ----------> a m-file as example
4) conv_1d.c   --------> a function similar to mcgo_conv but FASTER (added in release 1.1 ** 13 october 2003 **)
  



mcgo_conv is must be mex-compiled ,i.e.

mex mcgo_conv.c

The function mcgo_conv is called in this way (from Matlab)

mcgo_conv(a,b)
where a and b are double 1-dimensional array
The results (if a is 1-dimensional array with n double components and b is a 1-dimensional array with m double components) is a 1-dimensional array with
n+m-1 components.

This function results VERY fast when 
the size of a and b are more or less equal 
and very large

The bigger are d1 and d2 The better is the speed improvement.





NOTES
if (size(a) >> size(b)) and they are small it's better to use matlab conv function

if size(a) or size(b) is very small it's better to use default matlab conv function

No input check is performed.




********************* example of speed improvement****
if vector a has 75000 components
anb b has 80000 
matlab conv ------> 210.6100  secs.
our conv    ---------> 92.5160    secs.

              speed  X 2.28
********************************************
if a has 37500 compinents and
b has 40000
conv(a,b)   -----> requires 23.1250 secs.
mcgo_conv----> requires 21.8600 secs.
       
      speed X 1.058


now the accelation is smallee because the vectors has less
components.

(PC Win2k 2.4 GHerzt 1Giga Ram)

***************************************

IS it all ok?

For more informations please contact:
Luigi Rosa
mobile +39-340-3463208
luigi.rosa@tiscali.it

MCGO  Matlab Code Generation and Optimization
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++ updated 13 october 2003 ***************************************************************
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Release 1.1
this bersion includes a new function:
conv_1d
which is faster than mcgo_conv
conv_1d.c must be mexcompiled  --------> mex conv_1d.c

example of use

conv_1d(a,b) where a and b are 2 monodimensional vectors
of size n and m
the result is a monodimensional array of size n+m-1 which is the 
convolution of arrays a and b

conv_1d is  FASTER THAN mcgo_conv 
and memory-optimized.



