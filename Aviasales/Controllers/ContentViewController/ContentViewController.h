//
//  ContentViewController.h
//  aviasales
//
//  Created by Ilyas Tyumenev on 11.02.2021.
//  Copyright © 2021 Ilyas Tyumenev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentViewController : UIViewController

// свойства - изображения самолетов, заголовок и несколько слов о приложении
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) int index;
@property (nonatomic, strong) NSString *contentText;

@end
