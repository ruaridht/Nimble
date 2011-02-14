//
//  AppController.m
//  opiemac
//
//  Created by Ruaridh Thomson on 24/01/2011.
//  Copyright 2011 Life Up North. All rights reserved.
//

#import "AppController.h"
#import "OpieHeader.h"

@implementation AppController

@synthesize _currentRing = currentRing;

- (id)init
{
	if (![super init])
		return nil;
	
	
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mouseMovedForRing:) name:@"mouseMovedForRing" object:nil];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mouseDownForRing:) name:@"mouseDownForRing" object:nil];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyUpForRing:) name:@"ringGlobalHotkeyUpTriggered" object:nil];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animateRingIn) name:@"ringGlobalHotkeyDownTriggered" object:nil];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:NSApplicationWillResignActiveNotification object:nil];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidResignActive:) name:NSApplicationDidResignActiveNotification object:nil];
	
	[NSApp setDelegate:self];
	[[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
	
	launchedAppsRing = [[Ring alloc] initWithName:@"launchedAppsRing"];
	otherLARing = [[Ring alloc] initWithName:@"otherLARing"];
	currentRing = launchedAppsRing;
	
	return self;
}

- (void)awakeFromNib
{
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setTitle:@"N"];
	[statusItem setHighlightMode:YES];
	[statusItem setMenu:statusMenu];
	
	//Preferences
	
	SDGlobalShortcutsController *shortcutsController = [SDGlobalShortcutsController sharedShortcutsController];
	[shortcutsController addShortcutFromDefaultsKey:@"ringGlobalHotkey"
										withControl:ringHotkeyControl
											 target:self
									selectorForDown:@selector(animateRingIn)
											  andUp:@selector(keyUpForRing:)];
	
	[prefToolbar setSelectedItemIdentifier:[generalButton itemIdentifier]];
	[contentView addSubview:generalView];
	currentView = generalView;
}

- (void)dealloc
{
	[super dealloc];
}

#pragma mark -
#pragma mark Delegates

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	
}

- (void)applicationWillHide:(NSNotification *)notification
{
	
}

- (void)applicationWillUnhide:(NSNotification *)notification
{
	
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
	
}

- (void)applicationDidResignActive:(NSNotification *)notification
{
	
}

- (void)applicationWillBecomeActive:(NSNotification *)notification
{
	
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	
}

#pragma mark -
#pragma mark IBActions

- (IBAction)testButton:(id)sender
{
	
	[self willChangeValueForKey:@"currentRing"];
	if (currentRing == launchedAppsRing) {
		currentRing = otherLARing;
	} else if (currentRing == otherLARing) {
		currentRing = launchedAppsRing;
	}
	[self didChangeValueForKey:@"currentRing"];
	
	//NSLog(@"Combo: %@", launchedAppsRing.ringHotkeyControl);
}

- (IBAction)test2Button:(id)sender
{
	[launchedAppsRing tintRingWithColour:[sender color]];
}

#pragma mark -
#pragma mark Drawing Methods

- (void)presentApps:(NSArray *)theApps
{
	[self removeAllAppViews];
	
	int count = [openApps count];
	CGFloat angle = 360.0/count;
	CGFloat increment = 0.0;
	CGFloat radius = 300;
	CGFloat iconSize = 128;
	
	radius -= (iconSize/2);
	
	NSPoint windowCenter = [self viewCenter:ringView];
	NSRect ivFrame = NSMakeRect(0, 0, iconSize, iconSize);
	
	for (int i = 0; i < count; i++) {
		NSPoint position = NSMakePoint(radius*sin(DegreesToRadians(increment)), radius*cos(DegreesToRadians(increment)));
		
		ivFrame.origin.x = position.x + windowCenter.x - (iconSize/2);
		ivFrame.origin.y = position.y + windowCenter.y - (iconSize/2);
		
		NSImageView *iv = [[NSImageView alloc] initWithFrame:ivFrame];
		[iv setImageScaling:NSScaleToFit];
		NSRunningApplication *app = [openApps objectAtIndex:i];
		[iv setImage:[app icon]];
		
		[ringView addSubview:iv];
		
		increment += angle;
	}
}

- (NSPoint)viewCenter:(NSView *)theView
{
	NSRect windowFrame = [theView frame];
	return NSMakePoint(windowFrame.origin.x + (windowFrame.size.width/2.0), windowFrame.origin.y + (windowFrame.size.height/2.0));
}

- (NSImage *)currentRingImage
{
	CGImageRef windowImage = CGWindowListCreateImage(CGRectNull, 
													 kCGWindowListOptionIncludingWindow, 
													 (CGWindowID)[ringWindow windowNumber], 
													 kCGWindowImageDefault);
	
	NSRect rect = NSMakeRect(0, 0, CGImageGetWidth(windowImage), CGImageGetHeight(windowImage));
	NSImage* image = [[NSImage alloc] initWithSize:rect.size];
    [image lockFocus];
    CGContextDrawImage([[NSGraphicsContext currentContext]
						graphicsPort], *(CGRect*)&rect, windowImage);
    [image unlockFocus];
	
	return image;
}

- (void)removeAllAppViews
{
	NSArray *allViews = [ringView subviews];
	NSMutableArray *allViewsMut = [NSMutableArray arrayWithArray:allViews];
	for (NSView *aView in allViewsMut) {
		if ((aView != theRing) && (aView != theArrow)){
			[aView removeFromSuperview];
		}
	}
}

#pragma mark Animations

- (void)initiateAnimations
{
	[theRing setWantsLayer:YES];
	ringLayer = [theRing layer];
	[ringLayer addAnimation:[self rotateInfiniteAnimation] forKey:@"rotate"];
	[[theRing layer] setNeedsDisplay];
	
	[theArrow setWantsLayer:YES];
	arrowLayer = [theArrow layer];
	[arrowLayer addAnimation:[self rotateToMouseAnimation] forKey:@"rotate"];
	[[theArrow layer] setNeedsDisplay];
}

- (void)stopAllAnimations
{
	[ringLayer removeAllAnimations];
	[arrowLayer removeAllAnimations];
}

- (void)animateRingIn
{
	[launchedAppsRing animateRingIn];
	//ringIsActive = YES;
	
	/*
	[self getAndPresentLaunchedApps];
	[self initiateAnimations];
	
	[NSApp activateIgnoringOtherApps:YES];
	[ringWindow makeKeyAndOrderFront:self];
	[[ringWindow animator] setAlphaValue:1.0];
	*/
	/*
	NSRect windowFrame = [ringWindow frame];
	NSRect frame = [ringView frame];
	frame.size.width *= 2;
	frame.size.height *= 2;
	frame.origin.x = (windowFrame.size.width/2) - (frame.size.width/2);
	frame.origin.y = (windowFrame.size.height/2) - (frame.size.height/2);
	
	[[[ringWindow contentView] animator] setFrame:frame];
	[[[ringWindow contentView] animator] setAlphaValue:1.0];
	*/
	
	//NSLog(@"Animate In");
}

- (void)animateRingOut
{
	/*
	CustomView *imageView = [[CustomView alloc] init];
	imageView.circleImage = [self currentRingImage];
	[ringWindow setContentView:imageView];
	*/
	[[ringWindow animator] setAlphaValue:0.0];
	NSLog(@"Animate Out");
}

- (void)mouseMovedForRing:(NSNotification *)aNote
{
	//[arrowLayer addAnimation:[self rotateToMouseAnimation] forKey:@"rotate"];
	//[arrowLayer animationForKey:@"rotate"];
	//[[theArrow layer] setNeedsDisplay];
	//NSLog(@"Mouse Moved");
	[launchedAppsRing mouseMovedForRing];
}

- (void)mouseDownForRing:(NSNotification *)aNote
{
	[launchedAppsRing keyUpForRing];
	//ringIsActive = NO;
}

- (void)keyUpForRing:(NSNotification *)aNote
{
	[launchedAppsRing keyUpForRing];
	//ringIsActive = NO;
	//[self animateRingOut];
	//[self mouseDownForRing:nil];
	//NSLog(@"KeyUp");
}

#pragma mark -
#pragma mark Preferences

- (IBAction)switchPreferenceView:(id)sender
{
	[prefToolbar setSelectedItemIdentifier:[sender itemIdentifier]];
	
	if ([sender tag] == 1) {
		//[self loadView:generalView];
		[self loadViewAlt:generalView];
	} else if ([sender tag] == 2) {
		//[self loadView:aboutView];
		[self loadViewAlt:aboutView];
	} else if ([sender tag] == 3) {
		//[self loadView:ringsView];
		[self loadViewAlt:ringsView];
	}
}

- (void)loadView:(NSView *)theView
{
	[[[prefWindow contentView] animator] setFrame:[theView frame]];
	[contentView replaceSubview:currentView with:theView];
	currentView = theView;
}

- (void)loadViewAlt:(NSView *)newView
{
	NSView *tempView = [[NSView alloc] initWithFrame: [[prefWindow contentView] frame]];
    [prefWindow setContentView: tempView];
    [tempView release];
	
	NSRect newFrame = [prefWindow frame];
    newFrame.size.height =	[newView frame].size.height + ([prefWindow frame].size.height - [[prefWindow contentView] frame].size.height); // Compensates for toolbar
    newFrame.size.width =	[newView frame].size.width;
    newFrame.origin.y +=	([[prefWindow contentView] frame].size.height - [newView frame].size.height); // Origin moves by difference in two views
    newFrame.origin.x +=	([[prefWindow contentView] frame].size.width - newFrame.size.width)/2; // Origin moves by difference in two views, halved to keep center alignment
    
	[prefWindow setFrame: newFrame display: YES animate: YES];
    [prefWindow setContentView: newView];
}

- (IBAction)setRingCenterPosition:(id)sender
{
	[currentRing setRingDrawingPosition:[sender selectedSegment]];
}

@end
