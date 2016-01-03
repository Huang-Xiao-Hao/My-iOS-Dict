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
    self.navigationController.toolbarHidden = NO;
    // Do any additional setup after loading the view.
    self.navigationItem.title = [arr objectForKey:@"word"];
    soundSQL = [[dictSQL alloc] initWithDatabase:@"cald4.v"];
    queue = dispatch_queue_create( "queue", DISPATCH_QUEUE_SERIAL );
    meanDict = [[NSDictionary alloc]init];
    fontSize = 18;
    [self.adjustBar addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
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
        NSLog(string,nil);
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
        string = [NSString stringWithFormat:@"<style type=\"text/css\">.tc{display : none}.hw{color:#3399FF;font-style:normal;}.def{font-style:italic;color:#3399FF;}.pos{color:#009900;}.pron{font-weight:light}.lab{color:#666666}.en{font-size:%d;}.tc{font-size:%d;}.sc{font-size:%d;}td{font-size:%d;}a{color:#3399FF;text-decoration:none;font-style:italic;}body{font-size:%d;}</style>%@",fontSize,fontSize,fontSize,fontSize,fontSize,string];
        [self.webView loadHTMLString:string baseURL:nil];
    });
    dispatch_sync(queue, ^{
        usSound = [soundSQL getTheSound:[meanDict objectForKey:@"us"] withCode:@"s"];
        ukSound = [soundSQL getTheSound:[meanDict objectForKey:@"uk"] withCode:@"k"];
        if (usSound == nil) {
            [self.usBtn setEnabled:NO];
        }else{
            [self.usBtn setEnabled:YES];
        }
        if (ukSound == nil) {
            [self.ukBtn setEnabled:NO];
        }else{
            [self.ukBtn setEnabled:YES];
        }
    });
    tpcount = [[arr objectForKey:@"tpcount"] integerValue];
    aArr = [[NSMutableArray alloc]init];
    if (tpcount > 1) {
        NSString* string = [arr objectForKey:@"phraseids"];
        for (int i = 0; i < tpcount; i++) {
            if ([string rangeOfString:@"+"].location != 2147483647) {
                [aArr addObject:@([[string substringToIndex:[string rangeOfString:@"+"].location] intValue])];
                string = [string substringFromIndex:[string rangeOfString:@"+"].location + 1];
            }else if ([string rangeOfString:@"+"].location == 2147483647) {
                [aArr addObject:@([[string substringFromIndex:0] intValue])];
            }
            NSLog(@"%@",aArr[i]);
        }
    }else{
        self.nextBtn.enabled = NO;
        self.previousBtn.enabled = NO;
    }
    tpnow = 0;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(request.URL.absoluteString,nil);
    if (![request.URL.absoluteString  isEqualToString: @"about:blank"]) {
        return  NO;
//        dispatch_async(queue, ^{
//            NSMutableArray* tarr = [sql findWordListBy:[request.URL.absoluteString substringFromIndex:4] limit:1];
//            NSMutableDictionary* dict = tarr.lastObject;
//            NSString * string = [[sql getTheMean:[dict objectForKey:@"indexid"] index:0] objectForKey:@"meam"];
//            string = [NSString stringWithFormat:@"<style type=\"text/css\">.tc{display : none}.hw{color:#3399FF;font-style:normal;}.def{font-style:italic;color:#3399FF;}.pos{color:#009900;}.pron{font-weight:light}.lab{color:666666}.en{font-size:%d;}.tc{font-size:%d;}.sc{font-size:%d;}td{font-size:%d;}a{color:#3399FF;text-decoration:none;font-style:italic;}body{font-size:%d;}</style>%@",fontSize,fontSize,fontSize,fontSize,fontSize,string];
//            [self.webView loadHTMLString:string baseURL:nil];
//            self.navigationItem.title = [dict objectForKey:@"word"];
//        });
//        return NO;
    }else{
        return YES;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateValue:(id)sender {
    if ((int)self.adjustBar.value != fontSize) {
        fontSize = (int)self.adjustBar.value;
        NSString *str = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%' ",fontSize];
        [_webView stringByEvaluatingJavaScriptFromString:str];
    }
}

- (IBAction)playUKsound:(id)sender {
    dispatch_async(queue, ^{
        NSError *playerError;
        player = [[AVAudioPlayer alloc] initWithData:ukSound error:&playerError];
        [player prepareToPlay];
        [player play];
    });
}

- (IBAction)playUSsound:(id)sender {
    dispatch_async(queue, ^{
        NSError *playerError;
        player = [[AVAudioPlayer alloc] initWithData:usSound error:&playerError];
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
            string = [NSString stringWithFormat:@"<style type=\"text/css\">.tc{display : none}.hw{color:#3399FF;font-style:normal;}.def{font-style:italic;color:#3399FF;}.pos{color:#009900;}.pron{font-weight:light}.lab{color:#666666}.en{font-size:%d;}.tc{font-size:%d;}.sc{font-size:%d;}td{font-size:%d;}a{color:#3399FF;text-decoration:none;font-style:italic;}body{font-size:%d;}</style>%@",fontSize,fontSize,fontSize,fontSize,fontSize,string];
            [self.webView loadHTMLString:string baseURL:nil];
        });
    }else{
        tpnow = tpnow - 1;
        dispatch_async(dispatch_get_main_queue(), ^{
            meanDict = [sql getTheMean:[aArr objectAtIndex:tpnow] index: 0];
            NSString * string = [meanDict objectForKey:@"mean"];
            string = [NSString stringWithFormat:@"<style type=\"text/css\">.tc{display : none}.hw{color:#3399FF;font-style:normal;}.def{font-style:italic;color:#3399FF;}.pos{color:#009900;}.pron{font-weight:light}.lab{color:#666666}.en{font-size:%d;}.tc{font-size:%d;}.sc{font-size:%d;}td{font-size:%d;}a{color:#3399FF;text-decoration:none;font-style:italic;}body{font-size:%d;}</style>%@",fontSize,fontSize,fontSize,fontSize,fontSize,string];
            [self.webView loadHTMLString:string baseURL:nil];
        });
    }
}

- (IBAction)nextMean:(id)sender {
    if (tpnow == tpcount - 1) {
        tpnow = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            meanDict = [sql getTheMean:[aArr objectAtIndex:tpnow] index: 0];
            NSString * string = [meanDict objectForKey:@"mean"];
            string = [NSString stringWithFormat:@"<style type=\"text/css\">.tc{display : none}.hw{color:#3399FF;font-style:normal;}.def{font-style:italic;color:#3399FF;}.pos{color:#009900;}.pron{font-weight:light}.lab{color:#666666}.en{font-size:%d;}.tc{font-size:%d;}.sc{font-size:%d;}td{font-size:%d;}a{color:#3399FF;text-decoration:none;font-style:italic;}body{font-size:%d;}</style>%@",fontSize,fontSize,fontSize,fontSize,fontSize,string];
            [self.webView loadHTMLString:string baseURL:nil];
        });
    }else{
        tpnow = tpnow + 1;
        dispatch_async(dispatch_get_main_queue(), ^{
            meanDict = [sql getTheMean:[aArr objectAtIndex:tpnow] index: 0];
            NSString * string = [meanDict objectForKey:@"mean"];
            string = [NSString stringWithFormat:@"<style type=\"text/css\">.tc{display : none}.hw{color:#3399FF;font-style:normal;}.def{font-style:italic;color:#3399FF;}.pos{color:#009900;}.pron{font-weight:light}.lab{color:#666666}.en{font-size:%d;}.tc{font-size:%d;}.sc{font-size:%d;}td{font-size:%d;}a{color:#3399FF;text-decoration:none;font-style:italic;}body{font-size:%d;}</style>%@",fontSize,fontSize,fontSize,fontSize,fontSize,string];
            [self.webView loadHTMLString:string baseURL:nil];
        });
    }}
@end