//
//  UCFlashlessServices.m
//  Flashless
//
//  Created by Christoph on 04.08.09.
//  Copyright Useless Coding 2009. All rights reserved.
//

#import "UCFlashlessServices.h"

static NSString * sVideoIDKey = @"UCFlashlessVideoID";
static NSString * sVideoFilenameKey = @"UCFlashlessVideoFilename";

@implementation UCFlashlessServices

- (void) dealloc
{
	[lastSrc release];
	[lastDomain release];

	[super dealloc];
}


#pragma mark -

- (NSString *)domainForSrc:(NSURL *)src
{
	if(src==nil)
		{
		return nil;
		}
	
	if(src==lastSrc)
		{
		return lastDomain;
		}
	
	[lastSrc release];
	[lastDomain release];
	
	lastSrc = [src copy];
	NSString * host = [@"." stringByAppendingString:[src host]];
	NSRange dot = [host rangeOfString:@"." options:NSBackwardsSearch range:NSMakeRange(0, [host rangeOfString:@"." options:NSBackwardsSearch].location)];
	lastDomain = [[host substringFromIndex:dot.location+1] copy];
	return lastDomain;
}

- (NSString *)labelForSrc:(NSURL *)src;
{
	if(src==nil)
		{
		return @"???";
		}
	
	NSString * domain = [self domainForSrc:src];
	
	if(domain==nil)
		{
		return @"!!!";
		}
	
	return [[NSDictionary dictionaryWithObjectsAndKeys:@"YouTube", @"youtube.com",
			@"YouTube", @"ytimg.com",
			@"YouTube", @"youtube-nocookie.com",
			@"XTube", @"xtube.com",
			@"Vimeo", @"vimeo.com",
			@"blip.tv", @"blip.tv",
			@"Viddler", @"viddler.com",
			@"USTREAM", @"ustream.tv",
			@"Flickr", @"flickr.com",
			@"Google Video", @"google.com",
		nil] objectForKey:domain];
}

- (NSURL *)previewURLForSrc:(NSURL *)src andFlashVars:(NSMutableDictionary *)flashVars
{
	if(src==nil) { return nil; }
	
	NSURL * previewURL = nil;
	NSString * domain = [self domainForSrc:src];
	NSString * videoID = nil;
	NSString * srcString = [[src absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	
	if([domain isEqualToString:@"youtube.com"] || [domain isEqualToString:@"ytimg.com"] || [domain isEqualToString:@"youtube-nocookie.com"])
		{
		videoID = [flashVars objectForKey:@"video_id"];
		if(videoID==nil)
			{
			NSScanner * scan = [NSScanner scannerWithString:srcString];
			[scan scanUpToString:@".com/v/" intoString:NULL];
			if([scan scanString:@".com/v/" intoString:NULL])
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
				if(videoID==nil) { return nil; }
				}
			}
		previewURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://i1.ytimg.com/vi/%@/hqdefault.jpg", videoID]];
		}
	else if([domain isEqualToString:@"xtube.com"])
		{
		if([flashVars objectForKey:@"user_id"]==nil) { return nil; }
		NSString * hint = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://video2.xtube.com/find_video.php?sid=0&v_user_id=%@&idx=%@&from=&video_id=%@&clip_id=%@&qid=&qidx=&qnum=",
			[flashVars objectForKey:@"user_id"],
			[flashVars objectForKey:@"idx"],
			[flashVars objectForKey:@"video_id"],
			[flashVars objectForKey:@"clip_id"]
		]]];
		if(hint==nil) { return nil; }
		NSString * filename;
		NSScanner * scan = [NSScanner scannerWithString:hint];
		if([scan scanString:@"&filename=" intoString:NULL])
			{
			[scan scanUpToString:@"&" intoString:&filename];
			}
		if(filename==nil) { return nil; }
		[flashVars setObject:filename forKey:sVideoFilenameKey];
		scan = [NSScanner scannerWithString:filename];
		if([scan scanString:@"/videos" intoString:NULL])
			{
			[scan scanUpToString:@".flv" intoString:&filename];
			}
		if(filename==nil) { return nil; }
		previewURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://cdns.xtube.com/u/e10/video_thumb%@_0000.jpg", filename]];
		}
	else if([domain isEqualToString:@"viddler.com"])
		{
		videoID = [flashVars objectForKey:@"key"];
		if(videoID==nil)
			{
			NSScanner * scan = [NSScanner scannerWithString:srcString];
			[scan scanUpToString:@"simple_on_site/" intoString:NULL];
			if([scan scanString:@"simple_on_site/" intoString:NULL])
				{
				[scan scanUpToString:@"/" intoString:&videoID];
				}
			if(videoID==nil) { return nil; }
			}
		previewURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://cdn-thumbs.viddler.com/thumbnail_2_%@.jpg", videoID]];
		}
	else if([domain isEqualToString:@"vimeo.com"])
		{
		videoID = [flashVars objectForKey:@"clip_id"];
		NSScanner * scan;
		if(videoID==nil)
			{
			scan = [NSScanner scannerWithString:srcString];
			[scan scanUpToString:@"clip_id=" intoString:NULL];
			if([scan scanString:@"clip_id=" intoString:NULL])
				{
				[scan scanUpToString:@"&" intoString:&videoID];
				}
			}
		if(videoID==nil) { return nil; }
		NSString * hint = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.vimeo.com/moogaloop/load/clip:%@/embed", videoID]]];
		if(hint==nil) { return nil; }
		NSString * previewfile;
		scan = [NSScanner scannerWithString:hint];
		[scan scanUpToString:@"<thumbnail>" intoString:NULL];
		if([scan scanString:@"<thumbnail>" intoString:NULL])
			{
			[scan scanUpToString:@"</thumbnail>" intoString:&previewfile];
			}
		if(previewfile==nil) { return nil; }
		previewURL = [NSURL URLWithString:previewfile];
		}
	else if([domain isEqualToString:@"flickr.com"])
		{
		videoID = [flashVars objectForKey:@"photo_id"];
		if(videoID==nil) { return nil; }
		NSString * hint = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.flickr.com/apps/video/video_mtl_xml.gne?v=x&photo_id=%@&secret=null&olang=null&noBuffer=null&bitrate=700&target=_blank&show_info_box=1", videoID]]];
		if(hint==nil) { return nil; }
		NSString * server;
		NSString * secret;
		NSScanner * scan = [NSScanner scannerWithString:hint];
		[scan scanUpToString:@"<Item id=\"photo_server\">" intoString:NULL];
		if([scan scanString:@"<Item id=\"photo_server\">" intoString:NULL])
			{
			[scan scanUpToString:@"</Item>" intoString:&server];
			}
		[scan scanUpToString:@"<Item id=\"photo_secret\">" intoString:NULL];
		if([scan scanString:@"<Item id=\"photo_secret\">" intoString:NULL])
			{
			[scan scanUpToString:@"</Item>" intoString:&secret];
			}
		if(server!=nil && secret!=nil)
			{
			previewURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://farm3.static.flickr.com/%@/%@_%@.jpg?0", server, videoID, secret]];
			}
		}
	else if([domain isEqualToString:@"google.com"])
		{
		NSString * filename;
		NSString * thumbnail;
		NSScanner * scan = [NSScanner scannerWithString:srcString];
		[scan scanUpToString:@"videoURL=" intoString:NULL];
		if([scan scanString:@"videoURL=" intoString:NULL])
			{
			[scan scanUpToString:@"&" intoString:&filename];
			if(filename!=nil)
				{
				[flashVars setObject:[filename stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding] forKey:sVideoFilenameKey];
				}
			}
		[scan setScanLocation:0];
		[scan scanUpToString:@"thumbnailUrl=" intoString:NULL];
		if([scan scanString:@"thumbnailUrl=" intoString:NULL])
			{
			[scan scanUpToString:@"&" intoString:&thumbnail];
			if(thumbnail!=nil)
				{
				previewURL = [NSURL URLWithString:[thumbnail stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
				}
			}
		}

	if(videoID!=nil) { [flashVars setObject:videoID forKey:sVideoIDKey]; }
	
	return previewURL;
}

- (NSURL *)downloadURLForSrc:(NSURL *)src andFlashVars:(NSMutableDictionary *)flashVars
{
	if(src==nil) { return nil; }
	
	NSURL * downloadURL = nil;
	NSString * domain = [self domainForSrc:src];
	
	if([domain isEqualToString:@"youtube.com"] || [domain isEqualToString:@"ytimg.com"])
		{
		NSString * videoHash = [flashVars objectForKey:@"t"];
		if(videoHash==nil) { return nil; }
		downloadURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/get_video?fmt=18&video_id=%@&t=%@",
			[flashVars objectForKey:sVideoIDKey],
			videoHash
		]];
		}
	else if([domain isEqualToString:@"xtube.com"])
		{
		NSString * filename = [flashVars objectForKey:sVideoFilenameKey];
		if(filename==nil) { return nil; }
		downloadURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [flashVars objectForKey:@"swfURL"], filename]];
		}
	else if([domain isEqualToString:@"google.com"])
		{
		NSString * filename = [flashVars objectForKey:sVideoFilenameKey];
		if(filename==nil) { return nil; }
		downloadURL = [NSURL URLWithString:filename];
		}
	
	return downloadURL;
}

- (NSURL *)originalURLForSrc:(NSURL *)src andFlashVars:(NSMutableDictionary *)flashVars
{
	NSURL * originalURL = nil;
	NSString * domain = [self domainForSrc:src];
	
	if([domain isEqualToString:@"youtube.com"])
		{
		originalURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@",
			[flashVars objectForKey:sVideoIDKey]
		]];
		}
	
	return originalURL;
}

@end
