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
        configuredSamples = [NSNumber numberWithInt:6];
        interval = [NSNumber numberWithInt:10];
        startTime = [NSDate date];
        ledFrequency = [NSNumber numberWithInt:10];
        tempScale = [NSNumber numberWithInt:TEMP_C];
        lowTemperature = [NSNumber numberWithInt:TEMP_MIN];
        highTemperature = [NSNumber numberWithInt:TEMP_MAX_C];
        lowRH = [NSNumber numberWithInt:RH_MIN];
        highRH = [NSNumber numberWithInt:RH_MAX];
        startMode = [NSNumber numberWithInt:AUTO_START];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"samplerConfig: \n\
            configName=%@\n\
            configuredSamples=%@\n\
            recordedSamples=%@\n\
            interval=%@\n\
            startTime=%@\n\
            ledFrequency=%@\n\
            temperatureScale=%@\n\
            temperatureMin=%@\n\
            temperatureMax=%@\n\
            RHMin=%@\n\
            RHMax=%@\n\
            startMode=%@\n",
            self->name, self->configuredSamples, self->recordedSamples, self->interval, self->startTime, self->ledFrequency, self->tempScale, self->lowTemperature, self->highTemperature, self->lowRH, self->highRH, self->startMode];
}

-(s_config *) binaryConfigPtr {
    return &binaryConfig;
}

-(void) setBinaryConfigPtr:(s_config *)binConfig {
    self->binaryConfig = *binConfig;
}

-(void) decodeBinaryConfig {
    self->name = [NSString stringWithUTF8String:binaryConfig.name];
    self->configuredSamples = [NSNumber numberWithInt:binaryConfig.num_data_conf];
    self->recordedSamples = [NSNumber numberWithInt:binaryConfig.num_data_rec];
    self->interval = [NSNumber numberWithInt:binaryConfig.interval];
    
    self->startTime = [NSDate dateWithString:[NSString stringWithFormat:@"%i-%i-%i %i:%i:%i +0000", binaryConfig.time_year, binaryConfig.time_mon, binaryConfig.time_mday, binaryConfig.time_hour, binaryConfig.time_min, binaryConfig.time_sec]];
    
    self->tempScale = [NSNumber numberWithChar:binaryConfig.temp_scale];
    self->lowTemperature = [NSNumber numberWithShort:bin2num(binaryConfig.thresh_temp_low)];
    self->highTemperature = [NSNumber numberWithShort:bin2num(binaryConfig.thresh_temp_high)];
    self->lowRH = [NSNumber numberWithShort:bin2num(binaryConfig.thresh_rh_low)];
    self->highRH = [NSNumber numberWithShort:bin2num(binaryConfig.thresh_rh_high)];
    self->startMode = [NSNumber numberWithChar:binaryConfig.start];
    self->ledFrequency = [NSNumber numberWithInt:(binaryConfig.led_conf & 0x1F)];
}

-(void) encodeBinaryConfig {
    binaryConfig.config_begin = 0xce;
	binaryConfig.config_end = 0xce;
    
    strncpy(binaryConfig.name, [name UTF8String], 16);
    binaryConfig.num_data_conf = configuredSamples.intValue;
    binaryConfig.num_data_rec = recordedSamples.intValue;
    binaryConfig.interval = interval.intValue;
    
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
    
    binaryConfig.temp_scale = tempScale.charValue;
    binaryConfig.thresh_temp_low = num2bin(lowTemperature.shortValue);
    binaryConfig.thresh_temp_high = num2bin(highTemperature.shortValue);
    binaryConfig.thresh_rh_low = num2bin(lowRH.shortValue);
    binaryConfig.thresh_rh_high = num2bin(highRH.shortValue);
    binaryConfig.start = startMode.charValue;
    binaryConfig.led_conf = (1 << 7) | (ledFrequency.intValue & 0x1F);
    
}

-(NSNumber *) configuredSamples {
    return self->configuredSamples;
}

-(void) setConfiguredSamples:(NSNumber *)cfgSamples {
	if (cfgSamples.intValue <= 0 || 16000 < cfgSamples.intValue)
	{
		NSLog(@"isConfigValid: invalid configuredSamples, valid range: [1:16000]\n");
        cfgSamples = [NSNumber numberWithInt:1];
	}
    self->configuredSamples = cfgSamples;
}

-(NSNumber *) interval {
    return interval;
}

-(void) setInterval:(NSNumber *)ival {
    if (ival.intValue <= 0 || 86400 < ival.intValue)
	{
		NSLog(@"isConfigValid: invalid interval, valid range: [1:86400]\n");
        ival = [NSNumber numberWithInt:1];
	}
    self->interval = ival;
}

-(NSNumber *) ledFrequency {
    return self->ledFrequency;
}

-(void) setLedFrequency:(NSNumber *)ledFreq {
    if (ledFreq.intValue != 10 && ledFreq.intValue != 20 && ledFreq.intValue != 30)
	{
		NSLog(@"setLedFrequency: invalid led frequency\n");
        ledFreq = [NSNumber numberWithInt:10];
	}
    self->ledFrequency = ledFreq;
}

-(NSNumber *) tempScale {
    return self->tempScale;
}

-(void) setTempScale:(NSNumber *)scale {
    if (TEMP_C != scale.intValue && TEMP_F != scale.intValue) {
        NSLog(@"setTempScale: invalid scale\n");
        scale = [NSNumber numberWithInt:TEMP_C];
    }
    self->tempScale = scale;
}

-(NSString *) name {
    return self->name;
}

-(void) setName:(NSString *)cfgName {
    if (0 == cfgName.length)
	{
		NSLog(@"isConfigValid: empty name\n");
        cfgName = DEFAULT_CFG_NAME;
	}
    
    self->name = [cfgName substringToIndex: (cfgName.length > 15 ? 15 : cfgName.length)];
}

-(NSNumber *) startMode {
    return self->startMode;
}

-(void) setStartMode:(NSNumber *)stMode {
    if (MANUAL_START != stMode.intValue && AUTO_START != stMode.intValue)
	{
		NSLog(@"setStartMode: invalid start flag\n");
        stMode = [NSNumber numberWithInt:AUTO_START];
	}
    self->startMode = stMode;
}

-(NSNumber *) lowTemperature {
    return self->lowTemperature;
}

-(NSNumber *) highTemperature {
    return self->highTemperature;
}

-(void) setTemperatureRange:(NSNumber *)lowTemp :(NSNumber *) highTemp {
    if (TEMP_F == tempScale.intValue)
	{
		if (lowTemp.intValue < TEMP_MIN || TEMP_MAX_F < lowTemp.intValue)
		{
			NSLog(@"setTemperatureRange: invalid Fahrenheit lowTemperature\n");
            lowTemp = [NSNumber numberWithInt:TEMP_MIN];
		}
	} else {
		if (lowTemp.intValue < TEMP_MIN || TEMP_MAX_C < lowTemp.intValue)
		{
			NSLog(@"setTemperatureRange: invalid Celcius lowTemperature\n");
            lowTemp = [NSNumber numberWithInt:TEMP_MIN];
		}
	}
    
    if (TEMP_F == tempScale.intValue)
	{
		if (highTemp.intValue < TEMP_MIN || TEMP_MAX_F < highTemp.intValue)
		{
			NSLog(@"setTemperatureRange: invalid Fahrenheit highTemperature\n");
            highTemp = [NSNumber numberWithInt:TEMP_MAX_F];
		}
	} else {
		if (highTemp.intValue < TEMP_MIN || TEMP_MAX_C < highTemp.intValue)
		{
			NSLog(@"setTemperatureRange: invalid Celcius highTemperature\n");
            highTemp = [NSNumber numberWithInt:TEMP_MAX_C];
		}
	}
    
    if (highTemp.intValue <= lowTemp.intValue) {
        NSLog(@"setTemperatureRange: highTemp greater than lowTemp\n");
        highTemp = [NSNumber numberWithInt:lowTemp.intValue + 1];
    }
    
    self->lowTemperature = lowTemp;
    self->highTemperature = highTemp;
}

-(NSNumber *) lowRH {
    return self->lowRH;
}

-(NSNumber *) highRH {
    return self->highRH;
}

-(void) setRHRange:(NSNumber *)lowHum :(NSNumber *)highHum {
    if (lowHum.intValue < RH_MIN || RH_MAX < lowHum.intValue)
	{
		NSLog(@"setRHRange: invalid thresh_rh_low\n");
        lowHum = [NSNumber numberWithInt:RH_MIN];
	}
	
	if (highHum.intValue < RH_MIN || RH_MAX < highHum.intValue)
	{
		NSLog(@"setRHRange: invalid thresh_rh_high\n");
        highHum = [NSNumber numberWithInt:RH_MAX];
	}
	
	if (highHum.intValue < lowHum.intValue)
	{
		NSLog(@"setRHRange: invalid thresh_rh_low/high\n");
        highHum = [NSNumber numberWithInt:lowHum.intValue + 1];
	}
    
    self->lowRH = lowHum;
    self->highRH = highHum;
}

-(NSDate *) startTime {
    return startTime;
}

-(void) setStartTime:(NSDate *)sTime {
    /* USELESS ?
     if ([sTime compare:[NSDate date]] == NSOrderedAscending) {
     NSLog(@"setStartTime : sTime in the past");
     sTime = [NSDate date];
     }
     */
    self->startTime = sTime;
}

-(id) initWithPropertyListAtPath:(NSString *) path {
    self = [super init];
    
    NSPropertyListFormat format;
    NSString *errorDesc = nil;
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:path];
    NSDictionary *dict = (NSDictionary *)[NSPropertyListSerialization
                                          propertyListFromData:plistXML
                                          mutabilityOption:NSPropertyListImmutable
                                          format:&format
                                          errorDescription:&errorDesc];
    if (!dict) {
        NSLog(@"Error reading plist: %@, format: %ld", errorDesc, format);
    }
    
    self.configuredSamples = [dict objectForKey:@"configuredSamples"];
    self.interval = [dict objectForKey:@"interval"];
    self.ledFrequency = [dict objectForKey:@"ledFrequency"];
    self.tempScale = [dict objectForKey:@"tempScale"];
    self.name = [dict objectForKey:@"name"];
    self.startMode = [dict objectForKey:@"startMode"];
    self.startTime = [NSDate date];
    
    return self;
}

-(void) save:(NSString *)path {
    NSDictionary *dict = [NSDictionary
                          dictionaryWithObjects:[NSArray arrayWithObjects:
                                                 configuredSamples,
                                                 interval,
                                                 ledFrequency,
                                                 tempScale,
                                                 name,
                                                 startMode,
                                                 nil]
                          forKeys:[NSArray arrayWithObjects:
                                   @"configuredSampled",
                                   @"interval",
                                   @"ledFrequency",
                                   @"tempScale",
                                   @"name",
                                   @"startMode",
                                   nil]];
    
    [dict writeToFile:path atomically:TRUE];
}

@end
