//
//  LLNotifactionCenter.m
//  BDuerStudy
//
//  Created by 啸峰 on 17/4/12.
//  Copyright © 2017年 baidu. All rights reserved.
//

#import "LLNotifactionCenter.h"
#import <pthread.h>
#import <objc/runtime.h>

#define LL_NOTIFACTIONCENTER_MANAGER_KEY @"LL_NOTIFACTIONCENTER_MANAGER_KEY"

static LLNotifactionCenter *center = nil;

@implementation LLNotifactionCenter

+ (instancetype)defaultCenter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[LLNotifactionCenter alloc] init];
    });
    return center;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [super allocWithZone:zone];
    });
    return center;
}

#pragma mark addObserver

- (void)addObserver:(id)observer
               name:(NSString *)name
              block:(LLNotificationBlock)block {
    [self addObserver:observer name:name object:nil targetQueue:nil block:block];
}

- (void)addObserver:(id)observer
               name:(NSString *)name
      dispatchQueue:(dispatch_queue_t)queue
              block:(LLNotificationBlock)block {
    [self addObserver:observer name:name object:nil targetQueue:queue block:block];
}

- (void)addObserver:(id)observer
               name:(NSString *)name
             object:(id)object
              block:(LLNotificationBlock)block {
    [self addObserver:observer name:name object:object targetQueue:nil block:block];
}

- (void)addObserver:(id)observer
               name:(NSString *)name
             object:(id)object
        targetQueue:(dispatch_queue_t)queue
              block:(LLNotificationBlock)block {
    
    [self generateObserverManager:^(LLNotificationObserverManager *manager) {
        
        LLNotificationObserverIdentify *identify = [[LLNotificationObserverIdentify alloc] init];
        [identify configIndentifyWithName:name targerQueue:queue object:object block:block];
        [manager addNotificationIndentify:identify];
        
    } withObserver:observer];
}

- (void)generateObserverManager:(void(^)(LLNotificationObserverManager *))block
                   withObserver:(id)observer {
    NotificationPerformLocked(^{
        
        LLNotificationObserverManager *manager = (LLNotificationObserverManager *)objc_getAssociatedObject(observer, LL_NOTIFACTIONCENTER_MANAGER_KEY);
        
        if (!manager) {
            manager = [[LLNotificationObserverManager alloc] init];
            objc_setAssociatedObject(observer, LL_NOTIFACTIONCENTER_MANAGER_KEY, manager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        block(manager);
    });
}

#pragma mark remove

- (void)removeObserver:(id)observer name:(NSString *)name object:(id)object {
    NotificationPerformLocked(^{
        
        LLNotificationObserverManager *manager = (LLNotificationObserverManager *)objc_getAssociatedObject(observer, LL_NOTIFACTIONCENTER_MANAGER_KEY);
        if (manager) {
            [manager removeNotificationName:name];
        }
    });
}

- (void)removeObserver:(id)observer {
    NotificationPerformLocked(^{
        
        LLNotificationObserverManager *manager = (LLNotificationObserverManager *)objc_getAssociatedObject(observer, LL_NOTIFACTIONCENTER_MANAGER_KEY);
        if (manager) {
            [manager removeObserver];
        }
    });
}

#pragma mark post

- (void)postNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)postNotificationName:(NSString *)name object:(id)object {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:object];
}

- (void)postNotificationName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:object userInfo:userInfo];
}

#pragma mark help

static void NotificationPerformLocked(dispatch_block_t block) {
    static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
    pthread_mutex_lock(&lock);
    block();
    pthread_mutex_unlock(&lock);
}

@end
