//
//  NotificationCenter.h
//  aviasales
//
//  Created by Ilyas Tyumenev on 11.02.2021.
//  Copyright © 2021 Ilyas Tyumenev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

// структура Notification для хранения информации об уведомлении
typedef struct Notification {
    __unsafe_unretained NSString * _Nullable title;
    __unsafe_unretained NSString * _Nonnull body;
    __unsafe_unretained NSDate * _Nonnull date;
    __unsafe_unretained NSURL * _Nullable imageURL;
} Notification;

//У NotificationCenter есть метод для получения доступа к отправке уведомлений и метод для их отправления
@interface NotificationCenter : NSObject

+ (instancetype _Nonnull)sharedInstance;

- (void)registerService;
- (void)sendNotification:(Notification)notification;

Notification NotificationMake(NSString* _Nullable title, NSString* _Nonnull body, NSDate* _Nonnull date, NSURL * _Nullable  imageURL);

@end
