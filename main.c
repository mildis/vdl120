#include "vdl120.h"

int main (int argc, char **argv)
{
    
	if (argc < 2)
	{
		printf("usage:\n"),
		printf("  %s -c LOGNAME NUM_DATA INTERVAL  -->  configure logger\n", argv[0]);
		printf("  %s -p  -->  print config\n", argv[0]);
		printf("  %s -d  -->  print data\n", argv[0]);
		printf("  %s -s  -->  store data in LOGNAME.dat\n", argv[0]);
		return 1;
	}
	
    s_usb_dl120 *p = NULL;
	
    //	struct tm *log_start = NULL;
	
	char *buf = NULL;
	buf = malloc(sizeof(char)*BUFSIZE);
	
    /*
    int i,j;
    for (i=0; i<=100; i++) {
        printf("%4d ", i);
        
        for (j=0; j<16; j++) {
            //printf("%1d ", (0x8000>>j));
            printf("%1d", (i & (0x8000>>j)) ? 1 : 0);
            if (j % 4 == 3) printf(" ");
        }
        
        printf("\t%04x\t%04x\n", i, num2bin(i));
    }
    */
    
	// init
	p = usb_init();
    if (NULL == p) {
        printf("Huho, something went wrong. Aborting\n");
        exit(1);
    }
	
	/* configure logger */	
	if (0 == strcmp(argv[1], "-c"))
	{
		s_config *cfg = NULL;
		int num_data = atoi(argv[3]);
		int interval = atoi(argv[4]);
		
		/* at this point, the original software would do read_config(), */
		/* which seems not to be necessary for correct operation. */
		cfg = read_config(p);
		cfg = build_config(
                           argv[2],             // name
                           num_data, interval,
                           0, 40,               // temp range
                           25, 80,              // rh range
                           TEMP_C,              // Celcius or Fahrenheit
                           0, 10,               // led alarm, frequency
                           AUTO_START           // MANUAL_START || AUTO_START
                           );
		print_config(cfg, "config->");
		if (E_CONF_OK != is_conf_valid(cfg))
		{
			printf("config invalid!\n");
            exit(2);
		}
		write_config(p, cfg);
		
		free(cfg);
        cfg = NULL;
	}
	
	/* print config */
	
	if (0 == strcmp(argv[1], "-p"))
	{
		print_config(read_config(p), "config->");
	}
	
	/* print data */
	
	if (0 == strcmp(argv[1], "-d"))
	{
		print_data(read_data(p, read_config(p)));
	}
	
	/* store log data in file */
	if (0 == strcmp(argv[1], "-s"))
	{
		s_config *cfg = NULL;
		cfg = read_config(p);
		print_config(cfg, "config->");
		store_data(cfg, read_data(p, cfg));
		free(cfg);
        cfg = NULL;
	}
	
    // Should not get there as if VDL cannot be found
    // and initialized, we exit w/ code 1
	if (NULL != p) usb_close(p);
	return 0;
}
