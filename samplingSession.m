#import "samplingSession.h"

@implementation samplingSession

@synthesize name;
@synthesize startedAt;
@synthesize interval;
@synthesize datas;

-(id) initWithSampler:(usbSampler *)sampler {
    self = [super init];
    if (self) {
        [sampler readConfigFromSampler];
        [self setName:[[sampler cfg] name]];
        [self setStartedAt:[[sampler cfg] startTime]];
        [self setInterval:[[sampler cfg] interval]];
        [self setDatas:[sampler readData]];
    }
    return self;
}

@end
