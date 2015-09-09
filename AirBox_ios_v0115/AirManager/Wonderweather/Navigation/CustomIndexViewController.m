//
//  CustomIndexViewController.m
//  wonderweather
//
//  Created by 先丰 刘 on 14-6-25.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import "CustomIndexViewController.h"
#import "ImageString.h"
#import "Toast+UIView.h"
#import "CityManager.h"
#import "CurrentCityWeather.h"

@interface CustomIndexViewController ()
{
    NSMutableArray *_selectedArray;
    int _count;
}
@end

@implementation CustomIndexViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _count = 0;
    _selectedArray = [[NSMutableArray alloc] init];
    _indexArray = @[
                    @"空调开启指数",
                    @"晨练指数",
                    @"舒适度指数",
                    @"穿衣指数",
                    @"钓鱼指数",
                    @"防晒指数",
                    @"逛街指数",
                    @"感冒指数",
                    @"划船指数",
                    @"交通指数",
                    @"路况指数",
                    @"晾晒指数",
                    @"美发指数",
                    @"啤酒指数",
                    @"放风筝指数",
                    @"空气污染扩散条件指数",
                    @"化妆指数",
                    @"旅游指数",
                    @"紫外线强度指数",
                    @"风寒指数",
                    @"心情指数",
                    @"运动指数",
                    @"雨伞指数",
                    @"中暑指数"
                    ];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *nameArray;
    if ([userDefaults objectForKey:@"selectIndexArray"])
    {
        nameArray = [userDefaults objectForKey:@"selectIndexArray"];
    }else
    {
        nameArray = @[@"雨伞指数",@"感冒指数",
                      @"逛街指数",@"舒适度指数",
                      @"穿衣指数",@"旅游指数",
                      @"运动指数",@"空调开启指数",
                      @"紫外线强度指数"];
    }
    
    for (int i = 0; i < _indexArray.count; i ++)
    {
        BOOL select = NO;
        [_selectedArray addObject:[NSNumber numberWithBool:select]];
    }
    
    for (int j = 0; j < nameArray.count; j ++)
    {
        for (int i = 0; i < _indexArray.count; i ++)
        {
            if ([[nameArray objectAtIndex:j] isEqualToString:[_indexArray objectAtIndex:i]]) {
                [_selectedArray replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
                _count ++;
            }
        }
    }

    [self layoutView];
    [self createTableView];
    
    [Utility setExclusiveTouchAll:self.view];
    // Do any additional setup after loading the view from its nib.
}

- (void)layoutView
{
    //判断是不是ios7
    if (IOS7) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        view.backgroundColor = [UIColor blackColor];
       [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [UIApplication sharedApplication].statusBarHidden = NO;
        [self.view addSubview:view];
#endif
    }
    _baseview.frame = CGRectMake(0, ADDHEIGH, 320, VIEWHEIGHT);
    
}

- (void)createTableView
{
    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, _baseview.frame.size.height - 44) style:UITableViewStylePlain];
    tableview.delegate = self;
    tableview.dataSource = self;
    [_baseview addSubview:tableview];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _indexArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [self initCellView:cell];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self updateCellView:indexPath cell:cell];
    return cell;
}

- (void)initCellView :(UITableViewCell *)cell
{
    UIImageView *indexImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 55, 55  )];
    indexImageView.contentMode = UIViewContentModeScaleAspectFit;
    indexImageView.tag = 1;
    [cell.contentView addSubview:indexImageView];
    
    UILabel *indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, 170, 30)];
    indexLabel.tag = 2;
    [indexLabel setAdjustsFontSizeToFitWidth:YES];
    [cell.contentView addSubview:indexLabel];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 35, 170, 30)];
    contentLabel.tag = 3;
    contentLabel.font = [UIFont systemFontOfSize:13.f];
    [contentLabel setAdjustsFontSizeToFitWidth:YES];
    [cell.contentView addSubview:contentLabel];
    
    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(260.0f, 20.0f, 20.0f, 28.0f)];
    switchView.on = NO;
    [switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:switchView];
}

-(void)updateCellView:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell
{
    NSString *name = [_indexArray objectAtIndex:indexPath.row];

    UIImageView *indexImageView = (UIImageView *)[cell viewWithTag:1];
    NSString *imgStr = [ImageString getIndexHeadImageStr:name];
    indexImageView.image = [UIImage imageNamed:imgStr];
    
    /*----------------------ybyao-------------------*/
    UILabel *indexLabel = (UILabel *)[cell viewWithTag:2];
    indexLabel.text =NSLocalizedString(name,@"CustomIndexViewController.m");//ybyao,指数名字
    
    UILabel *contentLabel = (UILabel *)[cell viewWithTag:3];
    contentLabel.text =NSLocalizedString([ImageString getIndexContentStr:name],@"CustomIndexViewController.m");//ybyao,指数内容
    
    UISwitch *switchView = (UISwitch *)(UIImageView *)[[cell.contentView subviews] objectAtIndex:3];
    switchView.tag = indexPath.row + 10;
    NSNumber *boolNum = [_selectedArray objectAtIndex:indexPath.row];
    BOOL select = boolNum.boolValue;
    switchView.on = select;
}

- (void)switchAction:(id)sender
{
    DDLogFunction();
    UISwitch * tmpSwitch = (UISwitch *)sender;
    NSMutableArray *selectIndexArry = [[NSMutableArray alloc] init];
    for (int i = 0; i < _selectedArray.count; i ++) {
        NSNumber *boolNum = [_selectedArray objectAtIndex:i];
        if (boolNum.boolValue) {
            [selectIndexArry addObject:[_indexArray objectAtIndex:i]];
        }
    }
    DDLogCVerbose(@"num=%d",selectIndexArry.count);
    //    if (_count > 8)
    if (selectIndexArry.count > 8)
    {
        if (tmpSwitch.on)
        {
            tmpSwitch.on = NO;
            /*------------------------------ybyao---------------------------*/
            [self.view makeToast:NSLocalizedString(@"最多添加九个指数",@"CustomIndexViewController.m")
                        duration:1
                        position:@"bottom"
             ];
            return;
        }else
        {
            [_selectedArray replaceObjectAtIndex:(tmpSwitch.tag - 10) withObject:[NSNumber numberWithBool:NO]];
            _count --;
            return;
        }
    }
    
    if (tmpSwitch.on)
    {
        [_selectedArray replaceObjectAtIndex:(tmpSwitch.tag - 10) withObject:[NSNumber numberWithBool:YES]];
        _count ++;
        
    }else
    {
        [_selectedArray replaceObjectAtIndex:(tmpSwitch.tag - 10) withObject:[NSNumber numberWithBool:NO]];
        _count --;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    DDLogFunction();
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)commitAction:(id)sender
{
    DDLogFunction();
    NSMutableArray *selectIndexArry = [[NSMutableArray alloc] init];
    for (int i = 0; i < _selectedArray.count; i ++) {
        NSNumber *boolNum = [_selectedArray objectAtIndex:i];
        if (boolNum.boolValue) {
            [selectIndexArry addObject:[_indexArray objectAtIndex:i]];
        }
    }
    
    if (selectIndexArry.count < 9) {
        /*----------------------------------ybyao-----------------------------*/
        [self.view makeToast:NSLocalizedString(@"最少选择九个指数",@"CustomIndexViewController.m")
                    duration:1
                    position:@"bottom"
         ];
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:selectIndexArry forKey:@"selectIndexArray"];
    [userDefaults synchronize];
    
    CurrentCityWeather *_weather  = [[CityManager sharedManager] currentCityWeather];
        if (_citySelectedProtocol != nil) {
        [_citySelectedProtocol citySelected:_weather.city];
    }
    [self.navigationController popViewControllerAnimated:YES];

}
@end
