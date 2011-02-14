//
//  ring.m
//  opiemac
//
//  Created by Ruaridh Thomson on 27/01/2011.
//  Copyright 2011 Life Up North. All rights reserved.
//

#import "Ring.h"

#define RING_RADIUS 100
#define ARROW_RADIUS 250
#define ROTATION_SPEED 10.0

@implementation Ring

@synthesize ringName, ringColour, ringSize, iconSize, iconRadius, ringHotkeyControl, isSticky, tintRing;

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
	
	// Something at ring start.
	// At the moment we will just use this backwards way of triggering the ring.
	// We are not likely to need these, since we will be assigning the target from within the ring.
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyUpForRing:) name:@"ringGlobalHotkeyUpTriggered" object:nil];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animateRingIn) name:@"ringGlobalHotkeyDownTriggered" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mouseMovedForRing) name:@"mouseMovedForRing" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mouseDownForRing) name:@"mouseDownForRing" object:nil];
	
	ringAllowsActions = NO;
	isSticky = NO;
	tintRing = NO;
	ringIsActive = NO;
	ringColour = [NSColor clearColor];
	ringSize = 0;
	iconSize = 128;
	iconRadius = 300;
	
	ringPosition = 0;
	
	ringName = name;
	[self buildRing];
	
	KeyCombo combo1 = { (NSShiftKeyMask | NSAlternateKeyMask), (CGKeyCode)49 };
	[ringHotkeyControl setKeyCombo:combo1];
	/*
	SDGlobalShortcutsController *shortcutsController = [SDGlobalShortcutsController sharedShortcutsController];
	[shortcutsController addShortcutFromDefaultsKey:@"ringGlobalHotkey"
										withControl:ringHotkeyControl
											 target:self
									selectorForDown:@selector(animateRingIn)
											  andUp:@selector(keyUpForRing)];
	*/
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
#pragma mark Delegates

- (void)setTheme:(RingTheme *)theTheme
{
	
}

#pragma mark -
#pragma mark Drawing

/*
 *	Adds all the specified applications icons to the ring.
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
 *	Removes all applications from the ring that are not the ring or arrow.
 */
- (void)removeAllAppsFromRing
{
	NSArray *allViews = [ringView subviews];
	NSMutableArray *allViewsMut = [NSMutableArray arrayWithArray:allViews];
	for (NSView *aView in allViewsMut) {
		if ((aView != theRing) && (aView != theArrow)){
			[aView removeFromSuperview];
		}
	}
}

/*
 *	Gets ad returns the center point of an NSView.  Why isn't this in CustomView?
 */
- (NSPoint)viewCenter:(NSView *)theView
{
	NSRect viewFrame = [theView frame];
	return NSMakePoint(viewFrame.origin.x + (viewFrame.size.width/2.0), viewFrame.origin.y + (viewFrame.size.height/2.0));
}

/*
 *	Builds the visual component of this ring object by creating and initialising the
 *	ringWindow and ringView.
 */
- (void)buildRing
{
	NSScreen *main = [NSScreen mainScreen];
	NSRect screenRect = [main frame];
	//NSRect windowFrame = NSMakeRect(0, 0, screenRect.size.width - 100, screenRect.size.height - 100);
	NSRect windowFrame = NSMakeRect(0, 0, screenRect.size.width, screenRect.size.height);
	
	ringView = [[CustomView alloc] initWithFrame:windowFrame];
	ringWindow = [[CustomWindow alloc] initWithContentRect:[ringView frame] styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	[ringWindow setContentView:ringView];
	[ringWindow setHidesOnDeactivate:YES];
	
	[ringWindow setViewsNeedDisplay:YES];
	
	// Add the ring to the centre
	NSPoint ringCentre = [self viewCenter:ringView];
	NSRect arrowFrame = NSMakeRect(ringCentre.x - (ARROW_RADIUS/2), ringCentre.y - (ARROW_RADIUS/2), ARROW_RADIUS, ARROW_RADIUS);
	NSRect ringFrame = NSMakeRect(ringCentre.x - (RING_RADIUS/2), ringCentre.y - (RING_RADIUS/2), RING_RADIUS, RING_RADIUS);
	
	theArrow = [[NSImageView alloc] initWithFrame:arrowFrame];
	theRing = [[NSImageView alloc] initWithFrame:ringFrame];
	
	[theArrow setAutoresizingMask:NSScaleToFit];
	[theArrow setImageFrameStyle:NSImageFrameNone];
	[theRing setAutoresizingMask:NSScaleToFit];
	[theRing setImageFrameStyle:NSImageFrameNone];
	
	[theArrow setImage:[NSImage imageNamed:@"pointer"]];
	[theRing setImage:[NSImage imageNamed:@"circleCentre"]];
	
	[ringView addSubview:theArrow];
	[ringView addSubview:theRing];
	
	//=============================
	
	
	
	//=============================
	
	[ringWindow center]; // Centers the ringWindow on the users screen.  Though we may wish to override this with a custom position.
	
	NSLog(@"%@ built", ringName);
}

- (void)setRingCenterPosition:(NSPoint)center
{
	NSRect windowFrame = [[ringWindow contentView] frame];
	windowFrame.origin.x = center.x - (windowFrame.origin.x/2);
	windowFrame.origin.y = center.y - (windowFrame.origin.y/2);
	
	[[ringWindow contentView] setFrame:windowFrame];
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

/* Tints the ring to the chosen colour. */
- (void)tintRingWithColour:(NSColor *)colour
{	
	[[theArrow animator] setImage:[[NSImage imageNamed:@"pointer"] tintedImageWithColor:colour operation:NSCompositeSourceIn]];
	[[theRing animator] setImage:[[NSImage imageNamed:@"circleCentre"] tintedImageWithColor:colour operation:NSCompositeSourceIn]];
}

- (void)setRingDrawingPosition:(NSInteger *)position
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
	//[[ringWindow contentView] setWantsLayer:YES];
	//[[[ringWindow contentView] layer] addAnimation:[self sizeDecreaseAnimation] forKey:@"size"];
	
	if (tintRing)
		[self tintRingWithColour:ringColour];
	
	/*
	if (ringPosition == 0) {
		//[self setRingCenterPosition:[self screenCenter]];
		[ringWindow center];
	} else if (ringPosition == 1) {
		[self setRingCenterPosition:[NSEvent mouseLocation]];
		//NSLog(@"Set position to mouse");
	}
	 */
	
	[self getAndPresentLaunchedApps];
	[self initiateAnimations];
	
	[NSApp activateIgnoringOtherApps:YES];
	 
	[ringWindow makeKeyAndOrderFront:self];
	[[ringWindow animator] setAlphaValue:1.0];
	
	NSLog(@"Animate %@ in", ringName);
}

- (void)animateRingOut
{
	[[ringWindow animator] setAlphaValue:0.0];
}

- (void)mouseMovedForRing
{
	[arrowLayer addAnimation:[self rotateToMouseAnimation] forKey:@"rotate"];
	[[theArrow layer] setNeedsDisplay];
}

- (void)mouseDownForRing
{
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
	NSLog(@"Mouse down");
}

- (void)keyUpForRing
{	
	
	[self animateRingOut];
	[self mouseDownForRing];
	/*
	NSWorkspace
	NSApplication
	NSScreen
	 */
	//[[NSWorkspace sharedWorkspace] launchApplication:@"Safari"];
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
	CFArrayRef theArrayRef = [self copyLaunchedApplicationsInFrontToBackOrder];
	NSArray *allProcesses = [[NSWorkspace sharedWorkspace] runningApplications];
	NSMutableArray *runningApps = [NSMutableArray array];
	
	// Unfortunately this runs in O(n*m): where n is the number of processes and m is the number of launched apps.
	// But then again, we only need to call this when the "running apps wheel" is called forward.
	// This will add the apps in the static process order.  To change to the 
	for (NSRunningApplication *app in allProcesses) {
		for (int j = 0; j < CFArrayGetCount(theArrayRef); j++) {
			NSDictionary *dict = (NSDictionary *)CFArrayGetValueAtIndex(theArrayRef, j);
			/*
			if ([[dict objectForKey:@"CFBundleName"] isEqualToString:[app localizedName]]) {
				[runningApps addObject:app];
			}
			 */
			//NSLog(@"%@ == %@", [app localizedName], [dict objectForKey:@"CFBundleName"]);
			if ([[app localizedName] contains:[dict objectForKey:@"CFBundleName"]])
				 [runningApps addObject:app];
		}
	}
	
	ringApps = [[[runningApps copy] retain] autorelease];
	[self addAppsToRing];
}

/*
 * Returns an array of CFDictionaryRef types, each of which contains information about one of the processes.
 * The processes are ordered in front to back, i.e. in the same order they appear when typing command + tab, from left to right.
 * See the ProcessInformationCopyDictionary function documentation for the keys used in the dictionaries.
 * If something goes wrong, then this function returns NULL.
 */
- (CFArrayRef)copyLaunchedApplicationsInFrontToBackOrder
{    
    CFArrayRef (*_LSCopyApplicationArrayInFrontToBackOrder)(uint32_t sessionID) = NULL;
    void       (*_LSASNExtractHighAndLowParts)(void const* asn, UInt32* psnHigh, UInt32* psnLow) = NULL;
    CFTypeID   (*_LSASNGetTypeID)(void) = NULL;
    
    void *lsHandle = dlopen("/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/LaunchServices", RTLD_LAZY);
    if (!lsHandle) { return NULL; }
    
    _LSCopyApplicationArrayInFrontToBackOrder = (CFArrayRef(*)(uint32_t))dlsym(lsHandle, "_LSCopyApplicationArrayInFrontToBackOrder");
    _LSASNExtractHighAndLowParts = (void(*)(void const*, UInt32*, UInt32*))dlsym(lsHandle, "_LSASNExtractHighAndLowParts");
    _LSASNGetTypeID = (CFTypeID(*)(void))dlsym(lsHandle, "_LSASNGetTypeID");
    
    if (_LSCopyApplicationArrayInFrontToBackOrder == NULL || _LSASNExtractHighAndLowParts == NULL || _LSASNGetTypeID == NULL) { return NULL; }
    
    CFMutableArrayRef orderedApplications = CFArrayCreateMutable(kCFAllocatorDefault, 64, &kCFTypeArrayCallBacks);
    if (!orderedApplications) { return NULL; }
    
    CFArrayRef apps = _LSCopyApplicationArrayInFrontToBackOrder(-1);
    if (!apps) { CFRelease(orderedApplications); return NULL; }
    
    CFIndex count = CFArrayGetCount(apps);
    for (CFIndex i = 0; i < count; i++)
    {
        ProcessSerialNumber psn = {0, kNoProcess};
        CFTypeRef asn = CFArrayGetValueAtIndex(apps, i);
        if (CFGetTypeID(asn) == _LSASNGetTypeID())
        {
            _LSASNExtractHighAndLowParts(asn, &psn.highLongOfPSN, &psn.lowLongOfPSN);
            
            CFDictionaryRef processInfo = ProcessInformationCopyDictionary(&psn, kProcessDictionaryIncludeAllInformationMask);
            if (processInfo)
            {
                CFArrayAppendValue(orderedApplications, processInfo);
                CFRelease(processInfo);
            }
        }
    }
    CFRelease(apps);
    
    CFArrayRef result = CFArrayGetCount(orderedApplications) == 0 ? NULL : CFArrayCreateCopy(kCFAllocatorDefault, orderedApplications);
    CFRelease(orderedApplications);
    return result;
}

@end
