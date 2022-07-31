//
//  MainViewController.m
//  aviasales
//
//  Created by Ilyas Tyumenev on 25/12/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

#import "MainViewController.h"
#import "DataManager.h"
#import "PlaceViewController.h"
#import "APIManager.h"
#import "Ticket.h"
#import "TicketsViewController.h"
#import "ProgressView.h"
#import "FirstViewController.h"

@interface MainViewController () <PlaceViewControllerDelegate>

@property (nonatomic, strong) UIView *placeContainerView;
@property (nonatomic, strong) UIButton *departureButton;
@property (nonatomic, strong) UIButton *arrivalButton;
@property (nonatomic) SearchRequest searchRequest;
@property (nonatomic, strong) UIButton *searchButton;

@end


@implementation MainViewController

// При открытии главного контроллера будет осуществляться проверка истинности значения сохраненного в NSUserDefaults и
// если оно ложно, то пользователю не был показан вводный экран и необходимо его отобразить, иначе все действия будут
// проигнорированы. Для этого был реализован специальный метод в главном контроллере, который будет вызываться в
// viewDidAppear:
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self presentFirstViewControllerIfNeeded];
}


- (void)presentFirstViewControllerIfNeeded {
    BOOL isFirstStart = [[NSUserDefaults standardUserDefaults] boolForKey:@"first_start"];
    if (!isFirstStart) {
        FirstViewController *firstViewController = [[FirstViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        [self presentViewController:firstViewController animated:YES completion:nil];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[DataManager sharedInstance] loadData];
    
    self.view.backgroundColor = [UIColor systemTealColor];
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.title = NSLocalizedString(@"main_title_vc", "");
    
    // контейнер для формы поиска и тень для нее
    _placeContainerView = [[UIView alloc] initWithFrame:CGRectMake(20.0,
                                                                   140.0,
                                                                   [UIScreen mainScreen].bounds.size.width - 40.0,
                                                                   170.0)];
    _placeContainerView.backgroundColor = [UIColor whiteColor];
    _placeContainerView.layer.shadowColor = [[[UIColor blackColor] colorWithAlphaComponent:0.1] CGColor];
    _placeContainerView.layer.shadowOffset = CGSizeZero;
    _placeContainerView.layer.shadowRadius = 20.0;
    _placeContainerView.layer.shadowOpacity = 1.0;
    _placeContainerView.layer.cornerRadius = 6.0;

    // кнопка отправления
    _departureButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_departureButton setTitle:NSLocalizedString(@"main_from", "") forState: UIControlStateNormal];
    _departureButton.tintColor = [UIColor blackColor];
    _departureButton.frame = CGRectMake(10.0,
                                        20.0,
                                        _placeContainerView.frame.size.width - 20.0,
                                        60.0);
    _departureButton.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    _departureButton.layer.cornerRadius = 4.0;
    [_departureButton addTarget:self action:@selector(placeButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.placeContainerView addSubview:_departureButton];
    
    // кнопка прибытия
    _arrivalButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_arrivalButton setTitle:NSLocalizedString(@"main_to", "") forState: UIControlStateNormal];
    _arrivalButton.tintColor = [UIColor blackColor];
    _arrivalButton.frame = CGRectMake(10.0,
                                      CGRectGetMaxY(_departureButton.frame) + 10.0,
                                      _placeContainerView.frame.size.width - 20.0,
                                      60.0);
    _arrivalButton.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    _arrivalButton.layer.cornerRadius = 4.0;
    [_arrivalButton addTarget:self action:@selector(placeButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.placeContainerView addSubview:_arrivalButton];
    [self.view addSubview: _placeContainerView];
    
    // кнопка поиска
    _searchButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_searchButton setTitle:NSLocalizedString(@"main_search", "") forState:UIControlStateNormal];
    _searchButton.tintColor = [UIColor whiteColor];
    _searchButton.frame = CGRectMake(30.0,
                                     CGRectGetMaxY(_placeContainerView.frame) + 30,
                                     [UIScreen mainScreen].bounds.size.width - 60.0,
                                     60.0);
    _searchButton.backgroundColor = [UIColor blackColor];
    _searchButton.layer.cornerRadius = 8.0;
    _searchButton.titleLabel.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightBold];
    [_searchButton addTarget:self action:@selector(searchButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    _searchButton.enabled = NO;
    [self.view addSubview:_searchButton];
    
    // После создания всех компонентов контроллер подписывается на уведомления от DataManager, которые сообщат о полной
    // загрузке данных из json файлов
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataLoadedSuccessfully)
                                                 name:kDataManagerLoadDataDidComplete
                                               object:nil];
}


// при нажатии кнопки поиска (если выбраны место отправления и назначения) будет отображаться анимированный индикатор
// загрузки, до той поры, пока не будет полностью загружен необходимый контент
- (void)searchButtonDidTap:(UIButton *)sender {
    if (_searchRequest.origin && _searchRequest.destination) {
        [[ProgressView sharedInstance] show:^{
            [[APIManager sharedInstance] ticketsWithRequest:self->_searchRequest withCompletion:^(NSArray *tickets) {
                [[ProgressView sharedInstance] dismiss:^{
                    if (tickets.count > 0) {
                        TicketsViewController *ticketsViewController = [[TicketsViewController alloc] initWithTickets:tickets];
                        [self.navigationController showViewController:ticketsViewController sender:self];
                    } else {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"alas", "") message:NSLocalizedString(@"tickets_not_found", "") preferredStyle: UIAlertControllerStyleAlert];
                        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"close", "")
                                                                            style:(UIAlertActionStyleDefault)
                                                                          handler:nil]];
                        [self presentViewController:alertController animated:YES completion:nil];
                    }
                }];
            }];
        }];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", "") message:NSLocalizedString(@"not_set_place_arrival_or_departure", "") preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"close", "")
                                                            style:(UIAlertActionStyleDefault)
                                                          handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


- (void)dataLoadedSuccessfully {
    [[APIManager sharedInstance] cityForCurrentIP:^(City *city) {
        [self setPlace:city withDataType:DataSourceTypeCity andPlaceType:PlaceTypeDeparture
             forButton:self->_departureButton];
    }];
}


// метод, который вызывается при нажатии на кнопки отправления или прибытия. В нем создается объект класса
// PlaceViewController, а затем на него осуществляется переход
- (void)placeButtonDidTap:(UIButton *)sender {
    PlaceViewController *placeViewController;
    if ([sender isEqual:_departureButton]) {
        placeViewController = [[PlaceViewController alloc] initWithType: PlaceTypeDeparture];
    } else {
        placeViewController = [[PlaceViewController alloc] initWithType: PlaceTypeArrival];
    }
    placeViewController.delegate = self;
    [self.navigationController pushViewController: placeViewController animated:YES];
}

#pragma mark - PlaceViewControllerDelegate

// метод selectPlace протокола PlaceViewControllerDelegate, который вызывает метод setPlace, в котором уже
// устанавливается название города необходимой кнопке, а также добавляется информация в структуру searchRequest
- (void)selectPlace:(id)place withType:(PlaceType)placeType andDataType:(DataSourceType)dataType {
    [self setPlace:place withDataType:dataType andPlaceType:placeType forButton: (placeType == PlaceTypeDeparture)
     ? _departureButton : _arrivalButton ];
}


- (void)setPlace:(id)place withDataType:(DataSourceType)dataType andPlaceType:(PlaceType)placeType
       forButton:(UIButton *)button {
    NSString *title;
    NSString *iata;
    if (dataType == DataSourceTypeCity) {
        City *city = (City *)place;
        title = city.name;
        iata = city.code;
    }
    else if (dataType == DataSourceTypeAirport) {
        Airport *airport = (Airport *)place;
        title = airport.name;
        iata = airport.cityCode;
    }
    
    if (placeType == PlaceTypeDeparture) {
        _searchRequest.origin = iata;
    } else {
        _searchRequest.destination = iata;
    }    
    
    [button setTitle: title forState: UIControlStateNormal];
    self.searchButton.enabled = _searchRequest.origin && _searchRequest.destination;
}

@end
