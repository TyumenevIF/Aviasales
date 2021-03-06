//
//  DataManager.m
//  aviasales
//
//  Created by Ilyas Tyumenev on 26/12/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

#import "DataManager.h"

@interface DataManager ()

// countriesArray, citiesArray, airportsArray — приватные массивы для хранения готовых объектов данных;
@property (nonatomic, strong) NSMutableArray *countriesArray;
@property (nonatomic, strong) NSMutableArray *citiesArray;
@property (nonatomic, strong) NSMutableArray *airportsArray;

@end


@implementation DataManager

// sharedInstance — синглтон  —  позволяет однозначно определить существование лишь одного объекта этого класса;
+ (instancetype)sharedInstance {
    static DataManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DataManager alloc] init];
    });
    return instance;
}


// loadData — метод для загрузки данных из файлов json;
- (void)loadData {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        NSArray *countriesJsonArray = [self arrayFromFileName:@"countries" ofType:@"json"];
        self->_countriesArray = [self createObjectsFromArray:countriesJsonArray withType: DataSourceTypeCountry];
        
        NSArray *citiesJsonArray = [self arrayFromFileName:@"cities" ofType:@"json"];
        self->_citiesArray = [self createObjectsFromArray:citiesJsonArray withType: DataSourceTypeCity];
        
        NSArray *airportsJsonArray = [self arrayFromFileName:@"airports" ofType:@"json"];
        self->_airportsArray = [self createObjectsFromArray:airportsJsonArray withType: DataSourceTypeAirport];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kDataManagerLoadDataDidComplete object:nil];
        });
    });
}


// В методе cityForIATA осуществляется сравнение всех объектов городов по значению кода и при наличии соответствия
// возвращается значение города
- (City *)cityForIATA:(NSString *)iata {
    if (iata) {
        for (City *city in _citiesArray) {
            if ([city.code isEqualToString:iata]) {
                return city;
            }
        }
    }
    return nil;
}


// createObjectsFromArray: — метод для создания массива готовых объектов из массива объектов NSDictionary. Входными
// параметрами метода являются сам массив объектов NSDictionary и тип данных (в какой объект будет преобразован)
- (NSMutableArray *)createObjectsFromArray:(NSArray *)array withType:(DataSourceType)type {
    NSMutableArray *results = [NSMutableArray new];
    
    for (NSDictionary *jsonObject in array) {
        if (type == DataSourceTypeCountry) {
            Country *country = [[Country alloc] initWithDictionary: jsonObject];
            [results addObject: country];
        }
        else if (type == DataSourceTypeCity) {
            City *city = [[City alloc] initWithDictionary: jsonObject];
            [results addObject: city];
        }
        else if (type == DataSourceTypeAirport) {
            Airport *airport = [[Airport alloc] initWithDictionary: jsonObject];
            [results addObject: airport];
        }
    }
    return results;
}


// arrayFromFileName: — метод для загрузки массива объектов NSDictionary из файлов json. Входными параметрами метода
// являются имя и тип файла.
- (NSArray *)arrayFromFileName:(NSString *)fileName ofType:(NSString *)type {
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:type];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

- (NSArray *)countries {
    return _countriesArray;
}

- (NSArray *)cities {
    return _citiesArray;
}

- (NSArray *)airports {
    return _airportsArray;
}

// Метод cityForLocation возвращает город из данных на основе местоположения. В нем выполняется перебор всех городов и
// сравнение округленных значений широты и долготы. При их совпадении метод возвращает город.
- (City *)cityForLocation:(CLLocation *)location {
    for (City *city in _citiesArray) {
        if (ceilf(city.coordinate.latitude) == ceilf(location.coordinate.latitude) &&
                ceilf(city.coordinate.longitude) == ceilf(location.coordinate.longitude)) {
            return city;
        }
    }
    return nil;
}

@end
