//
//  ViewController.m
//  RowAnimationCallback
//
//  Created by 余梦实 on 2018/3/24.
//  Copyright © 2018年 余梦石. All rights reserved.
//

#import "ViewController.h"
#import "UITableView+YMRowAnimationCallback.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *mainTable;

@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.dataArr = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        [_dataArr addObject:[NSString stringWithFormat:@"%@%@%@%@%@",@(i),@(i),@(i),@(i),@(i)]];
    }
    
}

- (IBAction)deleteFirstRow:(id)sender {
    if (_dataArr.count <= 1) {
        return;
    }
    [_dataArr removeObjectAtIndex:0];

    [_mainTable ym_animatAction:^(UITableView *table) {
        [table deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    } complete:^(UITableView *table) {
        [table reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = _dataArr[indexPath.row];
    if (indexPath.row == 0) {
        cell.textLabel.textColor = [UIColor redColor];
    } else {
        cell.textLabel.textColor = [UIColor blueColor];
    }
    return cell;
}

@end
