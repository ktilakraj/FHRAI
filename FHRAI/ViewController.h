//
//  ViewController.h
//  FHRAI
//
//  Created by Tilak on 10/21/16.
//  Copyright © 2016 Tilak. All rights reserved.
//

#import <UIKit/UIKit.h>
#define SAVECOOKIES @"SAVECOOKIES"
#define UNID @"unid"
#define USERINFO @"UserInfo"

@interface ViewController : UIViewController

@property(nonatomic,assign) BOOL isFromNotification;
@property (strong, nonatomic) NSString *strWebUrl;

-(void)loadOtherWebUrlInWebView:(NSString*)strurl;

@end

