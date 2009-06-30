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
	[flashView initWithArguments:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSDictionary dictionaryWithObjectsAndKeys:
			@"http://example.com/play.swf", @"src",
			nil], WebPlugInAttributesKey,
		[NSURL URLWithString:@"http://example.com"], WebPlugInBaseURLKey,
		nil]];
/*	[flashView initWithArguments:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSDictionary dictionaryWithObjectsAndKeys:
			@"http://www.vimeo.com/moogaloop_local.swf?ver=26144", @"src",
			@"clip_id=5245067&amp;server=vimeo.com&amp;autoplay=0&amp;fullscreen=1&amp;md5=0&amp;show_portrait=0&amp;show_title=0&amp;show_byline=0&amp;context=user:1927735&amp;context_id=&amp;force_embed=0&amp;multimoog=&amp;color=00ADEF&amp;force_info=undefined", @"flashvars",
			nil], WebPlugInAttributesKey,
		[NSURL URLWithString:@"http://www.fscklog.com/"], WebPlugInBaseURLKey,
		nil]];
*/
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
