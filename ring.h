//
//  ring.h
//  Nimble
//
//  Created by Ruaridh Thomson on 27/01/2011.
//  Copyright 2011 Ruaridh Thomson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OpieHeader.h"
#import "RingTheme.h"

@interface Ring : NSObject {
	NSWindow *ringWindow;
	NSView *ringView;
	
	NSArray *ringApps;
	
	NSString *ringName;
	int ringSize;
	CGFloat iconSize;
	CGFloat iconRadius;
	NSInteger ringPosition;
    NSString *ringTheme;
	
    NSImageView *blurView;
    NSImage *bgBlur;
    
	NSImageView *theArrow;
	NSImageView *theRing;
	CALayer *arrowLayer;
	CALayer *ringLayer;
	
	float previousValue;
    
    NSImageView *highlightView;
    int lastHighlighted;
	
	BOOL isSticky;
    BOOL isBGBlur;
	BOOL ringIsActive;
    BOOL openPrefsOnRing;
	
	SRRecorderControl *ringHotkeyControl;
	KeyCombo ringGlobalHotKey;
}

@property (readwrite, retain) NSString *ringName;
@property (readwrite) int ringSize;
@property (readwrite) CGFloat iconRadius;
@property (readwrite) CGFloat iconSize;
@property (readwrite) BOOL isSticky;
@property (readwrite) BOOL isBGBlur;
@property (readwrite) NSInteger ringPosition;
@property (readwrite, retain) NSString *ringTheme;

// Creating rings
- (id)initWithName:(NSString *)name;
- (id)initFromDictionary:(NSDictionary *)dict;

// Getting and setting ring info
- (RingTheme *)currentTheme;
- (void)setTheme:(RingTheme *)theTheme;
- (KeyCombo)currentKeyCombo;
- (void)setGlobalHotkey:(KeyCombo)theCombo;
- (NSImage *)currentRingImage;
- (NSDictionary *)dictionaryForRing;
- (void)setOpenPrefs:(BOOL)open;

// Building the visual ring
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

@end
