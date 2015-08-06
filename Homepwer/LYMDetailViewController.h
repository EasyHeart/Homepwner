//
//  LYMDetailViewController.h
//  Homepwner
//
//  Created by hangliu on 15/6/4.
//  Copyright (c) 2015年 MoonBright. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LYMItem;

@interface LYMDetailViewController : UIViewController <UIViewControllerRestoration>
@property (nonatomic, strong) LYMItem *item;
@property (nonatomic, copy) void (^dimissBlock)(void);

- (instancetype)initForNewItem:(BOOL)isNew;

@end
