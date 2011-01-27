//
//  ring.m
//  opiemac
//
//  Created by Ruaridh Thomson on 27/01/2011.
//  Copyright 2011 Life Up North. All rights reserved.
//

#import "ring.h"


@implementation ring

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

- (id)init
{
	if (![super init])
		return nil;
	
	// Something at ring start.
	// At the moment we will just use this backwards way of triggering the ring.
	// We are not likely to need these, since we will be assigning the target from within the ring.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyUpForRing:) name:@"ringGlobalHotkeyUpTriggered" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animateRingIn) name:@"ringGlobalHotkeyDownTriggered" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mouseMovedForRing:) name:@"mouseMovedForRing" object:nil];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mouseDownForRing:) name:@"mouseDownForRing" object:nil];
	
	return self;
}

- (void)awakeFromNib
{
	// Something when woke?
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

#pragma mark -
#pragma mark Drawing

#pragma mark -
#pragma mark Animation


@end
