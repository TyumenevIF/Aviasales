//
//  ProgressView.m
//  aviasales
//
//  Created by Ilyas Tyumenev on 08.02.2021.
//  Copyright © 2021 Ilyas Tyumenev. All rights reserved.
//

#import "ProgressView.h"

@implementation ProgressView {
    BOOL isActive;
}

// ProgressView является наследником UIView. Имеет синглтон sharedInstance, через который полностью осуществляется обращение к
// методам класса. При инициализации создаются задний фон (изображение облаков), эффект размытия и создаются 5 самолетов.
+ (instancetype)sharedInstance {
    static ProgressView *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ProgressView alloc] initWithFrame: [UIApplication sharedApplication].windows[0].bounds];
        [instance setup];
    });
    return instance;
}


- (void)setup {
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    backgroundImageView.image = [UIImage imageNamed:@"cloud"];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.clipsToBounds = YES;
    [self addSubview:backgroundImageView];
    
    UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
    blurView.frame = self.bounds;
    [self addSubview:blurView];
    
    [self createPlanes];
}


- (void)createPlanes {
    for (int i = 1; i < 6; i++) {
        UIImageView *plane = [[UIImageView alloc] initWithFrame:CGRectMake(-50.0, ((float)i * 50.0) + 100.0, 50.0, 50.0)];
        plane.tag = i;
        plane.image = [UIImage imageNamed:@"plane"];
        [self addSubview:plane];
    }
}


// В методе startAnimating осуществляется анимированное перемещение самолетов от левого края к правому. Каждый самолет пролетает экран
// за секунду. Через 0,3 секунды после “вылета” первого самолета начинает перемещение второй и так далее по очереди. Когда очередь
// подойдет к концу все действия начнутся опять с первого самолета.
- (void)startAnimating:(NSInteger)planeId {
    if (!isActive) return;
    if (planeId >= 6) planeId = 1;

    UIImageView *plane = [self viewWithTag:planeId];
    if (plane) {
        [UIView animateWithDuration:1.0 animations:^{
            plane.frame = CGRectMake(self.bounds.size.width, plane.frame.origin.y, 50.0, 50.0);
        } completion:^(BOOL finished) {
            plane.frame = CGRectMake(-50.0, plane.frame.origin.y, 50.0, 50.0);
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self startAnimating:planeId+1];
        });
    }
}


// В методе show анимировано появляется все представление и начинается анимация.
- (void)show:(void (^)(void))completion {
    self.alpha = 0.0;
    isActive = YES;
    [self startAnimating:1];
    [[UIApplication sharedApplication].windows[0] addSubview:self];
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        completion();
    }];
}


// В методе dismiss представление анимировано исчезает с экрана и процесс анимации останавливается, благодаря изменению переменной isActive.
- (void)dismiss:(void (^)(void))completion {
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self->isActive = NO;
        if (completion) {
            completion();
        }
    }];
}

@end
