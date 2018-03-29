//
//  MOMusicViewController.h
//  音频Demo
//
//  Created by mo on 2017/12/27.
//  Copyright © 2017年 momo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DFPlayerModel;
@interface MOMusicViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *data;//数据

@property (nonatomic, assign)NSInteger rows;

+ (instancetype)shareMusic;

+ (void)play:(NSInteger)audioID;

+ (void)deallocShare;

@end
