#ifndef vdl120_h
#define vdl120_h

#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/usb/IOUSBLib.h>
#include <IOKit/usb/USBSpec.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>

#define DEBUG 1

/* hardware specs */
#define VID 0x10c4 /* Cygnal Integrated Products, Inc. */
#define PID 0x0003 /* Silabs C8051F320 USB Board */
#define EP_IN  0x81
#define EP_OUT 0x02
#define BUFSIZE 64 /* wMaxPacketSize = 1x 64 bytes */
#define TIMEOUT 5000
#define TEMP_C 0
#define TEMP_F 1
#define TEMP_MIN -40 /* same with celsius and fahrenheit */
#define TEMP_MAX_C 70
#define TEMP_MAX_F 158
#define RH_MIN 0
#define RH_MAX 100
#define MANUAL_START 1
#define AUTO_START 2

#define DL120_RDCNF 0
#define DL120_WRCNF 1
#define DL120_RDDAT 2
#define DL120_KEEP  3

#define E_CONF_OK           0
#define E_CONF_NAME         (1<<0)
#define E_CONF_DATARANGE    (1<<1)
#define E_CONF_IVALRANGE    (1<<2)
#define E_CONF_STARTFLAG    (1<<3)
#define E_CONF_TEMPRANGE    (1<<4)
#define E_CONF_RHRANGE      (1<<5)
#define E_CONF_LEDFREQ      (1<<6)


#define NUM2BIN_MAX 100
#define SIGN_BIT 0x8000

#define num2bin_data ((short int *)num2bin_data_char)
short int num2bin(short int num);
short int bin2num(short int bin);

typedef struct s_usb_dl120 {
    IOUSBDeviceInterface** usbDevice;
    IOUSBInterfaceInterface** usbInterface;
    UInt8 pipeIn;
    UInt8 pipeOut;
} s_usb_dl120;

typedef struct s_config {
    int config_begin;           /*  0- 3 0xce = set config, 0x00 = logger is active */
    int num_data_conf;          /*  4- 7 number of data configured */
    int num_data_rec;           /*  8-11 number of data recorded */
    int interval;               /* 12-15 log interval in seconds */
    int time_year;              /* 16-19 */
    short int padding20;        /* 20-21 */
    short int thresh_temp_low;  /* 22-23 */
    short int padding24;        /* 24-25 */
    short int thresh_temp_high; /* 26-27 */
    char time_mon;              /* 28    start time, local (!) timezone */
    char time_mday;             /* 29    */
    char time_hour;             /* 30    */
    char time_min;              /* 31    */
    char time_sec;              /* 32    */
    char temp_scale;            /* 33    */
    char led_conf;              /* 34    bit 0: alarm on/off, bits 1-2: 10 (?), bits 3-7: flash frequency in seconds */
    // 35 ?!
    char name[16];              /* 35-50 config name. actually just 16 bytes: 35-50 */
    char start;                 /* 51    0x02 = start logging immediately; 0x01 = start logging manually */
    short int padding52;        /* 52-53 */
    short int thresh_rh_low;    /* 54-55 */
    short int padding56;        /* 56-57 */
    short int thresh_rh_high;   /* 58-59 */
    int config_end;             /* 60-63 config_begin */
} s_config;

typedef struct s_data {
	short int temp;         /* temperature in °C or °F, check cfg->temp_scale */
	short int rh;           /* relative humidity in % */
	time_t time;            /* timestamp, unix time, GMT (!) timezone */
	struct s_data *next;    /* next data set or NULL */
} s_data;


s_usb_dl120 *usb_init();
void usb_close(s_usb_dl120 *device);

s_config *read_config(s_usb_dl120 *device);
IOReturn write_config(s_usb_dl120 *device, s_config *cfg);

s_config *build_config(
             char *name,                    /* logger name */
             int num_data,                  /* number of data points to collect */
             int interval,                  /* log frequency in seconds */
             int thresh_temp_low,
             int thresh_temp_high,
             int thresh_rh_low,
             int thresh_rh_high,
             int temp_scale,                /* temp scale : TEMP_C or TEMP_F */
             int led_alarm,                 /* bool: led alarm */
             int led_freq,                  /* led frequency in seconds */
             int start                      /* start logging: 1 = manually, 2 = automatically */
             );

void print_config(s_config *cfg, char *line_prefix);

int is_conf_valid(s_config *cfg);
s_data *read_data(s_usb_dl120 *p, s_config *cfg);
void print_data(s_data *data_first);
void store_data(s_config *cfg, s_data *data_first);

#endif
