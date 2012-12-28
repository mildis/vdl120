#include "usbSampler.h"
#include "samplerConfig.h"

int main(int argc, char **argv)
{
    
	if (argc < 2)
	{
		printf("usage:\n"),
		printf("\t%s -c LOGNAME NUM_DATA INTERVAL  -->  configure logger\n", argv[0]);
		printf("\t%s -p  -->  print config\n", argv[0]);
		printf("\t%s -d  -->  print data\n", argv[0]);
		printf("\t%s -s  -->  store data in LOGNAME.dat\n", argv[0]);
		return 1;
	}
	
    usbSampler *sampler = [[usbSampler alloc] init];
    [sampler readConfigFromSampler];
    NSMutableArray *retrievedDatas = [sampler readData];
    [sampler printDatas: retrievedDatas];

    /*
    samplerConfig *cfg = [sampler cfg];
    [cfg setConfigName:@"testObjc"];
    [cfg setConfiguredSamples:6];
    [cfg setInterval:10];
    [cfg setLedFrequency:10];
    [cfg setStartTime:[NSDate date]];
    [cfg setTemperatureRange:15 :30];
    [cfg setRHRange:0 :100];
    [cfg encodeBinaryConfig];
    
    [sampler writeConfigToSampler];
     */
}
