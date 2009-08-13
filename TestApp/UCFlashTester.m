//
//  UCFlashTester.m
//  Flashless TestApp
//
//  Created by Christoph on 13.06.09.
//  Copyright 2009 Useless Coding. All rights reserved.
//

#import "UCFlashTester.h"


@implementation UCFlashTester

- (void)awakeFromNib
{
/*	[flashView initWithArguments:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSDictionary dictionaryWithObjectsAndKeys:
			@"http://example.com/play.swf", @"src",
			nil], WebPlugInAttributesKey,
		[NSURL URLWithString:@"http://example.com"], WebPlugInBaseURLKey,
		nil]];
*/	[flashView initWithArguments:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSDictionary dictionaryWithObjectsAndKeys:
			@"http://www.youtube.com/v/0ciPntuvX0c&hl=en&fs=1&rel=0&hd=1", @"src",
			nil], WebPlugInAttributesKey,
		[NSURL URLWithString:@"http://www.fscklog.com/"], WebPlugInBaseURLKey,
		nil]];

}

- (void)start:(id)sender
{
	[flashView webPlugInInitialize];
}

- (void)stop:(id)sender
{
	[flashView webPlugInDestroy];
}

- (void)refresh:(id)sender
{
	[flashView setNeedsDisplay:YES];
}


@end
