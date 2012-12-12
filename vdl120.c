#include "vdl120.h"

s_usb_dl120 *usb_init() {
#ifdef DEBUG
    printf("Entering usb_init\n");
#endif
    
    s_usb_dl120 *dl120 = NULL;
    CFMutableDictionaryRef matchingDictionary = NULL;
    SInt32 idVendor = VID;
    SInt32 idProduct = PID;
    io_iterator_t iterator = 0;
    io_service_t usbRef;
    SInt32 score;
    IOCFPlugInInterface** plugin;
    IOUSBDeviceInterface** usbDevice = NULL;
    IOReturn ret;
    IOUSBConfigurationDescriptorPtr config;
    IOUSBFindInterfaceRequest interfaceRequest;
    IOUSBInterfaceInterface** usbInterface;
    
    
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
        printf("usb_init:device not found\n");
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
            printf("usb_init:could not get configuration descriptor (error: %x)\n", ret);
            return NULL;
        }
        ret = (*usbDevice)->SetConfiguration(usbDevice, config->bConfigurationValue);
        if (ret != kIOReturnSuccess)
        {
            printf("usb_init:could not set active configuration (error: %x)\n", ret);
            return NULL;
        }
    }
    else if (ret == kIOReturnExclusiveAccess)
    {
        // this is not a problem as we can still do some things
        printf("usb_init:got exclusive access (warning: %x)\n", ret);
    }
    else
    {
        printf("usb_init:could not open device (error: %x)\n", ret);
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
        printf("Could not open interface (error: %x)\n", ret);
        return NULL;
    }
    
    dl120 = (s_usb_dl120*) malloc(sizeof(s_usb_dl120));
    if (dl120 == NULL) {
        printf("usb_init:failed to malloc s_usb_dl120");
    }
    else {
        dl120->usbDevice = usbDevice;
        dl120->usbInterface = usbInterface;
        printf("Pipe Status : %i\n",(*usbInterface)->GetPipeStatus(usbInterface, 1));
        printf("ResetPipe : %i\n", (*usbInterface)->ResetPipe(usbInterface, 1));
        printf("Pipe Status : %i\n",(*usbInterface)->GetPipeStatus(usbInterface, 2));
        printf("ResetPipe : %i\n", (*usbInterface)->ResetPipe(usbInterface, 2));
    }
        
#ifdef DEBUG
    printf("Leaving usb_init\n");
#endif
    
    return dl120;
}

void usb_close(s_usb_dl120 *p) {
#ifdef DEBUG
    printf("Entering usb_close\n");
#endif
    int ret = 0;
    ret = (*(p->usbInterface))->ResetPipe(p->usbInterface, 1);
    printf("ResetPipe : %i\n", ret);
    ret = (*(p->usbInterface))->ResetPipe(p->usbInterface, 2);
    printf("ResetPipe : %i\n", ret);
    /*
    ret = (*(p->usbInterface))->USBInterfaceClose(p->usbInterface);
    printf("USBInterfaceClose : %i\n", ret);
    ret = (*(p->usbInterface))->Release(p->usbInterface);
    printf("Release : %i\n", ret);
    */
    ret = (*(p->usbDevice))->USBDeviceClose(p->usbDevice);
    printf("USBDeviceClose : %i\n", ret);
    ret = (*(p->usbDevice))->Release(p->usbDevice);
    printf("Release : %i\n", ret);
#ifdef DEBUG
    printf("Leaving usb_close\n");
#endif

}

IOReturn usb_read(s_usb_dl120 *p, void *buf, UInt32 size) {
#ifdef DEBUG
    printf("Entering usb_read %p, %p, %i\n", p, buf, size);
    printf("Pipe Status : %i\n",(*(p->usbInterface))->GetPipeStatus(p->usbInterface, 1));
#endif
    

    IOReturn ret = (*(p->usbInterface))->ReadPipe(p->usbInterface, 1, buf, &size);
    
    if (kIOReturnSuccess != ret)
    {
        printf("usb_read:failed with error %x\n", ret);
    }
    
#ifdef DEBUG
    printf("Leaving usb_read\n");
#endif

    return ret;
}

IOReturn usb_write(s_usb_dl120 *p, void *buf, UInt32 size) {
#ifdef DEBUG
    printf("Entering usb_write %p, %p, %i\n", p, buf, size);
    printf("Pipe Status : %i\n",(*(p->usbInterface))->GetPipeStatus(p->usbInterface, 2));
#endif
    IOReturn ret = (*(p->usbInterface))->WritePipe(p->usbInterface, 2, buf, size);
    if (kIOReturnSuccess != ret)
    {
        printf("usb_write:failed with error %x\n", ret);
    }
#ifdef DEBUG
    printf("Leaving usb_write\n");
#endif

    return ret;
}

IOReturn dl120_send_cmd(s_usb_dl120 *p, int command) {
#ifdef DEBUG
    printf("Entering dl120_send_cmd\n");
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
            printf("dl120_send_cmd command %i not implemented", command);
            break;
    }
    
#ifdef DEBUG
    printf("Leaving dl120_send_cmd\n");
#endif

    
    return usb_write(p, buf, 3);
}


s_config *read_config(s_usb_dl120 *p) {
#ifdef DEBUG
    printf("Entering read_config\n");
#endif

	char buf[BUFSIZE];
	IOReturn ret;
	s_config *cfg = NULL;
    int i;
	
    ret = dl120_send_cmd(p, DL120_RDCNF);
	if (kIOReturnSuccess == ret)
	{
        ret = usb_read(p, buf, 3);
        if (kIOReturnSuccess == ret)
        {
              printf("read_config: response header:");
              for (i=0; i<3; i++)
              {
              printf(" %02x", 0xFF & buf[i]);
              }
              printf("\n");
            
            
            // buf[1:2] --> logger status?
            // 02 00 00 = no data, ready to log
            // 02 b8 01 = still logging, data available
            // 02 58 13 = ditto
            // 02 c8 00 = done logging, data available
            
            /* read response data (64 byte) */
            cfg = malloc(sizeof(s_config));
            ret = usb_read(p, cfg, sizeof(s_config));
            if (kIOReturnSuccess != ret)
            {
                printf("read_config:usb_read config failed with error %i\n", ret);
            }
        }
        else {
            printf("read_config:usb_read logger status failed with error %i\n", ret);
        }
	}
    else {
        printf("read_config:dl120_send_cmd failed with error %i\n", ret);
    }
	
#ifdef DEBUG
    printf("Leaving read_config\n");
#endif

	return cfg;
}

IOReturn write_config(s_usb_dl120 *p, s_config *cfg) {
#ifdef DEBUG
    printf("Entering write_config\n");
#endif

	char buf[BUFSIZE];
	IOReturn ret;
	
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
    
    ret = dl120_send_cmd(p, DL120_WRCNF);
    if (kIOReturnSuccess == ret)
	{
        ret = usb_write(p, cfg,	sizeof(s_config));
        if (kIOReturnSuccess == ret)
        {
            /* read response code (1 byte) */
            ret = usb_read(p, buf, 1);
            if (kIOReturnSuccess == ret)
            {
                if ((buf[0] & 0xff) != 0xff)
                {
                    printf("write_config: device not acknwoledged with response code: %02x\n", (buf[0] & 0xff));
                    ret = kIOReturnError;
                }
            }
            else
            {
                printf("write_config:usb_read response failed with error %i\n", ret);
            }
            
        }
        else {
            printf("write_config:usb_write failed with error %i\n", ret);
        }
    }
    
#ifdef DEBUG
    printf("Leaving write_config\n");
#endif
	
	return ret;
}

s_data *read_data(s_usb_dl120 *p, s_config *cfg) {
#ifdef DEBUG
    printf("Entering read_data\n");
#endif

	char buf[BUFSIZE];
	int ret, i, num_data;
	
	s_data *data_head = NULL;
	s_data *data_tail  = NULL;
	s_data *data_temp  = NULL;
	
	/* try to read config */
	if (cfg == NULL) {
		cfg = read_config(p);
		if (cfg == NULL)
		{
			printf("read_data: failed to get config\n");
			return NULL;
		}
	}
	
	if (cfg->num_data_rec == 0)
	{
		printf("read_data: no data to read\n");
		return NULL;
	}
    
    ret = dl120_send_cmd(p, DL120_RDDAT);
    
	if (kIOReturnSuccess == ret){
        struct tm *time_start;
        time_start = malloc(sizeof(struct tm));
        memset(time_start, 0, sizeof(struct tm));
        time_start->tm_year = -1900 + cfg->time_year;
        time_start->tm_mon  = -1 + cfg->time_mon;
        time_start->tm_mday = cfg->time_mday;
        time_start->tm_hour = cfg->time_hour;
        time_start->tm_min  = cfg->time_min;
        time_start->tm_sec  = cfg->time_sec;
        time_start->tm_isdst = -1;
        
        time_t time_start_stamp;
        // create GMT timestamps for Gnuplot
        setenv("TZ", "GMT", 1);
        time_start_stamp = mktime(time_start);
        unsetenv("TZ");
        
        for (num_data = 0; num_data < cfg->num_data_rec;)
        {
            if (num_data >= 4096) return data_head;

            /* send (random?) keep-alive packet every 1024 bytes */
            /* the logger sends another response header before further data */
            if (num_data % 1024 == 0)
            {
                if (0 < num_data) {
                    ret = dl120_send_cmd(p, DL120_KEEP);
                    if (kIOReturnSuccess != ret)
                    {
                        printf("read_data:send_cmd keep alive failed with error %i\n", ret);
                        //break ?
                        return NULL;
                    }
                }
                else {
                    ret = usb_read(p, buf, 3);
                    if (kIOReturnSuccess != ret) {
                        printf("read_data:keep alive return failed with error %i\n", ret);
                        //break ?
                        return NULL;
                    }
                }
            }
            
            ret = usb_read(p, buf, BUFSIZE);
            if (kIOReturnSuccess == ret) {
                /* parse data: 4 bytes per data point (64/4=16) */
                for (i = 0; i < (BUFSIZE/4); i++)
                {
                    data_temp = malloc(sizeof(s_data));
                    memcpy((char *)data_temp, (char *)buf+i*4, 4);
                    data_temp->time = time_start_stamp + num_data * cfg->interval;
                    data_temp->next = NULL;
                    
                    if (num_data == 0)
                        data_head = data_temp;
                    else
                        data_tail->next = data_temp;
                    data_tail = data_temp;
                    
                    num_data++;
                    if (num_data == cfg->num_data_rec)
                        break;
                }
            }
            else {
                printf("read_data:reading data failed with error %i\n", ret);
                //break ?
                return NULL;
            }
            printf("read_data:num_data = %i\n", num_data);
        }
        printf("num_data = %i\n", num_data);
    }
    else
	{
		printf("read_data:send_cmd failed with error %i\n", ret);
		return NULL;
	}
    
#ifdef DEBUG
    printf("Leaving read_data\n");
#endif
	
	return data_head;
}


void print_data(s_data *data_first) {
#ifdef DEBUG
    printf("Entering print_data\n");
#endif

	s_data *data_temp = NULL;
    
    for (data_temp = data_first; NULL != data_temp; data_temp = data_temp->next) {
        printf("%i %.1f %.1f\n", (int)data_temp->time, data_temp->temp/10.0, data_temp->rh/10.0);
    }
    
#ifdef DEBUG
    printf("Leaving print_data\n");
#endif

}


void store_data(s_config *cfg, s_data *data_first) {
#ifdef DEBUG
    printf("Entering store_data\n");
#endif

	s_data *data_temp;
	char dumpfile_path[1024];
	FILE *dumpfile = NULL;
	
	data_temp = data_first;
	if (data_temp == NULL)
		return;
	
	sprintf(dumpfile_path, "%s.dat", cfg->name),
	dumpfile = fopen(dumpfile_path, "a");
	if (dumpfile == NULL)
	{
		printf("store_data:failed to fopen(\"%s\", \"a+\")", dumpfile_path);
		return;
	}
	printf("writing log data to %s\n", dumpfile_path);
	
	fprintf(dumpfile, "# [%04i-%02i-%02i %02i:%02i:%02i] %i points @ %i sec\n",
            cfg->time_year,
            cfg->time_mon,
            cfg->time_mday,
            cfg->time_hour,
            cfg->time_min,
            cfg->time_sec,
            cfg->num_data_rec,
            cfg->interval
            );
    for (data_temp = data_first; NULL != data_temp; data_temp = data_temp->next) {
		fprintf(dumpfile, "%i %.1f %.1f\n", (int)data_temp->time, data_temp->temp/10.0, data_temp->rh/10.0);
	}
    
	fclose(dumpfile);
    
#ifdef DEBUG
    printf("Leaving store_data\n");
#endif

}


void print_config(s_config *cfg, char *line_prefix) {
#ifdef DEBUG
    printf("Entering print_config\n");
#endif

    if (NULL == cfg) {
        printf("print_config:cant print a NULL config");
        return;
    }
    
    if (NULL == line_prefix) {
        printf("print_config:line_prefix is NULL");
    }
    
	//printf("%sconfig_begin =       0x%02x\n", line_prefix, cfg->config_begin);
	printf("%sname =               %s\n",   line_prefix, cfg->name);
	printf("%snum_data_conf =      %i\n",   line_prefix, cfg->num_data_conf);
	printf("%snum_data_rec =       %i\n",   line_prefix, cfg->num_data_rec);
	printf("%sinterval =           %i\n",   line_prefix, cfg->interval);
	printf("%stime_year =          %i\n",   line_prefix, cfg->time_year);
	printf("%stime_mon =           %i\n",   line_prefix, cfg->time_mon);
	printf("%stime_mday =          %i\n",   line_prefix, cfg->time_mday);
	printf("%stime_hour =          %i\n",   line_prefix, cfg->time_hour);
	printf("%stime_min =           %i\n",   line_prefix, cfg->time_min);
	printf("%stime_sec =           %i\n",   line_prefix, cfg->time_sec);
	printf("%stemp_scale =         %i\n",   line_prefix, cfg->temp_scale);
	printf("%sled_conf =           0x%02x (freq=%i, alarm=%i)\n",
           line_prefix, cfg->led_conf, (cfg->led_conf & 0x1F), (cfg->led_conf & 0x80 >> 7));
	printf("%sstart =              0x%02x", line_prefix, cfg->start);
	if (cfg->start == MANUAL_START)
		printf(" (manual)");
	if (cfg->start == AUTO_START)
		printf(" (automatic)");
	printf("\n");
	printf("%sthresh_temp_low =    %i\n",   line_prefix, bin2num(cfg->thresh_temp_low));
	printf("%sthresh_temp_high =   %i\n",   line_prefix, bin2num(cfg->thresh_temp_high));
	printf("%sthresh_rh_low =      %i\n",   line_prefix, bin2num(cfg->thresh_rh_low));
	printf("%sthresh_rh_high =     %i\n",   line_prefix, bin2num(cfg->thresh_rh_high));
	//printf("%sconfig_end =         0x%02x\n", line_prefix, cfg->config_end);
    
#ifdef DEBUG
    printf("Leaving print_config\n");
#endif

}


s_config *build_config(
                       char *name,                      /* logger name */
                       int num_data,                    /* number of data points to collect */
                       int interval,                    /* log frequency in seconds */
                       int thresh_temp_low,
                       int thresh_temp_high,
                       int thresh_rh_low,
                       int thresh_rh_high,
                       int temp_scale,                  /* bool: temp scale */
                       int led_alarm,                   /* bool: led alarm */
                       int led_freq,                    /* led frequency in seconds */
                       int start                        /* start loggin: 1 = manually, 2 = automatically */
                       ) {
#ifdef DEBUG
    printf("Entering build_config\n");
#endif

	s_config *cfg = NULL;
	cfg = malloc(sizeof(s_config));
	if (cfg == NULL)
	{
		printf("build_config: failed to malloc s_config\n");
		return NULL;
	}
	memset(cfg, 0, sizeof(s_config));
	
	cfg->config_begin = 0xce;
	cfg->config_end = 0xce;
	
	cfg->start = start;
	
	cfg->num_data_conf = num_data;
	cfg->interval = interval;
	
	time_t now_stamp = 0;
	now_stamp = time(NULL);
	struct tm *now = NULL;
	now = localtime(&now_stamp);
	if (now == NULL)
	{
		printf("build_config: failed to get localtime\n");
		return NULL;
	}
	cfg->time_year = now->tm_year + 1900;
	cfg->time_mon  = now->tm_mon + 1;
	cfg->time_mday = now->tm_mday;
	cfg->time_hour = now->tm_hour;
	cfg->time_min  = now->tm_min;
	cfg->time_sec  = now->tm_sec;
	
	cfg->thresh_temp_low  = num2bin(thresh_temp_low);
	cfg->thresh_temp_high = num2bin(thresh_temp_high);
	
	cfg->temp_scale = temp_scale;
	
	cfg->led_conf = (led_alarm & 1 << 7) | (led_freq & 0x1F);
	
	strncpy(cfg->name, name, 16);
	
	cfg->thresh_rh_low  = num2bin(thresh_rh_low);
	cfg->thresh_rh_high = num2bin(thresh_rh_high);
	
#ifdef DEBUG
    printf("Leaving build_config\n");
#endif

	return cfg;
}


int is_conf_valid(s_config *cfg) {
#ifdef DEBUG
    printf("Entering is_conf_valid\n");
#endif

    int ret = E_CONF_OK;
	
	if (0 == strlen(cfg->name))
	{
		printf("check_config: empty name\n");
        ret |= E_CONF_NAME;
	}
	
	if (cfg->num_data_conf <= 0 || 16000 < cfg->num_data_conf)
	{
		printf("check_config: invalid num_data_conf, valid range: [1:16000]\n");
		ret |= E_CONF_DATARANGE;
	}
	
	if (cfg->interval <= 0 || 86400 < cfg->interval)
	{
		printf("check_config: invalid interval, valid range: [1:86400]\n");
		ret |= E_CONF_IVALRANGE;
	}
	
	if (cfg->start != MANUAL_START && cfg->start != AUTO_START)
	{
		printf("check_config: invalid start flag\n");
		ret |= E_CONF_STARTFLAG;
	}
	
	if (TEMP_F == cfg->temp_scale)
	{
		if (bin2num(cfg->thresh_temp_low) < TEMP_MIN || TEMP_MAX_F < bin2num(cfg->thresh_temp_low))
		{
			printf("check_config: invalid Fahrenheit thresh_temp_low\n");
            ret |= E_CONF_TEMPRANGE;
		}
		if (bin2num(cfg->thresh_temp_high) < TEMP_MIN || TEMP_MAX_F < bin2num(cfg->thresh_temp_high))
		{
			printf("check_config: invalid Fahrenheit thresh_temp_high\n");
            ret |= E_CONF_TEMPRANGE;
		}
	} else {
		if (bin2num(cfg->thresh_temp_low) < TEMP_MIN || TEMP_MAX_C < bin2num(cfg->thresh_temp_low))
		{
			printf("check_config: invalid Celcius thresh_temp_low\n");
            ret |= E_CONF_TEMPRANGE;
		}
		if (bin2num(cfg->thresh_temp_high) < TEMP_MIN || TEMP_MAX_C < bin2num(cfg->thresh_temp_high))
		{
			printf("check_config: invalid Celcius thresh_temp_high\n");
            ret |= E_CONF_TEMPRANGE;
		}
	}
	
	if (bin2num(cfg->thresh_temp_high) < bin2num(cfg->thresh_temp_low))
	{
		printf("check_config: invalid thresh_temp_low/high\n");
        ret |= E_CONF_TEMPRANGE;
	}
	
	if (bin2num(cfg->thresh_rh_low) < RH_MIN || RH_MAX < bin2num(cfg->thresh_rh_low))
	{
		printf("check_config: invalid thresh_rh_low\n");
        ret |= E_CONF_RHRANGE;
	}
	
	if (bin2num(cfg->thresh_rh_high) < RH_MIN || RH_MAX < bin2num(cfg->thresh_rh_high))
	{
		printf("check_config: invalid thresh_rh_high\n");
        ret |= E_CONF_RHRANGE;
	}
	
	if (bin2num(cfg->thresh_rh_high) < bin2num(cfg->thresh_rh_low))
	{
		printf("check_config: invalid thresh_rh_low/high\n");
        ret |= E_CONF_RHRANGE;
	}
	
	int led_freq = cfg->led_conf & 0x1F;
	if (led_freq != 10 && led_freq != 20 && led_freq != 30)
	{
		printf("check_config: invalid led_conf (freq)\n");
        ret |= E_CONF_LEDFREQ;
	}
	
#ifdef DEBUG
    printf("Leaving is_conf_valid\n");
#endif

	return ret;
}
