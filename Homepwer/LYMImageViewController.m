//
//  LYMImageViewController.m
//  Homepwer
//
//  Created by hangliu on 15/6/22.
//  Copyright © 2015年 MoonBright. All rights reserved.
//

#import "LYMImageViewController.h"

@interface LYMImageViewController ()

@end

@implementation LYMImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    self.view = imageView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIImageView *imageView = (UIImageView *)self.view;
    imageView.image = self.image;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
