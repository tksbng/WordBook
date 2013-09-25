//
//  DetailViewController.m
//  WordBook
//
//  Created by Takeshi Bingo on 2013/08/05.
//  Copyright (c) 2013年 Takeshi Bingo. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

#pragma mark - データファイルのパス
// データ番号を指定して、該当するデータファイルのパスを算出する
+ (NSString *)makeDataFilePath:(NSInteger)idx {
    NSString* docFolder = [NSHomeDirectory()
                           stringByAppendingPathComponent:@"Documents"];
    NSString* dataFilePath = [NSString
                              stringWithFormat:@"%@/word-%04d.plist", docFolder, idx];
    return dataFilePath;
}

#pragma mark - ソフトウェアキーボードを閉じる
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ( [textField canBecomeFirstResponder])
        [textField resignFirstResponder];
    return YES;
}
#pragma mark - 翻訳
-(NSString *)getAccessToken {
    //XXXXは顧客の秘密
    NSString *clientSecret = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                            NULL,
                            (CFStringRef)@"3T48qd16MLFyGtzaZl9tcgcvJfGiLG3YIrY/fkTcsbA=",
                            NULL,
                            (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                            kCFStringEncodingUTF8
                                                                                          );
    //翻訳APIを利用するため、AccessTokenを取得する
    NSString *tokenurlString =
    [NSString stringWithFormat:@"https://datamarket.accesscontrol.windows.net/v2/OAuth2-13"];
    NSMutableURLRequest *req =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:tokenurlString]
                            cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    //YYYYはクライアントID
    NSString *params =
    [NSString stringWithFormat:
     @"client_id=%@&client_secret=%@&grant_type=client_credentials&scope=http://api.microsofttranslator.com",
     @"tksbng00",
     clientSecret
     ];
    [req setHTTPMethod:@"POST"];//メソッドをPOSTに指定します
    [req setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    NSData * res = [NSURLConnection sendSynchronousRequest:req
                                         returningResponse:nil
                                                     error:nil];
    NSString * responseString = [[NSString alloc]initWithData:res encoding:NSUTF8StringEncoding];
    return [[responseString JSONValue] objectForKey:@"access_token"];
}

-(NSString *)translate:(NSString *)word to:(NSString *)lang at:(NSString*)access_token{
    
    //翻訳元の単語（日本語）をURLに適する形に変換
    NSString *wordUTF8 = [word
                          stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //URLを作成
    NSString *urlString =
    [NSString stringWithFormat:
     @"http://api.microsofttranslator.com/v2/Http.svc/Translate?text=%@&from=ja&to=%@",
     wordUTF8,
     lang
     ];
    
    //リクエスト送信設定
    NSURL* url;
    url = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    // AccessTokenをヘッダー情報を追加する。
    NSString *header = [NSString stringWithFormat:@"Bearer %@", access_token];
    [request addValue:header forHTTPHeaderField:@"Authorization"];
    //リクエストしてデータを取得
    NSData *dataReplay;
    NSString *stringReplay;
    NSURLResponse *response;
    NSError *error;
    dataReplay = [NSURLConnection sendSynchronousRequest:request
                                       returningResponse:&response error:&error];
    //utf8データとして取得
    stringReplay = [[NSString alloc] initWithData:dataReplay
                                         encoding:NSUTF8StringEncoding];
    //取得結果を正規表現でパースする準備
    NSError *errorText = nil;
    NSString *translationResult = [[NSString alloc] init];
    NSRegularExpression *regexp = [NSRegularExpression
                                   regularExpressionWithPattern:@"<(.+)>(.+)<(.+)>"
                                   options:0 error:&errorText];
    if (errorText != nil) {
        NSLog(@"%@", error);
    } else {
        //正規表現で翻訳結果を取得
        NSTextCheckingResult *match =
        [regexp firstMatchInString:stringReplay options:0
                             range:NSMakeRange(0, stringReplay.length)];
        //正規表現に該当した数を取得
        NSLog(@"range: %d", match.numberOfRanges);
        //正規表現に該当した結果（配列）の3番目に翻訳結果文字列が格納されているのでそれを取得
        translationResult = [stringReplay
                             substringWithRange:[match rangeAtIndex:2]]; //「Tomorrow」
        NSLog(@"result :%@", translationResult);
    }
    
    return translationResult;
}

#pragma mark - 結果を保存する
-(IBAction)translateSave:(id)sender{
// 各言語の翻訳を開始
NSString* SearchWord = [_aTextField text];
NSString* AccessToken = [self getAccessToken];
NSString *englishWord = [self translate:SearchWord to:@"en" at:AccessToken];
NSString *germanWord = [self translate:SearchWord to:@"de" at:AccessToken];
NSString *frenchWord = [self translate:SearchWord to:@"fr" at:AccessToken];
NSString *koreanWord = [self translate:SearchWord to:@"ko" at:AccessToken];
// 翻訳結果をNSMutableDictionaryに格納して画面ラベルに表示
NSMutableDictionary* dic = [NSMutableDictionary dictionary];
[dic setValue:SearchWord forKey:@"SearchWord"];
[dic setValue:englishWord forKey:@"English"];
[dic setValue:germanWord forKey:@"German"];
[dic setValue:frenchWord forKey:@"French"];
[dic setValue:koreanWord forKey:@"Korean"];
_englishLabel.text = englishWord;
_germanLabel.text = germanWord;
_frenchLabel.text = frenchWord;
_koreanLabel.text = koreanWord;
// 新規に詳細ファイルを作成
NSString* dataFilePath = [DetailViewController makeDataFilePath:_fileIdx];
[dic writeToFile:dataFilePath atomically:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 一覧画面から選択されたfileIdxのデータ番号をもとにファイルを読み込み
    NSString *dataFilePath =
    [DetailViewController makeDataFilePath:_fileIdx];
    // ファイルが存在したらファイルの中身をNSMutableDictionaryに格納し各ラベルに表示
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath] == YES ) {
        NSMutableDictionary* dic =
        [NSMutableDictionary dictionaryWithContentsOfFile:dataFilePath];
        NSString *SearchWord = [dic valueForKey:@"SearchWord"];
        NSString *englishWord = [dic valueForKey:@"English"];
        NSString *germanWord = [dic valueForKey:@"German"];
        NSString *frenchWord = [dic valueForKey:@"French"];
        NSString *koreanWord = [dic valueForKey:@"Korean"];
        [_aTextField setText:SearchWord];
        _englishLabel.text = englishWord;
        _germanLabel.text = germanWord;
        _frenchLabel.text = frenchWord;
        _koreanLabel.text = koreanWord;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    [_aTextField setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
