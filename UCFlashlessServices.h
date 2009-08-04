//
//  UCFlashlessServices.h
//  Flashless
//
//  Created by Christoph on 04.08.09.
//  Copyright Useless Coding 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface UCFlashlessServices : NSObject
{
@private
	NSURL * lastSrc;
	NSString * lastDomain;
}

- (NSString *)domainForSrc:(NSURL *)src;
- (NSString *)labelForSrc:(NSURL *)src;

- (NSURL *)previewURLForSrc:(NSURL *)src andFlashVars:(NSMutableDictionary *)flashVars;
- (NSURL *)downloadURLForSrc:(NSURL *)src andFlashVars:(NSMutableDictionary *)flashVars;
- (NSURL *)originalURLForSrc:(NSURL *)src andFlashVars:(NSMutableDictionary *)flashVars;

@end
