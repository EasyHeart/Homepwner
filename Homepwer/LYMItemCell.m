//
//  LYMItemCell.m
//  Homepwner
//
//  Created by hangliu on 15/6/17.
//  Copyright © 2015年 MoonBright. All rights reserved.
//

#import "LYMItemCell.h"

@interface LYMItemCell ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;

@end

@implementation LYMItemCell

- (IBAction)showImage:(id)sender
{
    if (self.actionBlock) {
        self.actionBlock();
    }
}

- (void)updateInterfaceForDynamicTypeSize
{
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.nameLabel.font = font;
    self.serialNumber.font = font;
    self.valueLabel.font = font;
    
    static NSDictionary *imageSizeDictionary;
    
    if (!imageSizeDictionary) {
        imageSizeDictionary = @{
                                UIContentSizeCategoryExtraExtraExtraLarge: @65,
                                UIContentSizeCategoryExtraExtraLarge: @55,
                                UIContentSizeCategoryExtraLarge: @45,
                                UIContentSizeCategoryLarge: @40,
                                UIContentSizeCategoryMedium: @40,
                                UIContentSizeCategorySmall: @40,
                                UIContentSizeCategoryExtraSmall: @40
                                };
    }
    NSString *userSize = [[UIApplication sharedApplication]preferredContentSizeCategory];
    NSNumber *imageSize = imageSizeDictionary[userSize];
    self.imageViewHeightConstraint.constant = imageSize.floatValue;
}



- (void)awakeFromNib
{
    [self updateInterfaceForDynamicTypeSize];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(updateInterfaceForDynamicTypeSize) name:UIContentSizeCategoryDidChangeNotification object:nil];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.thumbnailView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.thumbnailView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    [self.thumbnailView addConstraint:constraint];
}

- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}
@end
