//
//  RingTheme.m
//  Nimble
//
//  Created by Ruaridh Thomson on 01/02/2011.
//  Copyright 2011 Ruaridh Thomson. All rights reserved.
//
//	Info regarding the images:
//	All images should be at least 512x512 (height and width ratio must be 1:1).
//	The centerImage and mouseImage will scale 1:1 – so they should be made together.
//	The appBG will act as a background for the app images and needs to be at least 20% bigger than the image size used (typically empty).
//	The ringBG should be as big as possible.  Since it will act as the core background for the ring (though typically empty).

#import "RingTheme.h"

@implementation RingTheme

@synthesize centerImage, mouseImage, appBG, ringBG;

- (id)initWithCenter:(NSImage *)theCenter mouse:(NSImage *)theMouse app:(NSImage *)theApp ring:(NSImage *)theRing
{
	if (![super init])
		return nil;
	
	centerImage = [theCenter copy];
	mouseImage = [theMouse copy];
	appBG = [theApp copy];
	ringBG = [theRing copy];
	
	return self;
}

@end
