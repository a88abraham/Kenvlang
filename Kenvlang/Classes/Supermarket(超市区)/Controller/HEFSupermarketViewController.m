//
//  HEFSupermarketViewController.m
//  Kenvlang
//
//  Created by 贺恩发 on 16/1/26.
//  Copyright © 2016年 kknx. All rights reserved.
//

#import "HEFSupermarketViewController.h"
#import "HEFSearchBar.h"
#import "UIBarButtonItem+HEFBarButtonItem.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"

@interface HEFSupermarketViewController ()<UIWebViewDelegate,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UISearchBar *mySearchBar;
    UISearchDisplayController *searchDisplayController;
    
    UITableView *myTableView;

}
@property (nonatomic, weak) UIActivityIndicatorView *loadingView;
@property (nonatomic, copy) NSMutableArray *dataArray;
@property (nonatomic, copy) NSMutableArray *searchResults;
@end

@implementation HEFSupermarketViewController

-(NSMutableArray *)dataArray{

    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

-(NSMutableArray *)searchResults{

    if (!_searchResults) {
        _searchResults = [NSMutableArray array];
    }
    return _searchResults;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置导航条
    [self setNavigationBar];
    
    // 1. 创建webView, 展示首页
    UIWebView *homeWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, _WIDTH,_HEIGHT - 64)];
    // 添加代理  对webView的编辑
    homeWebView.delegate = self;
    // 根据屏幕大小自动调整页面尺寸
    homeWebView.scalesPageToFit = YES;
    // 禁止webView的滑动
    //homeWebView.scrollView.bounces = NO;
    [self.view addSubview:homeWebView];
    // 2. 设置请求URL
    
    NSString *urlString = [__BASE_URL stringByAppendingString:@"/Mobile/SeckillGoods/Index?source=ios"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    // 加载页面
    [homeWebView loadRequest:request];
    
    //3.创建一个加载蒙板
    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loadingView startAnimating];
    loadingView.center = CGPointMake(_WIDTH / 2, _HEIGHT / 2);
    
    [self.view addSubview:loadingView];
    self.loadingView = loadingView;
    
    //4.设置搜索结果的显示
    [self setSearchDisplayController];
    
    // Do any additional setup after loading the view.
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // 删除圈圈
    [self.loadingView removeFromSuperview];
    
}

// 设置导航条
- (void)setNavigationBar{
    // 1. 创建searchBar
    mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(70, 0, _WIDTH - 100, 30)];
    mySearchBar.placeholder = @"请输入关键字进行搜索";
    mySearchBar.delegate = self;
    
//    [mySearchBar setInputAccessoryView:;]
    // 2. 中间添加searchBar
    
    [self.navigationController.navigationBar addSubview:mySearchBar];
    
    // 3. 左侧百货区
    self.navigationItem.leftBarButtonItem
    = [UIBarButtonItem barButtonItemWithBackgroundImage:nil
                                       highlightedImage:nil
                                                  title:@"百货区"
                                              titleFont:14
                                                 target:nil
                                                 action:nil
                                       forControlEvents:UIControlEventTouchUpInside];

}

// 设置搜索结果的显示
- (void)setSearchDisplayController{

    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(70, 0, _WIDTH - 100, 30) style:UITableViewStylePlain];
    
    // 1. 初始化 searchDisplayController
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:mySearchBar contentsController:self];
    
    // 搜索界面的可见性状态
    searchDisplayController.active = NO;
    
    // 2.设置搜索结果代理
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
   
    // 3.设置搜索显示代理
    myTableView.dataSource = self;
    myTableView.delegate = self;
    [myTableView addSubview:mySearchBar];
    
    //_dataArray = [@[@"百度",@"六六",@"谷歌",@"苹果",@"and",@"table",@"view",@"and",@"and",@"苹果IOS",@"谷歌android",@"微软",@"微软WP",@"table",@"table",@"table",@"六六",@"六六",@"六六",@"table",@"table",@"table"]mutableCopy];
    
    [self.navigationController.navigationBar addSubview:myTableView];
}

#pragma mark --- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return _searchResults.count;
    }else{
        
        return _dataArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = _searchResults[indexPath.row];
    }
    else {
        cell.textLabel.text = _dataArray[indexPath.row];
    }
    return cell;
}
// 选中Cell的代理回调
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    PushView *pv = [[PushView alloc]initWithNibName:@"PushView" bundle:nil];
//    if (tableView == self.searchDisplayController.searchResultsTableView) {
//        pv.nStr = searchResults[indexPath.row];
//    }
//    else {
//        pv.nStr = dataArray[indexPath.row];
//    }
//    [self.navigationController pushViewController:pv animated:YES];
}

#pragma UISearchDisplayDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _searchResults = [[NSMutableArray alloc]init];
    if (mySearchBar.text.length>0&&![ChineseInclude isIncludeChineseInString:mySearchBar.text]) {
        for (int i=0; i<_dataArray.count; i++) {
            if ([ChineseInclude isIncludeChineseInString:_dataArray[i]]) {
                NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:_dataArray[i]];
                NSRange titleResult=[tempPinYinStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [_searchResults addObject:_dataArray[i]];
                }
                NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:_dataArray[i]];
                NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                if (titleHeadResult.length>0) {
                    [_searchResults addObject:_dataArray[i]];
                }
            }
            else {
                NSRange titleResult=[_dataArray[i] rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [_searchResults addObject:_dataArray[i]];
                }
            }
        }
    } else if (mySearchBar.text.length>0&&[ChineseInclude isIncludeChineseInString:mySearchBar.text]) {
        for (NSString *tempStr in _dataArray) {
            NSRange titleResult=[tempStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
            if (titleResult.length>0) {
                [_searchResults addObject:tempStr];
            }
        }
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.frame = CGRectMake(-_WIDTH, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
    [UIView animateWithDuration:0.7 animations:^{
        cell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
