//
//  FavoriteTicket+CoreDataProperties.m
//  aviasales
//
//  Created by Ilyas Tyumenev on 30.01.2021.
//  Copyright © 2021 Ilyas Tyumenev. All rights reserved.
//
//

#import "FavoriteTicket+CoreDataProperties.h"

@implementation FavoriteTicket (CoreDataProperties)

+ (NSFetchRequest<FavoriteTicket *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"FavoriteTicket"];
}

@dynamic created;
@dynamic departure;
@dynamic expires;
@dynamic returnDate;
@dynamic airline;
@dynamic from;
@dynamic to;
@dynamic price;
@dynamic flightNumber;

@end
