//
//  NotificationCenter.m
//  aviasales
//
//  Created by Ilyas Tyumenev on 11.02.2021.
//  Copyright © 2021 Ilyas Tyumenev. All rights reserved.
//

#import "NotificationCenter.h"

@interface NotificationCenter () <UNUserNotificationCenterDelegate>

@end


@implementation NotificationCenter

+ (instancetype)sharedInstance {
    static NotificationCenter *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NotificationCenter alloc] init];
        
    });
    return instance;
}


// В registerService осуществляется запрос на получение доступа для отправления уведомлений, который будет происходить
// в момент первого запуска приложения
- (void)registerService {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (error) {
            NSLog(@"request authorization in not succeeded!");
        }
    }];
}


// При отправлении уведомления на основе переданной структуры формируется уведомление, добавляется в очередь и ожидает
// указанной даты для отображения пользователю.
- (void)sendNotification:(Notification)notification {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = notification.title;
    content.body = notification.body;
    content.sound = [UNNotificationSound defaultSound];
    
    if (notification.imageURL) {
        UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"image"
                                                                                              URL:notification.imageURL
                                                                                          options:nil
                                                                                            error:nil];
        if (attachment) {
            content.attachments = @[attachment];
        }
    }
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar componentsInTimeZone:[NSTimeZone systemTimeZone] fromDate:notification.date];
    NSDateComponents *newComponents = [[NSDateComponents alloc] init];
    newComponents.calendar = calendar;
    newComponents.timeZone = [NSTimeZone defaultTimeZone];
    newComponents.month = components.month;
    newComponents.day = components.day;
    newComponents.hour = components.hour;
    newComponents.minute = components.minute;
    
    UNCalendarNotificationTrigger *trigger =
    [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:newComponents repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Notification"
                                                                          content:content
                                                                          trigger:trigger];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:nil];
}


// Функция NotificationMake создает структуру на основе указанных параметров
Notification NotificationMake(NSString* _Nullable title,
                              NSString* _Nonnull body,
                              NSDate* _Nonnull date,
                              NSURL * _Nullable  imageURL) {
    Notification notification;
    notification.title = title;
    notification.body = body;
    notification.date = date;
    notification.imageURL = imageURL;
    return notification;
}

@end
