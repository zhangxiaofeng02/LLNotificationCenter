//
//  LLNotifactionCenter.h
//  BDuerStudy
//
//  Created by 啸峰 on 17/4/12.
//  Copyright © 2017年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLNotificationObserverManager.h"

@interface LLNotifactionCenter : NSObject

#pragma mark defaultCenter

+ (instancetype)defaultCenter;

#pragma mark add observer

- (void)addObserver:(id)observer
               name:(NSString *)name
             object:(id)object
        targetQueue:(dispatch_queue_t)queue
              block:(LLNotificationBlock)block;

- (void)addObserver:(id)observer
               name:(NSString *)name
              block:(LLNotificationBlock)block;

- (void)addObserver:(id)observer
               name:(NSString *)name
      dispatchQueue:(dispatch_queue_t)queue
              block:(LLNotificationBlock)block;

- (void)addObserver:(id)observer
               name:(NSString *)name
             object:(id)object
              block:(LLNotificationBlock)block;

#pragma mark remove observer

- (void)removeObserver:(id)observer name:(NSString *)name object:(id)object;

- (void)removeObserver:(id)observer;

#pragma mark post notification

- (void)postNotification:(NSNotification *)notification;

- (void)postNotificationName:(NSString *)name object:(id)object;

- (void)postNotificationName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo;

@end
