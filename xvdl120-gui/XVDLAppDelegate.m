#import "XVDLAppDelegate.h"

@implementation XVDLAppDelegate

@synthesize window;
@synthesize config;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (IBAction)showConfigWindow:(id)sender {   
    [config makeKeyAndOrderFront:nil];
}


@end
