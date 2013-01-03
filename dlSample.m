#import "dlSample.h"

@implementation dlSample

@synthesize timestamp;
@synthesize RH;
@synthesize temperature;

-(id) init {
    self = [super init];
    if (self) {
        timestamp = [NSDate date];
        RH = 0;
        temperature = 0;
    }
    return self;
}

-(NSString *) description {
    return [NSString stringWithFormat: @"sample: ts:%@ temp:%@ rh:%@", timestamp, temperature, RH];
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.timestamp forKey:@"timestamp"];
    [aCoder encodeObject:self.RH forKey:@"RH"];
    [aCoder encodeObject:self.temperature forKey:@"temperature"];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        self.timestamp = [aDecoder decodeObjectForKey:@"timestamp"];
        self.RH = [aDecoder decodeObjectForKey:@"RH"];
        self.temperature = [aDecoder decodeObjectForKey:@"temperature"];
    }
    
    return self;
}

@end
