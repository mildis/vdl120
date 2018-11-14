#ifndef _usbSampler_h
#define _usbSampler_h

#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>
#import <IOKit/IOCFPlugIn.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/usb/IOUSBLib.h>
#import <IOKit/usb/USBSpec.h>
#import "samplerConfig.h"

#define VID 0x10c4 /* Cygnal Integrated Products, Inc. */
#define PID 0x0003 /* Silabs C8051F320 USB Board */
#define BUFSIZE CONFIGSIZE /* wMaxPacketSize = 1x 64 bytes */

#define DL120_RDCNF 0
#define DL120_WRCNF 1
#define DL120_RDDAT 2
#define DL120_KEEP  3



@interface usbSampler : NSObject {
    IOUSBDeviceInterface** usbDevice;
    IOUSBInterfaceInterface** usbInterface;
    UInt8 pipeIn;
    UInt8 pipeOut;
    samplerConfig *cfg;
    
}
-(IOReturn) readFromSampler:(void *)toBuf :(UInt32) ofSize;
-(IOReturn) writeToSampler:(void *)fromBuf :(UInt32) ofSize;
-(IOReturn) setSamplerCommand:(int) command;
-(IOReturn) setSamplerCommand:(int) command :(char) offset;
-(void) readConfigFromSampler;
-(IOReturn) writeConfigToSampler;
-(void) printCurrentConfig;
-(NSMutableArray *) readData;
-(void) printDatas:(NSMutableArray *)datas;

@property IOUSBDeviceInterface** usbDevice;
@property IOUSBInterfaceInterface** usbInterface;
@property UInt8 pipeIn;
@property UInt8 pipeOut;
@property samplerConfig* cfg;

@end

#endif
