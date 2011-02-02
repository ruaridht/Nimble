//
//  AppController.h
//  opiemac
//
//  Created by Ruaridh Thomson on 24/01/2011.
//  Copyright 2011 Life Up North. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OpieHeader.h"

@interface AppController : NSObject <NSApplicationDelegate> {
	IBOutlet NSWindow *window;
	
	NSWindow *ringWindow;
	NSView *ringView;
	
	NSArray *openApps;
	
	NSImageView *theArrow;
	NSImageView *theRing;
	CALayer *arrowLayer;
	CALayer *ringLayer;
	
	float previousValue;
	
	IBOutlet NSImageView *testView;
	
	BOOL ringAllowsActions;
	BOOL ringIsSticky;
	BOOL ringIsActive;
	
	Ring *launchedAppsRing;
	
	IBOutlet NSMenu *statusMenu;
	NSStatusItem *statusItem;
}

- (IBAction)testButton:(id)sender;
- (IBAction)test2Button:(id)sender;

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
