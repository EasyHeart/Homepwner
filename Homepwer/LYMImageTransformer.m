//
//  LYMImageTransformer.m
//  Homepwer
//
//  Created by hangliu on 15/6/23.
//  Copyright © 2015年 MoonBright. All rights reserved.
//

#import "LYMImageTransformer.h"
#import <UIKit/UIKit.h>

@implementation LYMImageTransformer

+ (Class)transformedValueClass
{
    return [NSData class];
}

- (id)transformedValue:(nullable id)value
{
    if (!value) {
        return nil;
    }
    if ([value isKindOfClass:[NSData class]]) {
        return value;
    }
    return UIImagePNGRepresentation(value);
}

- (id)reverseTransformedValue:(nullable id)value
{
    return [UIImage imageWithData:value];
}

@end
