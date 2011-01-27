//
//  ring.h
//  opiemac
//
//  Created by Ruaridh Thomson on 27/01/2011.
//  Copyright 2011 Life Up North. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OpieHeader.h"

@interface ring : NSObject {
	NSWindow *ringWindow;
	NSView *ringView;

	NSArray *ringApps;
	
	NSImageView *theArrow;
	NSImageView *theRing;
	CALayer *arrowLayer;
	CALayer *ringLayer;
	
	float previousValue;
	
	BOOL ringAllowsActions;
	
	SRRecorderControl *ringHotkeyControl;
	KeyCombo ringGlobalHotKey;
}


- (void)presentApps:(NSArray *)theApps;
- (NSPoint)viewCenter:(NSView *)theView;
- (void)buildRing;
- (void)removeAllAppViews;

- (void)initiateAnimations;
- (void)stopAllAnimations;
- (void)animateRingOut;
- (void)animateRingIn;
- (void)mouseMovedForRing:(NSNotification *)aNote;
- (void)mouseDownForRing:(NSNotification *)aNote;
- (void)keyUpForRing:(NSNotification *)aNote;
- (CAAnimation *)rotateToMouseAnimation;
- (CAAnimation *)rotateInfiniteAnimation;

- (void)tintRingWithColour:(NSColor *)colour;

- (CGFloat)mouseAngleAboutRing;
- (void)getAndPresentLaunchedApps;
- (CFArrayRef)copyLaunchedApplicationsInFrontToBackOrder;

 
@end
