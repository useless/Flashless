//
//  UCVideoServiceGoogle.m
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


#import "UCVideoServiceGoogle.h"

@implementation UCVideoServiceGoogle

- (void)dealloc
{
	[query release];

	[super dealloc];
}

#pragma mark -

- (NSString *)label
{
	return @"Google Video";
}

- (void)prepare
{
	query = [[self queryString] retain];
}

- (void)findURLs
{
	NSString * thumbnail = nil;

	if(query==nil) { return; }

	[[self class] scan:query from:@"docid=" to:@"&" into:&videoID];
	[videoID retain];
	if(videoID!=nil) {
		[self foundAVideo:YES];
		[self foundOriginal:[NSURL URLWithString:[NSString stringWithFormat:@"http://video.google.com/videoplay?docid=%@", videoID]]];
	}

	[self findDownloadURL];

	[[self class] scan:query from:@"thumbnailUrl=" to:@"&" into:&thumbnail];
	if(thumbnail!=nil) {
		[self foundPreview:[NSURL URLWithString:[thumbnail stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	}
}

- (void)findDownloadURL
{
	NSString * videoFile = nil;

	if(query==nil) {
		[self foundNoDownload];
		return;
	}

	[[self class] scan:query from:@"videoURL=" to:@"&" into:&videoFile];
	if(videoFile==nil) {
		[self foundNoDownload];
	} else {
		[self foundDownload:[NSURL URLWithString:[videoFile stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	}
}

@end
