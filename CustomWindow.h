#import <Cocoa/Cocoa.h>

@interface CustomWindow : NSWindow {
    // This point is used in dragging to mark the initial click location
    NSPoint initialLocation;
	NSString *notificationName;
}

@property (assign) NSPoint initialLocation;

- (void)setNotificationName:(NSString *)aName;

@end
