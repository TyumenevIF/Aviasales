//
//  MapViewController.m
//  aviasales
//
//  Created by Ilyas Tyumenev on 20.01.2021.
//  Copyright © 2021 Ilyas Tyumenev. All rights reserved.
//

#import "MapViewController.h"
#import "LocationService.h"
#import "APIManager.h"
#import <MapKit/MapKit.h>
#import "DataManager.h"

@interface MapViewController () <MKMapViewDelegate>

// Свойства самой карты (mapView), объекта, который отвечает за работу с местоположением (locationService), объект города отправления
// (origin), а также массив полученных от API объектов.
@property (strong, nonatomic) MKMapView *mapView;
@property (nonatomic, strong) LocationService *locationService;
@property (nonatomic, strong) City *origin;
@property (nonatomic, strong) NSArray *prices;

@end


@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // При загрузке контроллера создается карта, загружаются данные (этот функционал перенесен с MainViewController), а также он
    // подписывается на уведомления от DataManager – о том, что данные были полностью загружены, и от LocationService – о том, что было
    // получено текущее местоположение.
    self.title = NSLocalizedString(@"map_title_vc", "");
    
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.showsUserLocation = YES;
    [self.view addSubview:_mapView];
    
    [[DataManager sharedInstance] loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataLoadedSuccessfully) name:kDataManagerLoadDataDidComplete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentLocation:) name:kLocationServiceDidUpdateCurrentLocation object:nil];
}


// При получении уведомления о полной загрузке данных создается объект класса LocationService
- (void)dataLoadedSuccessfully {
    _locationService = [[LocationService alloc] init];
}


// Метод updateCurrentLocation отвечает за обновление региона и загрузку данных из API, так как в него передается текущее местоположение от
// уведомления. При успешной загрузке устанавливается значение для свойства prices.
- (void)updateCurrentLocation:(NSNotification *)notification {
    CLLocation *currentLocation = notification.object;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 1000000, 1000000);
    [_mapView setRegion: region animated: YES];
    
    if (currentLocation) {
        _origin = [[DataManager sharedInstance] cityForLocation:currentLocation];
        if (_origin) {
            [[APIManager sharedInstance] mapPricesFor:_origin withCompletion:^(NSArray *prices) {
                self.prices = prices;
            }];
        }
    }
}


// Cеттер, в котором удаляются текущие метки с карты и добавляются все из массива.
- (void)setPrices:(NSArray *)prices {
    _prices = prices;
    [_mapView removeAnnotations: _mapView.annotations];
 
    for (MapPrice *price in prices) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.title = [NSString stringWithFormat:@"%@ (%@)", price.destination.name, price.destination.code];
            annotation.subtitle = [NSString stringWithFormat:@"%ld руб.", (long)price.value];
            annotation.coordinate = price.destination.coordinate;
            [self->_mapView addAnnotation: annotation];
        });
    }
}

@end
