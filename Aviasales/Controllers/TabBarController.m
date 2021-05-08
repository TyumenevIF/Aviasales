//
//  TabBarController.m
//  aviasales
//
//  Created by Ilyas Tyumenev on 25.01.2021.
//  Copyright © 2021 Ilyas Tyumenev. All rights reserved.
//

#import "TabBarController.h"
#import "MapViewController.h"
#import "MainViewController.h"
#import "TicketsViewController.h"

@interface TabBarController ()

@end


@implementation TabBarController

// При инициализации TabBarController создаются все необходимые контроллеры и устанавливается синий цвет, который будет отмечать выбранный элемент
- (instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.viewControllers = [self createViewControllers];
        self.tabBar.tintColor = [UIColor blueColor];
    }
    return self;
}


// В методе createViewControllers создается массив контроллеров. В нем поочередно создается главный контроллер, tabBarItem, после чего
// создается контроллер навигации, которому передается главный экран в качестве первого. Затем этот контроллер навигации добавляется в
// массив. Аналогичные действия выполняются и для контроллеров MapViewController.
- (NSArray<UIViewController*> *)createViewControllers {
    NSMutableArray<UIViewController*> *controllers = [NSMutableArray new];
    
    MainViewController *mainViewController = [[MainViewController alloc] init];
    mainViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"search_tab", "") image:[UIImage imageNamed:@"search"] selectedImage:[UIImage imageNamed:@"search_selected"]];
    UINavigationController *mainNavigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    [controllers addObject:mainNavigationController];
    
    MapViewController *mapViewController = [[MapViewController alloc] init];
    mapViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"map_tab", "") image:[UIImage imageNamed:@"map"] selectedImage:[UIImage imageNamed:@"map_selected"]];
    UINavigationController *mapNavigationController = [[UINavigationController alloc] initWithRootViewController:mapViewController];
    [controllers addObject:mapNavigationController];
    
    TicketsViewController *favoriteViewController = [[TicketsViewController alloc] initFavoriteTicketsController];
    favoriteViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"favorites_tab", "") image:[UIImage imageNamed:@"favorite"] selectedImage:[UIImage imageNamed:@"favorite_selected"]];
    UINavigationController *favoriteNavigationController = [[UINavigationController alloc] initWithRootViewController:favoriteViewController];
    [controllers addObject:favoriteNavigationController];
        
    return controllers;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


@end
