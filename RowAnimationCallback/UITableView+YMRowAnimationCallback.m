//
//  UITableView+YMRowAnimationCallback.m
//  RowAnimationCallback
//
//  Created by 余梦实 on 2018/3/24.
//  Copyright © 2018年 余梦石. All rights reserved.
//

#import "UITableView+YMRowAnimationCallback.h"

@implementation UITableView (YMRowAnimationCallback)

- (void)ym_animatAction:(void(^)(UITableView *table))action
               complete:(void(^)(UITableView *table))callback {
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        callback(self);
    }];
    action(self);
    [CATransaction commit];
}

@end
