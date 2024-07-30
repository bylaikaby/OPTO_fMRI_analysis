/**************************************************************************

		    LIBRARY OF MX UTILITY FUNCTIONS

AUTHOR:

    Thanos Siapas
    Center for Learning and Memory
    Departments of Brain and Cognitive Sciences, and Biology
    Massachusetts Institute of Technology
    Cambridge, MA 02139
    thanos@mit.edu

    Based on a program written by Matthew Wilson


DATES: Original  08/98 (GRITSA)


**************************************************************************/

void update_field( mxArray *array_ptr, char *field, double value );
void update_string_field( mxArray *array_ptr, char *field, char *str );
double get_scalar_field( mxArray *array_ptr, char *field );
char *get_string_field( mxArray *array_ptr, char *field );
char *get_string( const mxArray *arg );
