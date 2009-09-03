//
//  UCFlashlessView.m
//  Flashless
//
//  Created by Christoph on 13.06.09.
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


#import "UCFlashlessView.h"
#import "UCBlackwhitelist.h"
#import "UCFlashlessServices.h"

#import "PluginView+DOM.m"

static NSString * sShowAllNotification = @"UCFlashlessAllShouldShow";
static NSString * sRemoveAllNotification = @"UCFlashlessAllShouldRemove";

static NSString * sHostKey = @"UCFlashlessHost";

@interface UCFlashlessView (Internal)

- (id)_initWithArguments:(NSDictionary *)arguments;

- (void)_altChanged;

- (void)_drawWithTint:(NSColor *)tint andHalo:(NSColor *)halo inRect:(NSRect)bounds asPlay:(BOOL)play;

- (NSURL *)_srcFromAttributes:(NSDictionary *)attributes withBaseURL:(NSURL *)baseURL;
- (NSMutableDictionary *)_flashVarsFromAttributes:(NSDictionary *)attributes;

- (NSMenu *)_prepareMenu;
- (void)_writeToPasteboard:(NSURL *)url;

- (void)blacklistConfirmDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

@end

@implementation UCFlashlessView (Internal)

- (id)_initWithArguments:(NSDictionary *)newArguments
{
#ifndef TESTAPP // In Test-App the View gets initialized by the Nib
	self=[super initWithFrame:NSZeroRect];
#endif

    if(self)
		{
		_myBundle = [[NSBundle bundleForClass:[self class]] retain];
		
		_element = [[newArguments objectForKey:WebPlugInContainingElementKey] retain];
		_container = [[newArguments objectForKey:WebPlugInContainerKey] retain];
		NSDictionary * attributes = [newArguments objectForKey:WebPlugInAttributesKey];
		
		_src = [[self _srcFromAttributes:attributes withBaseURL:[newArguments objectForKey:WebPlugInBaseURLKey]] copy];
		_flashVars = [[self _flashVarsFromAttributes:attributes] retain];
		
		_mouseDown=NO;
		_mouseInside=NO;
		}
    
    return self;
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
	[menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Remove", nil, _myBundle, @"Remove Menu Title") action:@selector(remove:) keyEquivalent:@""];
	[menu addItem:[NSMenuItem separatorItem]];
	NSMenuItem * allItem = [menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Source", nil, _myBundle, @"Blackwhitelist Submenu Title") action:NULL keyEquivalent:@""];
	if([_src host]!=nil)
		{
		NSMenu * smenu = [[NSMenu alloc] initWithTitle:@"Source"];
		[smenu addItemWithTitle:[_src host] action:NULL keyEquivalent:@""];
		[smenu addItem:[NSMenuItem separatorItem]];
		[smenu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Show All", nil, _myBundle, @"Show All Menu Title") action:@selector(showAll:) keyEquivalent:@""];
		[smenu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Remove All", nil, _myBundle, @"Remove All Menu Title") action:@selector(removeAll:) keyEquivalent:@""];
		[smenu addItem:[NSMenuItem separatorItem]];
		[smenu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Also Show Subsequent", nil, _myBundle, @"Whitelist Menu Title") action:@selector(whitelistFlash:) keyEquivalent:@""];
		[smenu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Also Remove Subsequent...", nil, _myBundle, @"Blacklist Menu Title") action:@selector(blacklistFlash:) keyEquivalent:@""];
		[menu setSubmenu:smenu forItem:allItem];
		[smenu release];
		}
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Copy Source URL", nil, _myBundle, @"Copy Source Menu Title") action:@selector(copySource:) keyEquivalent:@""];
	[menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Copy Preview URL", nil, _myBundle, @"Copy Preview Menu Title") action:@selector(copyPreview:) keyEquivalent:@""];
	[menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Copy Download URL", nil, _myBundle, @"Copy Download Menu Title") action:@selector(copyDownload:) keyEquivalent:@""];
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"About Flashless", nil, _myBundle, @"About Menu Title") action:@selector(showAbout:) keyEquivalent:@""];
	return [menu autorelease];
}

- (void)_writeToPasteboard:(NSURL *)url
{
	NSPasteboard * pb = [NSPasteboard generalPasteboard];
	[pb declareTypes:[NSArray arrayWithObjects:NSURLPboardType, NSStringPboardType, nil] owner:self];
	[url writeToPasteboard:pb];
	[pb setString:[url absoluteString] forType:NSStringPboardType];
}

- (void) blacklistConfirmDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;
{
	[[alert window] orderOut:self];

	if(returnCode==NSAlertFirstButtonReturn)
		{
		[[UCBlackwhitelist sharedBlackwhitelist] blacklistHost:[_src host]];
		[[NSNotificationCenter defaultCenter] postNotificationName:sRemoveAllNotification object:self userInfo:[NSDictionary dictionaryWithObject:[_src host] forKey:sHostKey]];
		}
}

- (void)_altChanged
{
	[self setNeedsDisplay:YES];
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

@end

@implementation UCFlashlessView

// WebPlugInViewFactory protocol
// The principal class of the plug-in bundle must implement this protocol.

+ (NSView *)plugInViewWithArguments:(NSDictionary *)newArguments
{
    return [[[self alloc] _initWithArguments:newArguments] autorelease];
}

- (void) dealloc
{
	[_container release];
	[_element release];

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

- (void)windowDidUpdate:(NSNotification *)aNotification
{
	if(_alternateKeyDown!=(([[NSApp currentEvent] modifierFlags] & NSAlternateKeyMask)==NSAlternateKeyMask))
		{
		_alternateKeyDown=!_alternateKeyDown;
		[self _altChanged];
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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allShouldRemove:) name:sRemoveAllNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allShouldShow:) name:sShowAllNotification object:nil];

	UCFlashlessServices * services = [[UCFlashlessServices alloc] init];

	_siteLabel = [[services labelForSrc:_src] retain];

	_previewURL = [[services previewURLForSrc:_src andFlashVars:_flashVars] retain];
	_downloadURL = [[services downloadURLForSrc:_src andFlashVars:_flashVars] retain];
	_originalURL = [[services originalURLForSrc:_src andFlashVars:_flashVars] retain];

	[services release];
	
	if(_previewURL)
		{
		_previewConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:_previewURL] delegate:self];
		_previewBuf = [[NSMutableData alloc] init];
		}
	[self setNeedsDisplay:YES];
}

- (void)webPlugInDestroy
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_previewConnection cancel];
}

- (void)webPlugInStart
{
	_alternateKeyDown = (([[NSApp currentEvent] modifierFlags] & NSAlternateKeyMask)==NSAlternateKeyMask);
	if(_downloadURL!=nil)
		{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidUpdate:) name:NSWindowDidUpdateNotification object:[self window]];
		}
}

- (void)webPlugInStop
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidUpdateNotification object:[self window]];
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
	[self showAll:self];
}

- (void)blacklistFlash:(id)sender
{
	NSAlert * alert = [[NSAlert alloc] init];
	[alert setMessageText:NSLocalizedStringFromTableInBundle(@"Never show Flash from this source?", nil, _myBundle, @"Blacklist Confirmation Question")];
	[alert setInformativeText:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"All Flash from '%@' will be removed when loading a site, until you restart %@.", nil, _myBundle, @"Blacklist Explanation"), [_src host], [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey]]];
	[alert addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Never Show", nil, _myBundle, @"Blacklist Confirmation Button")];
	[alert addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, _myBundle, @"Blacklist Cancel Button")];
	// FIXME: Crashes on endSelector
	// if we got removed by an remove all notification
	[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(blacklistConfirmDidEnd:returnCode:contextInfo:) contextInfo:nil];
	[alert autorelease];
}

- (void)remove:(id)sender
{
	[self _removeFromContainer];
}

- (void)showAll:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:sShowAllNotification object:self userInfo:[NSDictionary dictionaryWithObject:[_src host] forKey:sHostKey]];
}

- (void)removeAll:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:sRemoveAllNotification object:self userInfo:[NSDictionary dictionaryWithObject:[_src host] forKey:sHostKey]];
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
	[about addButtonWithTitle:@"OK"];
	[about addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Product Site...", nil, _myBundle, @"Product Site Button")];
	if([about runModal]==NSAlertSecondButtonReturn)
		{
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[_myBundle objectForInfoDictionaryKey:@"UCProductSite"]]];
		}
	[about release];
}

#pragma mark -

- (void)allShouldShow:(NSNotification *)notification
{
	NSString * host = [[notification userInfo] objectForKey:sHostKey];
	if([host isEqualToString:[_src host]])
		{
		[self _convertTypesForContainer];
		}
}

- (void)allShouldRemove:(NSNotification *)notification
{
	NSString * host = [[notification userInfo] objectForKey:sHostKey];
	if([host isEqualToString:[_src host]])
		{
		[self performSelector:@selector(_removeFromContainer) withObject:nil afterDelay:0];
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
