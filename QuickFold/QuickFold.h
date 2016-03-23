//
//  QuickFold.h
//  QuickFold
//
//  Created by Barden, Daniel on 23/03/16.
//  Copyright © 2016 HERE GmbH. All rights reserved.
//

#import <AppKit/AppKit.h>

@class QuickFold;

static QuickFold *sharedPlugin;

@interface QuickFold : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end