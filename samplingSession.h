#ifndef _samplingSession_h
#define _samplingSession_h

#import <Foundation/Foundation.h>
#import "usbSampler.h"

@interface samplingSession : NSObject <NSCoding> {
    NSString *name;
    NSDate *startedAt;
    NSNumber *interval;
    NSMutableArray *datas;
}

@property NSString *name;
@property NSDate *startedAt;
@property NSNumber *interval;
@property NSMutableArray *datas;

-(id) initWithSampler:(usbSampler *)sampler;
-(id) initWithArchiveAtPath:(NSString *) path;
-(BOOL) save:(NSString *)path;

@end
#endif