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

-(id) initWithArchiveAtPath:(NSString *) path {
    self = [super init];
    
    self = [NSKeyedUnarchiver unarchiveObjectWithFile:[path stringByExpandingTildeInPath]];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.startedAt forKey:@"startedAt"];
    [aCoder encodeObject:self.interval forKey:@"interval"];
    [aCoder encodeObject:self.datas forKey:@"datas"];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {     
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.startedAt = [aDecoder decodeObjectForKey:@"startedAt"];
        self.interval = [aDecoder decodeObjectForKey:@"interval"];
        self.datas = [aDecoder decodeObjectForKey:@"datas"];
    }

    return self;
}

-(BOOL) save:(NSString *)path {
    return [NSKeyedArchiver archiveRootObject:self toFile:[path stringByExpandingTildeInPath]];
}

@end
