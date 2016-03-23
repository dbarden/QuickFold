//
//  NSObject_Extension.m
//  QuickFold
//
//  Created by Barden, Daniel on 23/03/16.
//  Copyright © 2016 HERE GmbH. All rights reserved.
//


#import "NSObject_Extension.h"
#import "QuickFold.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[QuickFold alloc] initWithBundle:plugin];
        });
    }
}
@end
