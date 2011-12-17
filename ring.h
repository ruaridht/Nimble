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
	int ringSize;
	CGFloat iconSize;
	CGFloat iconRadius;
	int ringType;
	NSInteger ringPosition;
    NSString *ringTheme;
	
	NSImageView *theArrow;
	NSImageView *theRing;
	CALayer *arrowLayer;
	CALayer *ringLayer;
	
	float previousValue;
	
	BOOL ringAllowsActions;
	BOOL isSticky;
    BOOL isBGBlur;
	BOOL ringIsActive;
	
	SRRecorderControl *ringHotkeyControl;
	KeyCombo ringGlobalHotKey;
    
    NSImageView *blurView;
    NSImage *bgBlur;
}

@property (readwrite, retain) NSString *ringName;
@property (readwrite, retain) NSColor *ringColour;
@property (readwrite) int ringSize;
@property (readwrite) CGFloat iconRadius;
@property (readwrite) CGFloat iconSize;
@property (readwrite) BOOL isSticky;
@property (readwrite) BOOL isBGBlur;
@property (readwrite) NSInteger ringPosition;
@property (readwrite, retain) NSString *ringTheme;

- (id)initWithName:(NSString *)name;
- (id)initFromDictionary:(NSDictionary *)dict;

- (void)setTheme:(RingTheme *)theTheme;
- (RingTheme *)currentTheme;
- (void)setGlobalHotkey:(KeyCombo)theCombo;
- (KeyCombo)currentKeyCombo;
- (NSImage *)currentRingImage;
- (NSDictionary *)dictionaryForRing;

- (void)addAppsToRing;
- (void)removeAllAppsFromRing;
- (NSPoint)viewCenter:(NSView *)theView;
- (void)blurAndSetBackground;
- (void)buildRing;
- (void)toggleBlurredBackground;

- (void)setRingCenterPosition:(NSPoint)center;
- (void)setRingDrawingPosition:(NSInteger)position;

- (void)initiateAnimations;
- (void)stopAllAnimations;
- (void)animateRingOut;
- (void)animateRingIn;

- (void)adjustHighlightedApp;
- (void)mouseMovedForRing;
- (void)mouseDownForRing;
- (void)keyUpForRing;

- (CAAnimation *)rotateToMouseAnimation;
- (CAAnimation *)rotateInfiniteAnimation;
- (CAAnimation *)sizeDecreaseAnimation;

- (CGFloat)mouseAngleAboutRing;
- (void)getAndPresentLaunchedApps;

// Saving and loading the ring

@end
