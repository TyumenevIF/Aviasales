//
//  TicketsViewController.h
//  aviasales
//
//  Created by Ilyas Tyumenev on 11.01.2021.
//  Copyright © 2021 Ilyas Tyumenev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TicketsViewController : UITableViewController

- (instancetype)initWithTickets:(NSArray *)tickets;
- (instancetype)initFavoriteTicketsController;

@end
