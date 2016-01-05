//
//  ShowSingleViewController.h
//  dict
//
//  Created by 黄小昊 on 15/12/26.
//  Copyright © 2015年 黄小昊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "dictSQL.h"
#import "ViewController.h"

@interface ShowSingleViewController : UIViewController <UIWebViewDelegate>{
    NSMutableDictionary* arr;
    dispatch_queue_t queue;
    int fontSize;
    __block NSDictionary* meanDict;
    dictSQL* soundSQL;
    NSData *ukSound,*usSound;
    NSString *ukPath, *usPath;
    AVAudioPlayer *player;
    unsigned int tpnow,tpcount;
    NSMutableArray* aArr;
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *adjustView;
@property (weak, nonatomic) IBOutlet UISlider *adjustBar;

- (IBAction)playUKsound:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *ukBtn;
- (IBAction)playUSsound:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *usBtn;
- (IBAction)showAdjustView:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousBtn;
- (IBAction)previousMean:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextBtn;
- (IBAction)nextMean:(id)sender;

@end
