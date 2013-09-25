//
//  DetailViewController.h
//  WordBook
//
//  Created by Takeshi Bingo on 2013/08/05.
//  Copyright (c) 2013年 Takeshi Bingo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSON.h"

@interface DetailViewController : UIViewController <UITextFieldDelegate>


@property(nonatomic,retain) IBOutlet UITextField *aTextField;
@property(nonatomic,retain) IBOutlet UILabel  *englishLabel;
@property(nonatomic,retain) IBOutlet UILabel  *germanLabel;
@property(nonatomic,retain) IBOutlet UILabel  *frenchLabel;
@property(nonatomic,retain) IBOutlet UILabel  *koreanLabel;


@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic,assign) NSInteger fileIdx;
// データ番号を指定して、該当するデータファイルのパスを算出する
+ (NSString *)makeDataFilePath:(NSInteger)idx;
@end
