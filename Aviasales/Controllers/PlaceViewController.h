//
//  PlaceViewController.h
//  aviasales
//
//  Created by Ilyas Tyumenev on 03.01.2021.
//  Copyright © 2021 Ilyas Tyumenev. All rights reserved.
//

// Контроллер будет отвечать за выбор города или аэропорта, из которого будет отправление (или прибытие). Данные для отображения будут
// получены из ранее созданного класса DataManager, в котором хранятся города, страны и аэропорты. При нажатии на какой-либо из городов
// необходимо вернуть пользователя на первоначальный экран и отобразить на нем выбранный элемент.

#import <UIKit/UIKit.h>
#import "DataManager.h"

// перечисление PlaceType необходимо для определения выбора места отправления или прибытия
typedef enum PlaceType {
    PlaceTypeArrival,
    PlaceTypeDeparture
} PlaceType;

// объявляется протокол PlaceViewControllerDelegate, который “поможет” сообщить другому контроллеру о том, что был сделан выбор конкретного
// места и передаст его в объявленном методе
@protocol PlaceViewControllerDelegate <NSObject>

- (void)selectPlace:(id)place withType:(PlaceType)placeType andDataType:(DataSourceType)dataType;

@end


@interface PlaceViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating>

@property (nonatomic, strong) id<PlaceViewControllerDelegate>delegate;
- (instancetype)initWithType:(PlaceType)type;

@end
