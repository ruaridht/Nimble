//
//  ring.h
//  opiemac
//
//  Created by Ruaridh Thomson on 27/01/2011.
//  Copyright 2011 Life Up North. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OpieHeader.h"
#import "RingTheme.h"

@interface Ring : NSObject {
	NSWindow *ringWindow;
	NSView *ringView;
	
	NSArray *ringApps;
	
	NSString *ringName;
	NSColor *ringColour;
	NSNumber *ringSize;
	CGFloat iconSize;
	CGFloat iconRadius;
	int ringType;
	NSInteger ringPosition;
	
	NSImageView *theArrow;
	NSImageView *theRing;
	CALayer *arrowLayer;
	CALayer *ringLayer;
	
	float previousValue;
	
	BOOL ringAllowsActions;
	BOOL isSticky;
	BOOL ringIsActive;
	BOOL tintRing;
	
	SRRecorderControl *ringHotkeyControl;
	KeyCombo ringGlobalHotKey;
    
    NSImageView *blurView;
    NSImage *bgBlur;
}

@property (readwrite, retain) NSString *ringName;
@property (readwrite, retain) NSColor *ringColour;
@property (readwrite, retain) NSNumber *ringSize;
@property (readwrite) CGFloat iconRadius;
@property (readwrite) CGFloat iconSize;
@property (readwrite) BOOL isSticky;
@property (readwrite) BOOL tintRing;
@property (readwrite) NSInteger ringPosition;
//@property (readwrite, retain) SRRecorderControl *ringHotkeyControl;

- (void)addAppsToRing;
- (NSPoint)viewCenter:(NSView *)theView;
- (void)buildRing;
- (void)removeAllAppsFromRing;
- (NSImage *)currentRingImage;

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

- (void)setTheme:(RingTheme *)theTheme;
- (RingTheme *)currentTheme;
- (void)setRingDrawingPosition:(NSInteger)position;
- (KeyCombo)currentKeyCombo;
- (void)setGlobalHotkey:(KeyCombo)theCombo;

@end
