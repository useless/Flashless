//
//  UCVideoServiceBliptv.m
//  Flashless
//
//  Created by Christoph on 04.09.2009.
//  Copyright 2009-2010 Useless Coding.
/*
Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/


#import "UCVideoServiceBliptv.h"

@implementation UCVideoServiceBliptv

- (NSString *)label
{
	return @"Blip.tv";
}

- (void)prepare
{
	if([[src host] isEqualToString:@"blip.tv"])
		{
		[self resolveURL:src];
		}
	else
		{
		[self redirectedTo:nil];
		}
}

- (void)findDownloadURL
{
// Prevent foundNoDownload
}

- (void)redirectedTo:(NSURL *)redirectedURL
{
	NSString * srcString = [self srcString];
	if(redirectedURL!=nil)
		{
		[self setSrc:redirectedURL];
		srcString = [self srcString];
		}
	NSString * hintURLString = nil;
	[[self class] scan:srcString from:@"file=" to:@"&" into:&hintURLString];
	if(hintURLString==nil) {
		[self foundNoDownload];
		return;
	}
	[self retrieveHint:[NSURL URLWithString:[hintURLString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

- (void)receivedHint:(NSString *)hint
{
	if(hint==nil) { return; }
	[self foundAVideo:YES];
	NSString * originalURLString = nil;
	NSString * preview = nil;
	NSString * downloadURLString = nil;
	[[self class] scan:hint from:@"<media:player url=\"" to:@"\">" into:&originalURLString];
	if(originalURLString!=nil)
		{
		[self foundOriginal:[NSURL URLWithString:originalURLString]];
		}

	[[self class] scan:hint from:@"<blip:thumbnail_src>" to:@"</blip:thumbnail_src>" into:&preview];
	if(preview!=nil)
		{
		[self foundPreview:[NSURL URLWithString:[NSString stringWithFormat:@"http://a.images.blip.tv/%@", preview]]];
		}

	[[self class] scan:hint from:@"<media:content url=\"" to:@"\"" into:&downloadURLString];
	if(downloadURLString!=nil)
		{
		[self foundDownload:[NSURL URLWithString:downloadURLString]];
		}
}


@end
