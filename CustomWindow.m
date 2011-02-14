/*
     File: CustomWindow.m
 Abstract: Subclass of NSWindow with a custom shape and transparency. Since the window will not have a title bar, -mouseDown: and -mouseDragged: are overriden so the window can be moved by dragging its content area.
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
 */

#import "CustomWindow.h"
#import <AppKit/AppKit.h>
#import <math.h>

@implementation CustomWindow

@synthesize initialLocation;

/*
 In Interface Builder, the class for the window is set to this subclass. Overriding the initializer provides a mechanism for controlling how objects of this class are created.
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
 Custom windows that use the NSBorderlessWindowMask can't become key by default. Override this method so that controls in this window will be enabled.
 */
- (BOOL)canBecomeKeyWindow {
    return YES;
}

/*
 Start tracking a potential drag operation here when the user first clicks the mouse, to establish the initial location.
 */
- (void)mouseDown:(NSEvent *)theEvent {    
    // Get the mouse location in window coordinates.
    //self.initialLocation = [theEvent locationInWindow];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"mouseDownForRing" object:nil];
}

/*
 Once the user starts dragging the mouse, move the window with it. The window has no title bar for the user to drag (so we have to implement dragging ourselves)
 */
- (void)mouseDragged:(NSEvent *)theEvent {
	/*
    NSRect screenVisibleFrame = [[NSScreen mainScreen] visibleFrame];
    NSRect windowFrame = [self frame];
    NSPoint newOrigin = windowFrame.origin;

    // Get the mouse location in window coordinates.
    NSPoint currentLocation = [theEvent locationInWindow];
    // Update the origin with the difference between the new mouse location and the old mouse location.
    newOrigin.x += (currentLocation.x - initialLocation.x);
    newOrigin.y += (currentLocation.y - initialLocation.y);

    // Don't let window get dragged up under the menu bar
    if ((newOrigin.y + windowFrame.size.height) > (screenVisibleFrame.origin.y + screenVisibleFrame.size.height)) {
        newOrigin.y = screenVisibleFrame.origin.y + (screenVisibleFrame.size.height - windowFrame.size.height);
    }
    
    // Move the window to the new location
    [self setFrameOrigin:newOrigin];
	 */
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
	//[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

- (void)setNotificationName:(NSString *)aName
{
	notificationName = aName;
}

- (void)keyUp:(NSEvent *)theEvent
{
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"keyUpForRing" object:nil];
}

- (void)keyDown:(NSEvent *)theEvent
{
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"keyDownForStickyRing" object:nil];
}

@end
