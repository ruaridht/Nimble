#import "CustomWindow.h"
#import <AppKit/AppKit.h>
#import <math.h>

@implementation CustomWindow

@synthesize initialLocation;

/*
 * In Interface Builder, the class for the window is set to this subclass. Overriding the initializer provides a mechanism for controlling how objects of this class are created.
 */
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    // Using NSBorderlessWindowMask results in a window without a title bar.
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    if (self != nil) {
        // Start with no transparency for all drawing into the window
        [self setAlphaValue:1.0];
        // Turn off opacity so that the parts of the window that are not drawn into are transparent.
        [self setOpaque:NO];
		
		[self setAcceptsMouseMovedEvents:YES];
    }
    return self;
}

/*
 * Custom windows that use the NSBorderlessWindowMask can't become key by default. Override this method so that controls in this window will be enabled.
 */
- (BOOL)canBecomeKeyWindow {
    return YES;
}

/*
 * Let the ring know that it has received a mouseDown.
 */
- (void)mouseDown:(NSEvent *)theEvent {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"mouseDownForRing" object:nil];
}

/*
 * Woah! I don't want rings to be dragged!
 */
- (void)mouseDragged:(NSEvent *)theEvent {
	
}

// Note: this only happens when the window is the frontmost! :)
- (void)mouseMoved:(NSEvent *)theEvent
{	
	/*
	 *	Here we are telling the notification center that the mouse is moving.
	 *	If the observer is in a ring object, then every ring will be triggered
	 *	when the mouse moves for one ring. Maybe send this to the controller who
	 *	can in turn send the event to the active ring?  Though the controller
	 *	now needs an 'activeRing' variable/pointer/reference.
	 */
	[[NSNotificationCenter defaultCenter] postNotificationName:@"mouseMovedForRing" object:nil];
}

- (void)setNotificationName:(NSString *)aName
{
	notificationName = aName;
}

- (void)keyUp:(NSEvent *)theEvent
{
	
}

- (void)keyDown:(NSEvent *)theEvent
{
    if ([theEvent keyCode] == 53){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"escapeWindow" object:nil];
    }
}

@end
