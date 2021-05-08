//
//  LocationService.m
//  aviasales
//
//  Created by Ilyas Tyumenev on 20.01.2021.
//  Copyright © 2021 Ilyas Tyumenev. All rights reserved.
//

#import "LocationService.h"
#import <UIKit/UIKit.h>

@interface LocationService () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

@end


@implementation LocationService

- (instancetype)init {
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        [_locationManager requestAlwaysAuthorization];
    }
    return self;
}


// При смене статуса доступа к сервисам определения местоположения вызывается метод делегата didChangeAuthorizationStatus, также метод будет
// вызван, если пользователь уже разрешил доступ. В данном методе проверяется текущий статус, если пользователь разрешил доступ к геолокации
// даже на время работы приложения, начинается работа по определению местоположения, однако, если пользователь отказался предоставлять
// доступ к геолокации открывается диалоговое окно, которое сообщает о невозможности определения города.
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [_locationManager startUpdatingLocation];
    } else if (status != kCLAuthorizationStatusNotDetermined) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Упс!"
                                                                                 message:@"Не удалось определить текущий город!"
                                                                          preferredStyle: UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Закрыть" style:(UIAlertActionStyleDefault) handler:nil]];
        [[UIApplication sharedApplication].windows[0].rootViewController presentViewController:alertController animated:YES completion:nil];
    }
}


// Если пользователь дал разрешение на использование геолокации, то после запуска службы будет вызван метод  didUpdateLocations, в котором
// будет получена текущая геолокации и отправлено уведомление с полученным результатом.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (_currentLocation == nil) {
        _currentLocation = [locations firstObject];
        [_locationManager stopUpdatingLocation];
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationServiceDidUpdateCurrentLocation object:_currentLocation];
    }
}

@end
