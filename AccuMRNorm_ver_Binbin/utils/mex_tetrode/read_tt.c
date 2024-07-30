/********************************************************************************

PROGRAM: read_tt.c 

DESCRIPTION:

    Load Neuralynx spike waveforms into matlab:

USE:

    w = read_tt( filename, varargin )

AUTHOR:

    Thanos Siapas
    Computation and Neural Systems
    Division of Biology, and Division of Engineering and Applied Science
    California Institute of Technology
    Pasadena, CA 91125
    thanos@mit.edu

DATES: Original  05/97
       Update[1]   06/97
       Update[2]   08/01/97 (gritsa)
       Update[3]   08/24/99 [ bring to parms format ]
       Update[4]   08/25/99 [incorporate tstart - tend ]

       Update[5]   08/07/01 [make Neuralynx the default format]
       Update[6]   08/10/01 [includes parameter extration]
       Update[?]   02/04/05 Yusuke Murayama@AGLOGO-MPI [compiled in windows]

********************************************************************************/

#define VERSION "4.00"

/*-----------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#if defined (_WIN32)
#include <windows.h>
#else
#include <unistd.h>
#endif
#include <math.h>
#include <mex.h>

#include "header.h"
#include "iolib.h"
#include "mxlib.h"


/*-----------------------------------------------------------------------------*/

#ifndef max
#define	max(A, B)	((A) > (B) ? (A) : (B))
#define	min(A, B)	((A) < (B) ? (A) : (B))
#endif

/*-----------------------------------------------------------------------------*/

#define MAX_PARAMS  8
#define SPIKE_NUMPOINTS 32

/*-----------------------------------------------------------------------------*/

/* Input Filename */

#define	FNAME   prhs[0]

/* Output Arguments */

#define RESULT   plhs[0]

/*-----------------------------------------------------------------------------*/
/* Structures */

/*
    class TTRec { 
    public: 
    LONGLONG qwTimeStamp; 
    long dwScNumber; 
    long dwCellNumber; 
    long dwParams[MAX_PARAMS]; 
    TetPoint snData[SPIKE_NUMPOINTS]; 
    }; 
*/

/*-----------------------------------------------------------------------------*/
/* Tetrode Spike Channel Record */


typedef struct tet_point_type {
  short adval[4];
} tet_point;


#pragma pack(1)
typedef struct TT_rec_type {

  UINT64 timestamp;                 /* timestamp */
  long scnumber;                    /* channel number */
  long cellnumber;                  /* cell # identification, determined by online cluster analysis */ 
  long params[MAX_PARAMS];          /* parameters calculated for data by the clustering algorithm */
  tet_point data[SPIKE_NUMPOINTS];  /* the A-D data samples */
  
} TT_rec;
#pragma pack()

typedef struct index_type {
  double *index;  
  long n;
  int file;
} Index;


/*-----------------------------------------------------------------------------*/

typedef struct parameter_type {

  FILE *fp;           /* file to read from */
  Index index;

  double *tt;
  double *time;
  double *wt[4];

  double *h;
  double tstart, tend;
  double tstart0, tend0;
  
  int header, headersize;

  int parameters;
  FILE *pfp;          /* parameters file */


  TT_rec tt_rec;
  int tt_rec_size;

  int verbose, convert, start, allspikes, spikereclen;
  long starti;

  double rate, nchannels, nelectrodes, dt;

  int tetrode, singletrode; 
  char *spiketype;

  int info; int process;
  long nmax;

} Parameters; 

/*-----------------------------------------------------------------------------*/

extern char *TimestampToString();
extern char *GetHeaderParameter();

/*-----------------------------------------------------------------------------*/

void Get_String( const mxArray *arg, char *str )
{
  int strlen; int status;
  
  strlen = (mxGetM(arg)*mxGetN(arg)*sizeof(mxChar))+1; 
  status = mxGetString(arg, str, strlen); 
  if (status != 0) mexErrMsgTxt("Could not convert string data.");
  
}

/*-----------------------------------------------------------------------------*/
/* Get File Information */

void Get_File_Info( Parameters *parms )
{

  struct stat fpstat;
  TT_rec tt_rec;
  long cfp;
  long nread;
  UINT64 timestamp;

  /*------------------------------------------------------------------------*/
  /* Find total number of records */
  
  fstat(fileno(parms->fp),&fpstat);
  parms->nmax = (fpstat.st_size - parms->headersize)/parms->tt_rec_size;
  if( parms->verbose ) fprintf( stderr, "Total Number of Records : %d\n", parms->nmax );

  /*------------------------------------------------------------------------*/
  /* Find start time */
  
  cfp = ftell( parms->fp );
  
  fprintf( stderr, "Headersize = %d, rec_size = %d \n", parms->headersize, parms->tt_rec_size );
  
  fseek( parms->fp, parms->headersize, SEEK_SET );
  nread = fread( &timestamp, sizeof(UINT64),1, parms->fp ); 
  if( nread != 1 ) mexErrMsgTxt("Error reading tetrode record." );
  if(parms->verbose) fprintf( stderr, "Starting time : %ld\t", timestamp/1000 );
  parms->tstart0 = TimestampToDouble(timestamp);

  fseek( parms->fp, -parms->tt_rec_size, SEEK_END );
  nread = fread( &timestamp, sizeof(UINT64),1, parms->fp ); 
  if( nread != 1 ) mexErrMsgTxt("Error reading tetrode record." );
  if( parms->verbose) fprintf( stderr, "Ending time : %ld\n", timestamp/1000 );
  parms->tend0 = TimestampToDouble(timestamp);

  /* rewind to original position */
  fseek( parms->fp, cfp, 0L);

}


/*-----------------------------------------------------------------------------*/
/* Process index file */

void ScanIndices( FILE *fp, Index *idx)
{
  int count;
  char line[1000];
  
  count = 0;
  while(!feof(fp)){
    if(fgets(line,1000,fp) == NULL) break;
    if(line[0] == '%') continue;
    count++;
  }
  idx->n = count;
}

/*-----------------------------------------------------------------------------*/
/* Read index file */

void ReadIndices( FILE *fp, Index *idx)
{
  int count;
  char line[1000];
  double fval;
  int nargs;;
  
  count = 0;
  fseek(fp,0L,0L);
  while(!feof(fp)){
    if(fgets(line,1000,fp) == NULL) break;
    if(line[0] == '%') continue;
    nargs = sgetargs(line,1,&fval);
    idx->index[count++] = (int)(fval+0.5);
  }
  idx->n = count;
}

/*-----------------------------------------------------------------------------*/
/* "Bhed" aka Divide and Conquer */

void Disect( Parameters *parms, long *il, long *ih, double t0)
{

  long i1,i2,i;
  UINT64 timestamp; 
  
  i1 = 0; i2 = parms->nmax; 

  while( 1 ) {
      
    i = (long) ((i1+i2)/2);
      
    fseek(parms->fp,(parms->start + i)* parms->tt_rec_size + parms->headersize,0L);

    if( fread(&timestamp,sizeof(UINT64),1,parms->fp) != 1 ) {
      mexErrMsgTxt("Error reading tetrode record." );
    }

    if( 0 ) {
      fprintf( stderr, "[ %ld  ,  %ld ]  %ld   %s --> ", 
	       i1,i2,i, TimestampToString((unsigned long) timestamp/100 ) );
      fprintf( stderr, " %s \n", TimestampToString((unsigned long) 10*t0) );
    }
    
    if( timestamp < (UINT64)(1000*t0) ) { i1=i; } else { i2=i; }
    if( abs( i2-i1 ) > 1 ) continue; else break;
      
  }

  *il = i1; *ih = i2;
  return;
  
}


/*-----------------------------------------------------------------------------*/
/* Compute Indices */

void Compute_Number_of_Indices( Parameters *parms )
{
  
  long i1,i2,i,n; long endi;
  unsigned long timestamp; 
  double *index;
  
  parms->starti = 0;
  
  /*------------------------------------------------------------------------*/
  /* All spikes? */
  
  if( parms->allspikes==1 ) {
    if( parms->verbose ) fprintf( stderr, "Processing all spikes.\n" );
    parms->index.n = parms->nmax;
    if( parms->verbose ) fprintf( stderr, "Number of Spikes to be processed : %ld\n", parms->index.n ); 
    return;
  }
  
  /*------------------------------------------------------------------------*/
  /* If not find the start index and number of indices */
  
  if( parms->tstart >0 ) {
    Disect( parms, &i1, &i2, parms->tstart );
    parms->starti = i2;
  } else {
    parms->starti = 0;
  }
  
  if( parms->tend > 0 ) {
    Disect( parms, &i1, &i2, parms->tend );
    endi = i1;
  } else {
    endi = parms->nmax;
  }

  parms->index.n = endi - parms->starti;
  parms->allspikes = 2;
  
  if( parms->verbose ) fprintf( stderr, "Number of Spikes to be processed : %ld\n", parms->index.n ); 
  
}

/*-----------------------------------------------------------------------------*/
/* Read Spike Waveforms */

void Read_Tetrode_Spike_Waveforms( Parameters *parms )
{

  long i,j,k,ii;
#ifdef _WINDOWS_
  short	tmp[2048];
#else
  short	tmp[parms->tt_rec_size];
#endif
  TT_rec tt_rec;
  unsigned long timestamp;
  long loc;
  float	dt;
  long count;
  double minv,maxv;
  long nread;
  float par_v;
  
  for(i=0;i<parms->index.n;i++){ 
    
    if(parms->verbose){
      if((parms->index.n > 100) && (i%(parms->index.n/100) == 0)){ 
	fprintf(stderr," %3d%%\b\b\b\b\b",(100*i)/(parms->index.n)); 
      }
    }
    
    if( parms->allspikes>0 ) { loc = parms->starti+i; } else { loc = (long) parms->index.index[i]; }
    
    fseek(parms->fp,(parms->start + loc)* parms->tt_rec_size + parms->headersize,0L);

    /* read record */
    
    nread = fread( &tt_rec, parms->tt_rec_size, 1, parms->fp );
    if( nread != 1 ) mexErrMsgTxt("Error reading tetrode record." );
  
    if((parms->tstart > 0) && (tt_rec.timestamp < (UINT64)(1000*parms->tstart))) { continue; }
    if((parms->tend > 0) && (tt_rec.timestamp > (UINT64)(1000*parms->tend))) { break; }

    //parms->tt[i] = ((double) tt_rec.timestamp)/1000.0 ; 
    parms->tt[i] = TimestampToDouble(tt_rec.timestamp); 

    for( k=0; k<4; k++ ) {
      for( j=0; j<parms->spikereclen; j++ ) { 
        parms->wt[k][i*parms->spikereclen+j] = (double) tt_rec.data[j].adval[k];
        if( j==0 ) {
          minv = (double) tt_rec.data[j].adval[k];
          maxv = (double) tt_rec.data[j].adval[k];
        } else {
          minv = min( minv, (double) tt_rec.data[j].adval[k] );
          maxv = max( maxv, (double) tt_rec.data[j].adval[k] );
        }
      }
      parms->h[ k*parms->index.n + i ] = maxv-minv;
    }

    if( parms->parameters ) { 
      par_v = (float) loc; fwrite( &par_v, sizeof(float), 1, parms->pfp );
      for( k=0; k<4; k++ ) {
        par_v = (float) parms->h[k*parms->index.n+i]; 
        fwrite( &par_v, sizeof(float), 1, parms->pfp );
      }
      par_v = (float) parms->tt[i]; fwrite( &par_v, sizeof(float), 1, parms->pfp );
    }

  }
}


/*-----------------------------------------------------------------------------*/
/* Write Parameter File Header */

void write_header( Parameters *parms )
{
  

  if( parms->pfp == NULL ) mexErrMsgTxt("Read_tt : Unable to write to parameter file.");

  fprintf( parms->pfp, "%%%%BEGINHEADER\n" );

  fprintf( parms->pfp, "%% Program:\t read_tt.mexlx\n" );
  fprintf( parms->pfp, "%% File type:\t Binary\n" );
  fprintf( parms->pfp, "%% Electrode type:\t Tetrode\n" );
  fprintf( parms->pfp, "%% Fields:\t id,4,4,1\t h1,4,4,1\t h2,4,4,1\t h3,4,4,1\t h4,4,4,1\t time,4,4,1\n" );

  fprintf( parms->pfp, "%%%%ENDHEADER\n" );
}


/*-----------------------------------------------------------------------------*/
/* GateWay routine */

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{

  char ifname[200]; FILE *fpi;
  
  char *str0;
  int narg; char arg[100]; char str[100]; char fname[200];
  int i,j; int nout;

  double *tmp;
  
  mxArray *field_ptr;
  mxArray *waveforms;
  mxArray *information;
  
  char *parmstr; int len;

  Parameters parms;
  
  int ndim=2, dims[2] = {1,1};
  int number_of_fields = 6;
  const char *field_names[] = {"t", "time", "w", "h", "tstart", "tend"};
  mxArray *time_field[1], *t_field[1], *w_field[4], *h_field[1], *tstart_field[1], *tend_field[1];
  
  /*--------------------------------------------------------------------------*/
  
  if(nrhs < 1)
    mexErrMsgTxt("READ_TT : FILE.TT [VERBOSE INDEX TSTART TEND]");
  if(nlhs > 1)
    mexErrMsgTxt("Too many output arguments.");
  
  if(mxIsChar(FNAME)==0)
    mexErrMsgTxt("Argument must be a filename.");
  
  Get_String( FNAME, fname );
  
  /*-------------------------------------------------------------------------*/
  /* Assign values to input parameters */
  
  parms.tetrode = 1; parms.singletrode = 0; parms.allspikes = 0;
  parms.verbose = 0; parms.start = 0; 
  parms.starti = 0;
  parms.index.index = NULL; parms.index.n = 0;
  parms.tstart = -1.0; parms. tend = -1.0; 
  parms.process = 1;
  parms.headersize = 0;
  parms.header = 1;
  
  narg = 0;
  
  while( ++narg < nrhs ) {
    if( mxIsChar( prhs[narg] ) ) {
      Get_String( prhs[narg], arg );
      if( arg!=NULL ) {
	
	if( strcmp( arg, "verbose" )==0 | strcmp( arg, "v" )==0 ) { parms.verbose=1; continue;  }
	if( strcmp( arg, "all" )==0 ) { parms.allspikes=1; continue;  }
	if( strcmp( arg, "header" )==0 ) { parms.header=1; continue;  }
	if( strcmp( arg, "noheader" )==0 ) { parms.header=0; continue;  }

	if( strcmp( arg, "params" )==0 || strcmp(arg, "parameters")==0 ) { /* extract parameters */
	  parms.parameters=1; 
	  Get_String( prhs[++narg], str );
	  if( parms.verbose ) fprintf( stderr, "Extracting parameters to file %s\n", str );
	  parms.pfp = fopen( str, "wb" );
	  if( parms.pfp == NULL ) mexErrMsgTxt("Could not open parameters file.");
	  write_header( &parms );
	  continue;  
	}
	
	if( strcmp( arg, "index" )==0 ) { 
	  if( narg+1< nrhs ) {
	    if( mxIsNumeric( prhs[narg+1] ) ) { 
	      if( parms.verbose ) fprintf( stderr, "Reading Vector Index..." ); 
	      parms.index.index = mxGetPr( prhs[++narg] );
	      parms.index.n = mxGetN( prhs[narg] ) * mxGetM( prhs[narg] );
	      parms.index.file = 0;
	      if( parms.verbose ) fprintf( stderr, "Done.\n" );
	    } else {
              Get_String( prhs[++narg], str );
              if( parms.verbose ) fprintf( stderr, "Reading Indices from file %s...", str );

	      fpi = fopen( str, "rt" ); 
	      if( fpi == NULL ) mexErrMsgTxt("Could not open index file.");
	      
	      if( parms.verbose ) fprintf( stderr, "Scanning indices..." );
	      ScanIndices( fpi, &parms.index );
	      parms.index.index = (double *)malloc(parms.index.n*sizeof(double));
	      if( parms.index.index == NULL){ mexErrMsgTxt("Could not allocate index array.");  }

	      ReadIndices(fpi,&parms.index);	    
	      parms.index.file = 1;
	      if( parms.verbose ) fprintf( stderr, "Done.\n" );

	    }
	  } else { mexErrMsgTxt("An argument should follow an index indicator."); }
	  continue;
	}

	if( strcmp( arg, "tstart" )==0 ) { 
	  if( mxIsNumeric( prhs[narg+1] ) ) { parms.tstart = mxGetScalar( prhs[++narg] );
	  } else {
	    Get_String( prhs[++narg], str );
	    parms.tstart = ((double) ParseTimestamp( str ));
	    parms.tstart = parms.tstart/10;
	  }
	  continue;
	}

	if( strcmp( arg, "tend" )==0 ) { 
	  if( mxIsNumeric( prhs[narg+1] ) ) { parms.tend = mxGetScalar( prhs[++narg] );
	  } else {
	    Get_String( prhs[++narg], str );
	    parms.tend = ((double) ParseTimestamp( str ));
	    parms.tend = parms.tend/10;
	  }
	  continue;
	}
	fprintf( stderr, "# : Unknown argument %d type ('%s').\n", narg, arg );
      }
    } else {
      fprintf( stderr, "# : Argument %d is not a string field.\n", narg );
    }
  }
  
  
  /*-------------------------------------------------------------------------*/
  
  if( parms.verbose ) fprintf(stderr, "Loading from  file %s\n", fname );
  parms.fp = fopen( fname , "rb" );
  if( parms.fp == NULL ) mexErrMsgTxt("Could not open file.");

  if( parms.header == 1 ) parms.headersize = 16384; 

  if( parms.verbose ) { 
    fprintf( stderr, "Tstart : %f\t", parms.tstart );
    fprintf( stderr, "Tend : %f\n", parms.tend );
  }


  /*-------------------------------------------------------------------------*/
  /* get number of indices */

  parms.tt_rec_size = sizeof( TT_rec );
  parms.spikereclen = SPIKE_NUMPOINTS;

  if( parms.verbose ) fprintf( stderr, "TT Record Size : %d\n", parms.tt_rec_size );

  Get_File_Info( &parms );
  

  if( (parms.allspikes==1) || (parms.tstart > 0) || (parms.tend > 0) ) 
    Compute_Number_of_Indices( &parms ); 

  /*-------------------------------------------------------------------------*/
  /* Create output structure */
  
  number_of_fields = number_of_fields; dims[0] = 1; 
  RESULT = mxCreateStructArray( ndim, dims, number_of_fields, field_names);
  
  t_field[0] = mxCreateDoubleMatrix(parms.index.n, 1, mxREAL); parms.tt = mxGetPr( t_field[0] );
  mxSetField( RESULT, 0, "t", t_field[0] ); 
  
  time_field[0] = mxCreateDoubleMatrix( parms.spikereclen, 1, mxREAL); parms.time = mxGetPr( time_field[0] );
  mxSetField( RESULT, 0, "time", time_field[0] ); 
  
  for( i=0; i<parms.spikereclen; i++ ) { parms.time[i] = i*parms.dt; }
  
  waveforms = mxCreateCellMatrix(1,4); 
  
  for( i=0; i<4; i++ ) { 
    w_field[i] = mxCreateDoubleMatrix(parms.spikereclen, parms.index.n, mxREAL); parms.wt[i]=mxGetPr( w_field[i] ); 
    mxSetCell(waveforms, i, w_field[i]);
  }
  mxSetField( RESULT, 0, "w", waveforms ); 
  
  h_field[0] = mxCreateDoubleMatrix(parms.index.n, 4, mxREAL); parms.h = mxGetPr( h_field[0] );
  mxSetField( RESULT, 0, "h", h_field[0] ); 

  /*------------------------------------------------------------------------*/


  tstart_field[0] = mxCreateDoubleMatrix(1, 1, mxREAL); 
  tmp = mxGetPr( tstart_field[0] ); tmp[0] = parms.tstart0;
  mxSetField( RESULT, 0, "tstart", tstart_field[0] ); 

  tend_field[0] = mxCreateDoubleMatrix(1, 1, mxREAL); 
  tmp = mxGetPr( tend_field[0] ); tmp[0] = parms.tend0;
  mxSetField( RESULT, 0, "tend", tend_field[0] ); 
  
  /*-------------------------------------------------------------------------*/
  
  if( parms.verbose ) fprintf( stderr, "Loading Waveforms..." );
  
  if( parms.tetrode ) {
    Read_Tetrode_Spike_Waveforms( &parms );
  }

  if( parms.parameters ) fclose( parms.pfp ); 
  if( parms.verbose ) fprintf( stderr, "done.\n");
  
  /*-------------------------------------------------------------------------*/
  /* Free */
  
  if( (parms.index.file == 1) && (parms.index.index != NULL) ) free( parms.index.index );  
  
}  
