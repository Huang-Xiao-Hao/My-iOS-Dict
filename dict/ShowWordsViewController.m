//
//  ShowWordsViewController.m
//  dict
//
//  Created by 黄小昊 on 15/12/30.
//  Copyright © 2015年 黄小昊. All rights reserved.
//

#import "ShowWordsViewController.h"

@interface ShowWordsViewController ()

@end

extern dictSQL* sql;

@implementation dictCell

@end

@implementation ShowWordsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = [arr objectForKey:@"word"];
    dictArr = [[NSMutableArray alloc] init];
    queue = dispatch_queue_create( "queue2", DISPATCH_QUEUE_SERIAL );
    dispatch_async(queue, ^{
        dictArr = [sql findWordListBy:[arr objectForKey:@"indexid"] limits:[[arr objectForKey:@"explanecount"] intValue]];
        [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:NO];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadTableView{
    [self.tableView reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    dictCell* cell = [tableView dequeueReusableCellWithIdentifier:@"moreCell"];
    if ([[dictArr[indexPath.item] objectForKey:@"tpcount"] intValue] != 1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.cellTitle.text =  [dictArr[indexPath.item] objectForKey:@"wordclass"];
    NSString * body = [NSString stringWithFormat:@"<style type=\"text/css\">.tc{display : none} body{color : #0050D0}</style>%@",[dictArr[indexPath.item] objectForKey:@"wordmean"]];
    [cell.cellSubtitle loadHTMLString:body baseURL:nil];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.hidesBottomBarWhenPushed = YES;
    [self performSegueWithIdentifier:@"showFromDetail" sender:dictArr[indexPath.item]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UIViewController* view = segue.destinationViewController;
    [view setValue:sender forKey:@"arr"];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dictArr.count;
}

@end
