//
//  ShowWordsViewController.h
//  dict
//
//  Created by 黄小昊 on 15/12/30.
//  Copyright © 2015年 黄小昊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "dictSQL.h"

@interface dictCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cellTitle;
@property (weak, nonatomic) IBOutlet UIWebView *cellSubtitle;
@property (weak, nonatomic) IBOutlet UILabel *wordContent;

@end

@interface ShowWordsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSMutableDictionary* arr;
    NSMutableArray* dictArr;
    dispatch_queue_t queue;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
