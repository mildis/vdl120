/* convert to/from cryptic integer encoding */

/* First byte is the numeric value, in a left-align bit order. */
/* Have to figure how to shift it the rigth number of bits to get the right int */

#include "num2bin.h"

char num2bin_data_char[] =
{
	0x00, 0x00, /*   0 */
	0x80, 0x3F, /*   1 */
	0x00, 0x40, /*   2 */
	0x40, 0x40, /*   3 */
	0x80, 0x40, /*   4 */
	0xA0, 0x40, /*   5 */
	0xC0, 0x40, /*   6 */
	0xE0, 0x40, /*   7 */
	0x00, 0x41, /*   8 */
	0x10, 0x41, /*   9 */
	0x20, 0x41, /*  10 */
	0x30, 0x41, /*  11 */
	0x40, 0x41, /*  12 */
	0x50, 0x41, /*  13 */
	0x60, 0x41, /*  14 */
	0x70, 0x41, /*  15 */
	0x80, 0x41, /*  16 */
	0x88, 0x41, /*  17 */
	0x90, 0x41, /*  18 */
	0x98, 0x41, /*  19 */
	0xA0, 0x41, /*  20 */
	0xA8, 0x41, /*  21 */
	0xB0, 0x41, /*  22 */
	0xB8, 0x41, /*  23 */
	0xC0, 0x41, /*  24 */
	0xC8, 0x41, /*  25 */
	0xD0, 0x41, /*  26 */
	0xD8, 0x41, /*  27 */
	0xE0, 0x41, /*  28 */
	0xE8, 0x41, /*  29 */
	0xF0, 0x41, /*  30 */
	0xF8, 0x41, /*  31 */
	0x00, 0x42, /*  32 */
	0x04, 0x42, /*  33 */
	0x08, 0x42, /*  34 */
	0x0C, 0x42, /*  35 */
	0x10, 0x42, /*  36 */
	0x14, 0x42, /*  37 */
	0x18, 0x42, /*  38 */
	0x1C, 0x42, /*  39 */
	0x20, 0x42, /*  40 */
	0x24, 0x42, /*  41 */
	0x28, 0x42, /*  42 */
	0x2C, 0x42, /*  43 */
	0x30, 0x42, /*  44 */
	0x34, 0x42, /*  45 */
	0x38, 0x42, /*  46 */
	0x3C, 0x42, /*  47 */
	0x40, 0x42, /*  48 */
	0x44, 0x42, /*  49 */
	0x48, 0x42, /*  50 */
	0x4C, 0x42, /*  51 */
	0x50, 0x42, /*  52 */
	0x54, 0x42, /*  53 */
	0x58, 0x42, /*  54 */
	0x5C, 0x42, /*  55 */
	0x60, 0x42, /*  56 */
	0x64, 0x42, /*  57 */
	0x68, 0x42, /*  58 */
	0x6C, 0x42, /*  59 */
	0x70, 0x42, /*  60 */
	0x74, 0x42, /*  61 */
	0x78, 0x42, /*  62 */
	0x7C, 0x42, /*  63 */
	0x80, 0x42, /*  64 */
	0x82, 0x42, /*  65 */
	0x84, 0x42, /*  66 */
	0x86, 0x42, /*  67 */
	0x88, 0x42, /*  68 */
	0x8A, 0x42, /*  69 */
	0x8C, 0x42, /*  70 */
	0x8E, 0x42, /*  71 */
	0x90, 0x42, /*  72 */
	0x92, 0x42, /*  73 */
	0x94, 0x42, /*  74 */
	0x96, 0x42, /*  75 */
	0x98, 0x42, /*  76 */
	0x9A, 0x42, /*  77 */
	0x9C, 0x42, /*  78 */
	0x9E, 0x42, /*  79 */
	0xA0, 0x42, /*  80 */
	0xA2, 0x42, /*  81 */
	0xA4, 0x42, /*  82 */
	0xA6, 0x42, /*  83 */
	0xA8, 0x42, /*  84 */
	0xAA, 0x42, /*  85 */
	0xAC, 0x42, /*  86 */
	0xAE, 0x42, /*  87 */
	0xB0, 0x42, /*  88 */
	0xB2, 0x42, /*  89 */
	0xB4, 0x42, /*  90 */
	0xB6, 0x42, /*  91 */
	0xB8, 0x42, /*  92 */
	0xBA, 0x42, /*  93 */
	0xBC, 0x42, /*  94 */
	0xBE, 0x42, /*  95 */
	0xC0, 0x42, /*  96 */
	0xC2, 0x42, /*  97 */
	0xC4, 0x42, /*  98 */
	0xC6, 0x42, /*  99 */
	0xC8, 0x42, /* 100 */
};

short int num2bin(short int num)
{
    short int nabs = abs(num);
    if (NUM2BIN_MAX < nabs)
	{
		NSLog(@"num2bin: cant convert number %i\n", num);
		num = 0;
	}
	
	return num > 0 ? num2bin_data[nabs] : (num2bin_data[nabs] | SIGN_BIT);
}

short int bin2num(short int bin)
{
    char found = 0;
    int is_negative = 0;
	short int ret = 0;
	
	is_negative = bin & SIGN_BIT;
	if (is_negative) bin ^= SIGN_BIT;
	
	for (ret = 0; ret <= NUM2BIN_MAX; ret++)
	{
		if (num2bin_data[ret] == bin)
		{
			if (is_negative)
                ret = -1*ret;
            
            found = 1;
            break;
		}
	}
	if (!found) {
        ret = 0;
        if (is_negative)
            NSLog(@"bin2num: cant convert data %x\n", bin | SIGN_BIT); // restore sign bit
        else
            NSLog(@"bin2num: cant convert data %x\n", bin);
    }
    
	return ret;
}
