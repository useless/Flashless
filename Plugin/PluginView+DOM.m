//
//  PluginView+DOM.m
//  Flashless
//
//  Created by Christoph on 14.08.09.
//  Copyright Useless Coding 2009.
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

static NSString * sFlashOldMIMEType = @"application/x-shockwave-flash";
static NSString * sFlashNewMIMEType = @"application/futuresplash";

@interface UCFlashlessView (DOM)
- (void)_convertTypesForContainer;
- (void)_convertTypesForElement:(DOMElement *)element;
- (void)_removeFromContainer;
@end

@implementation UCFlashlessView (DOM)

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

@end