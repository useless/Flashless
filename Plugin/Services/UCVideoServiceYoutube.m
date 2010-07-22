//
//  UCVideoServiceYoutube.m
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


#import "UCVideoServiceYoutube.h"

@implementation UCVideoServiceYoutube

- (NSString *)label
{
	return @"YouTube";
}

- (BOOL)canFindDownload
{
	return videoID!=nil;
}

- (void)findURLs
{
	videoID = [flashVars objectForKey:@"video_id"];
	if(videoID==nil)
		{
		NSScanner * scan;
		NSString * scanString = [self pathString];
		if(scanString==nil) { return; }

		scan = [NSScanner scannerWithString:scanString];
		[scan scanUpToString:@"/v/" intoString:NULL];
		if([scan scanString:@"/v/" intoString:NULL])
			{
			[scan scanUpToString:@"&" intoString:&videoID];
			}
		if(videoID==nil)
			{
			scanString = [self queryString];
			if(scanString==nil) { return; }

			scan = [NSScanner scannerWithString:scanString];
			[scan scanUpToString:@"video_id=" intoString:NULL];
			if([scan scanString:@"video_id=" intoString:NULL])
				{
				[scan scanUpToString:@"&" intoString:&videoID];
				}
			}
		}
	if(videoID==nil) { return; }
	[videoID retain];
	[self foundAVideo:YES];
	[self foundOriginal:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", videoID]]];
	[self foundPreview:[NSURL URLWithString:[NSString stringWithFormat:@"http://i1.ytimg.com/vi/%@/hqdefault.jpg", videoID]]];
	NSString * videoHash = [flashVars objectForKey:@"t"];
	if(videoHash!=nil)
		{
		[self foundDownload:[self downloadURLwithVideoID:videoID andHash:videoHash]];
		}
}

- (void)findDownloadURL
{
	if(videoID==nil)
		{
		[self foundNoDownload];
		return;
		}
	[self retrieveHint:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", videoID]]];
}

- (void)receivedHint:(NSString *)hint
{
	if(hint==nil)
		{
		[self foundNoDownload];
		return;
		}
	NSScanner * scan = [NSScanner scannerWithString:hint];
	[scan scanUpToString:@"swfHTML" intoString:NULL];
	[scan scanUpToString:@"&t=" intoString:NULL];
	NSString * videoHash = nil;
	if([scan scanString:@"&t=" intoString:NULL])
		{
		[scan scanUpToString:@"&" intoString:&videoHash];
		}
	if(videoHash==nil)
		{
		[self foundNoDownload];
		}
	else
		{
		[self foundDownload:[self downloadURLwithVideoID:videoID andHash:videoHash]];
		}
}

- (NSURL *)downloadURLwithVideoID:(NSString *)theID andHash:(NSString *)theHash
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/get_video?fmt=18&asv=2&video_id=%@&t=%@", theID, theHash]];
}

@end
