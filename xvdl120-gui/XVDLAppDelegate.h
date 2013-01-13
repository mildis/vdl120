#import <Cocoa/Cocoa.h>

@interface XVDLAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *config;

- (IBAction)showConfigWindow:(id)sender;
@end
