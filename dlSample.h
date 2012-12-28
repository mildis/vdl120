#ifndef _dlSample_h
#define _dlSample_h

#import <Foundation/Foundation.h>

@interface dlSample : NSObject {
    NSDate *timestamp;
    NSInteger RH;
    NSInteger temperature;
}

@property NSDate *timestamp;
@property NSInteger RH;
@property NSInteger temperature;

@end
#endif