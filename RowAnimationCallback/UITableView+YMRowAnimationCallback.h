//
//  UITableView+YMRowAnimationCallback.h
//  RowAnimationCallback
//
//  Created by 余梦实 on 2018/3/24.
//  Copyright © 2018年 余梦石. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (YMRowAnimationCallback)

- (void)ym_animatAction:(void(^)(UITableView *table))action
               complete:(void(^)(UITableView *table))callback;

@end
