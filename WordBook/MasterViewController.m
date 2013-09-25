//
//  MasterViewController.m
//  WordBook
//
//  Created by Takeshi Bingo on 2013/08/05.
//  Copyright (c) 2013年 Takeshi Bingo. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

@interface MasterViewController () {

}
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

#pragma mark - ファイル操作
// indexファイルのパスを算出する
- (NSString *)makeIndexFilePath {
    NSString *docFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *indexFilePath = [NSString stringWithFormat:@"%@/index.plist", docFolder];
    NSLog(@"%@",indexFilePath);
    return indexFilePath;
}

// indexファイルの load
-(void)loadIndexList {
    NSString *indexFilePath = [self makeIndexFilePath];
    if ( ! indexList ) {
        indexList = [[NSMutableArray alloc] init];
    }
    // indexファイルが存在していたら、indexListにセット
    if ( [[NSFileManager defaultManager] fileExistsAtPath:indexFilePath] ) {
        [indexList setArray:[NSMutableArray arrayWithContentsOfFile:indexFilePath]];
    }
}

// indexファイルの save
-(BOOL)saveIndexList {
    NSString *indexFilePath = [self makeIndexFilePath];
    return [indexList writeToFile:indexFilePath atomically:YES];
}

// indexファイルへ追加
-(BOOL)addIndexList:(NSInteger)fileIdx {
    // NSInteger型をNSNumber型に変換
    NSNumber *number = [NSNumber numberWithInteger:fileIdx];
    // fileIdxの番号の箇所にデータを挿入
    [indexList insertObject:number atIndex:0];
    return [self saveIndexList];
}

// データファイルとして存在していないデータ番号を求める
-(NSInteger)makeUniqeDataIndex {
    NSString *uniquePath;
    int i=0;
    do {
        i=i+1;
        // 詳細画面のデータファイルのパスを順番に指定
        uniquePath = [DetailViewController makeDataFilePath:i];
        // 詳細画面のデータファイルのが存在している間はループ
    } while([[NSFileManager defaultManager] fileExistsAtPath:uniquePath]);
    // 詳細画面のデータファイルのが存在しない番号を出力
    return i;
}

// indexListのデータ番号に対応するデータファイルがないなら項目を削除する
-(void)validateIndexList {
    NSMutableArray *aryIgnore = [NSMutableArray arrayWithCapacity:0];
    NSNumber *n;
    for (n in indexList) {
        NSString *detailDataPath =
        [DetailViewController makeDataFilePath:[n integerValue]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:detailDataPath]) {
            // 存在しないデータ番号を削除リスト（aryIgnore）に格納
            [aryIgnore addObject:n];
        }
    }
    // aryIgnoreに格納されたデータ番号のindexListのデータを削除
    for (n in aryIgnore) {
        [indexList removeObject:n];
    }
}



#pragma mark - 「＋」ボタン
-(void)addWord {
    NSLog(@"+ボタン");
    [self performSegueWithIdentifier:@"createDetail" sender:self];
}
#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"単語帳";
    // Navigationbarの左側にBarButtonItemを設置しクリック時のアクションを「addWordメソッド」に設定
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                  target:self action:@selector(addWord)];
    self.navigationItem.leftBarButtonItem = addButton;
    [self loadIndexList];
    
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated {
   // [super viewWillAppear:animated];
    [super viewWillAppear:animated];
    [self validateIndexList];
    [[self tableView] reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [indexList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSInteger cellIdx = [indexPath row];
    NSNumber *number = [indexList objectAtIndex:cellIdx];
    NSInteger fileIdx = [number integerValue];
    NSString *dataFilePath =
    [DetailViewController makeDataFilePath:fileIdx];
    NSString* title = @"新規データ";
    
    if ( [[NSFileManager defaultManager]
          fileExistsAtPath:dataFilePath] == YES ) {
        NSMutableDictionary* dic = [NSMutableDictionary
                                    dictionaryWithContentsOfFile:dataFilePath];
        NSString* savedTitle = [dic valueForKey:@"SearchWord"];
        title = savedTitle;
    }
    [[cell textLabel] setText:title];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}




- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSInteger cellIdx = [indexPath row];
        NSNumber *number = [indexList objectAtIndex:cellIdx];
        NSInteger fileIdx = [number integerValue];
        [[segue destinationViewController] setFileIdx:fileIdx];
        
    } else if ([[segue identifier] isEqualToString:@"createDetail"]) {
        NSInteger fileIdx = [self makeUniqeDataIndex];
        if ([self addIndexList:fileIdx] == FALSE) {
            NSLog(@"新規追加でindexファイルの保存ができませんでした");
            return;
        } else {
            NSLog(@"fileIdx:%d",fileIdx);
        }
        [[segue destinationViewController] setFileIdx:fileIdx];
    }}

@end
