//
//  ViewController.m
//  dict
//
//  Created by 黄小昊 on 15/12/19.
//  Copyright © 2015年 黄小昊. All rights reserved.
//

#import "ViewController.h"

@implementation wordCell

@end

@interface ViewController ()

@end

@implementation ViewController
dictSQL* sql;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    sql = [[dictSQL alloc] initWithDatabase:@"cald4.dat"];
    _textInputer.delegate = self;
    dictArray = [[NSMutableArray alloc]init];
    if ([[[UIDevice currentDevice] model] isEqualToString:@"iPad"]) {
        self.tableView.rowHeight = 64;
    }else{
        self.tableView.rowHeight = 44 * self.view.bounds.size.width/320;
    }
    for (UIView* o in self.view.subviews) {
        if (o.tag == 200 && [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] == NSOrderedAscending) {
            o.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1];
            break;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self removeKeyBoard:self.view];
}

- (void)removeKeyBoard:(UIView*)v {
    for (UIView* vi in v.subviews){
        if ([vi isKindOfClass:[UIView class]]) {
            [self removeKeyBoard:vi];
        }
        if ([vi isKindOfClass:[UITextField class]]) {
            [vi resignFirstResponder];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary * cellDict = (NSMutableDictionary*)dictArray[indexPath.item];
    wordCell* cell = [tableView dequeueReusableCellWithIdentifier:@"wordCell"];
    cell.cellTitle.text = [cellDict objectForKey:@"word"];
    cell.cellSubtitle.text = [cellDict objectForKey:@"wordclass"];
    if ([[cellDict objectForKey:@"nextflag"] intValue] == 1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dictArray count];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * regex = @"[A-Za-z]";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (range.length != 1 || [predicate evaluateWithObject:string] || [string isEqualToString:@" "]) {
        if (range.length == 0) {
            if ([string isEqualToString:@"\n"]) {
                [textField resignFirstResponder];
                return NO;
            }else{
                dictArray = [sql findWordListBy:[NSString stringWithFormat:@"%@%@",textField.text,string] limit:limitCount];
                [self.tableView reloadData];
            }
        }else if (range.length == 1) {
            dictArray = [sql findWordListBy:textField.text limit:limitCount];
            [self.tableView reloadData];
        }
    }else if (range.length == 1) {
        if (textField.text.length == 1) {
            [dictArray removeAllObjects];
            [self.tableView reloadData];
        }else{
            dictArray = [sql findWordListBy:[textField.text substringToIndex:textField.text.length - 1] limit:limitCount];
            [self.tableView reloadData];
        }
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"选词-->");
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableDictionary* arr = (NSMutableDictionary*)dictArray[indexPath.item];
    [self removeKeyBoard:self.view];
    if ([[arr objectForKey:@"nextflag"] intValue] == 1) {
        self.hidesBottomBarWhenPushed = YES;
        [self performSegueWithIdentifier:@"moreWordShow" sender:arr];
    }else{
        self.hidesBottomBarWhenPushed = NO;
        [self performSegueWithIdentifier:@"showFromMain" sender:arr];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	if ([segue.identifier isEqualToString:@"dictSetting"]) {
		UIViewController* view = segue.destinationViewController;
		[view setValue:sender forKey:@"setDiction"];
	}
	if ([segue.identifier isEqualToString:@"showFromMain"] || [segue.identifier isEqualToString:@"moreWordShow"]) {
		UIViewController* view = segue.destinationViewController;
		[view setValue:sender forKey:@"arr"];
	}
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [dictArray removeAllObjects];
    [self.tableView reloadData];
    return  YES;
}

- (IBAction)removeAllInput:(id)sender {
    [dictArray removeAllObjects];
    [self.tableView reloadData];
    [self.textInputer resignFirstResponder];
    [self.textInputer setText:@""];
}

- (IBAction)goToSetting:(id)sender {
    [self performSegueWithIdentifier:@"dictSetting" sender:nil];
    
}

- (IBAction)goToHistoryList:(id)sender {
	[self performSegueWithIdentifier:@"searchHistory" sender:nil];
}

@end
