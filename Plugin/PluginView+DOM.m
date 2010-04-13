//
//  PluginView+DOM.m
//  Flashless
//
//  Created by Christoph on 14.08.2009.
//  Copyright 2009-2010 Useless Coding.
//  Copyright (c) 2008-2009 ClickToFlash Developers.
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

#import "PluginView+DOM.h"

static NSString * sFlashOldMIMEType = @"application/x-shockwave-flash";
static NSString * sFlashNewMIMEType = @"application/futuresplash";

@implementation UCFlashlessView (DOM)

- (void)_convertTypesForElement:(DOMElement *)element
{
    NSString *type = [element getAttribute:@"type"];

    if([type isEqualToString:sFlashOldMIMEType] || [type length]==0)
	{
        [element setAttribute:@"type" value:sFlashNewMIMEType];
    }
}

- (void)_convertToFlash
{
#ifdef TESTAPP
	NSLog(@"DOM: Convert To Flash");
	return;
#endif

	DOMNodeList * nodeList;

	NSUInteger i;

	[self _convertTypesForElement:_element];

	nodeList = [_element getElementsByTagName:@"object"];
	for(i=0; i<nodeList.length; i++)
		{
		[self _convertTypesForElement:(DOMElement *)[nodeList item:i]];
		}

	nodeList = [_element getElementsByTagName:@"embed"];
	for(i=0; i<nodeList.length; i++)
		{
		[self _convertTypesForElement:(DOMElement *)[nodeList item:i]];
		}

	[[self retain] autorelease];

	DOMNode * parent = [_element parentNode];
	DOMNode * successor = [_element nextSibling];

	[_element retain];
	[parent removeChild:_element];
	[parent insertBefore:_element refChild:successor];
	[_element release];
	_element = nil;
}

- (void)_convertToVideo
{
#ifdef TESTAPP
	NSLog(@"DOM: Convert To Video");
	return;
#endif

	DOMElement * videoElement = [[_element ownerDocument] createElement:@"video"];

	[videoElement setAttribute:@"src" value:[_downloadURL absoluteString]];
	[videoElement setAttribute:@"autoplay" value:@"autoplay"];
	[videoElement setAttribute:@"controls" value:@"controls"];
	[videoElement setAttribute:@"width" value:[NSString stringWithFormat:@"%.0f", [self bounds].size.width]];
	[videoElement setAttribute:@"height" value:[NSString stringWithFormat:@"%.0f", [self bounds].size.height]];
	if(_previewURL!=nil)
		{
		[videoElement setAttribute:@"poster" value:[_previewURL absoluteString]];
		}

	[[self retain] autorelease];

	[_element.parentNode replaceChild:videoElement oldChild:_element];

	[_element release];
	_element = nil;
}

- (void)_removeFromContainer
{	
#ifdef TESTAPP
	NSLog(@"DOM: Remove from Container.");
	return;
#endif

	[[self retain] autorelease];

	[_element.parentNode removeChild:_element];

	[_element release];
	_element = nil;
}

@end
