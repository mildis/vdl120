#ifndef _samplerConfig_h
#define _samplerConfig_h

#import <Foundation/Foundation.h>

#define CONFIGSIZE 64
#define DEFAULT_CFG_NAME @"defaultCfg"
#define TEMP_C 0
#define TEMP_F 1
#define TEMP_MIN -40 /* same with celsius and fahrenheit */
#define TEMP_MAX_C 70
#define TEMP_MAX_F 158
#define RH_MIN 0
#define RH_MAX 100
#define MANUAL_START 1
#define AUTO_START 2

#define num2bin_data ((short int *)num2bin_data_char)
short int num2bin(short int num);
short int bin2num(short int bin);
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

@interface samplerConfig : NSObject {
    s_config binaryConfig;
    NSNumber *configuredSamples;
    NSNumber *recordedSamples;
    NSNumber *interval;
    NSDate *startTime;
    NSNumber *ledFrequency;
    NSNumber *lowTemperature;
    NSNumber *highTemperature;
    NSNumber *lowRH;
    NSNumber *highRH;
    NSNumber *tempScale;
    NSString *name;
    NSNumber *startMode;
}

-(s_config *) binaryConfigPtr;
-(void) setBinaryConfigPtr:(s_config *) binConfig;
-(void) decodeBinaryConfig;
-(void) encodeBinaryConfig;

-(id) initWithPropertyListAtPath:(NSString *) path;
-(void) save:(NSString *)path;

-(void) setTemperatureRange:(NSNumber *) lowTemp :(NSNumber *) highTemp;
-(void) setRHRange:(NSNumber *) lowHum :(NSNumber *) highHum;

@property s_config binaryConfig;
@property NSNumber *configuredSamples;
@property NSNumber *recordedSamples;
@property NSNumber *interval;
@property NSDate *startTime;
@property NSNumber *ledFrequency;
@property NSNumber *tempScale;
@property NSString *name;
@property NSNumber *startMode;

@end
#endif