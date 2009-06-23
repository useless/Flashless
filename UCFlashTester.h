//
//  UCFlashTester.h
//  Flashless TestApp
//
//  Created by Christoph on 13.06.09.
//  Copyright 2009 Useless Coding. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UCFlashlessView.h"


@interface UCFlashTester : NSObject
{
	IBOutlet UCFlashlessView * flashView;
}

- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)refresh:(id)sender;

@end
