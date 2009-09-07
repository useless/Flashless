//
//  UCFlashlessYoutubeService.m
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


#import "UCFlashlessYoutubeService.h"

@implementation UCFlashlessYoutubeService


- (NSString *)label;
{
	return @"YouTube";
}

- (NSURL *)previewURL
{	
	videoID = [flashVars objectForKey:@"video_id"];
	if(videoID==nil)
		{
		NSScanner * scan = [NSScanner scannerWithString:[self pathString]];
		[scan scanUpToString:@"/v/" intoString:NULL];
		if([scan scanString:@"/v/" intoString:NULL])
			{
			[scan scanUpToString:@"&" intoString:&videoID];
			}
		if(videoID==nil)
			{
			[scan setScanLocation:0];
			[scan scanUpToString:@"video_id=" intoString:NULL];
			if([scan scanString:@"video_id=" intoString:NULL])
				{
				[scan scanUpToString:@"&" intoString:&videoID];
				}
			}
		}
	if(videoID==nil) { return nil; }
	[videoID retain];
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://i1.ytimg.com/vi/%@/hqdefault.jpg", videoID]];
}

- (NSURL *)downloadURL
{
	if(videoID==nil) { return nil; }
	NSString * videoHash = [flashVars objectForKey:@"t"];
	if(videoHash==nil) { return nil; }
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/get_video?fmt=18&video_id=%@&t=%@", videoID, videoHash]];
}

- (NSURL *)originalURL
{
	if(videoID==nil) { return nil; }
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", videoID]];
}

@end
