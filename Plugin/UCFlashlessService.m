//
//  UCFlashlessService.m
//  Flashless
//
//  Created by Christoph on 04.08.09.
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


#import "UCFlashlessService.h"
#import "UCFlashlessYoutubeService.h"
#import "UCFlashlessXtubeService.h"
#import "UCFlashlessVimeoService.h"
#import "UCFlashlessViddlerService.h"
#import "UCFlashlessBliptvService.h"
#import "UCFlashlessUstreamService.h"
#import "UCFlashlessFlickrService.h"
#import "UCFlashlessGoogleService.h"


@implementation UCFlashlessService

+ (NSString *)domainForSrc:(NSURL *)src
{
	if(src==nil)
		{
		return nil;
		}

	NSString * host = [@"." stringByAppendingString:[src host]];
	NSRange dot = [host rangeOfString:@"." options:NSBackwardsSearch range:NSMakeRange(0, [host rangeOfString:@"." options:NSBackwardsSearch].location)];
	return [host substringFromIndex:dot.location+1];
}

- (id)initWithSrc:(NSURL *)aSrc andFlashVars:(NSDictionary *)theFlashVars
{
	if([self isMemberOfClass:[UCFlashlessService class]])
		{
		NSString * domain = [[self class] domainForSrc:aSrc];
		[self release];
		Class ConcreteSubclass = [[NSDictionary dictionaryWithObjectsAndKeys:
			[UCFlashlessYoutubeService class], @"youtube.com",
			[UCFlashlessYoutubeService class], @"ytimg.com",
			[UCFlashlessYoutubeService class], @"youtube-nocookie.com",
			[UCFlashlessXtubeService class], @"xtube.com",
			[UCFlashlessVimeoService class], @"vimeo.com",
			[UCFlashlessBliptvService class], @"blip.tv",
			[UCFlashlessViddlerService class], @"viddler.com",
			[UCFlashlessUstreamService class], @"ustream.tv",
			[UCFlashlessFlickrService class], @"flickr.com",
			[UCFlashlessGoogleService class], @"google.com",
		nil] objectForKey:domain];

		if(ConcreteSubclass==nil)
			{
			return nil;
			}

		self = [[ConcreteSubclass alloc] initWithSrc:aSrc andFlashVars:theFlashVars];
		}
	else
		{
		self = [self init];
		if(self!=nil)
			{
			src = [aSrc retain];
			flashVars = [theFlashVars mutableCopy];
			}
		}
	return self;
}

- (void)dealloc
{
	[src release];
	[flashVars release];

	[super dealloc];
}

@end

@implementation UCFlashlessService (AbstractMethods)

- (NSString *)label
{
	return nil;
}

- (NSURL *)previewURL
{
	return nil;
}

- (NSURL *)downloadURL
{
	return nil;
}

- (NSURL *)originalURL
{
	return nil;
}

@end

@implementation UCFlashlessService (SubclassMethods)

- (NSString *)srcString
{
	return [[src absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
}

@end
