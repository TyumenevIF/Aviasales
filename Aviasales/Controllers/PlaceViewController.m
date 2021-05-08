//
//  PlaceViewController.m
//  aviasales
//
//  Created by Ilyas Tyumenev on 03.01.2021.
//  Copyright © 2021 Ilyas Tyumenev. All rights reserved.
//

#import "PlaceViewController.h"

#define ReuseIdentifier @"CellIdentifier"

@interface PlaceViewController ()

// Изначально объявляются приватные свойства:
// placeType - для хранения типа места (отправление или прибытие);
// tableView - таблица, в которой будут выводиться данные о городах или аэропортах;
// segmentedControl - переключатель для выбора источника данных;
// currentArray - массив для хранения и вывода значений для текущего источника данных.
// searchArray - массив найденных элементов
// searchController - контроллер поиска
@property (nonatomic) PlaceType placeType;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) NSArray *currentArray;
@property (nonatomic, strong) NSArray *searchArray;
@property (nonatomic, strong) UISearchController *searchController;


@end

@implementation PlaceViewController

- (instancetype)initWithType:(PlaceType)type {
    self = [super init];
    if (self) {
        _placeType = type;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
        
    // создается объект searchController и searchArray
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.obscuresBackgroundDuringPresentation = NO;
    _searchController.searchResultsUpdater = self;
    _searchArray = [NSArray new];    
    
    // создается таблица
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    // контроллер поиска устанавливается в качестве параметра navigationItem
    self.navigationItem.searchController = _searchController;
    
    // создается переключатель
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"segment_cities", ""),
                                                                    NSLocalizedString(@"segment_airports", "")]];
    [_segmentedControl addTarget:self action:@selector(changeSource) forControlEvents:UIControlEventValueChanged];
    _segmentedControl.tintColor = [UIColor blackColor];
    self.navigationItem.titleView = _segmentedControl;
    _segmentedControl.selectedSegmentIndex = 0;
    [self changeSource];
    
    // устанавливается название в зависимости от переданного типа
    if (_placeType == PlaceTypeDeparture) {
        self.title = NSLocalizedString(@"placetype_from", "");
    } else {
        self.title = NSLocalizedString(@"placetype_to", "");
    }
}


// реализуется метод changeSource, который вызывается при смене источника данных. В нем массиву currentArray присваивается значение нужного
// массива из DataManager (городов или аэропортов), а после обновляется таблица.
- (void)changeSource {
    switch (_segmentedControl.selectedSegmentIndex) {
        case 0:
            _currentArray = [[DataManager sharedInstance] cities];
            break;
        case 1:
            _currentArray = [[DataManager sharedInstance] airports];
            break;
        default:
            break;
    }
    [self.tableView reloadData];
}

#pragma mark - UISearchResultsUpdating

// updateSearchResultsForSearchController - обязательный метод для протокола UISearchResultsUpdating. Он вызывается каждый раз при
// обновлении поисковой строки. Благодаря NSPredicate фильтруется полный массив городов или аэропортов и готовое значение устанавливается
// для searchArray, а затем обновляется табличное представление.
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (searchController.searchBar.text) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[cd] %@", searchController.searchBar.text];
        _searchArray = [_currentArray filteredArrayUsingPredicate: predicate];
        [_tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource

// в методе numberOfRowsInSection осуществляется проверка: если контроллер поиска активен и количество найденных элементов больше 0, то
// возвращается значение элементов для них, иначе возвращается количество всех элементов.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchController.isActive && [_searchArray count] > 0) {
        return [_searchArray count];
    }
    return [_currentArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ReuseIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (_segmentedControl.selectedSegmentIndex == 0) {
        City *city = (_searchController.isActive && [_searchArray count] > 0) ? [_searchArray objectAtIndex:indexPath.row] :
                                                                                            [_currentArray objectAtIndex:indexPath.row];
        cell.textLabel.text = city.name;
        cell.detailTextLabel.text = city.code;
    }
    else if (_segmentedControl.selectedSegmentIndex == 1) {
        Airport *airport = (_searchController.isActive &&
                            [_searchArray count] > 0) ? [_searchArray objectAtIndex:indexPath.row] :
                                                                                            [_currentArray objectAtIndex:indexPath.row];
        cell.textLabel.text = airport.name;
        cell.detailTextLabel.text = airport.code;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

// реализуется метод протокола UITableViewDelegate для определения нажатия на ячейку, при котором с помощью делегата на главный экран
// передается выбранное место и контроллер закрывается
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DataSourceType dataType = ((int)_segmentedControl.selectedSegmentIndex) + 1;
    if (_searchController.isActive && [_searchArray count] > 0) {
        [self.delegate selectPlace:[_searchArray objectAtIndex:indexPath.row] withType:_placeType andDataType:dataType];
        _searchController.active = NO;
    } else {
        [self.delegate selectPlace:[_currentArray objectAtIndex:indexPath.row] withType:_placeType andDataType:dataType];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
