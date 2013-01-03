#include "usbSampler.h"
#include "samplerConfig.h"
#include "samplingSession.h"

int main(int argc, char **argv)
{
    usbSampler *sampler = [[usbSampler alloc] init];
    
    samplingSession *session = [[samplingSession alloc] initWithSampler:sampler];
    NSLog(@"%@", [session datas]);
    
    /*
    BOOL saveOK =[session save:@"~/session.plist"];
    if (saveOK == YES) {
        NSLog(@"Saving OK");
    }
    else {
        NSLog(@"Saving NOK");
    }
    */
    
    /*
    samplerConfig *cfg = [[samplerConfig alloc] init];
    [cfg setName:@"testAgain3"];
    [cfg setConfiguredSamples:[NSNumber numberWithInt:12]];
    [cfg setInterval:[NSNumber numberWithInt:5]];
    [cfg setLedFrequency:[NSNumber numberWithInt:10]];
    [cfg setStartTime:[NSDate date]];
    [cfg setTemperatureRange:[NSNumber numberWithInt:15] :[NSNumber numberWithInt:30]];
    [cfg setRHRange:[NSNumber numberWithInt:0] :[NSNumber numberWithInt:100]];
    [cfg encodeBinaryConfig];
    
    [sampler setCfg:cfg];
    [sampler writeConfigToSampler];
    */
}
