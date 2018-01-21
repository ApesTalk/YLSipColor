//
//  YLPaletteListController.m
//  YLLoveMark
//
//  Created by lumin on 2018/1/7.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//

#import "YLPaletteListController.h"
#import "Masonry.h"
#import "YLPaletteListCell.h"
#import "YLCaptureColorController.h"
#import "YLPaletteDetailController.h"
#import "YLPalette.h"
#import "Constant.h"

static NSString *cellIdentifier = @"YLPaletteListCell";

@interface YLPaletteListController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, YLPaletteDetailDelegate>
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *paletteList;
@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) UIButton *coverConrol;
@end

@implementation YLPaletteListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Color Picker";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    _paletteList = [NSMutableArray array];
    [self generateTestData];
    [self.view addSubview:self.table];
    self.table.contentInset = UIEdgeInsetsMake(0, 0, 70 + kHomeIndicatorHeight, 0);
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    [self.view addSubview:self.addBtn];
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@50).priorityHigh();
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-10-kHomeIndicatorHeight);
    }];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showKeyBoard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideKeyBoard:) name:UIKeyboardWillHideNotification object:nil];
}

- (UITableView *)table
{
    if(!_table){
        _table = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_table registerClass:[YLPaletteListCell class] forCellReuseIdentifier:cellIdentifier];
        _table.dataSource = self;
        _table.delegate = self;
        _table.tableFooterView = [UIView new];
        _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _table;
}

- (UIButton *)addBtn
{
    if(!_addBtn){
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addBtn.backgroundColor = [UIColor whiteColor];
        [_addBtn setImage:[UIImage imageNamed:@"pick"] forState:UIControlStateNormal];
        _addBtn.layer.cornerRadius = 25;
        _addBtn.layer.shadowColor = [UIColor blackColor].CGColor;
        _addBtn.layer.shadowOffset = CGSizeMake(0, -1);
        _addBtn.layer.shadowRadius = 4;
        _addBtn.layer.shadowOpacity = 0.2;
        [_addBtn addTarget:self action:@selector(addNewPalette) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addBtn;
}

- (UIButton *)coverConrol
{
    if(!_coverConrol){
        _coverConrol = [UIButton buttonWithType:UIButtonTypeCustom];
        [_coverConrol addTarget:self action:@selector(dismissCover) forControlEvents:UIControlEventTouchUpInside];
    }
    return _coverConrol;
}
- (void)setKeyBoardHeight:(CGFloat)keyBoardHeight
{
//    _table.contentInset = UIEdgeInsetsMake(0, 0, MAX(keyBoardHeight, 70), 0);
//    [UIView animateWithDuration:0.25 delay:0.f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//        [_table mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.bottom.equalTo(self.view).offset(-keyBoardHeight);
//        }];
//    } completion:nil];
}

#pragma mark---UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _paletteList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YLPaletteListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    YLPalette *pallete = [_paletteList objectAtIndex:indexPath.row];
    [cell refreshWithPalette:pallete];
    cell.titleField.tag = indexPath.row;
    cell.titleField.delegate = self;
    __weak typeof (self) weakSelf =  self;
    cell.clickColorBlock = ^(UIColor *color, NSInteger index) {
        //TODO:goto detail vc
        [weakSelf.view endEditing:YES];
        YLPaletteDetailController *detailVc = [[YLPaletteDetailController alloc]initWithPalette:pallete currentIndex:index];
        detailVc.delegate = weakSelf;
        [self presentViewController:detailVc animated:YES completion:nil];
    };
    return cell;
}


#pragma mark---UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [YLPaletteListCell height];
}

#pragma mark---UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSInteger row = textField.tag;
    _table.contentInset = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.view.bounds) - [YLPaletteListCell height], 0);
    [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    NSArray *visibleCellls = _table.visibleCells;
    for(YLPaletteListCell *cell in visibleCellls){
        if(cell.titleField.tag  != row){
            cell.alpha = 0.5;
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.table.contentInset = UIEdgeInsetsMake(0, 0, 70 + kHomeIndicatorHeight, 0);
    //save name
    NSInteger row = textField.tag;
    NSString *name = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(name.length > 0 && row < _paletteList.count){
        YLPalette *palette = [_paletteList objectAtIndex:row];
        palette.name = name;
        [_table reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark---keyboard notification
- (void)showKeyBoard:(NSNotification *)notification
{
    CGRect keyBoardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyBoardHeight = CGRectGetHeight(keyBoardFrame);
    [self showCover];
}

- (void)hideKeyBoard:(NSNotification *)notification
{
    self.table.contentInset = UIEdgeInsetsMake(0, 0, 70, 0);
    self.keyBoardHeight = 0;
    [self dismissCover];
}

#pragma mark---YLPaletteDetailDelegate
- (void)changedPalette:(YLPalette *)palette
{
    NSUInteger index = [_paletteList indexOfObject:palette];
    if(index != NSNotFound){
        //全部删除完了
        if(palette.colors.count == 0){
            [_paletteList removeObjectAtIndex:index];
            [_table reloadData];
        }else{
            [_paletteList replaceObjectAtIndex:index withObject:palette];
            [_table reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

#pragma mark---other methods
- (void)addNewPalette
{
    YLCaptureColorController *vc = [[YLCaptureColorController alloc]init];
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)showCover
{
    CGFloat y = CGRectGetHeight(self.navigationController.navigationBar.bounds) + [YLPaletteListCell height];
    self.coverConrol.frame = CGRectMake(0, y, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - y);
    [self.view addSubview:_coverConrol];
}

- (void)dismissCover
{
    [self.view endEditing:YES];
    if(_coverConrol){
        [_coverConrol removeFromSuperview];
    }
}

- (void)generateTestData
{
    NSMutableArray *colors = [NSMutableArray array];
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    //arc4random() % x  0到x-1之间的整数
    for(NSInteger i = 0; i < 10; i++){
        red = (arc4random() % 256) / 255.0;
        green = (arc4random() % 256) / 255.0;
        blue = (arc4random() % 256) / 255.0;
        UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        [colors addObject:color];
        YLPalette *palette = [[YLPalette alloc]initWithName:[NSString stringWithFormat:@"测试%li", i] colors:colors];
        [_paletteList addObject:palette];
    }
}

@end
