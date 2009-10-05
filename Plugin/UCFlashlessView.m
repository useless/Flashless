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

#import "PluginView+DOM.m"

static NSString * sPlayAllNotification = @"UCFlashlessAllShouldPlay";
static NSString * sRemoveAllNotification = @"UCFlashlessAllShouldRemove";

static NSString * sHostKey = @"UCFlashlessHost";

@interface UCFlashlessView (Internal)

- (id)_initWithArguments:(NSDictionary *)arguments;

- (void)_modifiersChanged;
- (UCFlashIconType)_playIcon;

- (void)_drawWithTint:(NSColor *)tint andHalo:(NSColor *)halo inRect:(NSRect)bounds asIcon:(UCFlashIconType)icon;

- (NSURL *)_srcFromAttributes:(NSDictionary *)attributes withBaseURL:(NSURL *)baseURL;
- (NSMutableDictionary *)_flashVarsFromAttributes:(NSDictionary *)attributes;

- (NSMenu *)_prepareMenu;
- (void)_writeToPasteboard:(NSURL *)url;

- (void)blacklistConfirmDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (void)service:(UCFlashlessService *)service didFindPreview:(NSURL *)preview;
- (void)service:(UCFlashlessService *)service didFindDownload:(NSURL *)download;
- (void)service:(UCFlashlessService *)service didFindOriginal:(NSURL *)original;
- (void)service:(UCFlashlessService *)service didReceivePreviewData:(NSData *)data;

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
		_sheetOpen=NO;
		_shouldDownloadNow=NO;
		}
    
    return self;
}

- (void)_drawWithTint:(NSColor *)tint andHalo:(NSColor *)halo inRect:(NSRect)bounds asIcon:(UCFlashIconType)icon
{
	const float kMar = 3;

	NSSize size = (icon==UCDefaultFlashIcon)?NSMakeSize(32, 32):NSMakeSize(48, 48);

	if(bounds.size.width>size.width+3*kMar && bounds.size.height>size.height+3*kMar)
		{
		NSBezierPath * shape;

		shape = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect((bounds.size.width-size.width)/2-kMar, (bounds.size.height-size.height)/1.8-kMar, size.width+2*kMar, size.height+2*kMar)];
		[halo set];
		[shape fill];

		[tint set];
		shape = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect((bounds.size.width-size.width)/2, (bounds.size.height-size.height)/1.8, size.width, size.height)];
		[shape setLineWidth:kMar];
		[shape stroke];

		shape = [NSBezierPath bezierPath];

		switch(icon)
			{
			case UCPlayFlashIcon:
				[shape moveToPoint:NSMakePoint(bounds.size.width/2+size.width/3, (bounds.size.height-size.height)/1.8+size.height/2)];
				[shape lineToPoint:NSMakePoint(bounds.size.width/2-size.width*0.2, (bounds.size.height-size.height)/1.8+size.height*0.8)];
				[shape lineToPoint:NSMakePoint(bounds.size.width/2-size.width*0.2, (bounds.size.height-size.height)/1.8+size.height*0.2)];
				[shape fill];
				break;
			case UCDirectPlayFlashIcon:
				[NSGraphicsContext saveGraphicsState];
					{
					NSShadow * shadow = [[NSShadow alloc] init];
					[shadow setShadowColor:[NSColor shadowColor]];
					[shadow setShadowOffset:NSMakeSize(0, -0.75*kMar)];
					[shadow setShadowBlurRadius:1.5*kMar];
					[shadow set];
					[shadow release];
					[shape moveToPoint:NSMakePoint(bounds.size.width/2+size.width/3, (bounds.size.height-size.height)/1.8+size.height/2)];
					[shape lineToPoint:NSMakePoint(bounds.size.width/2-size.width*0.2, (bounds.size.height-size.height)/1.8+size.height*0.8)];
					[shape lineToPoint:NSMakePoint(bounds.size.width/2-size.width*0.2, (bounds.size.height-size.height)/1.8+size.height*0.2)];
					[shape fill];
					NSGradient * gradient = [[NSGradient alloc] initWithStartingColor:[NSColor highlightColor] endingColor:[NSColor keyboardFocusIndicatorColor]];
					[gradient drawInBezierPath:shape angle:270];
					[gradient release];
					}
				[NSGraphicsContext restoreGraphicsState];
				[shape closePath];
				[shape setLineWidth:kMar];
				[shape stroke];
				break;
			case UCDownloadFlashIcon:
				[shape moveToPoint:NSMakePoint(bounds.size.width/2-size.width*0.15, (bounds.size.height-size.height)/1.8+size.height*0.8)];
				[shape lineToPoint:NSMakePoint(bounds.size.width/2-size.width*0.15, (bounds.size.height-size.height)/1.8+size.height*0.45)];						
				[shape lineToPoint:NSMakePoint(bounds.size.width/2-size.width*0.3, (bounds.size.height-size.height)/1.8+size.height*0.45)];						
				[shape lineToPoint:NSMakePoint(bounds.size.width/2, (bounds.size.height-size.height)/1.8+size.height*0.15)];						
				[shape lineToPoint:NSMakePoint(bounds.size.width/2+size.width*0.3, (bounds.size.height-size.height)/1.8+size.height*0.45)];						
				[shape lineToPoint:NSMakePoint(bounds.size.width/2+size.width*0.15, (bounds.size.height-size.height)/1.8+size.height*0.45)];						
				[shape lineToPoint:NSMakePoint(bounds.size.width/2+size.width*0.15, (bounds.size.height-size.height)/1.8+size.height*0.8)];						
				[shape fill];
				break;
			case UCTryDownloadFlashIcon:
				[shape moveToPoint:NSMakePoint(bounds.size.width/2, (bounds.size.height-size.height)/1.8+size.height*0.15)];						
				[shape lineToPoint:NSMakePoint(bounds.size.width/2+size.width*0.3, (bounds.size.height-size.height)/1.8+size.height*0.45)];						
				[shape lineToPoint:NSMakePoint(bounds.size.width/2+size.width*0.15, (bounds.size.height-size.height)/1.8+size.height*0.45)];						
				[shape lineToPoint:NSMakePoint(bounds.size.width/2+size.width*0.15, (bounds.size.height-size.height)/1.8+size.height*0.8)];						
				[shape lineToPoint:NSMakePoint(bounds.size.width/2-size.width*0.15, (bounds.size.height-size.height)/1.8+size.height*0.8)];
				[shape lineToPoint:NSMakePoint(bounds.size.width/2-size.width*0.15, (bounds.size.height-size.height)/1.8+size.height*0.45)];						
				[shape lineToPoint:NSMakePoint(bounds.size.width/2-size.width*0.3, (bounds.size.height-size.height)/1.8+size.height*0.45)];						
				[shape closePath];
				[shape setLineWidth:kMar];
					{
					CGFloat pattern[2];
					pattern[0] = 2*kMar;
					pattern[1] = kMar;
					[shape setLineDash:pattern count:2 phase:1.0];
					}
				[shape stroke];
				break;
			case UCOriginalFlashIcon:
				[shape moveToPoint:NSMakePoint(bounds.size.width/2+size.width*0, (bounds.size.height-size.height)/1.8+size.height*0.15)];
				[shape curveToPoint:NSMakePoint(bounds.size.width/2+size.width*0+0, (bounds.size.height-size.height)/1.8+size.height*0.77) controlPoint1:NSMakePoint(bounds.size.width/2+size.width*0.45, (bounds.size.height-size.height)/1.8+size.height*0.15) controlPoint2:NSMakePoint(bounds.size.width/2+size.width*0.45, (bounds.size.height-size.height)/1.8+size.height*0.77)];
				[shape lineToPoint:NSMakePoint(bounds.size.width/2+size.width*0+0, (bounds.size.height-size.height)/1.8+size.height*0.9)];
				[shape lineToPoint:NSMakePoint(bounds.size.width/2-size.width*0.3, (bounds.size.height-size.height)/1.8+size.height*0.65)];
				[shape lineToPoint:NSMakePoint(bounds.size.width/2+size.width*0+0, (bounds.size.height-size.height)/1.8+size.height*0.4)];
				[shape lineToPoint:NSMakePoint(bounds.size.width/2+size.width*0+0, (bounds.size.height-size.height)/1.8+size.height*0.55)];
				[shape curveToPoint:NSMakePoint(bounds.size.width/2+size.width*0, (bounds.size.height-size.height)/1.8+size.height*0.15) controlPoint1:NSMakePoint(bounds.size.width/2+size.width*0.33, (bounds.size.height-size.height)/1.8+size.height*0.55) controlPoint2:NSMakePoint(bounds.size.width/2+size.width*0.33, (bounds.size.height-size.height)/1.8+size.height*0.15)];
				[shape fill];
				break;
			default:
				[shape moveToPoint:NSMakePoint(bounds.size.width/2-size.width*0.13, (bounds.size.height-size.height)/1.8+size.height*0.1)];
				[shape lineToPoint:NSMakePoint(bounds.size.width/2-size.width*0.03, (bounds.size.height-size.height)/1.8+size.height*0.49)];
				[shape lineToPoint:NSMakePoint(bounds.size.width/2-size.width*0.21, (bounds.size.height-size.height)/1.8+size.height*0.45)];
				[shape lineToPoint:NSMakePoint(bounds.size.width/2-size.width*0.09, (bounds.size.height-size.height)/1.8+size.height)];
				[shape lineToPoint:NSMakePoint(bounds.size.width/2+size.width*0.2, (bounds.size.height-size.height)/1.8+size.height)];
				[shape lineToPoint:NSMakePoint(bounds.size.width/2+size.width*0.05, (bounds.size.height-size.height)/1.8+size.height*0.61)];
				[shape lineToPoint:NSMakePoint(bounds.size.width/2+size.width/4, (bounds.size.height-size.height)/1.8+size.height*0.65)];
				[shape fill];
				break;
			}
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
		return [NSURL URLWithString:[srcAttribute stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] relativeToURL:baseURL];
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
	NSMenuItem * lastItem;
	[menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Play", nil, _myBundle, @"Play Menu Title") action:@selector(playFlash:) keyEquivalent:@""];
	[menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Play Video", nil, _myBundle, @"Play Video Menu Title") action:@selector(playDirectly:) keyEquivalent:@""];
	if(_siteLabel!=nil)
		{
		[menu addItemWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Show At '%@'", nil, _myBundle, @"Original Menu Title"), _siteLabel] action:@selector(openOriginal:) keyEquivalent:@""];
		lastItem = [menu addItemWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Show At '%@' in New Window", nil, _myBundle, @"Original In New Window Menu Title"), _siteLabel] action:@selector(openOriginalWindow:) keyEquivalent:@""];
		[lastItem setKeyEquivalentModifierMask:UCNewWindowModifiers];
		[lastItem setAlternate:YES];
		}
	else
		{
		[menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Show Original", nil, _myBundle, @"Original Nil Menu Title") action:@selector(openOriginal:) keyEquivalent:@""];
		}
	[menu addItemWithTitle:@"Video" action:@selector(download:) keyEquivalent:@""];
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Remove", nil, _myBundle, @"Remove Menu Title") action:@selector(remove:) keyEquivalent:@""];
	[menu addItem:[NSMenuItem separatorItem]];
	lastItem = [menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Source", nil, _myBundle, @"Blackwhitelist Submenu Title") action:NULL keyEquivalent:@""];
	if([_src host]!=nil)
		{
		NSMenu * smenu = [[NSMenu alloc] initWithTitle:@"Source"];
		[smenu addItemWithTitle:[_src host] action:NULL keyEquivalent:@""];
		[smenu addItem:[NSMenuItem separatorItem]];
		[smenu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Play All", nil, _myBundle, @"Play All Menu Title") action:@selector(playAll:) keyEquivalent:@""];
		[smenu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Remove All", nil, _myBundle, @"Remove All Menu Title") action:@selector(removeAll:) keyEquivalent:@""];
		[smenu addItem:[NSMenuItem separatorItem]];
		[smenu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Auto-Play", nil, _myBundle, @"Whitelist Menu Title") action:@selector(whitelistFlash:) keyEquivalent:@""];
		[smenu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Auto-Remove...", nil, _myBundle, @"Blacklist Menu Title") action:@selector(blacklistFlash:) keyEquivalent:@""];
		[menu setSubmenu:smenu forItem:lastItem];
		[smenu release];
		}
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Copy Source URL", nil, _myBundle, @"Copy Source Menu Title") action:@selector(copySource:) keyEquivalent:@""];
	[menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Copy Preview URL", nil, _myBundle, @"Copy Preview Menu Title") action:@selector(copyPreview:) keyEquivalent:@""];
	[menu addItemWithTitle:NSLocalizedStringFromTableInBundle(@"Copy Original URL", nil, _myBundle, @"Copy Original Menu Title") action:@selector(copyOriginal:) keyEquivalent:@""];
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
	_sheetOpen=NO;

	if(returnCode==NSAlertFirstButtonReturn)
		{
		[[UCBlackwhitelist sharedBlackwhitelist] blacklistHost:[_src host]];
		[[NSNotificationCenter defaultCenter] postNotificationName:sRemoveAllNotification object:self userInfo:[NSDictionary dictionaryWithObject:[_src host] forKey:sHostKey]];
		}
}

- (void)_modifiersChanged
{
	[self setNeedsDisplay:YES];
}

- (UCFlashIconType)_playIcon
{
	if(_originalURL!=nil && (_modifierFlags&UCOriginalModifiers)==UCOriginalModifiers)
		{
		return UCOriginalFlashIcon;
		}
	if(_downloadURL!=nil && _canPlayDirectly && (_modifierFlags&UCDirectPlayModifiers)==UCDirectPlayModifiers)
		{
		return UCDirectPlayFlashIcon;
		}
	if(_downloadURL!=nil && (_modifierFlags&UCDownloadModifiers)==UCDownloadModifiers)
		{
		return UCDownloadFlashIcon;
		}
	if(_canFindDownload && (_modifierFlags&UCDownloadModifiers)==UCDownloadModifiers)
		{
		return UCTryDownloadFlashIcon;
		}
	if(_siteLabel!=nil)
		{
		return UCPlayFlashIcon;
		}
	return UCDefaultFlashIcon;
}

#pragma mark Service Delegate

- (void)service:(UCFlashlessService *)service didFindPreview:(NSURL *)preview
{
	[_previewURL release];
	_previewURL = [preview retain];
}

- (void)service:(UCFlashlessService *)service didFindDownload:(NSURL *)download
{
	[_downloadURL release];
	_downloadURL = [download retain];
	if(_shouldDownloadNow)
		{
		[self download:self];
		}
}

- (void)service:(UCFlashlessService *)service didFindOriginal:(NSURL *)original
{
	[_originalURL release];
	_originalURL = [original retain];
}

- (void)service:(UCFlashlessService *)service didReceivePreviewData:(NSData *)data
{
	_previewImage = [[NSImage alloc] initWithData:data];
	[self setNeedsDisplay:YES];
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
	[self webPlugInDestroy];
	[_container release];
	[_element release];

	[_flashVars release];
	[_previewURL release];
	[_downloadURL release];
	[_siteLabel release];
	[_src release];
	[_service release];

	[_myBundle release];
	[_previewImage release];
	[_tracking release];

	[super dealloc];
}

#pragma mark -

- (void)mouseEntered:(NSEvent *)event
{
    _mouseInside=YES;
	if(_mouseDown || !MODIFIERS_EQUAL([event modifierFlags],_modifierFlags))
		{
		_modifierFlags = [event modifierFlags];
		[self setNeedsDisplay:YES];
		}
}

- (void)mouseExited:(NSEvent *)event
{
    _mouseInside=NO;
    if(_mouseDown || !MODIFIERS_EQUAL(_modifierFlags,0))
		{
		_modifierFlags=0;
		[self setNeedsDisplay:YES];
		}
}

- (void)mouseDown:(NSEvent *)event
{
    _mouseDown=YES;
	_mouseInside=YES;
	
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event
{
	_mouseDown=NO;
	[self display];

	if(_mouseInside)
		{
		if(([event modifierFlags]&UCOriginalModifiers)==UCOriginalModifiers)
			{
			if(([event modifierFlags]&UCNewWindowModifiers)==UCNewWindowModifiers)
				{
				[self openOriginalWindow:self];
				}
			else
				{
				[self openOriginal:self];
				}
			}
		else if(([event modifierFlags]&UCDirectPlayModifiers)==UCDirectPlayModifiers)
			{
			[self playDirectly:self];
			}
		else if(([event modifierFlags]&UCDownloadModifiers)==UCDownloadModifiers)
			{
			[self download:self];
			}
		else
			{
			[self playFlash:self];
			}
		}
}

- (void)windowDidUpdate:(NSNotification *)aNotification
{
	if(_mouseInside && !MODIFIERS_EQUAL(_modifierFlags, [[NSApp currentEvent] modifierFlags]))
		{
		_modifierFlags=[[NSApp currentEvent] modifierFlags];
		[self _modifiersChanged];
		}
}

#pragma mark WebPlugIn informal protocol

- (void)webPlugInInitialize
{
	// if whitelisted show directly
	if([[UCBlackwhitelist sharedBlackwhitelist] isWhiteHost:[_src host]])
		{
		[self _convertToFlash];
		return;
		}
	
	// if blacklisted remove from container after delay
	if([[UCBlackwhitelist sharedBlackwhitelist] isBlackHost:[_src host]])
		{
		[self performSelector:@selector(_removeFromContainer) withObject:nil afterDelay:0];
		return;
		}

	_service = [[UCFlashlessService alloc] initWithSrc:_src andFlashVars:_flashVars];
	[_service startWithDelegate:self];

	_siteLabel = [[_service label] retain];
	_canFindDownload = [_service canFindDownload];
	_canPlayDirectly = [_service canPlayDirectly];

	[self setMenu:[self _prepareMenu]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allShouldRemove:) name:sRemoveAllNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allShouldPlay:) name:sPlayAllNotification object:nil];

	_mouseInside=YES;
	_tracking = [[NSTrackingArea alloc] initWithRect:[self bounds] options:NSTrackingMouseEnteredAndExited|NSTrackingActiveInKeyWindow|NSTrackingEnabledDuringMouseDrag|NSTrackingInVisibleRect|NSTrackingAssumeInside owner:self userInfo:nil];
	[self addTrackingArea:_tracking];

	[self setNeedsDisplay:YES];
}

- (void)webPlugInDestroy
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_service cancel];
	[self removeTrackingArea:_tracking];
}

- (void)webPlugInStart
{
	_modifierFlags = [[NSApp currentEvent] modifierFlags];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidUpdate:) name:NSWindowDidUpdateNotification object:[self window]];
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

	tint = [NSColor whiteColor];
	halo = [NSColor colorWithCalibratedWhite:0.0 alpha:0.25];

	if(!_mouseDown || !_mouseInside)
		{
		[[NSColor colorWithCalibratedWhite:1.0 alpha:0.25] set];
		[shape fill];
		}
	
	if(_previewImage)
		{
		[_previewImage drawInRect:bounds fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
		}

	if(_siteLabel!=nil)
		{
		atts = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSFont systemFontOfSize:16], NSFontAttributeName,
			[NSNumber numberWithFloat:17], NSStrokeWidthAttributeName,
			[NSNumber numberWithFloat:-0.5], NSKernAttributeName,
			halo, NSStrokeColorAttributeName,
			halo, NSForegroundColorAttributeName,
		nil];
		
		size = [_siteLabel sizeWithAttributes:atts];
		loc = NSMakePoint(bounds.size.width - size.width - kXOff, kYOff);
		[_siteLabel drawAtPoint:loc withAttributes:atts];

		atts = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSFont systemFontOfSize:16], NSFontAttributeName,
			[NSNumber numberWithFloat:-0.5], NSKernAttributeName,
			tint, NSForegroundColorAttributeName,
		nil];
		[_siteLabel drawAtPoint:loc withAttributes:atts];
		}

	[self _drawWithTint:tint andHalo:halo inRect:bounds asIcon:[self _playIcon]];

	if(_mouseDown && _mouseInside)
		{
		[[NSColor colorWithCalibratedWhite:0.15 alpha:0.3] set];
		[shape fill];
		}
	
	[[NSColor colorWithCalibratedWhite:0.0 alpha:0.5] set];
	[shape stroke];
}

#pragma mark Actions

- (void)playFlash:(id)sender
{
	[self _convertToFlash];
}

- (void)playDirectly:(id)sender
{
	if(_canPlayDirectly && (_downloadURL!=nil))
		{
		[self _convertToVideo];
		}
}

- (void)openOriginal:(id)sender
{
	if(_originalURL)
		{
		if([_container respondsToSelector:@selector(webPlugInContainerLoadRequest:inFrame:)])
			{
			[_container webPlugInContainerLoadRequest:[NSURLRequest requestWithURL:_originalURL] inFrame:nil];
			}
		else
			{
			[[NSWorkspace sharedWorkspace] openURL:_originalURL];
			}
		}
}

- (void)openOriginalWindow:(id)sender
{
	if(_originalURL)
		{
		if([_container respondsToSelector:@selector(webPlugInContainerLoadRequest:inFrame:)])
			{
			[_container webPlugInContainerLoadRequest:[NSURLRequest requestWithURL:_originalURL] inFrame:@"_blank"];
			}
		else
			{
			[[NSWorkspace sharedWorkspace] openURL:_originalURL];
			}
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
	else if(_canFindDownload)
		{
		_shouldDownloadNow=YES;
		[_service findDownloadURL];
		}
}

- (void)whitelistFlash:(id)sender
{
	[[UCBlackwhitelist sharedBlackwhitelist] whitelistHost:[_src host]];
	[self playAll:self];
}

- (void)blacklistFlash:(id)sender
{
	NSAlert * alert = [[NSAlert alloc] init];
	[alert setMessageText:NSLocalizedStringFromTableInBundle(@"Automatically remove all Flash from this source?", nil, _myBundle, @"Blacklist Confirmation Question")];
	[alert setInformativeText:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"All Flash from '%@' will be removed when loading a site, until you restart %@.", nil, _myBundle, @"Blacklist Explanation"), [_src host], [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey]]];
	[alert addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Auto-Remove", nil, _myBundle, @"Blacklist Confirmation Button")];
	[alert addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, _myBundle, @"Blacklist Cancel Button")];
	[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(blacklistConfirmDidEnd:returnCode:contextInfo:) contextInfo:nil];
	_sheetOpen=YES;
	[alert autorelease];
}

- (void)remove:(id)sender
{
	[self _removeFromContainer];
}

- (void)playAll:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:sPlayAllNotification object:self userInfo:[NSDictionary dictionaryWithObject:[_src host] forKey:sHostKey]];
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

- (void)copyOriginal:(id)sender
{
	[self _writeToPasteboard:_originalURL];
}

- (void)copyDownload:(id)sender
{
	[self _writeToPasteboard:_downloadURL];
}

- (void)showAbout:(id)sender
{
	NSAlert * about = [[NSAlert alloc] init];
	NSImage * logo = [[NSImage alloc] initByReferencingFile:[_myBundle pathForResource:@"Logo" ofType:@"png"]];
	[about setIcon:logo];
	[logo release];
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
	[about addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"License...", nil, _myBundle, @"License Button")];
	NSInteger button = [about runModal];
	if(button==NSAlertSecondButtonReturn)
		{
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[_myBundle objectForInfoDictionaryKey:@"UCProductSite"]]];
		}
	else if(button==NSAlertThirdButtonReturn)
		{
		[[NSWorkspace sharedWorkspace] openFile:[_myBundle pathForResource:@"LICENSE" ofType:@""]];
		}
	[about release];
}

#pragma mark -

- (void)allShouldPlay:(NSNotification *)notification
{
	NSString * host = [[notification userInfo] objectForKey:sHostKey];
	if([host isEqualToString:[_src host]] && !_sheetOpen)
		{
		[self _convertToFlash];
		}
}

- (void)allShouldRemove:(NSNotification *)notification
{
	NSString * host = [[notification userInfo] objectForKey:sHostKey];
	if([host isEqualToString:[_src host]] && !_sheetOpen)
		{
		[self performSelector:@selector(_removeFromContainer) withObject:nil afterDelay:0];
		}
}

#pragma mark -

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
	if([anItem action]==@selector(openOriginal:) || [anItem action]==@selector(copyOriginal:))
		{
		return _originalURL!=nil;
		}
	else if([anItem action]==@selector(copyDownload:))
		{
		return _downloadURL!=nil;
		}
	else if([anItem action]==@selector(copyPreview:))
		{
		return _previewURL!=nil;
		}
	else if([anItem action]==@selector(playDirectly:))
		{
		return _canPlayDirectly && (_downloadURL!=nil);
		}
	else if([anItem action]==@selector(download:))
		{
		if(_canFindDownload && _downloadURL==nil)
			{
			[(NSMenuItem *)anItem setTitle:NSLocalizedStringFromTableInBundle(@"Try Download Video", nil, _myBundle, @"Try Download Menu Title")];
			}
		else
			{
			[(NSMenuItem *)anItem setTitle:NSLocalizedStringFromTableInBundle(@"Download Video", nil, _myBundle, @"Download Menu Title")];
			return _downloadURL!=nil;
			}
		}
	
	return YES;
}


@end
