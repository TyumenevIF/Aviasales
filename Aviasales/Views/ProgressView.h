//
//  ProgressView.h
//  aviasales
//
//  Created by Ilyas Tyumenev on 08.02.2021.
//  Copyright © 2021 Ilyas Tyumenev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressView : UIView

+ (instancetype)sharedInstance;

// два метода для отображения и скрытия
- (void)show:(void (^)(void))completion;
- (void)dismiss:(void (^)(void))completion;

@end
