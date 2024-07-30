/*=================================================================
 * dg_read.c
 *
 * Read a dgz file into matlab and create a matlab structure with
 * fields corresponding to individual elements.
 *
 * 10-August-2000
 * Yusuke MURAYAMA modified adding 'filename' to a return struct. 
 * To remove modification, undefine 'YM_MODIFY'.
 * 07-April-2003 by YM
 * changed max length of filename from 128 to 256
 * 16-July-2013 by YM
 * updated to support "-largeArrayDims".
 * "long" as "int32" to support 64bit *nix/mac system.
 * 07-October-2015 by YM
 * use mkstemp() for *nix, tmpnam_s() for win.
 *
 * Compile: >> mex  dg_read.c df.c dfutils.c dynio.c flip.c zlib.lib
 *=================================================================*/

#include "mex.h"
#include <string.h>
#include <df.h>
#include <zlib.h>
#include "dynio.h"

#ifdef _WIN32
#  define UNLINK   _unlink
#else
#  define UNLINK   unlink
#endif


#define	FILE_IN	        prhs[0]

/*****************************************************************************
 *
 * FUNCTION
 *    tclReadDynGroup
 *
 * ARGS
 *    Tcl Args
 *
 * TCL FUNCTION
 *    dg_read
 *
 * DESCRIPTION
 *    Reads in a dynGroup
 *
 *****************************************************************************/

/* ===========================================================================
 * Uncompress input to output then close both files.
 */
static void gz_uncompress(gzFile in, FILE *out)
{
    char buf[2048];
    int len;

    for (;;) {
        len = gzread(in, buf, sizeof(buf));
        if (len < 0) return;
        if (len == 0) break;

        if ((int)fwrite(buf, 1, (unsigned)len, out) != len) {
	  return;
	}
    }
    if (fclose(out)) return;
    if (gzclose(in) != Z_OK) return;
}

static FILE *uncompress_file(char *filename, char *tempname)
{
  FILE *fp;
  gzFile in;
#ifdef _WIN32
  static char fname[L_tmpnam_s];
#else
  static char fname[L_tmpnam];
  int fd;
#endif

  if (!filename) return NULL;

  if (!(in = gzopen(filename, "rb"))) {
    return 0;
  }

#ifdef _WIN32
  fname[0] = '\0';
  //tmpnam(fname);
  tmpnam_s(fname, L_tmpnam_s);
  //mexPrintf("%s\n",fname);
  if (!(fp = fopen(fname,"wb"))) {
    return 0;
  }
#else
  sprintf(fname,"/tmp/dg_read-temp.XXXXXX");
  fd = mkstemp(fname);
  if ((fp = fdopen(fd,"wb")) == NULL)  return 0;
#endif
  
  gz_uncompress(in, fp);

  fp = fopen(fname, "rb");
  if (tempname) strcpy(tempname, fname);
  return(fp);
}  

mxArray *dynListToCellArray(DYN_LIST *dl)
{
  mwSize dims;
  int i;
  DYN_LIST **sublists;
  mxArray *retval = NULL, *cell;
  double *d;

  switch(DYN_LIST_DATATYPE(dl)) {
  case DF_LIST:
    dims = DYN_LIST_N(dl);
    retval = mxCreateCellArray(1, &dims);
    sublists = (DYN_LIST **) DYN_LIST_VALS(dl);
    for (i = 0; i < DYN_LIST_N(dl); i++) {
      cell = dynListToCellArray(sublists[i]);
      mxSetCell(retval, i, cell);
    }
    break;
  case DF_INT32:
    {
      int32_t *vals = (int32_t *) DYN_LIST_VALS(dl);
      retval = mxCreateDoubleMatrix(DYN_LIST_N(dl), 1, mxREAL);
      d = mxGetPr(retval);
      for ( i = 0; i < DYN_LIST_N(dl); i++ ) 
	d[i] = (double) vals[i];
    }
    break;
  case DF_SHORT:
    {
      short *vals = (short *) DYN_LIST_VALS(dl);
      retval = mxCreateDoubleMatrix(DYN_LIST_N(dl), 1, mxREAL);
      d = mxGetPr(retval);
      for ( i = 0; i < DYN_LIST_N(dl); i++ ) 
	d[i] = (double) vals[i];
    }
    break;
  case DF_FLOAT:
    {
      float *vals = (float *) DYN_LIST_VALS(dl);
      retval = mxCreateDoubleMatrix(DYN_LIST_N(dl), 1, mxREAL);
      d = mxGetPr(retval);
      for ( i = 0; i < DYN_LIST_N(dl); i++ ) 
	d[i] = (double) vals[i];
    }
    break;
  case DF_CHAR:
    {
      char *vals = (char *) DYN_LIST_VALS(dl);
      retval = mxCreateDoubleMatrix(DYN_LIST_N(dl), 1, mxREAL);
      d = mxGetPr(retval);
      for ( i = 0; i < DYN_LIST_N(dl); i++ ) 
	d[i] = (double) vals[i];
    }
    break;
  case DF_STRING:
    {
      char **vals = (char **) DYN_LIST_VALS(dl);
      retval = mxCreateCharMatrixFromStrings(DYN_LIST_N(dl), vals);
    }
  }
  return retval;
}

void
mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
  mwSize dims[2] = {1, 1 };
  int i, buflen, status;
  char *filename;
  DYN_GROUP *dg;
  FILE *fp;
  char *newname = NULL, *suffix;
  char tempname[256];
  char message[256];
  char **field_names;
  mxArray *field_value;

  /* Check for proper number of input and  output arguments */
  if (nlhs == 0 && nrhs == 0) {
      mexPrintf("Usage: dg = dg_read(filename)\n");
      return;
  }
  if (nrhs > 1) {
    mexErrMsgTxt("Too many input arguments.");
  } 
  if (nlhs > 1) {
    mexErrMsgTxt("Too many output arguments.");
  }

  buflen = (int)(mxGetM(FILE_IN) * mxGetN(FILE_IN)) + 1;
  filename = mxCalloc(buflen, sizeof(char));
  status = mxGetString(FILE_IN, filename, buflen);

  /* No need to uncompress a .dg file */
  if ((suffix = strrchr(filename, '.')) && strstr(suffix, "dg") &&
      !strstr(suffix, "dgz")) {
    fp = fopen(filename, "rb");
    if (!fp) {
      sprintf(message, "Error opening data file \"%s\".", filename);
      mexErrMsgTxt(message);
      tempname[0] = 0;
    }
  }
  else if ((fp = uncompress_file(filename, tempname)) == NULL) {
    char fullname[256];
    sprintf(fullname,"%s.dg", filename);
    if ((fp = uncompress_file(fullname, tempname)) == NULL) {
      sprintf(fullname,"%s.dgz", filename);
      if ((fp = uncompress_file(fullname, tempname)) == NULL) {
        sprintf(message, "dg_read: file %s not found", filename);
        mexErrMsgTxt(message);
      }
    }
  }
  
  if (!(dg = dfuCreateDynGroup(4))) {
    mexErrMsgTxt("Error creating dyn group.");
  }

  if (!dguFileToStruct(fp, dg)) {
    sprintf(message, "dg_read: file %s not recognized as dg format", 
            filename);
    fclose(fp);
    if (tempname[0]) UNLINK(tempname);
    mexErrMsgTxt(message);
  }
  fclose(fp);
  if (tempname[0]) UNLINK(tempname);

  dims[1] = 1;


  // 10-August-2000
  // Yusuke MURAYAMA modified below to add dgzfilename
  field_names = mxCalloc(DYN_GROUP_NLISTS(dg)+1, sizeof (char *));
  for (i = 0; i < DYN_GROUP_NLISTS(dg); i++) {
    field_names[i] = DYN_LIST_NAME(DYN_GROUP_LIST(dg,i));
  }
  field_names[i] = "filename";

  plhs[0] = mxCreateStructArray(2, dims, DYN_GROUP_NLISTS(dg)+1, field_names);

  for (i = 0; i < DYN_GROUP_NLISTS(dg); i++) {
    field_value = dynListToCellArray(DYN_GROUP_LIST(dg, i));
    if (!field_value) {
      sprintf(message, "dg_read: error reading data file \"%s\"", filename);
      dfuFreeDynGroup(dg);
      mexErrMsgTxt(message);
    }
    mxSetFieldByNumber(plhs[0], 0, i, field_value);
  }
  mxSetFieldByNumber(plhs[0], 0, i, mxCreateString(filename));

  dfuFreeDynGroup(dg);
}
