#import "samplerConfig.h"

@implementation samplerConfig

@synthesize binaryConfig;
@dynamic configuredSamples;
@synthesize recordedSamples;
@dynamic interval;
@dynamic startTime;
@dynamic ledFrequency;
@dynamic tempScale;
@dynamic name;
@dynamic startMode;

-(id)init {
    self = [super init];
    
    if (self) {
        name = DEFAULT_CFG_NAME;
        configuredSamples = 6;
        interval = 10;
        startTime = [NSDate date];
        ledFrequency = 10;
        tempScale = TEMP_C;
        lowTemperature = TEMP_MIN;
        highTemperature = TEMP_MAX_C;
        lowRH = RH_MIN;
        highRH = RH_MAX;
        startMode = AUTO_START;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"samplerConfig: \n\
            configName=%@\n\
            configuredSamples=%li\n\
            recordedSamples=%li\n\
            interval=%li\n\
            startTime=%@\n\
            ledFrequency=%li\n\
            temperatureScale=%li\n\
            temperatureMin=%li\n\
            temperatureMax=%li\n\
            RHMin=%li\n\
            RHMax=%li\n\
            startMode=%li\n",
            name, configuredSamples, recordedSamples, interval, startTime, ledFrequency, tempScale, lowTemperature, highTemperature, lowRH, highRH, startMode];
}

-(s_config *) binaryConfigPtr {
    return &binaryConfig;
}

-(void) setBinaryConfigPtr:(s_config *)binConfig {
    binaryConfig = *binConfig;
}

-(void) decodeBinaryConfig {
    name = [NSString stringWithUTF8String:binaryConfig.name];
    configuredSamples = binaryConfig.num_data_conf;
    recordedSamples = binaryConfig.num_data_rec;
    interval = binaryConfig.interval;
    
    startTime = [NSDate dateWithString:[NSString stringWithFormat:@"%i-%i-%i %i:%i:%i +0000", binaryConfig.time_year, binaryConfig.time_mon, binaryConfig.time_mday, binaryConfig.time_hour, binaryConfig.time_min, binaryConfig.time_sec]];
    
    tempScale = binaryConfig.temp_scale;
    lowTemperature = bin2num(binaryConfig.thresh_temp_low);
    highTemperature = bin2num(binaryConfig.thresh_temp_high);
    lowRH = bin2num(binaryConfig.thresh_rh_low);
    highRH = bin2num(binaryConfig.thresh_rh_high);
    startMode = binaryConfig.start;
    ledFrequency = (binaryConfig.led_conf & 0x1F);
}

-(void) encodeBinaryConfig {
    binaryConfig.config_begin = 0xce;
	binaryConfig.config_end = 0xce;
    
    strncpy(binaryConfig.name, [name UTF8String], 16);
    binaryConfig.num_data_conf = (int) configuredSamples;
    binaryConfig.num_data_rec = (int) recordedSamples;
    binaryConfig.interval = (int) interval;
 
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:startTime];
    binaryConfig.time_year = (int) [comps year];
    binaryConfig.time_mon =  [comps month];
    binaryConfig.time_mday =  [comps day];
    binaryConfig.time_hour =  [comps hour];
    binaryConfig.time_min =  [comps minute];
    binaryConfig.time_sec =  [comps second];

    binaryConfig.temp_scale = tempScale;
    binaryConfig.thresh_temp_low = num2bin(lowTemperature);
    binaryConfig.thresh_temp_high = num2bin(highTemperature);
    binaryConfig.thresh_rh_low = num2bin(lowRH);
    binaryConfig.thresh_rh_high = num2bin(highRH);
    binaryConfig.start = startMode;
    binaryConfig.led_conf = (1 << 7) | (ledFrequency & 0x1F);

}

-(void) setConfiguredSamples:(NSInteger)cfgSamples {
	if (cfgSamples <= 0 || 16000 < cfgSamples)
	{
		NSLog(@"isConfigValid: invalid configuredSamples, valid range: [1:16000]\n");
        cfgSamples = 1;
	}
    configuredSamples = cfgSamples;
}

-(NSInteger) interval {
    return interval;
}

-(void) setInterval:(NSInteger)ival {
    if (ival <= 0 || 86400 < ival)
	{
		NSLog(@"isConfigValid: invalid interval, valid range: [1:86400]\n");
        ival = 1;
	}
    interval = ival;
}

-(void) setLedFrequency:(NSInteger)ledFreq {
    if (ledFreq != 10 && ledFreq != 20 && ledFreq != 30)
	{
		NSLog(@"setLedFrequency: invalid led frequency\n");
        ledFreq = 10;
	}
    ledFrequency = ledFreq;
}

-(void) setTempScale:(NSInteger)scale {
    if (TEMP_C != scale && TEMP_F != scale) {
        NSLog(@"setTempScale: invalid scale\n");
        scale = TEMP_C;
    }
    tempScale = scale;
}

-(void) setName:(NSString *)cfgName {
    if (0 == cfgName.length)
	{
		NSLog(@"isConfigValid: empty name\n");
        cfgName = DEFAULT_CFG_NAME;
	}
    
    name = [cfgName substringToIndex: (cfgName.length > 15 ? 15 : cfgName.length)];
}

-(void) setStartMode:(NSInteger)stMode {
    if (MANUAL_START != stMode && AUTO_START != stMode)
	{
		NSLog(@"setStartMode: invalid start flag\n");
        stMode = AUTO_START;
	}
    startMode = stMode;
}

-(void) setTemperatureRange:(NSInteger)lowTemp :(NSInteger) highTemp {
    if (TEMP_F == tempScale)
	{
		if (lowTemp < TEMP_MIN || TEMP_MAX_F < lowTemp)
		{
			NSLog(@"setTemperatureRange: invalid Fahrenheit lowTemperature\n");
            lowTemp = TEMP_MIN;
		}
	} else {
		if (lowTemperature < TEMP_MIN || TEMP_MAX_C < lowTemperature)
		{
			NSLog(@"setTemperatureRange: invalid Celcius lowTemperature\n");
            lowTemp = TEMP_MIN;
		}
	}
    
    if (TEMP_F == tempScale)
	{
		if (highTemp < TEMP_MIN || TEMP_MAX_F < highTemp)
		{
			NSLog(@"setTemperatureRange: invalid Fahrenheit highTemperature\n");
            highTemp = TEMP_MAX_F;
		}
	} else {
		if (highTemp < TEMP_MIN || TEMP_MAX_C < highTemp)
		{
			NSLog(@"setTemperatureRange: invalid Celcius highTemperature\n");
            highTemp = TEMP_MAX_C;
		}
	}
    
    if (highTemp <= lowTemp) {
        NSLog(@"setTemperatureRange: highTemp greater than lowTemp\n");
        highTemp = lowTemp + 1;
    }
    
    lowTemperature = lowTemp;
    highTemperature = highTemp;
}

-(void) setRHRange:(NSInteger)lowHum :(NSInteger)highHum {
    if (lowHum < RH_MIN || RH_MAX < lowHum)
	{
		NSLog(@"setRHRange: invalid thresh_rh_low\n");
        lowHum = RH_MIN;
	}
	
	if (highHum < RH_MIN || RH_MAX < highHum)
	{
		NSLog(@"setRHRange: invalid thresh_rh_high\n");
        highHum = RH_MAX;
	}
	
	if (highHum < lowHum)
	{
		NSLog(@"setRHRange: invalid thresh_rh_low/high\n");
        highHum = lowHum + 1;
	}
    
    lowRH = lowHum;
    highRH = highHum;
}

-(NSDate *) startTime {
    return startTime;
}

-(void) setStartTime:(NSDate *)sTime {
    if ([sTime compare:[NSDate date]] == NSOrderedAscending) {
        NSLog(@"setStartTime : sTime in the past");
        sTime = [NSDate date];
    }
    startTime = sTime;
}

@end
