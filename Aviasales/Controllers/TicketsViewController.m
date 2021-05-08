//
//  TicketsViewController.m
//  aviasales
//
//  Created by Ilyas Tyumenev on 11.01.2021.
//  Copyright © 2021 Ilyas Tyumenev. All rights reserved.
//

#import "TicketsViewController.h"
#import "TicketTableViewCell.h"
#import "CoreDataHelper.h"
#import "NotificationCenter.h"

#define TicketCellReuseIdentifier @"TicketCellIdentifier"

@interface TicketsViewController ()

@property (nonatomic, strong) NSArray *tickets;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UITextField *dateTextField;

@end


@implementation TicketsViewController {
    BOOL isFavorites;
    TicketTableViewCell *notificationCell;
}

// Конструктор initFavoriteTicketsController, при котором контроллер настраивает свою работу конкретно для избранных билетов.
// Для проверки используется переменная isFavorite, которой устанавливается значение Истина при инициализации только этим конструктором.
- (instancetype)initFavoriteTicketsController {
    self = [super init];
    if (self) {
        isFavorites = YES;
        self.tickets = [NSArray new];
        self.title = NSLocalizedString(@"favorites_title_vc", "");
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerClass:[TicketTableViewCell class] forCellReuseIdentifier:TicketCellReuseIdentifier];
    }
    return self;
}


// Для инициализации создан собственный конструктор, в который передается массив объектов Ticket, которые необходимо отобразить в таблице.
// В нем устанавливается имя для контроллера, регистрируется ячейка таблицы, создаются скрытый _dateTextField и _datePicker, а также
// добавляется кнопка “готово” для клавиатуры
- (instancetype)initWithTickets:(NSArray *)tickets {
    self = [super init];
    if (self) {
        _tickets = tickets;
        self.title = NSLocalizedString(@"tickets_title", "");
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerClass:[TicketTableViewCell class] forCellReuseIdentifier:TicketCellReuseIdentifier];
        
        _datePicker = [[UIDatePicker alloc] init];
        if (@available(iOS 13.4, *)) {
            _datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        } else {
            // Fallback on earlier versions
        }
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        _datePicker.minimumDate = [NSDate date];
        
        _dateTextField = [[UITextField alloc] initWithFrame:self.view.bounds];
        _dateTextField.hidden = YES;
        _dateTextField.inputView = _datePicker;
        
        UIToolbar *keyboardToolbar = [[UIToolbar alloc] init];
        [keyboardToolbar sizeToFit];
        UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                       target:nil
                                                                                       action:nil];
        UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                       target:self
                                                                                       action:@selector(doneButtonDidTap:)];
        keyboardToolbar.items = @[flexBarButton, doneBarButton];
        
        _dateTextField.inputAccessoryView = keyboardToolbar;
        [self.view addSubview:_dateTextField];
    }
    return self;
}


// В методе viewDidAppear обновляется массив избранных билетов и перезагружается таблица. Это необходимо для обновления контента каждый раз
// когда пользователь заново открывает данный экран, так как он может перейти и добавить новый билет, а затем вернуться в избранное и
// контент уже должен быть обновлен.
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (isFavorites) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        _tickets = [[CoreDataHelper sharedInstance] favorites];
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

// Реализуются методы для отображения данных, а также создается ячейка и передается значение объекта билета
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tickets.count;
}


// В зависимости от значения переменной isFavorite, в методе cellForRowAtIndexPath выбирается свойство ячейки, которому необходимо
// установить значение ticket или favoriteTicket (которое будет добавлено позже).
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TicketTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TicketCellReuseIdentifier forIndexPath:indexPath];
    if (isFavorites) {
        cell.favoriteTicket = [_tickets objectAtIndex:indexPath.row];
    } else {
        cell.ticket = [_tickets objectAtIndex:indexPath.row];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140.0;
}


// В методе didSelectRowAtIndexPath ничего не происходит при истинности isFavorite, иначе пользователю отображается диалоговое окно,
// в котором предлагается добавить либо удалить билет из избранного, в зависимости от его текущего статуса, также предлагается действие
// для создания уведомления. При его выборе становится активным _dateTextField, благодаря чему отображается _datePicker. Кроме этого
// устанавливается значение выбранной ячейки. При нажатии кнопки “Done” создается уведомление на выбранную дату и добавляется в очередь.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isFavorites) return;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Действия с билетом"
                                                                             message:@"Что необходимо сделать с выбранным билетом?"
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *favoriteAction;
    if ([[CoreDataHelper sharedInstance] isFavorite: [_tickets objectAtIndex:indexPath.row]]) {
        favoriteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"remove_from_favorite", "")
                                                  style:UIAlertActionStyleDestructive
                                                handler:^(UIAlertAction * _Nonnull action) {
            [[CoreDataHelper sharedInstance] removeFromFavorite:[self->_tickets objectAtIndex:indexPath.row]];
        }];
    } else {
        favoriteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"add_to_favorite", "")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            [[CoreDataHelper sharedInstance] addToFavorite:[self->_tickets objectAtIndex:indexPath.row]];
        }];
    }
    
    UIAlertAction *notificationAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"remind_me", "")
                                                                 style:(UIAlertActionStyleDefault)
                                                               handler:^(UIAlertAction * _Nonnull action) {
        self->notificationCell = [tableView cellForRowAtIndexPath:indexPath];
        [self->_dateTextField becomeFirstResponder];
        }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Закрыть"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:favoriteAction];
    [alertController addAction:notificationAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)doneButtonDidTap:(UIBarButtonItem *)sender {
    if (_datePicker.date && notificationCell) {
        NSString *message = [NSString stringWithFormat:@"%@ - %@ за %@ руб.", notificationCell.ticket.from, notificationCell.ticket.to, notificationCell.ticket.price];
        NSURL *imageURL;
        Notification notification = NotificationMake(NSLocalizedString(@"ticket_reminder", ""), message, _datePicker.date, imageURL);
        [[NotificationCenter sharedInstance] sendNotification:notification];

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"success", "") message:[NSString stringWithFormat:NSLocalizedString(@"notification_will_be_sent", ""), "- %@", _datePicker.date] preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"close", "") style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    _datePicker.date = [NSDate date];
    notificationCell = nil;
    [self.view endEditing:YES];
}

@end
