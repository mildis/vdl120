#import "dlSample.h"

@implementation dlSample

@synthesize timestamp;
@synthesize RH;
@synthesize temperature;

-(id) init {
    self = [super init];
    if (self) {
        RH = 0;
        temperature = 0;
    }
    return self;
}

-(NSString *) description {
    return [NSString stringWithFormat: @"sample: ts:%@ temp:%li rh:%li\n", timestamp, temperature, RH];
}

@end
