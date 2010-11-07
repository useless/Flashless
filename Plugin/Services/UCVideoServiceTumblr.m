//
//  UCVideoServiceTumblr.m
//  Flashless
//
//  Created by Christoph on 07.11.2010.
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


#import "UCVideoServiceTumblr.h"

@implementation UCVideoServiceTumblr

- (void)dealloc
{
	[videoFile release];

	[super dealloc];
}

#pragma mark -

- (NSString *)label
{
	return @"Tumblr";
}

- (void)prepare
{
	videoFile = [flashVars objectForKey:@"file"];
	if(videoFile==nil) {
		[self foundNoDownload];
		return;
	}

	videoFile = [videoFile stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[videoFile retain];
}

- (void)findURLs
{
	if(videoFile==nil) {
		NSString * hintFile = [flashVars objectForKey:@"dataFile"];
		if(hintFile!=nil) {
			[self retrieveHint:[NSURL URLWithString:hintFile relativeToURL:src]];
		}
		return;
	}

	[self foundAVideo:YES];
	[self findDownloadURL];

	[[self class] scan:videoFile from:@"tumblr_" to:@"_" into:&videoID];
	if(videoID!=nil) {
		[self foundPreview:[NSURL URLWithString:[NSString stringWithFormat:@"http://media.tumblr.com/tumblr_%@_r1_frame1.jpg", videoID]]];
	}
}

- (void)findDownloadURL
{
	if(videoFile==nil) {
		return;
	}

	NSURL * videoURL = [NSURL URLWithString:videoFile];
	if(videoURL!=nil) {
		[self foundDownload:videoURL];
	}
}

- (void)receivedHint:(NSString *)hint
{
	if(hint==nil) {
		return;
	}

	NSString * previewFile = nil;
	[[self class] scan:hint from:@"source=\"" to:@"\"" into:&previewFile];
	if(previewFile!=nil) {
		[self foundPreview:[NSURL URLWithString:previewFile]];
	}
}

@end
