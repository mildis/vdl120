#import "usbSampler.h"
#import "dlSample.h"

@implementation usbSampler

@synthesize usbDevice;
@synthesize usbInterface;
@synthesize pipeIn;
@synthesize pipeOut;
@synthesize cfg;

- (id)init
{
    
#ifdef DEBUG
    NSLog(@"Entering init\n");
#endif
    
    self = [super init];
    if (self) {
        
        CFMutableDictionaryRef matchingDictionary = NULL;
        SInt32 idVendor = VID;
        SInt32 idProduct = PID;
        io_iterator_t iterator;
        io_service_t usbRef;
        SInt32 score = 0;
        IOCFPlugInInterface** plugin;
        IOReturn ret;
        IOUSBConfigurationDescriptorPtr config;
        IOUSBFindInterfaceRequest interfaceRequest;
        UInt8 numEndpoints = 0;
        UInt8 dir = 0;
        UInt8 num = 0;
        UInt8 ttype = 0;
        UInt16 maxPS = 0;
        UInt8 interval = 0;
        
        
        
        matchingDictionary = IOServiceMatching("IOUSBDevice");
        CFDictionaryAddValue(matchingDictionary,
                             CFSTR(kUSBVendorID),
                             CFNumberCreate(kCFAllocatorDefault,
                                            kCFNumberSInt32Type, &idVendor));
        CFDictionaryAddValue(matchingDictionary,
                             CFSTR(kUSBProductID),
                             CFNumberCreate(kCFAllocatorDefault,
                                            kCFNumberSInt32Type, &idProduct));
        IOServiceGetMatchingServices(kIOMasterPortDefault,
                                     matchingDictionary, &iterator);
        
        usbRef = IOIteratorNext(iterator);
        if (usbRef == 0) {
            NSLog(@"usb_init:device not found\n");
            return NULL;
        }
        
        IOObjectRelease(iterator);
        IOCreatePlugInInterfaceForService(usbRef, kIOUSBDeviceUserClientTypeID,
                                          kIOCFPlugInInterfaceID, &plugin, &score);
        IOObjectRelease(usbRef);
        (*plugin)->QueryInterface(plugin,
                                  CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID),
                                  (LPVOID)&usbDevice);
        (*plugin)->Release(plugin);
        
        ret = (*usbDevice)->USBDeviceOpen(usbDevice);
        if (ret == kIOReturnSuccess)
        {
            // set first configuration as active
            ret = (*usbDevice)->GetConfigurationDescriptorPtr(usbDevice, 0, &config);
            if (ret != kIOReturnSuccess)
            {
                NSLog(@"usb_init:could not get configuration descriptor (error: %x)\n", ret);
                return NULL;
            }
            ret = (*usbDevice)->SetConfiguration(usbDevice, config->bConfigurationValue);
            if (ret != kIOReturnSuccess)
            {
                NSLog(@"usb_init:could not set active configuration (error: %x)\n", ret);
                return NULL;
            }
        }
        else if (ret == kIOReturnExclusiveAccess)
        {
            // this is not a problem as we can still do some things
            NSLog(@"usb_init:got exclusive access (warning: %x)\n", ret);
        }
        else
        {
            NSLog(@"usb_init:could not open device (error: %x)\n", ret);
            return NULL;
        }
        
        interfaceRequest.bInterfaceClass = kIOUSBFindInterfaceDontCare;
        interfaceRequest.bInterfaceSubClass = kIOUSBFindInterfaceDontCare;
        interfaceRequest.bInterfaceProtocol = kIOUSBFindInterfaceDontCare;
        interfaceRequest.bAlternateSetting = kIOUSBFindInterfaceDontCare;
        (*usbDevice)->CreateInterfaceIterator(usbDevice,
                                              &interfaceRequest, &iterator);
        usbRef = IOIteratorNext(iterator);
        IOObjectRelease(iterator);
        IOCreatePlugInInterfaceForService(usbRef,
                                          kIOUSBInterfaceUserClientTypeID,
                                          kIOCFPlugInInterfaceID, &plugin, &score);
        IOObjectRelease(usbRef);
        (*plugin)->QueryInterface(plugin,
                                  CFUUIDGetUUIDBytes(kIOUSBInterfaceInterfaceID),
                                  (LPVOID)&usbInterface);
        (*plugin)->Release(plugin);
        
        ret = (*usbInterface)->USBInterfaceOpen(usbInterface);
        if (ret != kIOReturnSuccess)
        {
            NSLog(@"Could not open interface (error: %x)\n", ret);
            return NULL;
        }
        
        self->pipeIn = 0;
        self->pipeOut = 0;
        
        ret = (*usbInterface)->GetNumEndpoints(usbInterface, &numEndpoints);
        if (ret != kIOReturnSuccess)
        {
            NSLog(@"usb_init:GetNumEndpoints (error: %x)\n", ret);
            return NULL;
        }
        
        for (UInt8 ep = 1; ep <= numEndpoints; ep++) {
            ret = (*usbInterface)->GetPipeProperties(usbInterface, ep, &dir, &num, &ttype, & maxPS, &interval);
            if (ret != kIOReturnSuccess)
            {
                NSLog(@"usb_init:GetPipeProperties (error: %x)\n", ret);
                return NULL;
            }
            
            if (kUSBIn == dir) {
                self->pipeIn = ep;
            }
            else if (kUSBOut == dir) {
                self->pipeOut = ep;
            }
            
            if (self->pipeOut && self->pipeIn)
                break;
        }
        
        (*usbInterface)->GetPipeStatus(usbInterface, pipeIn);
        (*usbInterface)->ResetPipe(usbInterface, pipeIn);
        (*usbInterface)->GetPipeStatus(usbInterface, pipeOut);
        (*usbInterface)->ResetPipe(usbInterface, pipeOut);
        
#ifdef DEBUG
        NSLog(@"Leaving init\n");
#endif
    }
    return self;
}

-(void)dealloc {
#ifdef DEBUG
    NSLog(@"Entering dealloc\n");
#endif
    int ret = 0;
    
    if (NULL != usbInterface) {
        ret = (*(usbInterface))->ResetPipe(usbInterface, pipeIn);
#ifdef DEBUG
        NSLog(@"ResetPipeIn : %i\n", ret);
#endif
        ret = (*(usbInterface))->ResetPipe(usbInterface, pipeOut);
#ifdef DEBUG
        NSLog(@"ResetPipeOut : %i\n", ret);
#endif
    }
    /*
     ret = (*(p->usbInterface))->USBInterfaceClose(p->usbInterface);
     printf("USBInterfaceClose : %i\n", ret);
     ret = (*(p->usbInterface))->Release(p->usbInterface);
     printf("Release : %i\n", ret);
     */
    if (NULL != usbDevice) {
        ret = (*(usbDevice))->USBDeviceClose(usbDevice);
#ifdef DEBUG
        NSLog(@"USBDeviceClose : %i\n", ret);
#endif
        ret = (*(usbDevice))->Release(usbDevice);
#ifdef DEBUG
        NSLog(@"Release : %i\n", ret);
#endif
    }
    
#ifdef DEBUG
    NSLog(@"Leaving dealloc\n");
#endif
}

-(IOReturn) readFromSampler:(void *)toBuf :(UInt32)ofSize {
#ifdef DEBUG
    NSLog(@"Entering readFromSampler\n");
    NSLog(@"PipeIn Status : %i\n",(*(usbInterface))->GetPipeStatus(usbInterface, pipeIn));
#endif
    
    
    IOReturn ret = (*(usbInterface))->ReadPipe(usbInterface, pipeIn, toBuf, &ofSize);
    
    if (kIOReturnSuccess != ret)
    {
        NSLog(@"readFromSampler:failed with error %x\n", ret);
    }
    
#ifdef DEBUG
    NSLog(@"Leaving readFromSampler\n");
#endif
    return ret;
}

-(IOReturn) writeToSampler:(void *)fromBuf :(UInt32) ofSize {
#ifdef DEBUG
    NSLog(@"PipeOut Status : %i\n",(*(usbInterface))->GetPipeStatus(usbInterface, pipeOut));
#endif
    
    IOReturn ret = (*(usbInterface))->WritePipe(usbInterface, pipeOut, fromBuf, ofSize);
    if (kIOReturnSuccess != ret)
    {
        NSLog(@"writeToSampler:failed with error %x\n", ret);
    }
    
#ifdef DEBUG
    NSLog(@"Leaving writeToSampler\n");
#endif
    return ret;
}

-(IOReturn) setSamplerCommand: (int) command {
#ifdef DEBUG
    NSLog(@"Entering setSamplerCommand\n");
#endif
    
    char buf[BUFSIZE];
    
    switch (command) {
        case DL120_RDCNF:
            buf[0] = 0x00;
            buf[1] = 0x10;
            buf[2] = 0x01;
            break;
            
        case DL120_WRCNF:
            buf[0] = 0x01;
            buf[1] = 0x40;
            buf[2] = 0x00;
            break;
            
        case DL120_RDDAT:
            buf[0] = 0x00;
            buf[1] = 0x00;
            buf[2] = 0x40;
            break;
            
        case DL120_KEEP:
            buf[0] = 0x00;
            buf[1] = 0x01;
            buf[2] = 0x40;
            break;
            
        default:
            NSLog(@"setSamplerCommand command %i not implemented", command);
            break;
    }
    
#ifdef DEBUG
    NSLog(@"Leaving setSamplerCommand\n");
#endif
    return [self writeToSampler :&buf :3];
}

-(void) readConfigFromSampler {
#ifdef DEBUG
    NSLog(@"Entering readConfigFromSampler\n");
#endif
    
    char buf[BUFSIZE];
    IOReturn ret;
#ifdef DEBUG
    int i;
#endif
    
    if (nil == cfg) {
#ifdef DEBUG
        NSLog(@"readConfigFromSampler: no configuration allocated. Allocating one.");
#endif
        cfg = [samplerConfig new];
    }
    
    ret = [self setSamplerCommand: DL120_RDCNF];
    if (kIOReturnSuccess == ret)
    {
        ret = [self readFromSampler: &buf: 3];
        if (kIOReturnSuccess == ret)
        {
#ifdef DEBUG
            NSLog(@"readConfigFromSampler: response header:");
            for (i=0; i<3; i++)
            {
                NSLog(@" %02x", 0xFF & buf[i]);
            }
            NSLog(@"\n");
#endif
            // buf[1:2] --> logger status?
            // 02 00 00 = no data, ready to log
            // 02 b8 01 = still logging, data available
            // 02 58 13 = ditto
            // 02 c8 00 = done logging, data available
            
            /* read response data (64 byte) */
            ret = [self readFromSampler: [cfg binaryConfigPtr]: CONFIGSIZE];
            if (kIOReturnSuccess != ret)
            {
                NSLog(@"readConfigFromSampler:readFromSampler config failed with error %i\n", ret);
            }
            [cfg decodeBinaryConfig];
#ifdef DEBUG
            NSLog(@"readConfigFromSampler: read result = %@", cfg);
#endif
        }
        else {
            NSLog(@"readConfigFromSampler:readFromSampler logger status failed with error %i\n", ret);
        }
    }
    else {
        NSLog(@"readConfigFromSampler:setSamplerCommand failed with error %i\n", ret);
    }
    
#ifdef DEBUG
    NSLog(@"Leaving readConfigFromSampler\n");
#endif
}

-(IOReturn) writeConfigToSampler {
#ifdef DEBUG
    NSLog(@"Entering writeConfigToSampler\n");
#endif
    
    char buf[BUFSIZE];
    IOReturn ret;
    
    if (nil == cfg) {
        NSLog(@"writeConfigToSampler : no configuration set");
    }
    else {
        [cfg encodeBinaryConfig];
        //#ifdef DEBUG
        NSLog(@"writeConfigToSampler: about to write %@", cfg);
        //#endif
        /*
         printf("writing config data:");
         for (i=0; i<64; i++)
         {
         if (i % 8 == 0)
         printf("\n\t");
         printf("%02x ", 0xFF & *(((char *)cfg)+i));
         }
         printf("\n");
         */
        
        ret = [self setSamplerCommand: DL120_WRCNF];
        if (kIOReturnSuccess == ret)
        {
            ret = [self writeToSampler: [cfg binaryConfigPtr]: CONFIGSIZE];
            if (kIOReturnSuccess == ret)
            {
                /* read response code (1 byte) */
                ret = [self readFromSampler: &buf :1];
                if (kIOReturnSuccess == ret)
                {
                    if ((buf[0] & 0xff) != 0xff)
                    {
                        NSLog(@"writeConfigToSampler: device not acknwoledged with response code: %02x\n", (buf[0] & 0xff));
                        ret = kIOReturnError;
                    }
                }
                else
                {
                    NSLog(@"writeConfigToSampler:usb_read response failed with error %i\n", ret);
                }
                
            }
            else {
                NSLog(@"writeConfigToSampler:usb_write failed with error %i\n", ret);
            }
        }
    }
#ifdef DEBUG
    NSLog(@"Leaving writeConfigToSampler\n");
#endif
    
    return ret;
}

-(NSMutableArray *) readData {
    
	char buf[BUFSIZE];
	int ret, i, num_data;
	
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[cfg recordedSamples].intValue];
	
	if ([cfg recordedSamples].intValue == 0)
	{
		NSLog(@"readData: no data to read\n");
		return NULL;
	}
    
    ret = [self setSamplerCommand: DL120_RDDAT];
    
	if (kIOReturnSuccess == ret){
        
        NSDate *startedAt = [cfg startTime];
        
        for (num_data = 0; num_data < [cfg recordedSamples].intValue;)
        {
            if (num_data >= 4096) return array;
            
            /* send (random?) keep-alive packet every 1024 bytes */
            /* the logger sends another response header before further data */
            if (num_data % 1024 == 0)
            {
                if (0 < num_data) {
                    ret = [self setSamplerCommand: DL120_KEEP];
                    if (kIOReturnSuccess != ret)
                    {
                        NSLog(@"readData:send_cmd keep alive failed with error %i\n", ret);
                        //break ?
                        return NULL;
                    }
                }
                else {
                    ret = [self readFromSampler: &buf: 3];
                    if (kIOReturnSuccess != ret) {
                        NSLog(@"readData:keep alive return failed with error %i\n", ret);
                        //break ?
                        return NULL;
                    }
                }
            }
            
            ret = [self readFromSampler: &buf :BUFSIZE];
            if (kIOReturnSuccess == ret) {
                /* parse data: 4 bytes per data point (64/4=16) */
                for (i = 0; i < (BUFSIZE/4); i++)
                {
                    dlSample *data_temp = [dlSample new];
                    [data_temp setTimestamp:[startedAt dateByAddingTimeInterval:([[cfg interval]intValue]*num_data)]];
                    [data_temp setTemperature:[NSNumber numberWithShort:*((short int *)buf+(i*2))]];
                    [data_temp setRH:[NSNumber numberWithShort:*((short int *)buf+(i*2)+1)]];
                    
                    /*
                     memcpy((char *)data_temp, (char *)buf+i*4, 4);
                     data_temp->time = time_start_stamp + num_data * cfg->interval;
                     data_temp->next = NULL;
                     */

                    [array addObject:data_temp];
                    
                    num_data++;
                    if (num_data == [cfg recordedSamples].intValue) {
#ifdef DEBUG
                        NSLog(@"readData : read %i records", num_data);
#endif
                        break;
                    }
                }
            }
            else {
                NSLog(@"readData:reading data failed with error %i\n", ret);
                //break ?
                return NULL;
            }
        }
    }
    else
	{
		NSLog(@"readData:send_cmd failed with error %i\n", ret);
		return NULL;
	}
    
#ifdef DEBUG
    NSLog(@"Leaving readData\n");
#endif
	
	return array;
}

-(void) printDatas:(NSMutableArray *)datas {
#ifdef DEBUG
    NSLog(@"Entering printData\n");
#endif
    
    for (dlSample *sample in datas) {
        NSLog(@"%@", sample);
    }
    
#ifdef DEBUG
    NSLog(@"Leaving printData\n");
#endif
    
}

-(void) printCurrentConfig {
    if (nil == cfg) {
        NSLog(@"No configuration set");
    }
    else {
        NSLog(@"currentConfig :\n%@", cfg);
    }
}

@end
