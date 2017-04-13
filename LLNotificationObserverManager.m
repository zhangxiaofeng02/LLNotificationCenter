//
//  LLNotificationObserverManager.m
//  BDuerStudy
//
//  Created by 啸峰 on 17/4/12.
//  Copyright © 2017年 baidu. All rights reserved.
//

#import "LLNotificationObserverManager.h"
#import <pthread.h>

@interface LLNotificationObserverIdentify()

@property (nonatomic, weak) id object;
@property (nonatomic, assign) dispatch_queue_t targetQueue;
@property (nonatomic, copy) LLNotificationBlock block;

@end

@implementation LLNotificationObserverIdentify

- (void)dealloc {
    NSLog(@"identify 释放");
    [self stopObserver];
}

- (void)configIndentifyWithName:(NSString *)name
                    targerQueue:(dispatch_queue_t)queue
                         object:(id)object
                          block:(LLNotificationBlock)block {
    [self clearAll];
    _name = name;
    _targetQueue = queue;
    _block = block;
    _object = object;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifaction:) name:name object:object];
}

- (void)handleNotifaction:(NSNotification *)noti {
    if (self.targetQueue) {
        if ([NSThread isMainThread] && self.targetQueue == dispatch_get_main_queue()) {
            _block(noti);
        } else {
            __weak typeof (self) weakSelf = self;
            dispatch_async(self.targetQueue, ^{
                __strong typeof (weakSelf) strongSelf = weakSelf;
                strongSelf.block(noti);
            });
        }
    } else {
        _block(noti);
    }
}

- (void)clearAll {
    _object = nil;
    _targetQueue = nil;
    _block = nil;
}

- (void)stopObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_name object:_object];
    [self clearAll];
}

@end

@interface LLNotificationObserverManager()

@property (nonatomic, strong) NSMutableDictionary *dict;

@end

@implementation LLNotificationObserverManager

- (void)dealloc {
    NSLog(@"manager 释放");
}

- (void)addNotificationIndentify:(LLNotificationObserverIdentify *)iden {
    NotificationPerformLocked(^{
        [self motifyManagerDict:^(NSMutableDictionary *dict) {
            if (![dict objectForKey:iden.name]) {
                [dict setObject:iden forKey:iden.name];
            }
        }];
    });
}

- (void)motifyManagerDict:(void(^)(NSMutableDictionary *))block {
    if (!self.dict) {
        self.dict = [NSMutableDictionary dictionary];
    }
    block(self.dict);
}

- (void)removeNotificationName:(NSString *)name {
    NotificationPerformLocked(^{
        [self motifyManagerDict:^(NSMutableDictionary *dict) {
            LLNotificationObserverIdentify *identify = (LLNotificationObserverIdentify *)[dict objectForKey:name];
            [identify stopObserver];
            [dict removeObjectForKey:name];
        }];
    });
}

- (void)removeObserver {
    NotificationPerformLocked(^{
       [self motifyManagerDict:^(NSMutableDictionary *dict) {
           for (NSString *key in dict) {
               LLNotificationObserverIdentify *indetify = (LLNotificationObserverIdentify *)[dict objectForKey:key];
               [indetify stopObserver];
           }
           [dict removeAllObjects];
       }];
    });
}

static void NotificationPerformLocked(dispatch_block_t block) {
    static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
    pthread_mutex_lock(&lock);
    block();
    pthread_mutex_unlock(&lock);
}

@end
