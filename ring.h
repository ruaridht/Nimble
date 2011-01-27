//
//  ring.h
//  opiemac
//
//  Created by Ruaridh Thomson on 27/01/2011.
//  Copyright 2011 Life Up North. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OpieHeader.h"

@interface Ring : NSObject {
	NSWindow *ringWindow;
	NSView *ringView;
	
	NSArray *ringApps;
	
	NSString *ringName;
	
	NSImageView *theArrow;
	NSImageView *theRing;
	CALayer *arrowLayer;
	CALayer *ringLayer;
	
	float previousValue;
	
	BOOL ringAllowsActions;
	
	SRRecorderControl *ringHotkeyControl;
	KeyCombo ringGlobalHotKey;
}


- (void)addAppsToRing;
- (NSPoint)viewCenter:(NSView *)theView;
- (void)buildRing;
- (void)removeAllAppsFromRing;

- (void)initiateAnimations;
- (void)stopAllAnimations;
- (void)animateRingOut;
- (void)animateRingIn;
- (void)mouseMovedForRing;
- (void)mouseDownForRing;
- (void)keyUpForRing;
- (CAAnimation *)rotateToMouseAnimation;
- (CAAnimation *)rotateInfiniteAnimation;

- (void)tintRingWithColour:(NSColor *)colour;

- (CGFloat)mouseAngleAboutRing;
- (void)getAndPresentLaunchedApps;
- (CFArrayRef)copyLaunchedApplicationsInFrontToBackOrder;

@end
