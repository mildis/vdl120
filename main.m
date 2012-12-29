#include "usbSampler.h"
#include "samplerConfig.h"
#include "samplingSession.h"

int main(int argc, char **argv)
{
    usbSampler *sampler = [[usbSampler alloc] init];
    //samplingSession *session = [[samplingSession alloc] initWithSampler:sampler];
    

    samplerConfig *cfg = [[samplerConfig alloc] init];
    [cfg setName:@"testAgain"];
    [cfg setConfiguredSamples:12];
    [cfg setInterval:5];
    [cfg setLedFrequency:10];
    [cfg setStartTime:[NSDate date]];
    [cfg setTemperatureRange:15 :30];
    [cfg setRHRange:0 :100];
    [cfg encodeBinaryConfig];
    
    [sampler setCfg:cfg];
    [sampler writeConfigToSampler];
}
