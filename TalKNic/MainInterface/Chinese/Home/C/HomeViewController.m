//
//  HomeViewController.m
//  TalkNic
//
//  Created by ldy on 15/10/20.
//  Copyright (c) 2015年 TalkNic. All rights reserved.
//

#import "VoiceViewController.h"
#import "HomeViewController.h"
#import "CouponViewController.h"
#import "AFNetworking.h"
#import "solveJsonData.h"
#import "Featured.h"
#import "HomeShowPicturwCell.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "EaseMobSDK.h"
#import "YGPayByAliTool.h"
#import "MBProgressHUD+MJ.h"
#import "ViewControllerUtil.h"

@interface HomeViewController ()<UISearchBarDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *dataArray;
    NSMutableDictionary *dataDic_1;
    NSString *praise;
    
    NSString *foreigner_uid;
    NSString *topic;
    NSString *user_pic;
    NSString *username;
    
    //NSString *userid;
    NSMutableArray *searChArr;//搜索结果数组
    NSDictionary * _dicP;//接受匹配信息的通知
    NSMutableArray *_piArr;//存放匹配信息
    NSString *_order_id_from_db;
}
@property (nonatomic,strong)UINavigationBar *bar;
@property (nonatomic,strong)UISearchDisplayController *searchController;
@property (nonatomic,strong)UISearchBar *searchBar;
@property(nonatomic,strong)NSMutableDictionary *dataDic;
@property(nonatomic)NSInteger seletedCount;
@property(nonatomic)float   price;
@property(nonatomic)BOOL    bMaskHidden;
@property(nonatomic)BOOL    bShowViewForm;
@end

@implementation HomeViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self resignFirstResponder];
    self.homecollectview.delegate = self;
    self.homecollectview.dataSource = self;
    // 把遮挡板放在当前window最外层

    [[UIApplication sharedApplication].keyWindow addSubview:self.zhedangbanview];
    self.bMaskHidden = YES;
    self.zhedangbanview.hidden = _bMaskHidden;
    self.seletedCount = 0;
    self.bShowViewForm = NO;
    [self.homecollectview addLegendHeaderWithRefreshingBlock:^{

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //FIXME use other words than featured
        [self requestDataMethod:@"featured"];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    //    // 头部的刷新
    //    self.homecollectview.header = [MJRefreshHeader headerWithRefreshingBlock:^{
    //        NSArray *titleArr = @[@"featured",@"latest",@"popular"];
    //        [self requestDataMethod:titleArr[self.segmentControl.selectedSegmentIndex]];
    //    }];
    
    //注册通知
    
    [self requestDataMethod:@"featured"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tongzhi:) name:@"tongzhi" object:nil];
}

-(void)tongzhi:(NSNotification *)dic
{
    TalkLog(@"接受匹配信息 -- %@",dic);
    TalkLog(@"%@",dic.userInfo);
    dataArray = (NSMutableArray *)dic.userInfo;
    
    [self.homecollectview reloadData];
    
}
#pragma mark - UICollectionViewDataSouce And UICollectionViewDelegate
//分区数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return dataArray.count;
}
//cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HomeShowPicturwCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeShowPicturwCell" forIndexPath:indexPath];
    
    //赋值
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",dataArray[indexPath.item][@"user_pic"]]];
    [cell.imageview sd_setImageWithURL:url placeholderImage:nil];
    cell.titlelb.text = [NSString stringWithFormat:@"Topic：%@",dataArray[indexPath.item][@"topic"]];
    cell.nickNameLb.text = [NSString stringWithFormat:@"Nick：%@",dataArray[indexPath.item][@"username"]];
    cell.dianzanLb.text = [NSString stringWithFormat:@"%@",dataArray[indexPath.item][@"praise"]];
    cell.pingfenLb.text = [NSString stringWithFormat:@"%@",dataArray[indexPath.item][@"star"]];;
    cell.occupationLb.text = [NSString stringWithFormat:@"%@",dataArray[indexPath.item][@"occupation"]];
    return cell;
    
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake( (kWidth - 20) / 2, (kWidth - 20) / 2 * 4 / 3 );
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

//点击cell触发事件
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //init 2 pop page
    self.seletedCount = 0;
    self.bShowViewForm = NO;
    [self showViewForm:_bShowViewForm];
    
    NSDictionary *dataDic = dataArray[indexPath.item];
    self.dataDic = [NSDictionary dictionaryWithDictionary:dataDic];
    
    self.bMaskHidden = NO;
    self.zhedangbanview.hidden = self.bMaskHidden;
    
    self.detailimage1.layer.masksToBounds = YES;
    self.detailimage1.layer.cornerRadius = 50 / 2 * (kWidth / 320);
    self.beijingView.layer.masksToBounds = YES;
    self.beijingView.layer.cornerRadius = 54 / 2 * (kWidth / 320);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",dataDic[@"user_pic"]]];
    [self.detailimage1 sd_setImageWithURL:url placeholderImage:nil];
    self.nameLb.text = dataDic[@"username"];
    self.addressLb.text = dataDic[@"nationality"];
    foreigner_uid = dataDic[@"uid"];
    
    //FIXME to add bio in server database
    self.bioLb.text = dataDic[@"bio"];
    self.topicLb.text = dataDic[@"topic"];
    
    // 点赞、评分
    self.dianzaiLb.text = dataDic[@"praise"];
    self.pingfenLb.text = dataDic[@"star"];
    [self.dianzangBtn addTarget:self action:@selector(dianzangBtn:) forControlEvents:(UIControlEventTouchUpInside)];

    //确定进入下一步
    [self.sureBtn addTarget:self action:@selector(sureBtn:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.cancelBtn addTarget:self action:@selector(cancelBtn:) forControlEvents:(UIControlEventTouchUpInside)];
    
}
//FIXME to cancel the praise when clicking again
- (void)dianzangBtn:(id)sender
{
    NSDictionary *parmeDic = @{@"cmd":@"15",@"user_id":self.dataDic[@"uid"],@"praise_id":_uid};
    TalkLog(@"Praise parmeDic: %@",parmeDic);
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [session POST:PATH_GET_LOGIN parameters:parmeDic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [solveJsonData changeType:responseObject];
        TalkLog(@"result: %@",dic);

        if([dic[@"code"] isEqualToString:@"2"])
        {
            int praiseCount = [self.dataDic[@"praise"] intValue] + 1;
            self.dianzaiLb.text = [NSString stringWithFormat:@"%d",praiseCount];
        }
        else if([dic[@"code"] isEqualToString:@"3"])
        {
            TalkLog(@"Praise succeeds return 3");
            [MBProgressHUD showError:AppPraised];
        }
        else if ([dic[@"code"] isEqualToString:@"4"])
        {
            TalkLog(@"Praise fails returns 4");
            [MBProgressHUD showError:AppPraiseFail];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error%@",error);
        [MBProgressHUD showError:kAlertNetworkError];
        return;
    }];
    
}

- (void)cancelBtn:(id)sender
{
    if (self.seletedCount % 2 == 1)
    {
        self.bShowViewForm = NO;
        [self showViewForm:_bShowViewForm];
        self.seletedCount --;
    }
    else if (self.seletedCount % 2 == 0)
    {
        self.bMaskHidden = YES;
        self.zhedangbanview.hidden = _bMaskHidden;
        self.bShowViewForm = NO;
        [self showViewForm:_bShowViewForm];
        self.seletedCount = 0;
        [self requestDataMethod:@"featured"];
        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //    [self requestDataMethod:@"featured"];
        //});
    }
}

- (void)sureBtn:(id)sender
{
    self.seletedCount ++;
    //1st page to 2nd page
    if (self.seletedCount % 2 == 1)
    {
        self.bShowViewForm = YES;
        [self showViewForm:_bShowViewForm];
        
        [self priceBtnAction];
        NSString *couponValue = @"0%";
        [self.youhuiquanBtn setTitle:couponValue forState:UIControlStateNormal];
        
        [self.youhuiquanBtn addTarget:self action:@selector(CouponAction) forControlEvents:(UIControlEventTouchUpInside)];
        [self.priceBtn addTarget:self action:@selector(priceBtnAction) forControlEvents:(UIControlEventTouchUpInside)];
        
    }
    //2nd page to pay
    else if (self.seletedCount % 2 == 0)
    {
        //进入支付页面
        self.bMaskHidden = YES;
        self.zhedangbanview.hidden = _bMaskHidden;
        TalkLog(@"foreigner UID = %@",foreigner_uid);
        
        //1. Check the user balance at first, if user has money in balance, then use it at first
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        session.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        NSMutableDictionary *parmes = [NSMutableDictionary dictionary];
        parmes[@"theory_time"] = @(DEFAULT_VOICE_MSG_DURATION_MINS);
        parmes[@"student_id"] = [NSNumber numberWithInt:[_uid intValue]];
        parmes[@"teacher_id"] = [NSNumber numberWithInt:[foreigner_uid intValue]];
        NSLog(@"parmes %@",parmes);
        
        [session POST:PATH_GET_ORDER parameters:parmes progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *dic = [solveJsonData changeType:responseObject];
            NSLog(@"result = %@",dic);
            _order_id_from_db = [dic objectForKey:@"order_id"];
            
            if ([[dic objectForKey:@"code" ] isEqualToString:@"2"])
            {
                [EaseMobSDK createOneChatViewWithConversationChatter:foreigner_uid Name:self.nameLb.text onNavigationController:self.navigationController];
                self.navigationController.tabBarItem.badgeValue = nil;
            }
            else if([[dic objectForKey:@"code" ] isEqualToString:@"5"])
            {
                float remain_price = [[dic objectForKey:@"balance"] floatValue];
                NSString *AliPayOrderId = [self generateTradeNO];
                [YGPayByAliTool payByAliWithSubjects:ALI_PAY_SUBJECT body:nil price:remain_price orderId:AliPayOrderId partner:ALI_PARTNER_ID seller:ALI_SELLER_ID privateKey:ALI_PRIVATE_KEY success:^(NSDictionary *info) {
                    NSLog(@"info = %@",info);
                    
                    NSString *resultStatus = info[@"resultStatus"];
                    NSString *result = info[@"result"];
                    
                    //Pay successful and record data in server
                    if(result.length > 0 && [resultStatus isEqualToString: @"9000"] )
                    {
                        //2. finish pay
                        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
                        session.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
                        NSMutableDictionary *parmes = [NSMutableDictionary dictionary];
                        parmes[@"theory_time"] = @(DEFAULT_VOICE_MSG_DURATION_MINS);//FIXME user choose time
                        parmes[@"order_id"] = [NSNumber numberWithInt:[_order_id_from_db intValue]];
                        NSLog(@"%@",parmes);
                        
                        [session POST:PATH_FINISH_ORDER_PAY parameters:parmes progress:^(NSProgress * _Nonnull uploadProgress) {

                        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            NSDictionary *dic = [solveJsonData changeType:responseObject];
                            NSLog(@"result = %@",dic);
                            if ([[dic objectForKey:@"code" ] isEqualToString:@"2"])
                            {
                                [MBProgressHUD showSuccess:@"Ali pay successful"];
                                [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"order_id"] forKey:@"order_id"];
                                NSInteger SingleChattedDuration = 0;
                                [EaseMobSDK createOneChatViewWithConversationChatter:foreigner_uid Name:self.nameLb.text onNavigationController:self.navigationController];
                                self.navigationController.tabBarItem.badgeValue = nil;
                            }
                            else
                            {
                                [MBProgressHUD showError:kAlertdataFailure];
                            }
                            
                            
                        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            NSLog(@"error%@",error);
                            [MBProgressHUD showError:kAlertNetworkError];
                            return;
                            
                        }];

                    }
                    else
                    {
                        [MBProgressHUD showError:kAlertAliPayFail];
                        TalkLog(@"Alipay fails");
                        return;
                    }
                }];
                
                return ;
            }
            else
                [MBProgressHUD showError:kAlertdataFailure];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error%@",error);
            [MBProgressHUD showError:kAlertNetworkError];
            return;
        }];

    }

}

- (void)charge{
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSMutableDictionary *parmes = [NSMutableDictionary dictionary];

    parmes[@"user_id"] = [NSNumber numberWithInt:[_uid intValue]];
    
    parmes[@"recharge_money"] = @"10";
    
    //    parmes[@"theory_time"] = @"";
    //    parmes[@"cmd"] = @"19";
    
    [session POST:PATH_ADD_MONEY parameters:parmes progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dic = [solveJsonData changeType:responseObject];
        NSLog(@"%@",dic);
        if ([[dic objectForKey:@"code"] isEqualToString:@"2"]) {
            
            // 充值成功
            NSLog(@"充值成功");
            //            [self getData];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"chatDuration"];
            
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error%@",error);
        [MBProgressHUD showError:kAlertNetworkError];
        return;
    }];
    
}

- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"01234789ABCDEFGHIJKLMNOPQRSTUVWXY";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand(time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}


- (void)CouponAction
{
    //Do not record bMaskHidden here to show the mask after return back
    //self.bMaskHidden = YES;
    self.zhedangbanview.hidden = YES;//_bMaskHidden;
    CouponViewController *couponVC = [[CouponViewController alloc]init];
    couponVC.uid = _uid;
    [self.navigationController pushViewController:couponVC animated:YES];
}

- (void)priceBtnAction
{
    self.price = 0.01;//DEFAULT_VOICE_MSG_DURATION_MINS * RMB_PER_MIN;
    NSString* pricelb = [[NSString alloc]initWithFormat:@"￥ %.1f/%d mins", self.price, DEFAULT_VOICE_MSG_DURATION_MINS];
    //self.priceBtn.titleLabel.text = pricelb;//[[NSString alloc]initWithFormat:@"%f for %d mins", self.price, DEFAULT_VOICE_MSG_DURATION_MINS];
    
    [self.priceBtn setTitle:pricelb forState:UIControlStateNormal];
}

-(void)searchBarView
{
    UISearchBar *searchbar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 129.0/2, kWidth, KHeightScaled(44))];
    UITextField *searchField = [searchbar valueForKey:@"_searchField"];
    searchField.textColor = [UIColor colorWithRed:125/255.0 green:194/255.0 blue:232/255.0 alpha:0.5f];
    [searchField setValue:[UIColor colorWithRed:125/255.0 green:194/255.0 blue:232/255.0 alpha:0.5f] forKeyPath:@"_placeholderLabel.textColor"];
    searchbar.delegate = self;
    searchbar.placeholder = AppSearch;
    
    self.searchBar.delegate = self;
    self.searchBar = searchbar;
    [self.view addSubview:searchbar];
    
    //    [self.searchBar setSearchFieldBackgroundImage:
    //     [UIImage imageNamed:@"search_icon.png"]forState:UIControlStateNormal];
    self.searchController = [[UISearchDisplayController alloc]initWithSearchBar:searchbar contentsController:self];
    self.searchController.searchResultsTableView.tableFooterView = [[UIView alloc]init];
    _searchController.searchResultsDataSource =self;
    _searchController.searchResultsDelegate =self;
    
    
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //    searchBar.hidden = YES;
}

-(void)segmentAction:(UISegmentedControl *)segment
{
    //NSArray *titleArr = @[@"featured"];//, @"latest",@"popular"];
    [self requestDataMethod:@"featured"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.homecollectview reloadData];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.hidden = YES;
    
    //self.tabBarController.tabBar.translucent = YES;
    //self.tabBarController.tabBar.hidden = YES;
    //[self initNavigationBar];
    
    //FIXME strange behavior in viewdidload
    ViewControllerUtil *vcUtil = [[ViewControllerUtil alloc]init];
    self.bar = [vcUtil ConfigNavigationBar:AppDiscover NavController: self.navigationController NavBar:self.bar];
    [self.view addSubview:self.bar];
    
    if (self.searchBar == nil)
    {
        [self searchBarView];
    }
    
    //Keep previous state
    self.zhedangbanview.hidden = _bMaskHidden;
    [self showViewForm:_bShowViewForm];
    
    // 界面出现时，显示featured的collectview
    //FIXME crash on plus
    //[self requestDataMethod:@"featured"];
}
-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBarHidden = NO;
    //    self.tabBarController.tabBar.translucent = NO;
    //    self.tabBarController.tabBar.hidden = NO;
}

#define mark ------ UISearchDisplayController的布局

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  searChArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"mycell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellId];
    }
    cell.textLabel.text = [[searChArr objectAtIndex:indexPath.row] valueForKey:@"username"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dataDic = searChArr[indexPath.row];
    self.dataDic = [NSMutableDictionary dictionaryWithDictionary:dataDic];
    
    self.seletedCount = 0;
    self.bMaskHidden = NO;
    self.zhedangbanview.hidden = _bMaskHidden;
    self.bShowViewForm = NO;
    [self showViewForm:_bShowViewForm];
    
    self.detailimage1.layer.masksToBounds = YES;
    self.detailimage1.layer.cornerRadius = 50 / 2 * (kWidth / 320);
    self.beijingView.layer.masksToBounds = YES;
    self.beijingView.layer.cornerRadius = 54 / 2 * (kWidth / 320);
    
    NSLog(@"self.dataDic%@",self.dataDic);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",dataDic[@"user_pic"]]];
    [self.detailimage1 sd_setImageWithURL:url placeholderImage:nil];
    self.nameLb.text = searChArr[indexPath.row][@"username"];
    
    foreigner_uid = searChArr[indexPath.row][@"uid"];
    self.addressLb.text = dataDic[@"nationality"];
    self.bioLb.text = dataDic[@"bio"];
    self.topicLb.text = dataDic[@"topic"];
    
    // 点赞、评分
    self.dianzaiLb.text = dataDic[@"praise"];
    self.pingfenLb.text = dataDic[@"star"];
    [self.dianzangBtn addTarget:self action:@selector(dianzangBtn:) forControlEvents:(UIControlEventTouchUpInside)];
    
    //确定进入下一步+
    [self.sureBtn addTarget:self action:@selector(sureBtn:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.cancelBtn addTarget:self action:@selector(cancelBtn:) forControlEvents:(UIControlEventTouchUpInside)];
    
    tableView.hidden = YES;
    
    self.searchBar.frame = CGRectMake(0, 129.0/2, kWidth, KHeightScaled(44));
    self.searchBar.alpha = 1.0f;
    //[self.searchBar resignFirstResponder];
    [self.searchController setActive:NO];
    
}

-(void)loadPayment
{
    
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchBar.frame = CGRectMake(0, 129.0 / 2, kWidth, KHeightScaled(44));
    //self.searchBar.alpha = 1.0f;
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    //self.searchBar.frame = CGRectMake(0, 129.0 / 2, kWidth, KHeightScaled(44));
    //self.searchBar.alpha = 1.0f;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    if (!searChArr)
    {
        searChArr = [[NSMutableArray alloc]init];
    }
    else
    {
        [searChArr removeAllObjects];
    }
    NSString *strSearch = searchBar.text;
    
    for (int i = 0; i<[dataArray count]; i++)
    {
        NSDictionary *searchDic = dataArray[i];
        NSString *searchStr = searchDic[@"username"];
        
        NSRange range = [searchStr rangeOfString:strSearch];
        if (range.location != NSNotFound)
        {
            //TalkLog(@"i = %d", i);
            [searChArr addObject:[dataArray objectAtIndex:i]];
        }
    }
    //TalkLog(@"all users count: %lu, %@",(unsigned long)[dataArray count], searChArr);
    //TalkLog(@"searching: %@",strSearch);
    
    
    [self.searchController.searchResultsTableView reloadData];
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    TalkLog(@"cancel");
}

- (void)setImage:(nullable UIImage *)iconImage forSearchBarIcon:(UISearchBarIcon)icon state:(UIControlState)state
{
    [self.searchBar setSearchFieldBackgroundImage:
     [UIImage imageNamed:@"search_icon.png"]forState:UIControlStateNormal];
}

- (void)requestDataMethod:(NSString *)discover
{
    [self.homecollectview.header endRefreshing];
    
    if (!dataArray) {
        dataArray = [NSMutableArray array];
    }
    else
    {
        [dataArray removeAllObjects];
    }
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSMutableDictionary *parmes = [NSMutableDictionary dictionary];
    parmes[@"cmd"] = @"10";
    parmes[@"discover"] = discover;
    [session POST:PATH_GET_LOGIN parameters:parmes progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideHUD];
        NSDictionary *dic = [solveJsonData changeType:responseObject];
        if ([[dic objectForKey:@"code"]isEqualToString:@"2"]) {
            
            NSArray *array = [dic objectForKey:@"result"];
            NSString *localUid = [[NSUserDefaults standardUserDefaults] valueForKey:@"uid"];
            for (NSDictionary *dic in array) {
                if (![[dic valueForKey:@"username"] isEqualToString:localUid]) {
                    [dataArray addObject:dic];
                }
            }
            TalkLog(@"数组  ＝＝＝＝＝ %@",dataArray);
            
            [self.homecollectview reloadData];
            
            TalkLog(@"dataArray count %lu",(unsigned long)[dataArray count]);
        }
        else if ([[dic objectForKey:@"code"]isEqualToString:@"3"])
        {
            [MBProgressHUD showError:kAlertdataFailure];
            return;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error%@",error);
        [MBProgressHUD showError:kAlertNetworkError];
        return;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.homecollectview reloadData];
        
    });
    
}

// 布局时，根据不同按钮，展示不同控件
- (void)showViewForm:(BOOL)isBool
{
    BOOL noBool = !isBool;
    self.jieshaoLb.hidden = isBool;
    self.bioLb.hidden =  isBool;
    self.dailyTopicLb2.hidden = noBool;
    self.fengexian2.hidden = noBool;
    self.fengexian3.hidden = noBool;
    self.dailyTopicLb1.hidden = isBool;
    self.topicLb.hidden = isBool;
    self.xiaofengexian1.hidden = noBool;
    self.xiaofengexian2.hidden = noBool;
    self.youhuiquanBtn.hidden = noBool;
    self.priceBtn.hidden = noBool;
    self.couponsLb.hidden = noBool;
    self.rmbLb.hidden = noBool;
    
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
