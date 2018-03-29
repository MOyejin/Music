//
//  MOAudioViewController.m
//  音频Demo
//
//  Created by mo on 2017/12/27.
//  Copyright © 2017年 momo. All rights reserved.
//

#import "MOAudioViewController.h"
#import <DFPlayer.h>
//#import <DFPlayerControlManager.h>
#import "YourDataModel.h"
#import <MJExtension.h>
#import "NSObject+Alert.h"
#import "UIImage+Blur.h"
#import "YourDataModel.h"

#import "MOMusicViewController.h"


#define  SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define  SCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height
//有关距离、位置
#define CountWidth(w)  ((w)/750.0)*SCREEN_WIDTH
#define CountHeight(hh) ([UIScreen mainScreen].bounds.size.height==812.0?((hh)/1334.0)*667.0:((hh)/1334.0)*SCREEN_HEIGHT)
#define topH SCREEN_HEIGHT - self.tabBarController.tabBar.frame.size.height-CountHeight(300)

@interface MOAudioViewController ()<UITableViewDelegate,UITableViewDataSource,DFPlayerDelegate,DFPlayerDataSource>


@property (nonatomic, strong) UITableView       *tableView;


@property (nonatomic, strong) NSMutableArray    *dataArray;//数据
@property (nonatomic, strong) NSMutableArray    *df_ModelArray;

@end

@implementation MOAudioViewController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self tableViewReloadData];
    NSLog(@"%ld",[DFPlayer shareInstance].state);
    
//     [[DFPlayerControlManager shareInstance] df_playerLyricTableviewResumeUpdate];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
    

}
- (void)initUI{
    

    CGRect rect = CGRectMake( 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    self.tableView = [[UITableView alloc] initWithFrame:rect];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = CountHeight(100);
    [self.view addSubview:self.tableView];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:cellId];
        cell.backgroundColor = [UIColor clearColor];
    }
    YourDataModel *model = self.dataArray[indexPath.row];
    
    NSString *audioType = @"网络音频";
    if (![model.audioUrl hasPrefix:@"http"]) {audioType = @"本地音频";}
    cell.textLabel.text = [NSString stringWithFormat:@"%ld--%@-%@(%@)",(long)indexPath.row,audioType,model.audioName,model.audioSinger];
    NSURL *url = [self translateIllegalCharacterWtihUrlStr:model.audioUrl];
    if ([DFPlayer df_playerCheckIsCachedWithAudioUrl:url]) {
        cell.tintColor = [UIColor blackColor];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.detailTextLabel.hidden = YES;
    return cell;
}

- (NSURL *)translateIllegalCharacterWtihUrlStr:(NSString *)yourUrl{
    //如果链接中存在中文或某些特殊字符，需要通过以下代码转译
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)yourUrl, (CFStringRef)@"!NULL,'()*+,-./:;=?@_~%#[]", NULL, kCFStringEncodingUTF8));
    //    NSString *encodedString = [yourUrl stringByAddingPercentEncodingWithAllowedCharacters:charactSet];
    return [NSURL URLWithString:encodedString];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
   

//    DFPlayerStateFailed,     // 播放失败
//    DFPlayerStateBuffering,  // 缓冲中
//    DFPlayerStatePlaying,    // 播放中
//    DFPlayerStatePause,      // 暂停播放
//    DFPlayerStateStopped     // 停止播放
    
    
    NSInteger state = [DFPlayer shareInstance].state;
    NSLog(@"%ld",state);
    
    
    DFPlayerModel *model = [DFPlayer shareInstance].currentAudioModel;
    
    MOMusicViewController *music = [MOMusicViewController shareMusic];
    
    if (model.audioId == indexPath.row && model != nil) {
        
        
    }else{
        
      
        if (state != 0 ) {
            
            [MOMusicViewController play:indexPath.row];
            
        }else{
            
            music.data = self.dataArray;
            music.rows = indexPath.row;
        }
    }
    
   
    
     [self.navigationController pushViewController:music animated:YES];
  
}

- (void)dealloc{
    
    [MOMusicViewController deallocShare];//释放对象
    [[DFPlayer shareInstance] df_deallocPlayer];//释放播放器
    
}
#pragma mark - 从plist中加载音频数据
- (NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
        NSString *path1 = [[NSBundle mainBundle] pathForResource:@"AudioData" ofType:@"plist"];
        NSMutableArray *arr = [[NSMutableArray alloc] initWithContentsOfFile:path1];
        for (int tag = 0; tag < 1; tag++) {
            for (int i = 0; i < arr.count; i++) {
                YourDataModel *model = [YourDataModel mj_objectWithKeyValues:arr[i]];
                if (i == 1) {

                    model.audioUrl = @"http://113.105.181.131:8888/javascript/kindeditor/asp.net/appfile_download.ashx?filepath=D:%5CSoonfor%5CMS_CRM%5CAttachment%5Cimage%5C20180327%5C20180327103303_9030%5C20180327103303.aac";
                }
                [_dataArray addObject:model];
            }
        }
      
    }
    return _dataArray;
}
- (void)tableViewReloadData{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

@end
