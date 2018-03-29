//
//  MOMusicViewController.m
//  音频Demo
//
//  Created by mo on 2017/12/27.
//  Copyright © 2017年 momo. All rights reserved.
//

#import "MOMusicViewController.h"
#import <DFPlayer.h>
#import <DFPlayerFileManager.h>
#import "NSObject+Alert.h"
#import "UIImage+Blur.h"
#import "YourDataModel.h"
#import <DFPlayerControlManager.h>


#define  SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define  SCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height
//有关距离、位置
#define CountWidth(w)  ((w)/750.0)*SCREEN_WIDTH
#define CountHeight(hh) ([UIScreen mainScreen].bounds.size.height==812.0?((hh)/1334.0)*667.0:((hh)/1334.0)*SCREEN_HEIGHT)
#define topH SCREEN_HEIGHT - self.tabBarController.tabBar.frame.size.height-CountHeight(150)
#define HDFGreenColor  [UIColor colorWithRed:66.0/255.0 green:196.0/255.0 blue:133.0/255.0 alpha:1]

@interface MOMusicViewController()<DFPlayerDelegate,DFPlayerDataSource,NSCopying,NSMutableCopying>

@property (nonatomic, strong) UIImageView       *backgroundImageView;//背景Veiw
@property (nonatomic, strong) NSMutableArray    *df_ModelArray;
@property (nonatomic, strong) NSMutableArray    *dataArray;//数据
@property (nonatomic, assign)NSInteger row; //判断自己播放第几条音频

@end

@implementation MOMusicViewController

static MOMusicViewController *music;
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    
    @synchronized (self){
        
        if (music == nil) {
            music = [super allocWithZone:zone];
        }
        return music;
    }
}
+ (void)deallocShare{
    [music removeFromParentViewController];
    music = nil;
}
+ (instancetype)shareMusic{
    
    return [[self alloc] init];
    
}

- (id)copyWithZone:(NSZone *)zone{
    return music;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    return music;
}

#pragma mark - 初始化DFPlayer
- (void)initDFPlayer{
    [[DFPlayer shareInstance] df_initPlayerWithUserId:nil];
    [DFPlayer shareInstance].dataSource  = self;
    [DFPlayer shareInstance].delegate    = self;
    [DFPlayer shareInstance].category    = DFPlayerAudioSessionCategoryPlayback;
    [DFPlayer shareInstance].isObserveWWAN = YES;
    //    [DFPlayer shareInstance].isManualToPlay = NO;
    //    [DFPlayer shareInstance].playMode = DFPlayerModeOnlyOnce;//DFPLayer默认单曲循环。
    [[DFPlayer shareInstance] df_reloadData];//须在传入数据源后调用（类似UITableView的reloadData）
    CGRect buffRect = CGRectMake(CountWidth(104), topH+CountHeight(28), CountWidth(542), CountHeight(4));
    CGRect proRect  = CGRectMake(CountWidth(104), topH+CountHeight(10), CountWidth(542), CountHeight(40));
    CGRect currRect = CGRectMake(CountWidth(10), topH+CountHeight(10), CountWidth(90), CountHeight(40));
    CGRect totaRect = CGRectMake(SCREEN_WIDTH-CountWidth(100), topH+CountHeight(10), CountWidth(90), CountHeight(40));
    CGRect playRect = CGRectMake(CountWidth(320), topH+CountHeight(70), CountWidth(110), CountWidth(110));
    CGRect nextRext = CGRectMake(CountWidth(490), topH+CountHeight(84), CountWidth(80), CountWidth(80));
    CGRect lastRect = CGRectMake(CountWidth(180), topH+CountHeight(84), CountWidth(80), CountWidth(80));
    CGRect typeRect = CGRectMake(CountWidth(40), topH+CountHeight(100), CountWidth(63), CountHeight(45));
    
    DFPlayerControlManager *manager = [DFPlayerControlManager shareInstance];
    //缓冲条
    [manager df_bufferProgressViewWithFrame:buffRect trackTintColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5] progressTintColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5] superView:self.backgroundImageView];
    //进度条

    [manager df_sliderWithFrame:proRect minimumTrackTintColor:HDFGreenColor maximumTrackTintColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.0] trackHeight:CountHeight(4) thumbSize:(CGSizeMake(CountWidth(34), CountWidth(34))) superView:self.backgroundImageView];
    //当前时间
    UILabel *curLabel = [manager df_currentTimeLabelWithFrame:currRect superView:self.backgroundImageView];
    curLabel.textColor = [UIColor whiteColor];
    //总时间
    UILabel *totLabel = [manager df_totalTimeLabelWithFrame:totaRect superView:self.backgroundImageView];
    totLabel.textColor = [UIColor whiteColor];
    
    //播放模式按钮
    [manager df_typeControlBtnWithFrame:typeRect superView:self.backgroundImageView block:nil];
    //播放暂停按钮
    [manager df_playPauseBtnWithFrame:playRect superView:self.backgroundImageView block:nil];
    //下一首按钮
    [manager df_nextAudioBtnWithFrame:nextRext superView:self.backgroundImageView block:nil];
    //上一首按钮
    [manager df_lastAudioBtnWithFrame:lastRect superView:self.backgroundImageView block:nil];
    
    
//    [[DFPlayer shareInstance] df_setPlayerWithPreviousAudioModel];

    DFPlayerModel *model = self.df_ModelArray[self.row];
    [[DFPlayer shareInstance] df_playerPlayWithAudioId:model.audioId];
//
//    DFPlayerModel *playerModel =  [DFPlayer shareInstance].currentAudioModel;
//    if (playerModel.audioId != model.audioId) {
//
////        [[DFPlayer shareInstance] df_setPlayerWithPreviousAudioModel];
////
//
////        DFPlayerInfoModel *model = [[DFPlayerInfoModel alloc] init];
////        model
////         [[DFPlayer shareInstance] df_setPlayerWithPreviousAudioModel];
////         [[DFPlayer shareInstance] df_playerPlayWithAudioId:2];
//
//      //播放
////        [[DFPlayer shareInstance] df_playerPlayWithAudioId:model.audioId];
////        [[DFPlayer shareInstance] df_setPreviousAudioModel];
//
//    }

}

+ (void)play:(NSInteger)audioID{
    
    [[DFPlayer shareInstance] df_playerPlayWithAudioId:audioID];
//    [[DFPlayer shareInstance] df_setPreviousAudioModel];
    
}

- (void)dealloc{
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
    
    [self initBackGroundView];
    [self initDFPlayer];
}

#pragma mark - UI
- (void)initBackGroundView{
    self.backgroundImageView = [[UIImageView alloc] init];
    self.backgroundImageView.frame = self.view.bounds;
    self.backgroundImageView.backgroundColor = [UIColor whiteColor];
    self.backgroundImageView.image = [UIImage imageNamed:@"default_bg.jpg"];
    self.backgroundImageView.userInteractionEnabled = YES;
    [self.view addSubview:self.backgroundImageView];
    //这里使用iOS8以后才能使用的虚化方法
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    effectView.frame = self.backgroundImageView.frame;
    [self.backgroundImageView addSubview:effectView];
}

#pragma mark - DFPLayer dataSource
- (NSArray<DFPlayerModel *> *)df_playerModelArray{
    if (_df_ModelArray.count == 0) {
        _df_ModelArray = [NSMutableArray array];
    }else{
        [_df_ModelArray removeAllObjects];
    }
    for (int i = 0; i < self.dataArray.count; i++) {
        YourDataModel *yourModel    = self.dataArray[i];
        DFPlayerModel *model        = [[DFPlayerModel alloc] init];
        model.audioId               = i;//****重要。AudioId从0开始，仅标识当前音频在数组中的位置。
        if ([yourModel.audioUrl hasPrefix:@"http"]) {//网络音频
            model.audioUrl  = [self translateIllegalCharacterWtihUrlStr:yourModel.audioUrl];
        }else{//本地音频
            NSString *path = [[NSBundle mainBundle] pathForResource:yourModel.audioUrl ofType:@""];
            if (path) {model.audioUrl = [NSURL fileURLWithPath:path];}
        }
        [_df_ModelArray addObject:model];
    }
    
    return self.df_ModelArray;
}
- (DFPlayerInfoModel *)df_playerAudioInfoModel:(DFPlayer *)player{
    
    YourDataModel *yourModel        = self.dataArray[player.currentAudioModel.audioId];
    
    DFPlayerInfoModel *infoModel    = [[DFPlayerInfoModel alloc] init];
    
    //音频名 歌手 专辑名
    infoModel.audioName     = yourModel.audioName;
    infoModel.audioSinger   = yourModel.audioSinger;
    infoModel.audioAlbum    = yourModel.audioAlbum;
    
    //歌词
    NSString *lyricPath     = [[NSBundle mainBundle] pathForResource:yourModel.audioLyric ofType:nil];
    infoModel.audioLyric    = [NSString stringWithContentsOfFile:lyricPath encoding:NSUTF8StringEncoding error:nil];
    //配图
    NSURL *imageUrl         = [NSURL URLWithString:yourModel.audioImage];
    NSData *imageData       = [NSData dataWithContentsOfURL:imageUrl];
    infoModel.audioImage    = [UIImage imageWithData: imageData];
    return infoModel;
}

#pragma mark - DFPlayer delegate
//加入播放队列
- (void)df_playerAudioWillAddToPlayQueue:(DFPlayer *)player{
//    [self tableViewReloadData];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *audioImage = player.currentAudioInfoModel.audioImage;
        if (audioImage) {
            CGFloat imgW = audioImage.size.height*SCREEN_WIDTH/SCREEN_HEIGHT;
            CGRect imgRect = CGRectMake((audioImage.size.width-imgW)/2, 0, imgW, audioImage.size.height);
            audioImage = [audioImage getSubImage:imgRect];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *audioName = player.currentAudioInfoModel.audioName;
            self.navigationItem.title = [NSString stringWithFormat:@"当前音频：%@",audioName];
            self.backgroundImageView.image = audioImage;
        });
    });
}
//缓冲进度代理
- (void)df_player:(DFPlayer *)player bufferProgress:(CGFloat)bufferProgress totalTime:(CGFloat)totalTime{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:player.currentAudioModel.audioId
                                                inSection:0];
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"正在缓冲%lf",bufferProgress];
//    cell.detailTextLabel.hidden = NO;
}
//播放进度代理
- (void)df_player:(DFPlayer *)player progress:(CGFloat)progress currentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:player.currentAudioModel.audioId
                                                inSection:0];
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"当前进度%lf--当前时间%.0f--总时长%.0f",progress,currentTime,totalTime];
//    cell.detailTextLabel.hidden = NO;
}
//状态信息代理
- (void)df_player:(DFPlayer *)player didGetStatusCode:(DFPlayerStatusCode)statusCode{

    if (statusCode == 0) {
        [self showAlertWithTitle:@"没有网络连接" message:nil yesBlock:nil];
        return;
    }else if(statusCode == 1){
        [self showAlertWithTitle:@"继续播放将产生流量费用" message:nil noBlock:nil yseBlock:^{
            [DFPlayer shareInstance].isObserveWWAN = NO;
            [[DFPlayer shareInstance] df_playerPlayWithAudioId:player.currentAudioModel.audioId];
        }];
        return;
    }else if(statusCode == 2){
        [self showAlertWithTitle:@"请求超时" message:nil yesBlock:nil];
        return;
    }else if(statusCode == 8){


    }


//    NSString *cacheFilePath = [DFPlayerFileManager df_isExistAudioFileWithURL:model.audioUrl];
//    NSLog(@"-- DFPlayer： 是否有缓存：%@",cacheFilePath?@"有":@"无");
//
//    NSString *urlAbsoluteStr = [DFPlayer shareInstance].previousAudioModel.audioUrlAbsoluteString;
//    NSLog(@"---上次播放地址%@", urlAbsoluteStr);
//
//    BOOL JUD = [[DFPlayer shareInstance] df_setPreviousAudioModel];
//
//    if (!JUD) {
//
//         [[DFPlayer shareInstance] df_playerPlayWithAudioId:model.audioId];
//    }

//    NSLog(@"------------%d",JUD);

}

- (NSURL *)translateIllegalCharacterWtihUrlStr:(NSString *)yourUrl{
    //如果链接中存在中文或某些特殊字符，需要通过以下代码转译
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)yourUrl, (CFStringRef)@"!NULL,'()*+,-./:;=?@_~%#[]", NULL, kCFStringEncodingUTF8));
    //    NSString *encodedString = [yourUrl stringByAddingPercentEncodingWithAllowedCharacters:charactSet];
    return [NSURL URLWithString:encodedString];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
    
//    [[DFPlayer shareInstance] df_deallocPlayer];
}

- (void)setData:(NSMutableArray *)data{
    _dataArray = data;
}

- (void)setRows:(NSInteger)rows{
    _row = rows;
}

- (void)applicationWillTerminate{
    [[DFPlayer shareInstance] df_setPreviousAudioModel];
}


@end
