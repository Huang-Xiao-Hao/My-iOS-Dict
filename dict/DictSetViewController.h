//
//  DictSetViewController.h
//  dict
//
//  Created by 黄小昊 on 16/6/8.
//  Copyright © 2016年 黄小昊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface setCell: UITableViewCell

@property (weak, nonatomic) IBOutlet UISlider *adjustBarSet;
- (IBAction)setValueChanged:(id)sender;

- (IBAction)SetDefaultFontSize:(id)sender;
@end

@interface clearCell: UITableViewCell
- (IBAction)clearHis:(id)sender;

@end

@interface DictSetViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
     NSMutableDictionary* arr;
}
@property (weak, nonatomic) IBOutlet UITableView *setTab;

@end
