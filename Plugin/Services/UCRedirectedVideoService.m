//
//  UCRedirectedVideoService.m
//  Flashless
//
//  Created by Christoph on 30.11.09.
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


#import "UCRedirectedVideoService.h"

@implementation UCRedirectedVideoService

- (void)dealloc
{
	[redirectConnection release];

	[super dealloc];
}

#pragma mark -

- (void)cancel
{
	[redirectConnection cancel];

	[super cancel];
}

- (void)resolveURL:(NSURL *)URL
{
	redirectConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:src] delegate:self];
}

- (void)redirectedTo:(NSURL *)redirectedURL
{
}

#pragma mark Connection Delegate

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
	if(connection==redirectConnection && redirectResponse!=nil)
		{
		[connection cancel];
		[self redirectedTo:[request URL]];
		return nil;
		}
	else
		{
		return request;
		}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if(connection==redirectConnection)
		{
		// We waited for a redirection that didn't happen
		[self redirectedTo:nil];
		}
	else
		{
		[super connectionDidFinishLoading:connection];
		}
}


@end
