#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
double *u,*v;
double *u1,*v1;
int d1,d2,dmax,kk,ii,jj;
double *out,*w;
int dim;
int num;
int pos;

d1=mxGetNumberOfElements(prhs[0]);
d2=mxGetNumberOfElements(prhs[1]);
dim=d1+d2-1;

if (d1>d2)
dmax=d1;
else
dmax=d2;

num=dmax*2-1;
u1=mxCalloc(num,sizeof(double));
v1=mxCalloc(num,sizeof(double));
w=mxCalloc(num,sizeof(double));

u= (double *)mxGetPr(prhs[0]);
v= (double *)mxGetPr(prhs[1]);

for(ii=0;ii<d1;ii++)
   {*(u1+ii)=*(u+ii);
   }
for(ii=0;ii<d2;ii++)
   {*(v1+ii)=*(v+ii);
   }



/*--------------------- opero distinzione per accelerare i tempi --*/
if(d2>d1)
{
 for (kk=0;kk<num;kk++)
  {for (ii=0;ii<kk+1;ii++)
     { pos=kk-ii;
       if((ii<d1)&&(pos<d2))
       {
       *(w+kk)=*(w+kk)+*(u1+ii)*(*(v1+pos));
       }
     }
   }
}
else
{
 for (kk=0;kk<num;kk++)
  {for (ii=0;ii<kk+1;ii++)
     { pos=kk-ii;
       if((pos<d2)&&(ii<d1))
       {
       *(w+kk)=*(w+kk)+*(u1+ii)*(*(v1+pos));
       }
     }
   }
}

/*--------------------------------------------------------------------------------*/



	 
plhs[0]=mxCreateDoubleMatrix(dim,1,mxREAL);
out=mxGetPr(plhs[0]);
for (ii=0;ii<dim;ii++)
{*(out+ii)=*(w+ii);}









}

