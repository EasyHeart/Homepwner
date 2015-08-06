//
//  LYMItemStore.m
//  Homepwner
//
//  Created by hangliu on 15/6/3.
//  Copyright (c) 2015年 MoonBright. All rights reserved.
//

#import "LYMItemStore.h"
#import "LYMItem.h"
#import "LYMImageStore.h"
#import "AppDelegate.h"
@import CoreData;

@interface LYMItemStore ()

@property (nonatomic) NSMutableArray *privateItems;
@property (nonatomic, strong) NSMutableArray *allAssetTypes;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSManagedObjectModel *model;

@end

@implementation LYMItemStore

+ (instancetype)sharedStore
{
    static LYMItemStore *sharedStore;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc]initPrivate];
    });
    return sharedStore;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"use + [LYMItemStore sharedStore]" userInfo:nil];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        _model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:_model];
        
        //设置SQLite文件路径
        NSString *path = self.itemArchivePath;
        NSURL *stroeURL = [NSURL fileURLWithPath:path];
        NSError *error;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:stroeURL options:nil error:&error]) {
            @throw [NSException exceptionWithName:@"Open failed" reason:[error localizedDescription] userInfo:nil];
        }
        //创建NSManagedObjectContext对象
        _context = [[NSManagedObjectContext alloc]init];
        _context.persistentStoreCoordinator = psc;
        
        [self loadAllItems];
    }
    return self;
}

- (NSArray *)allItems
{
    return [self.privateItems copy];
}

- (LYMItem *)createItem
{
    double order;
    if ([self.allItems count]== 0) {
        order = 1.0;
    } else {
        order = [[self.privateItems lastObject]orderingValue]+1.0;
    }
    NSLog(@"Addimg after %lu items,order = %.2f",(unsigned long)[self.privateItems count],order);
    LYMItem *item =[NSEntityDescription insertNewObjectForEntityForName:@"LYMItem" inManagedObjectContext:self.context];
    item.orderingValue =order;
    
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    item.valueInDollars = (int)[defaluts integerForKey:LYMNextItemValuePrefsKey];
    item.itemName = [defaluts objectForKey:LYMNextItemNamePrefsKey];
    NSLog(@"defaluts = %@",[defaluts dictionaryRepresentation]);
    
    [self.privateItems addObject:item];
    return item;
}

- (void)removeItem:(LYMItem *)item
{
    NSString *key = item.imageKey;
    if (key) {
    [[LYMImageStore sharedStore] deleteImageForKey:key];
    }
    [self.context deleteObject:item];
    [self.privateItems removeObjectIdenticalTo:item];
}

- (void)moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSInteger)toIndex
{
    if (fromIndex == toIndex) {
        return;
    }
    LYMItem *item = self.privateItems[fromIndex];
    [self.privateItems removeObjectAtIndex:fromIndex];
    [self.privateItems insertObject:item atIndex:toIndex];
    //为被移动的对象计算新的orderValue
    double lowerBound = 0.0;
    //在数组中，该对象之前是否还有其他对象
    if (toIndex > 0) {
        lowerBound = [self.privateItems[(toIndex - 1)] orderingValue];
    } else {
        lowerBound = [self.privateItems[1]orderingValue] - 2.0;
    }
    double upperBound = 0.0;
    //在该数组之后是否还有其他对象
    if (toIndex < [self.privateItems count] -1) {
        upperBound = [self.privateItems[(toIndex + 1)]orderingValue];
    } else {
        upperBound = [self.privateItems[(toIndex - 1)]orderingValue] + 2.0;
    }
    
    double newOrderValue = (lowerBound + upperBound) / 2.0;
    NSLog(@"moving to order %f",newOrderValue);
    item.orderingValue = newOrderValue;
}

- (NSArray *)allAssetTypes
{
    if (!_allAssetTypes) {
        NSFetchRequest *request = [[NSFetchRequest alloc]init];
        NSEntityDescription *e =[NSEntityDescription entityForName:@"LYMAssetType" inManagedObjectContext:self.context];
        request.entity = e;
        NSError *error;
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed" format:@"Reason:%@",[error localizedDescription]];
        }
        _allAssetTypes = [result mutableCopy];
    }
    //第一次运行？
    if ([_allAssetTypes count] == 0) {
        NSManagedObject *type;
        type = [NSEntityDescription insertNewObjectForEntityForName:@"LYMAssetType" inManagedObjectContext:self.context];
        [type setValue:@"Furniture" forKey:@"label"];
        [_allAssetTypes addObject:type];
        type = [NSEntityDescription insertNewObjectForEntityForName:@"LYMAssetType" inManagedObjectContext:self.context];
        [type setValue:@"Jewelry" forKey:@"label"];
        [_allAssetTypes addObject:type];
        type = [NSEntityDescription insertNewObjectForEntityForName:@"LYMAssetType" inManagedObjectContext:self.context];
        [type setValue:@"Electronics" forKey:@"label"];
        [_allAssetTypes addObject:type];
    }
    return _allAssetTypes;
}

#pragma mark - NSKeyedArchiver ==

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
   // NSLog(@"%@",documentDirectory);
    
    return [documentDirectory stringByAppendingPathComponent:@"stroe.data"];
}

- (BOOL)saveChanges
{
    NSError *error;
    BOOL successful = [self.context save:&error];
    if (!successful) {
        NSLog(@"Error saving : %@",[error localizedDescription]);
    }
    return successful;
}

- (void)loadAllItems
{
    if (!self.privateItems) {
        NSFetchRequest *request = [[NSFetchRequest alloc]init];
        NSEntityDescription *e = [NSEntityDescription entityForName:@"LYMItem" inManagedObjectContext:self.context];
        request.entity = e;
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue" ascending:YES];
        request.sortDescriptors = @[sd];
        NSError *error;
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed" format:@"Reason: %@",[error localizedDescription]];
        }
        self.privateItems = [[NSMutableArray alloc]initWithArray:result];
    }
}
@end
