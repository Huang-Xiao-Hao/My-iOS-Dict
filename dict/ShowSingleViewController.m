//
//  ShowSingleViewController.m
//  dict
//
//  Created by 黄小昊 on 15/12/26.
//  Copyright © 2015年 黄小昊. All rights reserved.
//

#import "ShowSingleViewController.h"

@interface ShowSingleViewController ()

@end

extern dictSQL* sql;


@implementation ShowSingleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //保存字典尺寸
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"fontsize"] != nil) {
        fontSize = [[userDefaults objectForKey:@"fontsize"] intValue];
        [self.adjustBar setValue:(float)fontSize];
    }
    self.navigationController.toolbarHidden = NO;
    // Do any additional setup after loading the view.
    self.navigationItem.title = [arr objectForKey:@"word"];
    soundSQL = [[dictSQL alloc] initWithDatabase:@"cald4.v"];
    queue = dispatch_queue_create( "queue", DISPATCH_QUEUE_SERIAL );
    meanDict = [[NSDictionary alloc]init];
    fontSize = 18;
    [self.adjustBar addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
    dispatch_sync(queue, ^{
        int indexs = -1;
        for (NSString* str in [arr allKeys]) {
            if ([str isEqualToString:@"phrasestr"]) {
                indexs = 0;
                break;
            }
        }
        meanDict = [sql getTheMean:[arr objectForKey:@"indexid"] index: indexs];
        NSString * string = [meanDict objectForKey:@"mean"];
        /*
         * hw   被解释单词
         * pos  词性
         * def  定义
         * pron 音标
         * en   英语解释
         * sc   简体中文解释
         * tc   繁体中文解释
         * lab  不知道是什么
         * body 所有内容
         */
        string = [NSString stringWithFormat:@"<style type=\"text/css\">.tc{display : none}.hw{color:#3399FF;font-style:normal;}.def{font-style:italic;color:#3399FF;}.pos{color:#009900;}.pron{font-weight:light}.lab{color:#666666}a{color:#3399FF;text-decoration:none;font-style:italic;}</style>%@",string];
        [self.webView loadHTMLString:string baseURL:nil];
    });
    
    NSArray *dicArr = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask , true);
    NSString* dirPath = dicArr[0];
    ukPath = [NSString stringWithFormat:@"%@/%@",dirPath,@"uksound.wav"];
    usPath = [NSString stringWithFormat:@"%@/%@",dirPath,@"ussound.wav"];
    dispatch_sync(queue, ^{
        usSound = [soundSQL getTheSound:[meanDict objectForKey:@"us"] withCode:@"s"];
        ukSound = [soundSQL getTheSound:[meanDict objectForKey:@"uk"] withCode:@"k"];
        if (usSound == nil) {
            [self.usBtn setEnabled:NO];
        }else{
            [self.usBtn setEnabled:YES];
            [usSound writeToFile:usPath atomically:YES];
        }
        if (ukSound == nil) {
            [self.ukBtn setEnabled:NO];
        }else{
            [self.ukBtn setEnabled:YES];
            [ukSound writeToFile:ukPath atomically:YES];
        }
    });
    tpcount = [[arr objectForKey:@"tpcount"] intValue];
    aArr = [[NSMutableArray alloc] init];
    if (tpcount > 1) {
        NSString* string = [arr objectForKey:@"phraseids"];
        for (int i = 0; i < tpcount; i++) {
            NSUInteger a = [string rangeOfString:@"+"].location;
            if (a != NSIntegerMax) {
                [aArr addObject:@([[string substringToIndex:a] intValue])];
                string = [string substringFromIndex:a + 1];
            }else if (a == NSIntegerMax) {
                [aArr addObject:@([[string substringFromIndex:0] intValue])];
            }
        }
    }else{
        self.nextBtn.enabled = NO;
        self.previousBtn.enabled = NO;
        NSLog(@"%@",self.navigationItem.rightBarButtonItems);
    }
    tpnow = 0;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (![request.URL.absoluteString  isEqualToString: @"about:blank"]) {
        //选词跳转功能
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray* tarr = [sql findWordListBy:[request.URL.absoluteString substringFromIndex:4] limit:1];
            NSMutableDictionary* dict = tarr.lastObject;
            if ([[dict objectForKey:@"nextflag"] integerValue] > 0) {
                
            }else{
                NSString * string = [[sql getTheMean:[dict objectForKey:@"indexid"] index:-1] objectForKey:@"meam"];
                string = [NSString stringWithFormat:@"<style type=\"text/css\">.tc{display : none}.hw{color:#3399FF;font-style:normal;}.def{font-style:italic;color:#3399FF;}.pos{color:#009900;}.pron{font-weight:light}.lab{color:#666666}a{color:#3399FF;text-decoration:none;font-style:italic;}</style>%@",string];
                NSLog(string,nil);
                [self.webView loadHTMLString:string baseURL:nil];
                self.navigationItem.title = [dict objectForKey:@"word"];
            }
        });
        return NO;
    }else{
        return YES;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)valueChanged {
    fontSize = (int)self.adjustBar.value;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:fontSize forKey:@"fontsize"];
    NSString *str = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%' ",fontSize];
    [_webView stringByEvaluatingJavaScriptFromString:str];
}

- (IBAction)playUKsound:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *playerError;
        player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:ukPath] error:&playerError];
        [player prepareToPlay];
        [player play];
    });
}

- (IBAction)playUSsound:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *playerError;
        player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:usPath] error:&playerError];
        [player prepareToPlay];
        [player play];
    });
}

- (IBAction)showAdjustView:(id)sender {
    if (self.adjustView.isHidden == YES) {
        self.adjustView.hidden = NO;
    }else{
        self.adjustView.hidden = YES;
    }
}

- (IBAction)previousMean:(id)sender {
    if (tpnow == 0) {
        tpnow = tpcount - 1;
        dispatch_async(dispatch_get_main_queue(), ^{
            meanDict = [sql getTheMean:[aArr objectAtIndex:tpnow] index: 0];
            NSString * string = [meanDict objectForKey:@"mean"];
            string = [NSString stringWithFormat:@"<style type=\"text/css\">.tc{display : none}.hw{color:#3399FF;font-style:normal;}.def{font-style:italic;color:#3399FF;}.pos{color:#009900;}.pron{font-weight:light}.lab{color:#666666}a{color:#3399FF;text-decoration:none;font-style:italic;}</style>%@",string];
            [self.webView loadHTMLString:string baseURL:nil];
        });
    }else{
        tpnow = tpnow - 1;
        dispatch_async(dispatch_get_main_queue(), ^{
            meanDict = [sql getTheMean:[aArr objectAtIndex:tpnow] index: 0];
            NSString * string = [meanDict objectForKey:@"mean"];
            string = [NSString stringWithFormat:@"<style type=\"text/css\">.tc{display : none}.hw{color:#3399FF;font-style:normal;}.def{font-style:italic;color:#3399FF;}.pos{color:#009900;}.pron{font-weight:light}.lab{color:#666666}a{color:#3399FF;text-decoration:none;font-style:italic;}</style>%@",string];
            [self.webView loadHTMLString:string baseURL:nil];
        });
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self valueChanged];
}

- (IBAction)nextMean:(id)sender {
    if (tpnow == tpcount - 1) {
        tpnow = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            meanDict = [sql getTheMean:[aArr objectAtIndex:tpnow] index: 0];
            NSString * string = [meanDict objectForKey:@"mean"];
            string = [NSString stringWithFormat:@"<style type=\"text/css\">.tc{display : none}.hw{color:#3399FF;font-style:normal;}.def{font-style:italic;color:#3399FF;}.pos{color:#009900;}.pron{font-weight:light}.lab{color:#666666}a{color:#3399FF;text-decoration:none;font-style:italic;}</style>%@",string];
            [self.webView loadHTMLString:string baseURL:nil];
        });
    }else{
        tpnow = tpnow + 1;
        dispatch_async(dispatch_get_main_queue(), ^{
            meanDict = [sql getTheMean:[aArr objectAtIndex:tpnow] index: 0];
            NSString * string = [meanDict objectForKey:@"mean"];
            string = [NSString stringWithFormat:@"<style type=\"text/css\">.tc{display : none}.hw{color:#3399FF;font-style:normal;}.def{font-style:italic;color:#3399FF;}.pos{color:#009900;}.pron{font-weight:light}.lab{color:#666666}a{color:#3399FF;text-decoration:none;font-style:italic;}</style>%@",string];
            [self.webView loadHTMLString:string baseURL:nil];
        });
    }}
@end
