//
//  DictSetViewController.m
//  dict
//
//  Created by 黄小昊 on 16/6/8.
//  Copyright © 2016年 黄小昊. All rights reserved.
//

#import "DictSetViewController.h"

@interface DictSetViewController ()

@end

@implementation setCell

- (IBAction)setValueChanged:(id)sender {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	UISlider* slider = (UISlider*)sender;
	[userDefaults setInteger:slider.value forKey:@"fontsize"];
}
- (IBAction)SetDefaultFontSize:(id)sender {
	[self.adjustBarSet setValue:100];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setInteger:100 forKey:@"fontsize"];
	
}
@end

@implementation clearCell
- (IBAction)clearHis:(id)sender {
	NSLog(@"do nothing!");
	UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"set" message:@"" delegate:self cancelButtonTitle:@"" otherButtonTitles:nil, nil];
	[alert show];
}
@end

@implementation DictSetViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	self.setTab.dataSource = self;
	self.setTab.delegate = self;
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	setCell* cell;
	switch (indexPath.section) {
		case 0:
		{
			cell = [tableView dequeueReusableCellWithIdentifier:@"fontSet"];
			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
			if ([userDefaults objectForKey:@"fontsize"] != nil)  [cell.adjustBarSet setValue:[[userDefaults objectForKey:@"fontsize"] floatValue]];
		}
			break;
			
		case 1:
			cell = [tableView dequeueReusableCellWithIdentifier:@"clearSet"];
			break;
			
		default:
			cell = (setCell*)[[UITableViewCell alloc]init];
			break;
	}
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString* titleName = @"";
	switch (section) {
		case 0:
			titleName = @"字体大小";
			break;
		case 1:
			titleName = @"清除搜索历史";
			break;
		default:
			break;
	}
	return titleName;
}

@end
