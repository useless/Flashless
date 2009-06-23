//
//  UCFlashTester.m
//  Flashless TestApp
//
//  Created by Christoph on 13.06.09.
//  Copyright 2009 Useless Coding. All rights reserved.
//

#import "UCFlashTester.h"


@implementation UCFlashTester

- (void)awakeFromNib
{
/*	[flashView initWithArguments:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSDictionary dictionaryWithObjectsAndKeys:
			@"http://useless.com/play.swf", @"src",
			nil], WebPlugInAttributesKey,
		[NSURL URLWithString:@"http://useless.com"], WebPlugInBaseURLKey,
		nil]];
*/
/*	[flashView initWithArguments:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSDictionary dictionaryWithObjectsAndKeys:
			@"en_flash_debug_mode=0&en_flash_show_overlay=false&en_flash_overlay_xml_path=http://www.xtube.com/phone_caption.php&en_flash_show_adverticement_type=4&en_flash_mdh_image=http://cdn01.xtube.com/e5/embed/mdh_video_baner_nm_3.jpg&en_flash_mdh_link= http://www.mydirtyhobby.com/?sub=9718-1&en_flash_lib_path=library.swf&h=&swfURL=http://cdns15.xtube.com/s/e13&wall_idx=111_9&sid=0&user_id=duplo&owner_u=duplo&idx=5&from=&sex_type=G&video_id=8Dr2g-C118-&clip_id=C8sUI-C118-&content_type=&preview_flag=&preview_video_id=&preview_clip_id=", @"flashvars",
			@"scenes_player.swf", @"src",
			nil], WebPlugInAttributesKey,
		[NSURL URLWithString:@"http://video2.xtube.com/watch_video.php?v_user_id=duplo&idx=5&v=8Dr2g-C118-&cl=C8sUI-C118-&from=&ver=3&ccaa=1&qid=&qidx=&qnum=&preview_flag="], WebPlugInBaseURLKey,
		nil]];
*/
/*	[flashView initWithArguments:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSDictionary dictionaryWithObjectsAndKeys:
			@"/v/fstVfM49zsU&hl=de&fs=1&", @"src",
			nil], WebPlugInAttributesKey,
		[NSURL URLWithString:@"http://www.youtube.com/v/fstVfM49zsU&hl=de&fs=1&"], WebPlugInBaseURLKey,
		nil]];
*/
	[flashView initWithArguments:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSDictionary dictionaryWithObjectsAndKeys:
			@"http://www.viddler.com/simple_on_site/4348c94", @"src",
			nil], WebPlugInAttributesKey,
		[NSURL URLWithString:@"http://www.fscklog.com/"], WebPlugInBaseURLKey,
		nil]];
}

- (void)start:(id)sender
{
	[flashView webPlugInInitialize];
}

- (void)stop:(id)sender
{
	[flashView webPlugInDestroy];
}

- (void)refresh:(id)sender
{
	[flashView setNeedsDisplay:YES];
}


@end
