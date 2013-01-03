#ifndef _dlSample_h
#define _dlSample_h

#import <Foundation/Foundation.h>

@interface dlSample : NSObject <NSCoding> {
    NSDate *timestamp;
    NSNumber *RH;
    NSNumber *temperature;
}

@property NSDate *timestamp;
@property NSNumber *RH;
@property NSNumber *temperature;

@end
#endif