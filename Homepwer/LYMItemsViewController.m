//
//  LYMItemsViewController.m
//  Homepwner
//
//  Created by hangliu on 15/6/3.
//  Copyright (c) 2015年 MoonBright. All rights reserved.
//

#import "LYMItemsViewController.h"
#import "LYMItem.h"
#import "LYMItemStore.h"
#import "LYMImageStore.h"
#import "LYMImageViewController.h"

@interface LYMItemsViewController () <UIPopoverControllerDelegate,UIDataSourceModelAssociation>

//@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong)UIPopoverController *imagePopover;

@end

@implementation LYMItemsViewController

#pragma mark - init

- (instancetype)init
{
    //调用父类的指定初始方法
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = NSLocalizedString(@"Homepwner", @"Name of application");
        
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
        navItem.rightBarButtonItem = bbi;
        navItem.leftBarButtonItem = self.editButtonItem;
        
        NSNotificationCenter *defalutCenter = [NSNotificationCenter defaultCenter];
        [defalutCenter addObserver:self selector:@selector(updateTableViewForDynamicTypeSize) name:UIContentSizeCategoryDidChangeNotification object:nil];
        
        [defalutCenter addObserver:self selector:@selector(localeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
        
    }
    return self;
}

- (void)localeChanged:(NSNotification *)note
{
    [self.tableView reloadData];
}

- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    UINib *nib = [UINib nibWithNibName:@"LYMItemCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"LYMItemCell"];
    self.tableView.restorationIdentifier = @"LYMItemViewControllerTableView";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateTableViewForDynamicTypeSize];
}

#pragma mark - font

- (void)updateTableViewForDynamicTypeSize
{
    static NSDictionary *cellHeightDictionary;
    
    if (!cellHeightDictionary) {
        cellHeightDictionary = @{
                                 UIContentSizeCategoryExtraExtraExtraLarge: @75,
                                 UIContentSizeCategoryExtraExtraLarge: @65,
                                 UIContentSizeCategoryExtraLarge: @55,
                                 UIContentSizeCategoryLarge: @44,
                                 UIContentSizeCategoryMedium: @44,
                                 UIContentSizeCategorySmall: @44,
                                 UIContentSizeCategoryExtraSmall: @44
                                 };
    }
    
    NSString *userSize = [[UIApplication sharedApplication]preferredContentSizeCategory];
    NSNumber *cellHeight = cellHeightDictionary[userSize];
    [self.tableView setRowHeight:cellHeight.floatValue];
    [self.tableView reloadData];
}

#pragma mark - IBAction

- (IBAction)addNewItem:(id)sender
{
   // NSInteger lastRow = [self.tableView numberOfRowsInSection:0];
    LYMItem *newItem = [[LYMItemStore sharedStore]createItem];
    LYMDetailViewController *detailViewController = [[LYMDetailViewController alloc]initForNewItem:YES];
    detailViewController.item = newItem;
    
    detailViewController.dimissBlock = ^{
        [self.tableView reloadData];
    };
    
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:detailViewController];
    
    navController.restorationIdentifier = NSStringFromClass([navController class]);
   // navController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    
    [self presentViewController:navController animated:YES completion:nil];
}


#pragma mark - dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[LYMItemStore sharedStore]allItems]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LYMItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LYMItemCell" forIndexPath:indexPath];
    NSArray *items = [[LYMItemStore sharedStore]allItems];
    LYMItem *item = items[indexPath.row];
    if (item.valueInDollars > 50) {
        cell.valueLabel.textColor = [UIColor greenColor];
    } else {
        cell.valueLabel.textColor = [UIColor redColor];
    }
    cell.nameLabel.text = item.itemName;
    cell.serialNumber.text = item.serialNumber;
    
    static NSNumberFormatter *currencyFormatter = nil;
    if (currencyFormatter == nil) {
        currencyFormatter = [[NSNumberFormatter alloc]init];
        currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    }
    
    cell.valueLabel.text = [currencyFormatter stringFromNumber:@(item.valueInDollars)];
    
    cell.thumbnailView.image = item.thumbnail;
    __weak LYMItemCell *weakCell = cell;
    cell.actionBlock = ^{
        NSLog(@"Going to show image for %@",item);
        
        LYMItemCell *strongCell = weakCell;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            NSString *imageKey = item.imageKey;
            UIImage *img = [[LYMImageStore sharedStore] imageForKey:imageKey];
            if (!img) {
                return ;
            }
            //根据UITableView对象的坐标系获取UIImageView对象的位置和大小；
            CGRect rect = [self.view convertRect:strongCell.thumbnailView.bounds
                                       fromView:strongCell.thumbnailView];
            LYMImageViewController *ivc = [[LYMImageViewController alloc]init];
            ivc.image = img;
            
            self.imagePopover = [[UIPopoverController alloc]initWithContentViewController:ivc];
            self.imagePopover.delegate = self;
            self.imagePopover.popoverContentSize = CGSizeMake(600, 600);
            [self.imagePopover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    };
    return cell;
}

- (void)popoverControllerDidDismissPopover:(nonnull UIPopoverController *)popoverController
{
    self.imagePopover = nil;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *items = [[LYMItemStore sharedStore]allItems];
        LYMItem *item = items[indexPath.row];
        [[LYMItemStore sharedStore] removeItem:item];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[LYMItemStore sharedStore]moveItemAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}

#pragma mark -delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LYMDetailViewController *detailViewController = [[LYMDetailViewController alloc]initForNewItem:NO];
    NSArray *items = [[LYMItemStore sharedStore]allItems];
    LYMItem *selectedItem = items[indexPath.row];
    detailViewController.item = selectedItem;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(nonnull NSArray *)identifierComponents coder:(nonnull NSCoder *)coder
{
    return [[self alloc]init];
}

- (void)encodeRestorableStateWithCoder:(nonnull NSCoder *)coder
{
    [coder encodeBool:self.isEditing forKey:@"TableViewIsEditing"];
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(nonnull NSCoder *)coder
{
    self.editing = [coder decodeBoolForKey:@"TableViewIsEditing"];
    [super decodeRestorableStateWithCoder:coder];
}

- (NSString *)modelIdentifierForElementAtIndexPath:(nonnull NSIndexPath *)idx inView:(nonnull UIView *)view
{
    NSString *identifier = nil;
    if (idx && view) {
        LYMItem *item = [[LYMItemStore sharedStore ]allItems][idx.row];
        identifier = item.imageKey;
    }
    return identifier;
}

- (NSIndexPath *)indexPathForElementWithModelIdentifier:(nonnull NSString *)identifier inView:(nonnull UIView *)view
{
    NSIndexPath *indexPath = nil;
    if (identifier && view) {
        NSArray *items = [[LYMItemStore sharedStore]allItems];
        for (LYMItem *item in items) {
            if ([identifier isEqualToString:item.imageKey]) {
                int row = (int)[items indexOfObjectIdenticalTo:item];
                indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                break;
            }
        }
    }
    return indexPath;
} 

@end
