//
//  ring.m
//  Nimble
//
//  Created by Ruaridh Thomson on 27/01/2011.
//  Copyright 2011 Ruaridh Thomson. All rights reserved.
//

#import "Ring.h"
#import <QuartzCore/QuartzCore.h>

#define ROTATION_SPEED 10.0
#define CROP_VALUE 50.0

@implementation Ring

@synthesize ringName, ringSize, iconSize, iconRadius, isSticky, isBGBlur, ringPosition, ringTheme;

// Standard functions
CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
}

CGFloat RadiansToDegrees(CGFloat radians)
{
    return radians * (180 / M_PI);
}

NSNumber* DegreesToNumber(CGFloat degrees)
{
    return [NSNumber numberWithFloat:
            DegreesToRadians(degrees)];
}

- (id)initWithName:(NSString *)name
{
	if (![super init])
		return nil;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mouseMovedForRing) name:@"mouseMovedForRing" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mouseDownForRing) name:@"mouseDownForRing" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mouseMovedForRing) name:[NSString stringWithFormat:@"%@%@",name,@"movedMouse"] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animateRingOut) name:@"escapeWindow" object:nil];
	
	isSticky = NO;
    isBGBlur = NO;
	ringIsActive = NO;
	ringSize = 300;
	iconSize = 128;
	iconRadius = 300;
    ringTheme = @"default";
    openPrefsOnRing = NO;
    
    lastHighlighted = -1; // So something is highlighted the first time.
    NSRect hFrame = NSMakeRect(0.0, 0.0, 1024.0, 1024.0);
    highlightView = [[NSImageView alloc] initWithFrame:hFrame];
	[highlightView setAutoresizingMask:NSScaleToFit];
	[highlightView setImageFrameStyle:NSImageFrameNone];
    [highlightView setImage:[NSImage imageNamed:@"apphighlight"]];
    [highlightView setHidden:YES];
	
	ringPosition = 0;
	
	ringName = name;
	[self buildRing];
	
	ringHotkeyControl = [[[SRRecorderControl alloc] init] retain];
	
	SDGlobalShortcutsController *shortcutsController = [SDGlobalShortcutsController sharedShortcutsController];
	[shortcutsController addShortcutFromDefaultsKey:[NSString stringWithFormat:@"%@%@",ringName,@"GlobalHotkey"]
										withControl:ringHotkeyControl
											 target:self
									selectorForDown:@selector(animateRingIn)
											  andUp:@selector(keyUpForRing)];
	
	// If this is the first time a ring with this name has existed
	// then we want to set a default KeyCombo.  Or do we? Maybe not. =/
	/*
	if ([ringHotkeyControl keyCombo] == NULL) {
		KeyCombo combo1 = { (NSShiftKeyMask | NSAlternateKeyMask), (CGKeyCode)49 };
		[ringHotkeyControl setKeyCombo:combo1];
	}
	 */
	
	return self;
}

- (id)initFromDictionary:(NSDictionary *)dict
{
    if (![super init])
		return nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mouseMovedForRing) name:@"mouseMovedForRing" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mouseDownForRing) name:@"mouseDownForRing" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animateRingOut) name:@"escapeWindow" object:nil];
	
	isSticky = [[dict objectForKey:RING_STICKY] boolValue];
    isBGBlur = [[dict objectForKey:RING_BLUR] boolValue];
	ringIsActive = NO;
	ringSize = [[dict objectForKey:RING_SIZE] intValue];
	iconSize = [[dict objectForKey:RING_ICON_SIZE] floatValue];
	iconRadius = [[dict objectForKey:RING_ICON_RAD] floatValue];;
    ringTheme = [dict objectForKey:RING_THEME];
    openPrefsOnRing = NO;
    
    lastHighlighted = -1; // So something is highlighted the first time.
    NSRect hFrame = NSMakeRect(0.0, 0.0, 1024.0, 1024.0);
    highlightView = [[NSImageView alloc] initWithFrame:hFrame];
	[highlightView setAutoresizingMask:NSScaleToFit];
	[highlightView setImageFrameStyle:NSImageFrameNone];
    [highlightView setImage:[NSImage imageNamed:@"apphighlight"]];
    [highlightView setHidden:YES];
	
	ringPosition = [[dict objectForKey:RING_POSITION] integerValue];
	
	ringName = [dict objectForKey:RING_NAME];
	[self buildRing];
	
	ringHotkeyControl = [[[SRRecorderControl alloc] init] retain];
	
	SDGlobalShortcutsController *shortcutsController = [SDGlobalShortcutsController sharedShortcutsController];
	[shortcutsController addShortcutFromDefaultsKey:[NSString stringWithFormat:@"%@%@",ringName,@"GlobalHotkey"]
										withControl:ringHotkeyControl
											 target:self
									selectorForDown:@selector(animateRingIn)
											  andUp:@selector(keyUpForRing)];
    
    KeyCombo combo;
    combo.code = [[dict objectForKey:RING_KEYCODE] intValue];
    combo.flags = [[dict objectForKey:RING_MODS] intValue];
    [self setGlobalHotkey:combo];
	
	return self;
}

- (void)dealloc
{
	[ringWindow release];
	[ringView release];
	[ringApps release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Accessing Ring Information

- (void)setTheme:(RingTheme *)theTheme
{
	// Woah, this does nothing yet!
}

- (RingTheme *)currentTheme
{
	return nil;
}

- (void)setGlobalHotkey:(KeyCombo)theCombo
{
	//NSLog(@"Setting hotkey to: %i and %i", theCombo.code, theCombo.flags);
	[ringHotkeyControl setKeyCombo:theCombo];
}

- (KeyCombo)currentKeyCombo
{
	return [ringHotkeyControl keyCombo];
}

/*
 *	Returns a snapshot of this ring.
 */
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

/*
 *  Returns a dictionary with the ring preferences that can be written to file.
 */
- (NSDictionary *)dictionaryForRing
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:ringName forKey:RING_NAME];
    [dict setValue:[NSNumber numberWithBool:isBGBlur] forKey:RING_BLUR];
    [dict setValue:[NSNumber numberWithBool:isSticky] forKey:RING_STICKY];
    
    KeyCombo combo = [ringHotkeyControl keyCombo];
    int keycode = combo.code;
    int flags = combo.flags;
    [dict setValue:[NSNumber numberWithInt:keycode] forKey:RING_KEYCODE];
    [dict setValue:[NSNumber numberWithInt:flags] forKey:RING_MODS];
    
    [dict setValue:[NSNumber numberWithInt:ringSize] forKey:RING_SIZE];
    [dict setValue:ringTheme forKey:@"RING_THEME"];
    [dict setValue:[NSNumber numberWithInteger:ringPosition] forKey:RING_POSITION];
    [dict setValue:[NSNumber numberWithFloat:iconRadius] forKey:RING_ICON_RAD];
    [dict setValue:[NSNumber numberWithFloat:iconSize] forKey:RING_ICON_SIZE];
    
    return dict;
}

- (void)setOpenPrefs:(BOOL)open
{
    openPrefsOnRing = open;
}

#pragma mark -
#pragma mark Drawing

/*
 *	Adds all the specified app icons to the ring.
 */
- (void)addAppsToRing
{
	[self removeAllAppsFromRing];
	
	int count = [ringApps count];
	CGFloat angle = 360.0/count;
	CGFloat increment = 0.0;
	CGFloat radius = (int)iconRadius;
	CGFloat iconsSize = (int)iconSize;
	
	radius -= (iconsSize/2);
	
	NSPoint windowCenter = [self viewCenter:ringView];
	NSRect ivFrame = NSMakeRect(0, 0, iconsSize, iconsSize);
	
	for (int i = 0; i < count; i++) {
		NSPoint position = NSMakePoint(radius*sin(DegreesToRadians(increment)), radius*cos(DegreesToRadians(increment)));
		
		ivFrame.origin.x = position.x + windowCenter.x - (iconsSize/2);
		ivFrame.origin.y = position.y + windowCenter.y - (iconsSize/2);
																													
		NSImageView *iv = [[NSImageView alloc] initWithFrame:ivFrame];
		[iv setImageScaling:NSScaleToFit];
		NSRunningApplication *app = [ringApps objectAtIndex:i];
		[iv setImage:[app icon]];
		
		[ringView addSubview:iv];
		
		increment += angle;
	}
}

/*
 *	Removes all applications from the ring that are not the ring or arrow (or BG).
 */
- (void)removeAllAppsFromRing
{
	NSArray *allViews = [ringView subviews];
	NSMutableArray *allViewsMut = [NSMutableArray arrayWithArray:allViews];
	for (NSView *aView in allViewsMut) {
		if ((aView != theRing) && (aView != theArrow) && (aView != blurView) && (aView != highlightView)){
			[aView removeFromSuperview];
		}
	}
}

/*
 *	Gets ad returns the center point of an NSView. Why isn't this in CustomView?
 */
- (NSPoint)viewCenter:(NSView *)theView
{
	NSRect viewFrame = [theView frame];
	return NSMakePoint(viewFrame.origin.x + (viewFrame.size.width/2.0), viewFrame.origin.y + (viewFrame.size.height/2.0));
}

/*
 *  Gets the current screen's background image, scales it to the screen size and 
 *  blurs it using either CIGaussianBlur, CIBoxBlur, CIDiscBlur, CIMotionBlur or
 *  CIZoomBlur.
 */
- (void)blurAndSetBackground
{
    NSRect screenRect = [[NSScreen mainScreen] frame];
    NSURL *bgURL = [[NSWorkspace sharedWorkspace] desktopImageURLForScreen:[NSScreen mainScreen]];
    
    NSImage *sourceImage = [[NSImage alloc] initWithContentsOfURL:bgURL];
    NSSize sourceSize = [sourceImage size];
    //float scaleFactor = screenRect.size.width / sourceSize.width;
    
    NSImage *resizedImage = [[NSImage alloc] initWithSize: NSMakeSize(screenRect.size.width, screenRect.size.height)];
    [resizedImage lockFocus];
    [sourceImage drawInRect: NSMakeRect(0, 0, screenRect.size.width, screenRect.size.height) 
                   fromRect: NSMakeRect(0, 0, sourceSize.width, sourceSize.height) 
                  operation: NSCompositeSourceOver fraction: 1.0];
    [resizedImage unlockFocus];
    
    //CIImage *inputImage = [CIImage imageWithData:[sourceImage TIFFRepresentation]];
    CIImage *inputImage = [CIImage imageWithData:[resizedImage TIFFRepresentation]];
    
    CIFilter *blur = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blur setValue:inputImage forKey:@"inputImage"];
    [blur setValue:[NSNumber numberWithFloat:5.0] forKey:@"inputRadius"];
    CIImage *blurred = [blur valueForKey:@"outputImage"];
    
    /*
    CIFilter *scale = [CIFilter filterWithName:@"CILanczosScaleTransform"];
    [scale setValue:blurred forKey:@"inputImage"];
    [scale setValue:[NSNumber numberWithFloat:scaleFactor] forKey:@"inputScale"];
    [scale setValue:[NSNumber numberWithFloat:1.0] forKey:@"inputAspectRatio"];
    CIImage *scaled = [scale valueForKey:@"outputImage"];
    */
    
    NSImage *blurredImage = [[NSImage alloc] initWithSize:screenRect.size];
    //NSImage *blurredImage = [[NSImage alloc] initWithSize:outSize];
    
    [blurredImage lockFocus];
    [blurred drawAtPoint:NSZeroPoint fromRect:screenRect operation:NSCompositeCopy fraction:1.0];
    //[scaled drawAtPoint:NSZeroPoint fromRect:outRect operation:NSCompositeCopy fraction:1.0];
    [blurredImage unlockFocus];
    
    [blurView setImage:blurredImage];
}

/*
 *	Builds the visual component of this ring object by creating and initialising the
 *	ringWindow and ringView.
 */
- (void)buildRing
{
	NSScreen *main = [NSScreen mainScreen];
	NSRect screenRect = [main frame];
	NSRect windowFrame = NSMakeRect(0, 0, screenRect.size.width, screenRect.size.height);
	
	ringView = [[CustomView alloc] initWithFrame:windowFrame];
	ringWindow = [[CustomWindow alloc] initWithContentRect:[ringView frame] styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    
    // A very bad way to stop the window locking to a desktop! :)
    [ringWindow setRestorable:YES];
    [ringWindow setReleasedWhenClosed:NO];
	
	[ringWindow setContentView:ringView];
	[ringWindow setHidesOnDeactivate:YES];
	[ringWindow setViewsNeedDisplay:YES];
	
	// Add the ring to the centre
	NSPoint ringCentre = [self viewCenter:ringView];
	NSRect arrowFrame = NSMakeRect(ringCentre.x - (ringSize/2), ringCentre.y - (ringSize/2), ringSize, ringSize);
	NSRect ringFrame = NSMakeRect(ringCentre.x - (ringSize/2), ringCentre.y - (ringSize/2), ringSize, ringSize);
    
    blurView = [[NSImageView alloc] initWithFrame:windowFrame];
    [blurView setAutoresizingMask:NSScaleToFit];
    [blurView setImageFrameStyle:NSImageFrameNone];
    [self blurAndSetBackground];
	
	theArrow = [[NSImageView alloc] initWithFrame:arrowFrame];
	theRing = [[NSImageView alloc] initWithFrame:ringFrame];
	
	[theArrow setAutoresizingMask:NSScaleToFit];
	[theArrow setImageFrameStyle:NSImageFrameNone];
	[theRing setAutoresizingMask:NSScaleToFit];
	[theRing setImageFrameStyle:NSImageFrameNone];
	
    // Set the look of the ring (the theme)
	[theArrow setImage:[NSImage imageNamed:@"dark_noir_pointer"]];
	[theRing setImage:[NSImage imageNamed:@"dark_noir_circle_blue"]];
	
    if (isBGBlur) [ringView addSubview:blurView];
	[ringView addSubview:theArrow];
	[ringView addSubview:theRing];
    [ringView addSubview:highlightView];
	
	[ringWindow center]; // Centers the ringWindow on the users screen.
	
	NSLog(@"%@ built.", ringName);
}

- (void)toggleBlurredBackground
{
    NSArray *allViews = [ringView subviews];
	NSMutableArray *allViewsMut = [NSMutableArray arrayWithArray:allViews];
    BOOL isOn = NO;
    
    // First just a quick sanity check if it is on already.
    for (NSView *aView in allViewsMut) {
        if (aView == blurView){
            isOn = YES;
        }
    }
    
    if (isBGBlur) {
        // If we want it on and it's not on, add it.
        if (!isOn)
            [ringView addSubview:blurView];
    } else {
        if (isOn)
            [blurView removeFromSuperview];
    }
}

- (void)setRingCenterPosition:(NSPoint)center
{
	NSScreen *main = [NSScreen mainScreen];
	NSRect screenRect = [main frame];
	
	// Note: there is a (somewhat) bug here.  If the user chooses a large ring (or large icons) then graphic will be cut at the edge of the window.
	//		 Using the approach below the apps are drawn appropriately, though the ring is off.
	/*
	NSRect windowFrame = NSMakeRect(center.x - (screenRect.size.width), center.y - (screenRect.size.height), screenRect.size.width*2, screenRect.size.height*2);
	[[ringWindow contentView] setFrame:windowFrame];
	[ringWindow setFrame:windowFrame display:YES];
	*/
	
	NSPoint new = NSMakePoint(center.x - (screenRect.size.width/2), center.y - (screenRect.size.height/2));
	[ringWindow setFrameOrigin:new];
    //[theRing setFrameOrigin:new];
    //[theArrow setFrameOrigin:new];
}

- (void)setRingDrawingPosition:(NSInteger)position
{
	ringPosition = position;
}

#pragma mark -
#pragma mark Animation

/*
 *	Starts and stops ring animations.
 */
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

/*
 *	Smoothly fades the ring in out.
 */
- (void)animateRingIn
{
    if (isBGBlur) {
        // Hide the menubar when activating the app
        NSApplicationPresentationOptions options = NSApplicationPresentationHideDock + NSApplicationPresentationHideMenuBar;
        [NSApp setPresentationOptions:options];
    }
	
	if (ringPosition == 0) {
		[ringWindow center];
	} else if (ringPosition == 1) {
		[self setRingCenterPosition:[NSEvent mouseLocation]];
	}
	
	[self getAndPresentLaunchedApps];
	[self initiateAnimations];
    
	[NSApp activateIgnoringOtherApps:YES];
    
	[ringWindow makeKeyAndOrderFront:self];
	[[ringWindow animator] setAlphaValue:1.0];
    
    [self adjustHighlightedApp];
}

- (void)animateRingOut
{
    // We could just set this all the time (not necessary but may be safer).
    if (isBGBlur)
        [NSApp setPresentationOptions:NSApplicationPresentationDefault];
	
    [[ringWindow animator] setAlphaValue:0.0];
    [ringWindow close];
}

- (void)adjustHighlightedApp
{
    int count = [ringApps count];
    CGFloat mAngle = [self mouseAngleAboutRing];
	
	CGFloat spacing = 360.0 / count;
	CGFloat mInc = spacing/2;
	int index = 0;
	
	BOOL found = NO;
	
	if (mAngle > 0) {
		mAngle -= 360;
	}
	
	mAngle = -mAngle;
	
	// Probably ineffiecient.  But the number of loops is the index.  Typically there shouldn't be too many loops.
	while (!found) {
		if (mAngle > (360 - (spacing/2))) {
			found = YES;
			index = 0;
		} else if (mAngle < mInc ) {
			found = YES;
		} else {
			mInc += spacing;
			index++;
		}
	}
	
    if (lastHighlighted != index) {
        int iSize = (int)iconSize + 32;
        int iRad = (int)iconRadius - 65;
        NSPoint windowCenter = [self viewCenter:ringView];
        NSRect ivFrame = NSMakeRect(0, 0, iSize, iSize);
        
        NSPoint position = NSMakePoint( iRad*sin(DegreesToRadians(mInc - (spacing/2))), iRad*cos(DegreesToRadians(mInc - (spacing/2))) );
            
        ivFrame.origin.x = position.x + windowCenter.x - (iSize/2);
        ivFrame.origin.y = position.y + windowCenter.y - (iSize/2);
        
        [highlightView setFrame:ivFrame];
        if ([highlightView isHidden]) [highlightView setHidden:NO];
        
        lastHighlighted = index;
    }
}

- (void)mouseMovedForRing
{
	[arrowLayer addAnimation:[self rotateToMouseAnimation] forKey:@"rotate"];
	[[theArrow layer] setNeedsDisplay];
    
    // The way it is right now this is a very expensive step.
    [self adjustHighlightedApp];
}

- (void)mouseDownForRing
{
    // check if we should open the preferences. I don't know how to spell 'centre'
    if (openPrefsOnRing) {
        NSPoint ringCentre = [self viewCenter:theRing];
        NSPoint mousePos = [NSEvent mouseLocation];
        float mouseDistFromCentre = sqrt(pow((ringCentre.x - mousePos.x), 2) + pow((ringCentre.y - mousePos.y), 2));
        
        if (mouseDistFromCentre < (ringSize/2)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"iCommandThePrefsToOpen" object:nil];
            return;
        }
    }
    
    // Otherwise do the normal ring stuff
	CGFloat angle = [self mouseAngleAboutRing];
	
	CGFloat spacing = 360.0 / [ringApps count];
	CGFloat increment = spacing/2;
	int index = 0;
	
	BOOL found = NO;
	
	if (angle > 0) {
		angle -= 360;
	}
	
	angle = -angle;
	
	// Probably ineffiecient.  But the number of loops is the index.  Typically there shouldn't be too many loops.
	while (!found) {
		if (angle > (360 - (spacing/2))) {
			found = YES;
			index = 0;
		} else if (angle < increment ) {
			found = YES;
		} else {
			increment += spacing;
			index++;
		}
	}
	
	[NSApp activateIgnoringOtherApps:YES];
	NSRunningApplication *app = [ringApps objectAtIndex:index];
	[app activateWithOptions:NSApplicationActivateAllWindows];
	//NSLog(@"Mouse down");
}

- (void)keyUpForRing
{	
	if (isSticky)
        return;
    
	[self animateRingOut];
	[self mouseDownForRing];
	
}

- (CAAnimation *)rotateToMouseAnimation
{
	CGFloat angle = [self mouseAngleAboutRing];
	// Note: When we animate from -270 to 90 (and vice versa), the animation goes all the way around the circle.
	
	CABasicAnimation *animation;
	animation = [CABasicAnimation 
                 animationWithKeyPath:@"transform.rotation.z"];
	
    [animation setFromValue:DegreesToNumber(previousValue)];
    [animation setToValue:DegreesToNumber(angle)];
    
    [animation setRemovedOnCompletion:NO];
    [animation setFillMode:kCAFillModeForwards];
    
    previousValue = angle;
    
	return animation;
}

- (CAAnimation *)rotateInfiniteAnimation
{
	CABasicAnimation * animation;
	animation = [CABasicAnimation 
                 animationWithKeyPath:@"transform.rotation.z"];
    
    [animation setFromValue:DegreesToNumber(-180.0)];
    [animation setToValue:DegreesToNumber(180.0)];
    
    [animation setRemovedOnCompletion:NO];
    [animation setFillMode:kCAFillModeForwards];
	[animation setDuration:ROTATION_SPEED]; // Determines the center ring rotation speed
	
	[animation setRepeatCount:HUGE_VALF]; // Rotate forever
    
	return animation;
}

/*
 *  Here's a nice bit of unfinished code that I don't know how to fix anymore. :)
 */
- (CAAnimation *)sizeDecreaseAnimation
{
	//NSRect fromRect = [ringWindow frame];
	//NSRect toRect = NSMakeRect(fromRect.origin.x + fromRect.origin.x, fromRect.origin.y*2, fromRect.size.width/2, fromRect.size.height/2);
	
	NSNumber *fromValue = [NSNumber numberWithInt:1];
							
	CABasicAnimation *animation;
	animation = [CABasicAnimation 
                 animationWithKeyPath:@"transform.size.z"];
	
    [animation setFromValue:fromValue];
    [animation setToValue:0];
    
    [animation setRemovedOnCompletion:YES];
    [animation setFillMode:kCAFillModeForwards];
    
	return animation;
}

/*
 *  I wrote this so long that I don't actually know what it's doing anymore. =/
 */
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context;
{
    if( layer == ringLayer )
    {
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGPathMoveToPoint(path,NULL, [theRing bounds].size.width/2.0, 0.0);
        CGPathAddLineToPoint(path, NULL, [theRing bounds].size.width/2.0, [theRing bounds].size.height);
		
        CGPathMoveToPoint(path,NULL, 0.0, [theRing bounds].size.height/2.0);
        CGPathAddLineToPoint(path, NULL, [theRing bounds].size.width, [theRing bounds].size.height/2.0);
        
        CGColorRef black =
        CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0);
        CGContextSetStrokeColorWithColor(context, black);
        CFRelease(black);
        
        CGContextBeginPath(context);
        CGContextAddPath(context, path);
        
        CGContextSetLineWidth(context, 3.0);
        
        CGContextStrokePath(context);
        
        CFRelease(path);
        
    }
	
	if( layer == arrowLayer )
    {
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGPathMoveToPoint(path,NULL, [theArrow bounds].size.width/2.0, 0.0);
        CGPathAddLineToPoint(path, NULL, [theArrow bounds].size.width/2.0, [theArrow bounds].size.height);
		
        CGPathMoveToPoint(path,NULL, 0.0, [theArrow bounds].size.height/2.0);
        CGPathAddLineToPoint(path, NULL, [theArrow bounds].size.width, [theArrow bounds].size.height/2.0);
        
        CGColorRef black =
        CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0);
        CGContextSetStrokeColorWithColor(context, black);
        CFRelease(black);
        
        CGContextBeginPath(context);
        CGContextAddPath(context, path);
        
        CGContextSetLineWidth(context, 3.0);
        
        CGContextStrokePath(context);
		
        CFRelease(path);
    }
}

#pragma mark -
#pragma mark System Information

/*
 *	Returns the angle (from the positive Y axis) of the mouse.
 */
- (CGFloat)mouseAngleAboutRing
{
	NSPoint mouseLoc = [NSEvent mouseLocation];
	NSRect windowFrame = [ringWindow frame];
	NSPoint windowCenter = NSMakePoint(windowFrame.origin.x + (windowFrame.size.width/2.0), windowFrame.origin.y + (windowFrame.size.height/2.0));
	
	CGFloat theX = mouseLoc.x - windowCenter.x;
	CGFloat theY = mouseLoc.y - windowCenter.y;
	
	CGFloat angle = acos(theX/(sqrt(theX*theX + theY*theY)));
	angle = RadiansToDegrees(angle);
	
	if (mouseLoc.y < windowCenter.y)
		angle = -angle;
	
	angle -= 90.0;
	return angle;
}

/*
 *	Sets the currently running apps to the ring.
 */
- (void)getAndPresentLaunchedApps
{
    NSMutableArray *runningApps = [NSMutableArray array];
    NSArray *launchedNames = [[NSWorkspace sharedWorkspace] valueForKeyPath:@"launchedApplications.NSApplicationName"];
    NSArray *allProcesses = [[NSWorkspace sharedWorkspace] runningApplications];
    
    for (NSRunningApplication *app in allProcesses) {
        for (NSString *appName in launchedNames) {
            if ([[app localizedName] isEqualToString:appName]) {
                [runningApps addObject:app];
                break;
            }
        }
    }
	
	ringApps = [[[runningApps copy] retain] autorelease];
	[self addAppsToRing];
}

@end
