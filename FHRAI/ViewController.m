//
//  ViewController.m
//  FHRAI
//
//  Created by Tilak on 10/21/16.
//  Copyright © 2016 Tilak. All rights reserved.
//

#import "ViewController.h"
#import "RMMapper.h"
#import "NSUserDefaults+RMSaveCustomObject.h"

#define SAVECOOKIES @"SAVECOOKIES"
#define UNID @"unid"
#define USERINFO @"UserInfo"

@interface ViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *objWebView;
@property (strong, nonatomic) NSDictionary *dictUserInfo;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dictUserInfo=[NSDictionary dictionaryWithDictionary:[self getSaveDetails]];
    // Do any additional setup after loading the view, typically from a nib.
    
    //NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    //NSLog(@"THE cookies:%@",cookies);
    NSString *strUrl =@"http://www.fhrai.com/Home.aspx";//@"http://www.fhrai.com/AutoLogin.aspx";
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    if (self.dictUserInfo) {
        if ([[self.dictUserInfo valueForKey:UNID] length]>0) {
            strUrl=[NSString stringWithFormat:@"http://www.fhrai.com/Home.aspx?UNID=%@",[self.dictUserInfo valueForKey:UNID]];
            request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
            NSArray * cookies = [self.dictUserInfo valueForKey:SAVECOOKIES];
            NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies: cookies];
            [request setAllHTTPHeaderFields:headers];
        }
    }
    self.objWebView.delegate=self;
    [self.objWebView loadRequest:request];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
   // NSLog(@"The requested Url:%@",request.URL.description);
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // NSLog(@"The did start load Url:%@",webView.request.URL.description);
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //NSLog(@"The finish Url:%@",webView.request.URL.description);
    
    
    if ([self isSignOut:webView]) {
        
        self.dictUserInfo=[self getSaveDetails];
        
    } else {
        
        if (self.dictUserInfo) {
            if ([[self.dictUserInfo valueForKey:UNID] length]>0) {
                
            }
            else {
                
                [self manupulatedata:webView];
            }
        } else {
            
            [self manupulatedata:webView];
        }
    }
}

-(void)manupulatedata:(UIWebView*)webView {
    
    NSArray *arrQmSeprator = [webView.request.URL.description componentsSeparatedByString:@"?"];
    NSString *lastObjetString=[arrQmSeprator lastObject];
    NSArray *arrEqualSep=[lastObjetString componentsSeparatedByString:@"="];
    if ([[arrEqualSep firstObject] isKindOfClass:[NSString class]]) {
        NSString *strUNIDKey=[arrEqualSep firstObject];
        NSString *strUNIDId=[arrEqualSep lastObject];
        if ([strUNIDKey.lowercaseString isEqualToString:@"unid"]) {
            
            NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
            //NSLog(@"THE cookies:%@",cookies);
            NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
            [dict setObject:cookies forKey:SAVECOOKIES];
            [dict setObject:strUNIDId forKey:UNID];
            [self saveDetails:[NSDictionary dictionaryWithDictionary:dict]];
            
        }
        
    }
}

-(BOOL)isSignOut:(UIWebView*)webView {

        NSArray *arrQmSeprator = [webView.request.URL.description componentsSeparatedByString:@"?"];
        NSString *lastObjetString=[arrQmSeprator lastObject];
        NSArray *arrEqualSep=[lastObjetString componentsSeparatedByString:@"="];
        if ([[arrEqualSep firstObject] isKindOfClass:[NSString class]]) {
            NSString *strUNIDKey=[arrEqualSep firstObject];
            //NSString *strUNIDId=[arrEqualSep lastObject];
            if ([strUNIDKey.lowercaseString isEqualToString:@"signout"]) {
                //NSLog(@"THE User signed Out");
                NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
                [self saveDetails:[NSDictionary dictionaryWithDictionary:dict]];
                return YES;
            }
            
        }

    return NO;
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

-(void)saveDetails:(NSDictionary *)dictDetails
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults rm_setCustomObject:dictDetails forKey:USERINFO];
    [defaults synchronize];
}

-(NSDictionary *)getSaveDetails
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *dict=[defaults rm_customObjectForKey:USERINFO];
    return dict;
}

@end
