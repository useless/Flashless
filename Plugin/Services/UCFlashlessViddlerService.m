//
//  UCFlashlessViddlerService.m
//  Flashless
//
//  Created by Christoph on 04.09.09.
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


#import "UCFlashlessViddlerService.h"

@implementation UCFlashlessViddlerService

- (NSString *)label;
{
	return @"Viddler";
}

- (NSURL *)previewURL
{	
	videoID = [flashVars objectForKey:@"key"];
	if(videoID==nil)
		{
		NSScanner * scan = [NSScanner scannerWithString:[self srcString]];
		[scan scanUpToString:@"simple/" intoString:NULL];
		if([scan scanString:@"simple/" intoString:NULL])
			{
			[scan scanUpToString:@"/" intoString:&videoID];
			}
		if(videoID==nil)
			{
			[scan setScanLocation:0];
			[scan scanUpToString:@"simple_on_site/" intoString:NULL];
			if([scan scanString:@"simple_on_site/" intoString:NULL])
				{
				[scan scanUpToString:@"/" intoString:&videoID];
				}
			}
		if(videoID==nil)
			{
			[scan setScanLocation:0];
			[scan scanUpToString:@"player/" intoString:NULL];
			if([scan scanString:@"player/" intoString:NULL])
				{
				[scan scanUpToString:@"/" intoString:&videoID];
				}
			}
		}
	if(videoID==nil) { return nil; }
	[videoID retain];
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://cdn-thumbs.viddler.com/thumbnail_2_%@.jpg", videoID]];
}

@end
