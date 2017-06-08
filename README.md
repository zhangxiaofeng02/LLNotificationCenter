# LLNotificationCenter

LLNotification 解决NSNotifaction和多线程的问题

### 问题起源：

无论在哪个线程注册了Notification，处理这个Notification的线程一定是和发送这个Notification处在同一个线程的
这就会造成一些问题，比如收到通知在子线程，这个时候处理了UI就会很危险

### 具体问题讨论参见：
https://segmentfault.com/a/1190000005889055

### 解决方案：
<code>LLNotificationCenter</code> 提供了3个关键类

<code>LLNotificationCenter</code>: 接口上完全模仿了NSNotificationCenter，提供了addObserver..,removeObserver,postNotification等方法<br>
<br>
<code>LLNotificationIdentify</code>: 通知标识类，每个通知都是注册到了一个identify对象上，包含了通知名字，处理通知的block等<br>
<br>
<code>LLNotificationIdentifyManger</code>：通知管理类，每个观察者observer都会通过Associate关联一个Manager对象，每个Manager对象又会维护一个字典，字典里保存了该Manager需要处理的通知
<br>

### 注册监听：
<pre><code>
/**
 注册通知

 @param observer 观察者
 @param name 通知名字
 @param object 信息
 @param queue 期待处理通知的目标线程
 @param block 处理通知的回调，所在的线程即为queue所代表的线程
 */
- (void)addObserver:(id)observer
               name:(NSString *)name
             object:(id)object
        targetQueue:(dispatch_queue_t)queue
              block:(LLNotificationBlock)block;
</code></pre>
<br>

### 移除监听：
<pre><code>
- (void)removeObserver:(id)observer name:(NSString *)name object:(id)object;
</code></pre>
<br>

### 发送通知：
<pre><code>
- (void)postNotificationName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo;
</code></pre>
