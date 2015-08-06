//
//  LYMDetailViewController.m
//  Homepwner
//
//  Created by hangliu on 15/6/4.
//  Copyright (c) 2015年 MoonBright. All rights reserved.
//

#import "LYMDetailViewController.h"
#import "LYMItem.h"
#import "LYMImageStore.h"
#import "LYMItemStore.h"
#import "LYMAssetTypeViewController.h"
#import "AppDelegate.h"

@interface LYMDetailViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextFieldDelegate,UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *imagePickerPopover;
@property (strong, nonatomic) UIPopoverController *assetTypePopover;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *serialField;
@property (weak, nonatomic) IBOutlet UITextField *ValueField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *assetTypeButton;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;


@end

@implementation LYMDetailViewController
- (IBAction)takePicture:(id)sender
{
    if ([self.imagePickerPopover isPopoverVisible]) {
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
        return;
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    imagePicker.delegate = self;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.imagePickerPopover = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
        self.imagePickerPopover.delegate = self;
        [self.imagePickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)popoverControllerDidDismissPopover:(nonnull UIPopoverController *)popoverController
{
    NSLog(@"User dismissed popover");
    self.imagePickerPopover = nil;
    self.assetTypePopover = nil;
}

- (IBAction)backgroundTapped:(id)sender {
    [self.view endEditing:YES];

}

- (IBAction)showAssetTypePicker:(id)sender
{
    [self.view endEditing:YES];
    if ([self.assetTypePopover isPopoverVisible]) {
        [self.assetTypePopover dismissPopoverAnimated:YES];
        self.assetTypePopover = nil;
        return;
    }
    LYMAssetTypeViewController *avc = [[LYMAssetTypeViewController alloc]init];
    avc.item = self.item;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.assetTypePopover = [[UIPopoverController alloc]initWithContentViewController:avc];
        self.imagePickerPopover.delegate = self;
        [self.assetTypePopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self.navigationController pushViewController:avc animated:YES];
    }
}

- (void)imagePickerController:(nonnull UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //以itemKey 为键，将照片存入LYMImageStore中
    [self.item setThumbnailFromImage:image];
    [[LYMImageStore sharedStore] setImage:image forKey:self.item.imageKey];
    self.imageView.image = image;
    if (self.imagePickerPopover) {
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIInterfaceOrientation io = [[UIApplication sharedApplication] statusBarOrientation];
    [self prepareViewsForOrientation:io];
    
    LYMItem *item = self.item;
    self.nameField.text = item.itemName;
    self.serialField.text = item.serialNumber;
    self.ValueField.text = [NSString stringWithFormat:@"%d",item.valueInDollars];
    
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    self.dateLabel.text = [dateFormatter stringFromDate:item.dateCreated];
    
    NSString *imageKey = self.item.imageKey;
    if (imageKey) {
        UIImage *imageToDisplay = [[LYMImageStore sharedStore] imageForKey:imageKey];
        self.imageView.image = imageToDisplay;
    } else {
        self.imageView.image = nil;
    }

    
    NSString *typeLabel =[self.item.assetType valueForKey:@"label"];
    if (!typeLabel) {
        typeLabel = NSLocalizedString(@"None", @"Type label None");
    }
    self.assetTypeButton.title = [NSString stringWithFormat:NSLocalizedString(@"Type: %@", @"Asset type button"),typeLabel];
    
    [self updateFonts];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    LYMItem *item = self.item;
    item.itemName = self.nameField.text;
    item.serialNumber = self.serialField.text;
    
    int newValue = [self.ValueField.text intValue];
    if (newValue != item.valueInDollars) {
        item.valueInDollars = newValue;
        
        NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
        [defaluts setInteger:newValue forKey:LYMNextItemValuePrefsKey];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *iv = [[UIImageView alloc]initWithImage:nil];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    iv.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:iv];
    self.imageView = iv;
    NSDictionary *nameMap = @{@"imageView" : self.imageView,
                              @"dateLabel" : self.dateLabel,
                              @"toolbar" : self.toolbar};
    
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]-0-|" options:0 metrics:nil views:nameMap];
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[dateLabel]-8-[imageView]-8-[toolbar]" options:0 metrics:nil views:nameMap];
    [self.view addConstraints:horizontalConstraints];
    [self.view addConstraints:verticalConstraints];
    [self.imageView setContentHuggingPriority:200 forAxis:UILayoutConstraintAxisVertical];
    [self.imageView setContentCompressionResistancePriority:700 forAxis:UILayoutConstraintAxisVertical];
}

- (void)prepareViewsForOrientation:(UIInterfaceOrientation)orientation
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return;
    }
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.imageView.hidden = YES;
        self.cameraButton.enabled = NO;
    } else {
        self.imageView.hidden = NO;
        self.cameraButton.enabled = YES;
    }
}

- (void)updateFonts
{
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    self.nameLabel.font = font;
    self.serialNumberLabel.font = font;
    self.valueLabel.font = font;
    self.dateLabel.font = font;
    
    self.serialField.font = font;
    self.nameField.font = font;
    self.ValueField.font = font;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self prepareViewsForOrientation:toInterfaceOrientation];
}

- (BOOL)textFieldShouldReturn:(nonnull UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)setItem:(LYMItem *)item
{
    _item = item;
    self.navigationItem.title = _item.itemName;
}

- (instancetype)initForNewItem:(BOOL)isNew
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        if (isNew) {
            UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
            self.navigationItem.rightBarButtonItem = doneItem;
            
            UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
            self.navigationItem.leftBarButtonItem = cancelItem;
        }
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self selector:@selector(updateFonts) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    NSNotificationCenter *defalutCenter = [NSNotificationCenter defaultCenter];
    [defalutCenter removeObserver:self];
}

- (void)save:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dimissBlock];
}

- (void)cancel:(id)sender
{
    [[LYMItemStore sharedStore] removeItem:self.item];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dimissBlock];
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    @throw [NSException exceptionWithName:@"Wrong initializer" reason:@"Use initForItem" userInfo:nil];
    return nil;
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(nonnull NSArray *)identifierComponents coder:(nonnull NSCoder *)coder
{
    BOOL isNew = NO;
    if ([identifierComponents count] == 3) {
        isNew = YES;
    }
    return [[self alloc]initForNewItem:isNew];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.item.imageKey forKey:@"item.imageKey"];
    
    self.item.itemName = self.nameField.text;
    self.item.serialNumber = self.serialField.text;
    self.item.valueInDollars = [self.ValueField.text intValue];
    
    [[LYMItemStore sharedStore]saveChanges];
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSString *Key = [coder decodeObjectForKey:@"item.imageKey"];
    
    for (LYMItem *item in [[LYMItemStore sharedStore]allItems]) {
        if ([Key isEqualToString:item.imageKey]) {
            self.item = item;
            break;
        }
    }
    [super decodeRestorableStateWithCoder:coder];
}
@end