//
//  ViewController.h
//  dict
//
//  Created by 黄小昊 on 15/12/19.
//  Copyright © 2015年 黄小昊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "dictSQL.h"

#define limitCount 25

@interface wordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cellTitle;
@property (weak, nonatomic) IBOutlet UILabel *cellSubtitle;

@end

@interface ViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>{
    NSMutableArray* dictArray;
}

@property (weak, nonatomic) IBOutlet UITextField *textInputer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)removeAllInput:(id)sender;

@end

