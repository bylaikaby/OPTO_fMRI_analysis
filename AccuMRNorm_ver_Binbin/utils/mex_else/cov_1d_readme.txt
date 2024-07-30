A faster covariance function for 1 or 2 monodimensional vectors

The zip file includes:

- readme.txt this file
- cov_1d.c  the mex file
- prova.m an example of use


cov_1d compute 1-dimensional covariance

Copy cov_1d.c in matlab current directory
mex compile this file:

mex cov_1d.c

To call this function:

cov_1d(a) returns the variance of the vector elements 
	  normalizes by (N-1) where N is the number of
          observations

cov_1d(a,0) returns the variance of the vector elements 
	    normalizes by (N-1) where N is the number of
            observations

cov_1d(a,1) returns the variance of the vector elements 
	    normalizes by (N) where N is the number of
            observations

cov_1d(a,b) a and b are monodimensional vectors with the same 
            size N. It returns E[(a-aa)(b-ba)] where aa=E[a]
            and ba=E[b]  E is the mathematical expectation
            normalizes by (N-1) where N is the number of
            observations

cov_1d(a,b,0) a and b are monodimensional vectors with the same 
              size N. It returns E[(a-aa)(b-ba)] where aa=E[a]
              and ba=E[b]  E is the mathematical expectation
              normalizes by (N-1) where N is the number of
              observations

cov_1d(a,b,1) a and b are monodimensional vectors with the same 
              size N. It returns E[(a-aa)(b-ba)] where aa=E[a]
              and ba=E[b]  E is the mathematical expectation
              normalizes by (N) where N is the number of
              observations

----------------------------------------------------
NOTE:
a and b must be REAL vectors (i.e. monodimensional)
----------------------------------------------------

From these relationships it follows that:
cov_1d(a,a)=cov_1d(a)=cov_1d(a,a,0)
cov_1d(a,a,1)=cov_1d(a,1)


sqrt(std(a))   is the standard deviation of vector a (normalized to N-1)
sqrt(std(a,1)) is the standard deviation of vector a (normalizaed to N)


cov_1d is faster than matlab cov function
and can be also used to compute std of
1-dimensional vector a

++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++

Example:

>> a=rand(1,30000000);
>> tic;v1=cov(a);toc

elapsed_time =

   2.10900000000000

>> tic;v2=cov_1d(a);toc

elapsed_time =

   0.75000000000000

>> 
++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++


Keyword: covariance, standard deviation







*******************************************************
*******************************************************

MCGO
Luigi Rosa
Via Centrale 35
67042 Civita di Bagno
L'Aquila -- Italy


Please contribute if you find this software useful.
email luigi.rosa@tiscali.it
mobile +39-340-3463208

Report bugs to luigi.rosa@tiscali.it
*******************************************************
*******************************************************