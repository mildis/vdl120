#ifndef _samplingSession_h
#define _samplingSession_h

#import <Foundation/Foundation.h>
#import "usbSampler.h"

@interface samplingSession : NSObject {
    NSString *name;
    NSDate *startedAt;
    NSInteger interval;
    NSMutableArray *datas;
}

@property NSString *name;
@property NSDate *startedAt;
@property NSInteger interval;
@property NSMutableArray *datas;

-(id) initWithSampler:(usbSampler *)sampler;

@end
#endif