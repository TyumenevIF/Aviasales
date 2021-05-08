//
//  FirstViewController.m
//  aviasales
//
//  Created by Ilyas Tyumenev on 11.02.2021.
//  Copyright © 2021 Ilyas Tyumenev. All rights reserved.
//

#import "FirstViewController.h"
#import "ContentViewController.h"

#define CONTENT_COUNT 4

@interface FirstViewController ()

// У FirstViewController есть также собственные компоненты, такие как кнопка, которая будет перемещать пользователя на следующий экран и
// компонент для отображения страниц (UIPageControl).
@property (strong, nonatomic) UIButton *nextButton;
@property (strong, nonatomic) UIPageControl *pageControl;

@end

// Для более удобной работы с контентом создана структура contentData (Массив языка С с заголовком, текстом и названием изображения).
@implementation FirstViewController {
    struct firstContentData {
        __unsafe_unretained NSString *title;
        __unsafe_unretained NSString *contentText;
        __unsafe_unretained NSString *imageName;
    } contentData[CONTENT_COUNT];
}

// При загрузке создаются данные для отображения с помощью метода createContentDataArray. Затем устанавливается первый контроллер для
// отображения, а после конфигурируются кнопка и компонент отображения страниц.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self createContentDataArray];
    
    self.dataSource = self;
    self.delegate = self;
    ContentViewController *startViewController = [self viewControllerAtIndex:0];
    [self setViewControllers:@[startViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 150.0, self.view.bounds.size.width, 50.0)];
    _pageControl.numberOfPages = CONTENT_COUNT;
    _pageControl.currentPage = 0;
    _pageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    [self.view addSubview:_pageControl];
    
    _nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _nextButton.frame = CGRectMake(self.view.bounds.size.width - 100.0, self.view.bounds.size.height - 150.0, 100.0, 50.0);
    [_nextButton addTarget:self action:@selector(nextButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [_nextButton setTintColor:[UIColor blackColor]];
    [self updateButtonWithIndex:0];
    [self.view addSubview:_nextButton];
}

- (void)createContentDataArray {
    NSArray *titles = [NSArray arrayWithObjects:
                       NSLocalizedString(@"about_app_header", ""),
                       NSLocalizedString(@"tickets_header", ""),
                       NSLocalizedString(@"map_price_header", ""),
                       NSLocalizedString(@"favorites_header", ""),
                       nil];
    NSArray *contents = [NSArray arrayWithObjects:
                         NSLocalizedString(@"about_app_describe", ""),
                         NSLocalizedString(@"tickets_describe", ""),
                         NSLocalizedString(@"map_price_describe", ""),
                         NSLocalizedString(@"favorites_describe", ""),
                         nil];
    for (int i = 0; i < 4; ++i) {
        contentData[i].title = [titles objectAtIndex:i];
        contentData[i].contentText = [contents objectAtIndex:i];
        contentData[i].imageName = [NSString stringWithFormat:@"first_%d", i+1];
    }
}


// Для более удобного получения контроллера был создан метод viewControllerAtIndex, который на основе индекса создает контроллер для
// контента и возвращает его.
- (ContentViewController *)viewControllerAtIndex:(int)index {
    if (index < 0 || index >= CONTENT_COUNT) {
        return nil;
    }
    ContentViewController *contentViewController = [[ContentViewController alloc] init];
    contentViewController.title = contentData[index].title;
    contentViewController.contentText = contentData[index].contentText;
    contentViewController.image =  [UIImage imageNamed: contentData[index].imageName];
    contentViewController.index = index;
    return contentViewController;
}


// При изменении страницы будет осуществляться изменение текста у кнопки
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    if (completed) {
        int index = ((ContentViewController *)[pageViewController.viewControllers firstObject]).index;
        _pageControl.currentPage = index;
        [self updateButtonWithIndex:index];
    }
}


// Если пользователь дошел до последней страницы, то кнопка получит название “ДАЛЕЕ”, иначе “ГОТОВО”. При нажатии кнопки соответственно
// будет осуществляться либо переход на следующую страницу, либо полное закрытие
- (void)updateButtonWithIndex:(int)index {
    switch (index) {
        case 0:
        case 1:
        case 2:
            [_nextButton setTitle:NSLocalizedString(@"next_button", "") forState:UIControlStateNormal];
            _nextButton.tag = 0;
            break;
        case 3:;
            [_nextButton setTitle:NSLocalizedString(@"done_button", "") forState:UIControlStateNormal];
            _nextButton.tag = 1;
            break;
        default:
            break;
    }
}


- (void)nextButtonDidTap:(UIButton *)sender {
    int index = ((ContentViewController *)[self.viewControllers firstObject]).index;
    if (sender.tag) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"first_start"];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        __weak typeof(self) weakSelf = self;
        [self setViewControllers:@[[self viewControllerAtIndex:index+1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
            weakSelf.pageControl.currentPage = index+1;
            [weakSelf updateButtonWithIndex:index+1];
        }];
    }
}

#pragma mark - UIPageViewControllerDataSource

// методы протокола UIPageViewControllerDataSource - в них возвращается следующая и предыдущая страница соответственно.
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    int index = ((ContentViewController *)viewController).index;
    index--;
    return [self viewControllerAtIndex:index];
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    int index = ((ContentViewController *)viewController).index;
    index++;
    return [self viewControllerAtIndex:index];
}

@end
