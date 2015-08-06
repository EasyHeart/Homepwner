//
//  LYMImageStore.m
//  Homepwner
//
//  Created by hangliu on 15/6/13.
//  Copyright © 2015年 MoonBright. All rights reserved.
//

#import "LYMImageStore.h"

@interface LYMImageStore ()

@property (nonatomic, strong) NSMutableDictionary *dictionary;
- (NSString *)imagePathForKey:(NSString *)key;

@end

@implementation LYMImageStore

#pragma mark init
+ (instancetype)sharedStore
{
    static LYMImageStore *sharedStore = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc]initPrivate];
    });
    
    return sharedStore;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[LYMImageStore sharedStore]" userInfo:nil];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        _dictionary = [[NSMutableDictionary alloc]init];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(clearCache:)
                   name:UIApplicationDidReceiveMemoryWarningNotification
                 object:nil];
    }
    return self;
}

- (void)clearCache:(NSNotification *)note
{
    NSLog(@"flushing %d images out of the Cache",(int)[self.dictionary count]);
    [self.dictionary removeAllObjects];
}

#pragma methods
- (void)setImage:(UIImage *)image forKey:(NSString *)key
{
    self.dictionary[key] = image;
    NSString *imagePath = [self imagePathForKey:key];
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    [data writeToFile:imagePath atomically:YES];
}

- (UIImage *)imageForKey:(NSString *)key
{
    UIImage *result = self.dictionary[key];
    if (!result) {
        NSString *imagePath = [self imagePathForKey:key];
        result = [UIImage imageWithContentsOfFile:imagePath];
        
        if (result) {
            self.dictionary[key] = result;
        } else {
            NSLog(@"Error:unable to find %@",[self imagePathForKey:key]);
        }
    }
    return result;
}

- (void)deleteImageForKey:(NSString *)key
{
    if (!key) {
        return;
    }
    [self.dictionary removeObjectForKey:key];
    NSString *imagePath = [self imagePathForKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
}

#pragma mark save
- (NSString *)imagePathForKey:(NSString *)key
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    return [documentDirectory stringByAppendingPathComponent:key];
}

@end
