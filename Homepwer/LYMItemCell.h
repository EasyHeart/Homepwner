//
//  LYMItemCell.h
//  Homepwner
//
//  Created by hangliu on 15/6/17.
//  Copyright © 2015年 MoonBright. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYMItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialNumber;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@property (nonatomic, copy) void (^actionBlock)(void);

@end
