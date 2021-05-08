//
//  DataManager.h
//  aviasales
//
//  Created by Ilyas Tyumenev on 26/12/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Country.h"
#import "City.h"
#import "Airport.h"

// kDataManagerLoadDataDidComplete — константа, которая содержит имя уведомления
#define kDataManagerLoadDataDidComplete @"DataManagerLoadDataDidComplete"

// DataSourceType — перечисление с возможными типами данных
typedef enum DataSourceType {
    DataSourceTypeCountry,
    DataSourceTypeCity,
    DataSourceTypeAirport
} DataSourceType;


// SearchRequest - структура, которая будет хранить информацию для создания запроса
typedef struct SearchRequest {
    __unsafe_unretained NSString *origin;
    __unsafe_unretained NSString *destination;
    __unsafe_unretained NSDate *departDate;
    __unsafe_unretained NSDate *returnDate;
} SearchRequest;


@interface DataManager : NSObject

// sharedInstance — синглтон — чтобы можно было однозначно определить существование лишь одного объекта этого класса
+ (instancetype)sharedInstance;

// loadData — метод для загрузки данных из файлов json
- (void)loadData;

// cityForIATA - осуществляется сравнение всех объектов городов по значению кода
- (City *)cityForIATA:(NSString *)iata;

// countries, cities, airports — массивы для хранения готовых объектов данных, доступных только для чтения.
@property (nonatomic, strong, readonly) NSArray *countries;
@property (nonatomic, strong, readonly) NSArray *cities;
@property (nonatomic, strong, readonly) NSArray *airports;

// метод cityForLocation возвращает город из данных на основе местоположения
- (City *)cityForLocation:(CLLocation *)location;

@end
