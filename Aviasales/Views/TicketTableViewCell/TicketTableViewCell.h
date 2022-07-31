//
//  TicketTableViewCell.h
//  aviasales
//
//  Created by Ilyas Tyumenev on 11.01.2021.
//  Copyright © 2021 Ilyas Tyumenev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"
#import "APIManager.h"
#import "Ticket.h"
#import "FavoriteTicket+CoreDataClass.h"

// метод для формирования ссылки на логотип авиакомпании
#define AirlineLogo(iata) [NSURL URLWithString:[NSString stringWithFormat:@"https://pics.avs.io/200/200/%@.png", iata]];

@interface TicketTableViewCell : UITableViewCell

@property (nonatomic, strong) Ticket *ticket;
@property (nonatomic, strong) FavoriteTicket *favoriteTicket;

@end
