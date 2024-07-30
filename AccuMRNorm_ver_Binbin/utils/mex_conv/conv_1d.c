#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
double *u,*v;
int d1,d2,kk,ii;
double *w;
int dim;
int pos;

d1=mxGetNumberOfElements(prhs[0]);
d2=mxGetNumberOfElements(prhs[1]);
dim=d1+d2-1;

w=mxCalloc(dim,sizeof(double));

if(d1<d2)
{
 u= (double *)mxGetPr(prhs[0]);
 v= (double *)mxGetPr(prhs[1]);
}

else
{
 v= (double *)mxGetPr(prhs[0]);
 u= (double *)mxGetPr(prhs[1]);
 pos=d1;
 d1=d2;
 d2=pos;
}


plhs[0]=mxCreateDoubleMatrix(dim,1,mxREAL);
w=mxGetPr(plhs[0]);

 for (kk=0;kk<dim;kk++)
  {for (ii=0;ii<kk+1;ii++)
     { if (ii<d1)
       {
       pos=kk-ii;
       if(pos<d2)
       {
       *(w+kk)=*(w+kk)+*(u+ii)*(*(v+pos));
       }
       }
       else break;
     }
   }





	 











}

