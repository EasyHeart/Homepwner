//
//  LYMItemStore.h
//  Homepwner
//
//  Created by hangliu on 15/6/3.
//  Copyright (c) 2015年 MoonBright. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LYMItem;

@interface LYMItemStore : NSObject

@property (nonatomic, readonly) NSArray *allItems;

+ (instancetype)sharedStore;
- (LYMItem *)createItem;
- (void)removeItem:(LYMItem *)item;
- (void)moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSInteger)toIndex;
- (BOOL)saveChanges;
- (NSArray *)allAssetTypes;

@end
