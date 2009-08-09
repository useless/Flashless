//
//  UCFlashlessView.m
//  Flashless
//
//  Created by Christoph on 13.06.09.
//  Copyright Useless Coding 2009. All rights reserved.
//

#import "UCFlashlessView.h"

static NSString * sFlashOldMIMEType = @"application/x-shockwave-flash";
static NSString * sFlashNewMIMEType = @"application/futuresplash";

@implementation UCFlashlessView

// WebPlugInViewFactory protocol
// The principal class of the plug-in bundle must implement this protocol.

+ (NSView *)plugInViewWithArguments:(NSDictionary *)newArguments
{
    return [[[self alloc] initWithArguments:newArguments] autorelease];
}

- (id)initWithArguments:(NSDictionary *)newArguments
{
#ifndef TESTAPP // In Test-App the View gets initialized by the Nib
	self=[super init];
#endif

    if(self)
		{
		_myBundle = [[NSBundle bundleForClass:[self class]] retain];
		
		_element = [[newArguments objectForKey:WebPlugInContainingElementKey] retain];
		_container = [[newArguments objectForKey:WebPlugInContainerKey] retain];
		NSDictionary * attributes = [newArguments objectForKey:WebPlugInAttributesKey];
		
		_src = [[self _srcFromAttributes:attributes withBaseURL:[newArguments objectForKey:WebPlugInBaseURLKey]] copy];
		_flashVars = [[self _flashVarsFromAttributes:attributes] retain];
		[self setToolTip:[_src absoluteString]];
		
		_mouseDown=NO;
		_mouseInside=NO;
		}
    
    return self;
}

- (void) dealloc
{
	[_container release];
	[_element release];

	[_services release];

	[_flashVars release];
	[_previewURL release];
	[_downloadURL release];
	[_siteLabel release];
	[_src release];

	[_myBundle release];
	[_previewImage release];
	[_previewBuf release];
	[_previewConnection release];

	[super dealloc];
}

#pragma mark -

- (void)mouseEntered:(NSEvent *)event
{
    _mouseInside=YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)event
{
    _mouseInside=NO;
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)event
{
    _mouseDown=YES;
	_mouseInside=YES;
	
	[self setNeedsDisplay:YES];
	
	// Not supported in 10.4. Workaround?
	_tracking = [[NSTrackingArea alloc] initWithRect:[self bounds] options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow | NSTrackingEnabledDuringMouseDrag owner:self userInfo:nil];
	[self addTrackingArea:_tracking];
}

- (void)mouseUp:(NSEvent *)event
{
	_mouseDown=NO;
	[self display];
	
	[self removeTrackingArea:_tracking];
	[_tracking release];
	_tracking=nil;
		
	if(_mouseInside)
		{
		if(([event modifierFlags]&NSAlternateKeyMask)==NSAlternateKeyMask)
			{
			[self download:self];
			}
		else
			{
			[self _convertTypesForContainer];
			}
		}
}

#pragma mark WebPlugIn informal protocol

- (void)webPlugInInitialize
{
	// if whitelisted show directly
	if([[UCBlackwhitelist sharedBlackwhitelist] isWhiteHost:[_src host]])
		{
		[self _convertTypesForContainer];
		return;
		}
	
	// if blacklisted remove from container after delay
	if([[UCBlackwhitelist sharedBlackwhitelist] isBlackHost:[_src host]])
		{
		[self performSelector:@selector(_removeFromContainer) withObject:nil afterDelay:0];
		return;
		}

	[self setMenu:[self _prepareMenu]];

	_services = [[UCFlashlessServices alloc] init];

	_siteLabel = [[_services labelForSrc:_src] retain];

	_previewURL = [[_services previewURLForSrc:_src andFlashVars:_flashVars] retain];
	_downloadURL = [[_services downloadURLForSrc:_src andFlashVars:_flashVars] retain];
	_originalURL = [[_services originalURLForSrc:_src andFlashVars:_flashVars] retain];
	
	if(_previewURL)
		{
		_previewConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:_previewURL] delegate:self];
		_previewBuf = [[NSMutableData alloc] init];
		}
	[self setNeedsDisplay:YES];
}

- (void)webPlugInDestroy
{
	[_previewConnection cancel];
}

#pragma mark Draw

- (void)drawRect:(NSRect)rect
{
	const float kXOff = 10;
	const float kYOff = 5;

	NSRect bounds = [self bounds];
	
	NSBezierPath * shape;
	NSColor * tint;
	NSColor * halo;
	NSPoint loc;
	NSDictionary * atts = nil;
	NSSize size;
	
	shape = [NSBezierPath bezierPathWithRect:bounds];

	if(_mouseDown && _mouseInside)
		{
		tint = [NSColor colorWithCalibratedWhite:0.75 alpha:1.0];
		halo = [NSColor colorWithCalibratedWhite:0.25 alpha:0.5];
		}
	else
		{
		tint = [NSColor whiteColor];
		halo = [NSColor colorWithCalibratedWhite:0.25 alpha:0.25];
		[[NSColor colorWithCalibratedWhite:1.0 alpha:0.25] set];
		[shape fill];
		}
	
	if(_previewImage)
		{
		[_previewImage drawInRect:bounds fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
		}

	if(_siteLabel!=nil || _downloadURL!=nil)
		{
		atts = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSFont systemFontOfSize:16], NSFontAttributeName,
			[NSNumber numberWithFloat:17], NSStrokeWidthAttributeName,
			[NSNumber numberWithFloat:-0.5], NSKernAttributeName,
			halo, NSStrokeColorAttributeName,
			halo, NSForegroundColorAttributeName,
		nil];
		NSString * arrow = @"\u2b07";
		
		if(_siteLabel!=nil)
			{
			size = [_siteLabel sizeWithAttributes:atts];
			loc = NSMakePoint(bounds.size.width - size.width - kXOff, kYOff);
			[_siteLabel drawAtPoint:loc withAttributes:atts];
			}
		if(_downloadURL!=nil)
			{
			[arrow drawAtPoint:NSMakePoint(kXOff, kYOff) withAttributes:atts];
			}

		atts = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSFont systemFontOfSize:16], NSFontAttributeName,
			[NSNumber numberWithFloat:-0.5], NSKernAttributeName,
			tint, NSForegroundColorAttributeName,
		nil];
		if(_siteLabel!=nil)
			{
			[_siteLabel drawAtPoint:loc withAttributes:atts];
			}
		if(_downloadURL!=nil)
			{
			[arrow drawAtPoint:NSMakePoint(kXOff, kYOff) withAttributes:atts];
			}
		}

	if(_mouseDown && _mouseInside)
		{
		[[NSColor colorWithCalibratedWhite:0.25 alpha:0.25] set];
		[shape fill];
		}
	
	[[NSColor colorWithCalibratedWhite:0.0 alpha:0.5] set];
	[shape stroke];

	[self _drawWithTint:tint andHalo:halo inRect:bounds asPlay:(_siteLabel!=nil)];
}

- (void)_drawWithTint:(NSColor *)tint andHalo:(NSColor *)halo inRect:(NSRect)bounds asPlay:(BOOL)play;
{
	const float kMar = 3;

	NSSize size = play?NSMakeSize(48, 48):NSMakeSize(32, 32);

	if(bounds.size.width>size.width+3*kMar && bounds.size.height>size.height+3*kMar)
		{
		NSBezierPath * shape;
				
		shape = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect((bounds.size.width-size.width)/2-kMar, (bounds.size.height-size.height)/1.8-kMar, size.width+2*kMar, size.height+2*kMar)];
		[halo set];
		[shape fill];
		
		[tint set];
		shape = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect((bounds.size.width-size.width)/2, (bounds.size.height-size.height)/1.8, size.width, size.height)];
		[shape setLineWidth:3];
		[shape stroke];

		shape = [NSBezierPath bezierPath];

		if(play)
			{
			[shape moveToPoint:NSMakePoint(bounds.size.width/2+size.width/3, (bounds.size.height-size.height)/1.8+size.height/2)];
			[shape lineToPoint:NSMakePoint(bounds.size.width/2-size.width*0.2, (bounds.size.height-size.height)/1.8+size.height*0.8)];
			[shape lineToPoint:NSMakePoint(bounds.size.width/2-size.width*0.2, (bounds.size.height-size.height)/1.8+size.height*0.2)];
			}
		else
			{
			[shape moveToPoint:NSMakePoint(bounds.size.width/2-size.width*0.13, (bounds.size.height-size.height)/1.8+size.height*0.1)];
			[shape lineToPoint:NSMakePoint(bounds.size.width/2-size.width*0.03, (bounds.size.height-size.height)/1.8+size.height*0.49)];
			[shape lineToPoint:NSMakePoint(bounds.size.width/2-size.width*0.21, (bounds.size.height-size.height)/1.8+size.height*0.45)];
			[shape lineToPoint:NSMakePoint(bounds.size.width/2-size.width*0.09, (bounds.size.height-size.height)/1.8+size.height)];
			[shape lineToPoint:NSMakePoint(bounds.size.width/2+size.width*0.2, (bounds.size.height-size.height)/1.8+size.height)];
			[shape lineToPoint:NSMakePoint(bounds.size.width/2+size.width*0.05, (bounds.size.height-size.height)/1.8+size.height*0.61)];
			[shape lineToPoint:NSMakePoint(bounds.size.width/2+size.width/4, (bounds.size.height-size.height)/1.8+size.height*0.65)];
			}

		[shape fill];
		}
}

#pragma mark Internal

- (void)_convertTypesForElement:(DOMElement *)element
{
    NSString *type = [element getAttribute:@"type"];

    if([type isEqualToString:sFlashOldMIMEType] || [type length]==0)
	{
        [element setAttribute:@"type" value:sFlashNewMIMEType];
    }
}

- (void)_convertTypesForContainer
{
	DOMElement * newElement = (DOMElement *)[_element cloneNode:YES];
	DOMNodeList * nodeList;
	
	unsigned i;
	
	[self _convertTypesForElement:newElement];
	
	nodeList = [newElement getElementsByTagName:@"object"];
	for (i=0; i<nodeList.length; i++)
		{
		[self _convertTypesForElement:(DOMElement *)[nodeList item:i]];
		}

	nodeList = [newElement getElementsByTagName:@"embed"];
	for (i=0; i<nodeList.length; i++)
		{
		[self _convertTypesForElement:(DOMElement *)[nodeList item:i]];
		}
	
	[[self retain] autorelease];
	
	[_element.parentNode replaceChild:newElement oldChild:_element];
	
	[_element release];
	_element = nil;
}

- (void)_removeFromContainer
{	
	[[self retain] autorelease];
	
	[_element.parentNode removeChild:_element];
	
	[_element release];
	_element = nil;
}

#pragma mark -

- (NSURL *)_srcFromAttributes:(NSDictionary *)attributes withBaseURL:(NSURL *)baseURL
{
	NSString * srcAttribute = [attributes objectForKey:@"src"];

	if(srcAttribute==nil)
		{
		srcAttribute = [attributes objectForKey:@"data"];
		}
	if(srcAttribute==nil)
		{
		srcAttribute = [attributes objectForKey:@"movie"];
		}
	if(srcAttribute==nil)
		{
		return baseURL;
		}
	else
		{
		return [NSURL URLWithString:[srcAttribute stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] relativeToURL:baseURL];
		}
}

- (NSMutableDictionary *)_flashVarsFromAttributes:(NSDictionary *)attributes
{
	NSString * flashVars = [attributes objectForKey:@"flashvars"];

	NSArray * args = [flashVars componentsSeparatedByString:@"&"];
	NSUInteger count = [args count];
	NSMutableDictionary * vars = [NSMutableDictionary dictionaryWithCapacity:count+1];
	
	NSUInteger i;
	NSString * arg;
	NSRange sep;
	for(i=0; i<count; i++)
		{
		arg = (NSString *)[args objectAtIndex:i];
		sep=[arg rangeOfString:@"="];
		if(sep.location != NSNotFound)
			{
			[vars setObject:[arg substringFromIndex:NSMaxRange(sep)] forKey:[arg substringToIndex:sep.location]];
			}		
		}
	
	return vars;
}

- (NSMenu *)_prepareMenu
{
	NSMenu * menu = [[NSMenu alloc] init];
	[menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Show Flash", nil, _myBundle, @"Show Menu Title") action:@selector(loadFlash:) keyEquivalent:@""];
	[menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Open Original", nil, _myBundle, @"Original Menu Title") action:@selector(openOriginal:) keyEquivalent:@""];
	[menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Download Video", nil, _myBundle, @"Download Menu Title") action:@selector(download:) keyEquivalent:@""];
	[menu addItem:[NSMenuItem separatorItem]];
	if([_src host]!=nil)
		{
		[menu addItemWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Always Show from '%@'", nil, _myBundle, @"Whitelist Menu Title"), [_src host]] action:@selector(whitelistFlash:) keyEquivalent:@""];
		[menu addItemWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Never Show from '%@'...", nil, _myBundle, @"Blacklist Menu Title"), [_src host]] action:@selector(blacklistFlash:) keyEquivalent:@""];
		}
	else
		{
		[menu addItemWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Always Show", nil, _myBundle, @"Nil Whitelist Menu Title")] action:NULL keyEquivalent:@""];		
		[menu addItemWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Never Show...", nil, _myBundle, @"Nil Blacklist Menu Title")] action:NULL keyEquivalent:@""];		
		}
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Remove", nil, _myBundle, @"Remove Menu Title") action:@selector(remove:) keyEquivalent:@""];
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Copy Source URL", nil, _myBundle, @"Copy Source Menu Title") action:@selector(copySource:) keyEquivalent:@""];
	[menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Copy Preview URL", nil, _myBundle, @"Copy Preview Menu Title") action:@selector(copyPreview:) keyEquivalent:@""];
	[menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Copy Download URL", nil, _myBundle, @"Copy Download Menu Title") action:@selector(copyDownload:) keyEquivalent:@""];
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"About Flashless", nil, _myBundle, @"About Menu Title") action:@selector(showAbout:) keyEquivalent:@""];
//	[menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Settings...", nil, _myBundle, @"Settings Menu Title") action:@selector(showSettings:) keyEquivalent:@""];
	return [menu autorelease];
}

- (void)_writeToPasteboard:(NSURL *)url
{
	NSPasteboard * pb = [NSPasteboard generalPasteboard];
	[pb declareTypes:[NSArray arrayWithObjects:NSURLPboardType, NSStringPboardType, nil] owner:self];
	[url writeToPasteboard:pb];
	[pb setString:[url absoluteString] forType:NSStringPboardType];
}

#pragma mark URLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_previewBuf appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	_previewImage = [[NSImage alloc] initWithData:_previewBuf];
	[self setNeedsDisplay:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
}

#pragma mark Actions

- (void)loadFlash:(id)sender
{
	[self _convertTypesForContainer];
}

- (void)openOriginal:(id)sender
{
	if(_originalURL)
		{
		[[NSWorkspace sharedWorkspace] openURL:_originalURL];
		}
}

- (void)download:(id)sender
{
	if(_downloadURL)
		{
		if([_container respondsToSelector:@selector(webPlugInContainerLoadRequest:inFrame:)])
			{
			[_container webPlugInContainerLoadRequest:[NSURLRequest requestWithURL:_downloadURL] inFrame:nil];
			}
		else
			{
			[[NSWorkspace sharedWorkspace] openURL:_downloadURL];
			}
		}
}

- (void)whitelistFlash:(id)sender
{
	[[UCBlackwhitelist sharedBlackwhitelist] whitelistHost:[_src host]];
	[self _convertTypesForContainer];
}

- (void)blacklistFlash:(id)sender
{
	NSAlert * confirm = [[NSAlert alloc] init];
	[confirm setMessageText:NSLocalizedStringFromTableInBundle(@"Remove all?", nil, _myBundle, @"Blacklist Confirm Question")];
	[confirm setInformativeText:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Remove from '%@'", nil, _myBundle, @"Blacklist Confirm Info"), [_src host]]];
	[confirm addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Remove", nil, _myBundle, @"Blacklist Confirm Button")];
	[confirm addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, _myBundle, @"Blacklist Confirm Cancel")];

	[confirm beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(confirmDidEnd:returnCode:contextInfo:) contextInfo:NULL];
	[confirm release];
}

- (void)remove:(id)sender
{
	[self _removeFromContainer];
}

- (void)copySource:(id)sender
{
	[self _writeToPasteboard:_src];
}

- (void)copyPreview:(id)sender
{
	[self _writeToPasteboard:_previewURL];
}

- (void)copyDownload:(id)sender
{
	[self _writeToPasteboard:_downloadURL];
}

- (void)showAbout:(id)sender
{
	NSAlert * about = [[NSAlert alloc] init];
	[about setMessageText:[_myBundle objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey]];
	[about setInformativeText:[NSString stringWithFormat:@"%@\nVersion %@ (%@) (%@)\n\n%@",
		NSLocalizedStringFromTableInBundle(@"A plug-in to block Flash.", nil, _myBundle, @"About Desription"),
		[_myBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
		[_myBundle objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey],
		[_myBundle objectForInfoDictionaryKey:@"WebPluginDescription"],
		[_myBundle objectForInfoDictionaryKey:@"NSHumanReadableCopyright"]
		]];
	[about runModal];
	[about release];
}

#pragma mark -

- (void)confirmDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if(returnCode==NSAlertFirstButtonReturn)
		{
		[[UCBlackwhitelist sharedBlackwhitelist] blacklistHost:[_src host]];
		[self _removeFromContainer];
		}
}

#pragma mark -

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
	if([anItem action]==@selector(openOriginal:))
		{
		return _originalURL!=nil;
		}
	else if([anItem action]==@selector(download:) || [anItem action]==@selector(copyDownload:))
		{
		return _downloadURL!=nil;
		}
	else if([anItem action]==@selector(copyPreview:))
		{
		return _previewURL!=nil;
		}
	
	return YES;
}


@end
