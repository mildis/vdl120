#ifndef _num2bin_h
#define _num2bin_h

#include <stdlib.h>
#import <CoreFoundation/CoreFoundation.h>


#define NUM2BIN_MAX 100
#define SIGN_BIT 0x8000

#define num2bin_data ((short int *)num2bin_data_char)
short int num2bin(short int num);
short int bin2num(short int bin);


#endif
