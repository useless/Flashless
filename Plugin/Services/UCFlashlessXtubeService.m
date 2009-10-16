//
//  UCFlashlessXtubeService.m
//  Flashless
//
//  Created by Christoph on 03.09.09.
//  Copyright Useless Coding 2009.
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


#import "UCFlashlessXtubeService.h"

@implementation UCFlashlessXtubeService

- (void)dealloc
{
	[super dealloc];
}

#pragma mark -

- (NSString *)label
{
	return @"XTube";
}

- (void)findURLs
{
	videoID = [[flashVars objectForKey:@"video_id"] retain];
	if(videoID==nil) { return; }
	[self foundAVideo:YES];
	[self foundOriginal:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.xtube.com/play_re.php?v=%@", videoID]]];
	[self retrieveHint:[NSURL URLWithString:[NSString stringWithFormat:@"http://video2.xtube.com/find_video.php?sid=0&v_user_id=%@&idx=%@&video_id=%@&clip_id=%@",
		[flashVars objectForKey:@"user_id"],
		[flashVars objectForKey:@"idx"],
		videoID,
		[flashVars objectForKey:@"clip_id"]
	]]];
}

- (void)receivedHint:(NSString *)hint
{
	if(hint==nil) { return; }
	NSScanner * scan = [NSScanner scannerWithString:hint];
	NSString * videoFile = nil;
	if([scan scanString:@"&filename=" intoString:NULL])
		{
		[scan scanUpToString:@"&" intoString:&videoFile];
		}
	if(videoFile==nil) { return; }
	[self foundDownload:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [flashVars objectForKey:@"swfURL"], videoFile]]];
	NSString * thumbnail = nil;
	scan = [NSScanner scannerWithString:videoFile];
	if([scan scanString:@"/videos" intoString:NULL])
		{
		[scan scanUpToString:@".flv" intoString:&thumbnail];
		}
	if(thumbnail==nil) { return; }
	[self foundPreview:[NSURL URLWithString:[NSString stringWithFormat:@"http://cdns.xtube.com/u/e10/video_thumb%@_0000.jpg", thumbnail]]];
}

@end
