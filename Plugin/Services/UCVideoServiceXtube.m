//
//  UCVideoServiceXtube.m
//  Flashless
//
//  Created by Christoph on 03.09.2009.
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


#import "UCVideoServiceXtube.h"

@implementation UCVideoServiceXtube

- (void)dealloc
{
	[super dealloc];
}

#pragma mark -

- (NSString *)label
{
	return @"XTube";
}

- (void)prepare
{
	videoID = [flashVars objectForKey:@"video_id"];
	if(videoID==nil) {
		NSString * scanString = [self queryString];
		if(scanString==nil) { return; }

		[[self class] scan:scanString from:@"v=" to:@"&" into:&videoID];
	}
	if(videoID==nil) {
		[self foundNoDownload];
		return;
	}
	[videoID retain];
	[self retrieveHint:[NSURL URLWithString:[NSString stringWithFormat:@"http://video2.xtube.com/find_video.php?video_id=%@", videoID]]];
}

- (void)findURLs
{
	if(videoID==nil) { return; }
	[self foundAVideo:YES];
	[self foundOriginal:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.xtube.com/play_re.php?v=%@&cont=y", videoID]]];
}

- (void)findDownloadURL
{
	// Prevent foundNoDownload
}

- (void)receivedHint:(NSString *)hint
{
	if(hint==nil) {
		[self foundNoDownload];
		return;
	}
	NSString * videoFile = nil;
	[[self class] scan:hint from:@"&filename=" to:@"&" into:&videoFile];
	if(videoFile==nil) {
		[self foundNoDownload];
		return;
	} else {
		videoFile = [videoFile stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		videoFile = [videoFile stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}
	NSString * base = [flashVars objectForKey:@"swfURL"];
	if(base==nil) {
		base = @"http://cdn1.publicvideo.xtube.com";
	}
	[self foundDownload:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", base, videoFile]]];

	NSString * thumbnail = nil;
	[[self class] scan:videoFile from:@"/videos" to:@".flv" into:&thumbnail];
	if(thumbnail==nil) { return; }
	[self foundPreview:[NSURL URLWithString:[NSString stringWithFormat:@"http://cdns.xtube.com/u/e10/video_thumb%@_0000.jpg", thumbnail]]];
}

@end
