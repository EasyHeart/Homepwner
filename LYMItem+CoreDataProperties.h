//
//  LYMItem+CoreDataProperties.h
//  Homepwer
//
//  Created by hangliu on 15/6/23.
//  Copyright © 2015年 MoonBright. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

#import "LYMItem.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LYMItem (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *itemName;
@property (nullable, nonatomic, retain) NSString *serialNumber;
@property (nullable, nonatomic, retain) NSNumber *valueInDollars;
@property (nullable, nonatomic, retain) NSDate *dateCreated;
@property (nullable, nonatomic, retain) NSString *imageKey;
@property (nullable, nonatomic, retain) UIImage *thumbnail;
@property (nullable, nonatomic, retain) NSNumber *orderingValue;
@property (nullable, nonatomic, retain) NSManagedObject *assetType;

@end

NS_ASSUME_NONNULL_END
