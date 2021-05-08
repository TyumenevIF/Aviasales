//
//  APIManager.h
//  aviasales
//
//  Created by Ilyas Tyumenev on 10.01.2021.
//  Copyright © 2021 Ilyas Tyumenev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataManager.h"
#import "MapPrice.h"

// класс для работы с API Aviasales
@interface APIManager : NSObject

+ (instancetype)sharedInstance;
- (void)cityForCurrentIP:(void (^)(City *city))completion;
- (void)ticketsWithRequest:(SearchRequest)request withCompletion:(void (^)(NSArray *tickets))completion;
- (void)mapPricesFor:(City *)origin withCompletion:(void (^)(NSArray *prices))completion;

@end
