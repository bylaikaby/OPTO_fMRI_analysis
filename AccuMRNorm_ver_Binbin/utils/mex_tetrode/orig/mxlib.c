/**************************************************************************

		    LIBRARY OF MX UTILITY FUNCTIONS

AUTHOR:


%------------------------------------------
%
%                Author:
%             Thanos Siapas
%      Computation and Neural Systems
%            Div. of Biology, 
% Div. of Engineering and Applied Science
%  California Institute of Technology
%          Pasadena, CA 91125
%          thanos@caltech.edu
%
%------------------------------------------

**************************************************************************/

#include <stdio.h>
#include <mex.h>

#define VERSION "1.00"

/*-----------------------------------------------------------------------------*/
/* Update scalar structure fields */

void update_field( mxArray *array_ptr, char *field, double value )
{
  mxArray *old_field_ptr, *new_field_ptr;
  double *new_value;
  
  old_field_ptr = mxGetField( array_ptr,0, field );
  if(!old_field_ptr) mexErrMsgTxt( "The requested field does not exist." );

  new_field_ptr = mxCreateDoubleMatrix( 1,1,mxREAL ); new_value = mxGetPr( new_field_ptr );
  new_value[0] = value;
  
  mxSetField( array_ptr,0, field, new_field_ptr );
  mxDestroyArray( old_field_ptr );
}

/*-----------------------------------------------------------------------------*/

void set_field( mxArray *array_ptr, char *field, double value )
{
  mxArray *new_field_ptr;
  double *new_value;
  
  new_field_ptr = mxCreateDoubleMatrix( 1,1,mxREAL ); new_value = mxGetPr( new_field_ptr );
  new_value[0] = value;
  
  mxSetField( array_ptr,0, field, new_field_ptr );
}

/*-----------------------------------------------------------------------------*/
/* Update string structure fields */

void update_string_field( mxArray *array_ptr, char *field, char *str )
{
  mxArray *old_field_ptr, *new_field_ptr;
  double *new_value;

  old_field_ptr = mxGetField( array_ptr,0, field );
  if(!old_field_ptr) mexErrMsgTxt( "The requested field does not exist." );

  new_field_ptr = mxCreateString( str );
  mxSetField( array_ptr,0, field, new_field_ptr );
  mxDestroyArray( old_field_ptr );
}

/*-----------------------------------------------------------------------------*/
/* set string structure fields */

void set_string_field( mxArray *array_ptr, char *field, char *str )
{
  mxArray *new_field_ptr;
  double *new_value;

  new_field_ptr = mxCreateString( str );
  mxSetField( array_ptr,0, field, new_field_ptr );

}

/*-----------------------------------------------------------------------------*/
/* Read scalar structure fields */

double get_scalar_field( mxArray *array_ptr, char *field )
{
  mxArray *field_ptr;

  field_ptr = mxGetField( array_ptr, 0, field );
  if( !field_ptr ) mexErrMsgTxt( "The requested field does not exist." );
  return( mxGetScalar (field_ptr) );
}

/*-----------------------------------------------------------------------------*/
/* Read string structure fields */

char *get_string_field( mxArray *array_ptr, char *field )
{
  mxArray *field_ptr;
  int len; char *str;

  field_ptr = mxGetField( array_ptr, 0, field );
  if(!field_ptr) mexErrMsgTxt( "The requested field does not exist." );
  
  len = mxGetM(field_ptr)+mxGetN(field_ptr)+1; 
  str = mxCalloc(len,sizeof(char)); 
  if( mxGetString(field_ptr,str,len)==0 ) 
    return( str );
  else
    mexErrMsgTxt( "Could not read string." );
}


/*-----------------------------------------------------------------------------*/
/* Read string */

char *get_string( const mxArray *arg )
{
  int strlen; int status; char *str;

  strlen = (mxGetM(arg)*mxGetN(arg)*sizeof(mxChar))+1; 
  str = mxCalloc( strlen, sizeof( char ) );

  status = mxGetString(arg, str, strlen); 
  if (status != 0) mexErrMsgTxt("Could not convert string data.");
  
  return( str );

}

/*----------------------------------------------------------------------------*/

