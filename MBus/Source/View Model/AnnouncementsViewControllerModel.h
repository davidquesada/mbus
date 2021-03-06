//
//  AnnouncementsViewControllerModel.h
//  UMBus
//
//  Created by Jonah Grant on 12/20/13.
//  Copyright (c) 2013 Jonah Grant. All rights reserved.
//

#import "ViewControllerModelBase.h"

@class Announcement;

@interface AnnouncementsViewControllerModel : ViewControllerModelBase

- (NSString *)footerString;
- (NSString *)headerString;
- (CGFloat)heightForAnnouncement:(Announcement *)announcement width:(CGFloat)width font:(UIFont *)font;

@end
