//
//  LLNotificationObserverManager.h
//  BDuerStudy
//
//  Created by 啸峰 on 17/4/12.
//  Copyright © 2017年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LLNotificationBlock)(NSNotification *notification);

@interface LLNotificationObserverIdentify : NSObject

@property (nonatomic, strong) NSString *name;

- (void)configIndentifyWithName:(NSString *)name
                    targerQueue:(dispatch_queue_t)queue
                         object:(id)object
                          block:(LLNotificationBlock)block;

- (void)stopObserver;

@end

@interface LLNotificationObserverManager : NSObject

- (void)addNotificationIndentify:(LLNotificationObserverIdentify *)iden;

- (void)removeNotificationName:(NSString *)name;

- (void)removeObserver;
@end
