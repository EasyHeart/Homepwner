//
//  LYMItem.h
//  Homepwer
//
//  Created by hangliu on 15/6/23.
//  Copyright (c) 2015年 MoonBright. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface LYMItem : NSManagedObject

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSString * imageKey;
@property (nonatomic, retain) NSString * itemName;
@property (nonatomic) double orderingValue;
@property (nonatomic, retain) NSString * serialNumber;
@property (nonatomic, retain) UIImage *thumbnail;
@property (nonatomic) int valueInDollars;
@property (nonatomic, retain) NSManagedObject *assetType;

- (void)setThumbnailFromImage:(UIImage *)image;

@end

