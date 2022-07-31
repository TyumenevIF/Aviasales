//
//  FavoriteTicket+CoreDataProperties.h
//  aviasales
//
//  Created by Ilyas Tyumenev on 30.01.2021.
//  Copyright © 2021 Ilyas Tyumenev. All rights reserved.
//
//

#import "FavoriteTicket+CoreDataClass.h"

@interface FavoriteTicket (CoreDataProperties)

+ (NSFetchRequest<FavoriteTicket *> *_Nullable)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *created;
@property (nullable, nonatomic, copy) NSDate *departure;
@property (nullable, nonatomic, copy) NSDate *expires;
@property (nullable, nonatomic, copy) NSDate *returnDate;
@property (nullable, nonatomic, copy) NSString *airline;
@property (nullable, nonatomic, copy) NSString *from;
@property (nullable, nonatomic, copy) NSString *to;
@property (nonatomic) int64_t price;
@property (nonatomic) int16_t flightNumber;

@end
