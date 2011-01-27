//
//  AppController.m
//  opiemac
//
//  Created by Ruaridh Thomson on 24/01/2011.
//  Copyright 2011 Life Up North. All rights reserved.
//

#import "AppController.h"
#import "OpieHeader.h"

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

@implementation AppController

- (id)init
{
	if (![super init])
		return nil;
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mouseMovedForRing:) name:@"mouseMovedForRing" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mouseDownForRing:) name:@"mouseDownForRing" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyUpForRing:) name:@"ringGlobalHotkeyUpTriggered" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animateRingIn) name:@"ringGlobalHotkeyDownTriggered" object:nil];
	
	[[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
	
	return self;
}

- (void)awakeFromNib
{	
	ringAllowsActions = NO;
	[self buildRing];
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

#pragma mark -
#pragma mark IBActions

- (IBAction)testButton:(id)sender
{
	[self tintRingWithColour:[sender color]];
}

- (IBAction)test2Button:(id)sender
{
	[self tintRingWithColour:[sender color]];
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

- (void)buildRing
{
	NSScreen *main = [NSScreen mainScreen];
	NSRect screenRect = [main frame];
	NSRect windowFrame = NSMakeRect(0, 0, screenRect.size.width - 100, screenRect.size.height - 100);
	
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
	
	[ringWindow center];
	//[ringWindow makeKeyAndOrderFront:self];
	
	NSLog(@"Ring built");
	//[self initiateAnimations];
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
	[self getAndPresentLaunchedApps];
	[self initiateAnimations];
	
	[NSApp activateIgnoringOtherApps:YES];
	[ringWindow makeKeyAndOrderFront:self];
	[[ringWindow animator] setAlphaValue:1.0];
	
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
	
	NSLog(@"Animate In");
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
	[arrowLayer addAnimation:[self rotateToMouseAnimation] forKey:@"rotate"];
	//[arrowLayer animationForKey:@"rotate"];
	[[theArrow layer] setNeedsDisplay];
	//NSLog(@"Mouse Moved");
}

- (void)mouseDownForRing:(NSNotification *)aNote
{
	CGFloat angle = [self mouseAngleAboutRing];
	
	CGFloat spacing = 360.0 / [openApps count];
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
	
	//NSLog(@"Mouse down at angle %f. Index is %i?", angle, index);
	
	NSRunningApplication *app = [openApps objectAtIndex:index];
	[app activateWithOptions:NSApplicationActivateAllWindows];
}

- (void)keyUpForRing:(NSNotification *)aNote
{
	
	[self animateRingOut];
	[self mouseDownForRing:nil];
	//NSLog(@"KeyUp");
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
	[animation setDuration:10.0];
	
	[animation setRepeatCount:HUGE_VALF]; // Rotate forever
    
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

- (void)tintRingWithColour:(NSColor *)colour
{	
	[[theArrow animator] setImage:[[NSImage imageNamed:@"pointer"] tintedImageWithColor:colour operation:NSCompositeSourceIn]];
	[[theRing animator] setImage:[[NSImage imageNamed:@"circleCentre"] tintedImageWithColor:colour operation:NSCompositeSourceIn]];
}

#pragma mark -
#pragma mark System Access

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
			if ([[dict objectForKey:@"CFBundleName"] isEqualToString:[app localizedName]]) {
				[runningApps addObject:app];
				//NSLog(@"App: %@", [app localizedName]);
			}
		}
	}
	
	openApps = [[[runningApps copy] retain] autorelease];
	[self presentApps:runningApps];
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
