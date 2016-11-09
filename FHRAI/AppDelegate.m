//
//  AppDelegate.m
//  FHRAI
//
//  Created by Tilak on 10/21/16.
//  Copyright © 2016 Tilak. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self activateNotification:application];
    if (launchOptions)
    {
        [self handleNotificationUserInfo:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    
    
    return YES;
}

#pragma mark-Notifications Module

-(void)activateNotification:(UIApplication*)application
{
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeAlert|UIUserNotificationTypeSound
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
        
    }
#else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
#endif
    
}

- (void) handleNotificationUserInfo:(NSDictionary*)userInfo
{
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
    
    if ( [UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
        //App is active
        
        NSLog(@"The notification active state");
        
    }
    else
    {
        //App is not active
        NSLog(@"The notification  Inactive active state");
    }
    
}

-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    
    if (![AppDelegate notificationServicesEnabled]) {
        [self activateNotification:application];
    } else {
        
        // Prepare the Device Token for Registration (remove spaces and < >)
        NSString *devToken = [[[[deviceToken description]
                                stringByReplacingOccurrencesOfString:@"<"withString:@""]
                               stringByReplacingOccurrencesOfString:@">" withString:@""]
                              stringByReplacingOccurrencesOfString: @" " withString: @""];
        
        NSString *strUrl=[NSString stringWithFormat:@"http://www.fhrai.com/AutoLogin.aspx?UNID=7c29dc2d-1f68-4bdc-8478-b90d4de08520&gcm_id=%@",devToken];
        
        dispatch_queue_t queue = dispatch_queue_create("com.company.app.queue", DISPATCH_QUEUE_SERIAL);
        dispatch_async(queue, ^{
            [self htttpCallWithUrl:[NSURL URLWithString:strUrl]];
            dispatch_async(dispatch_get_main_queue(), ^{
                
               
            });
        });
        
    }
}

+ (BOOL)notificationServicesEnabled {
    BOOL isEnabled = NO;
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]){
        UIUserNotificationSettings *notificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        
        if (!notificationSettings || (notificationSettings.types == UIUserNotificationTypeNone)) {
            isEnabled = NO;
        } else {
            isEnabled = YES;
        }
    } else {
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (types & UIRemoteNotificationTypeAlert) {
            isEnabled = YES;
        } else{
            isEnabled = NO;
        }
    }
    
    return isEnabled;
}
-(void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"%s..userInfo=%@",__FUNCTION__,userInfo);
    [self handleNotificationUserInfo:userInfo];
    
    
}

-(id)htttpCallWithUrl:(NSURL*)Url
{
    id jsonArray;
    {
        NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:Url
                                                                  cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                              timeoutInterval:180];
        [request setHTTPMethod:@"GET"];
        [request setHTTPShouldHandleCookies:YES];
        
        jsonArray=[self getResponse:request];
    }
    
    return jsonArray;
}

-(id)getResponse:(NSURLRequest*)request
{
    
    {
        
        NSHTTPURLResponse *response = nil;
        NSError *error;
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if ([response statusCode] == 404)
        {
            return nil;
        }
        else
        {
            if (returnData)
            {
                
                
                NSLog(@"ResponseURL:\n\n%@  \nData:\n\n%@\n\n",request.URL.description,[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding]);
                
                id response1=[NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers error:&error];
                if (error)
                {
                    NSLog(@"error response:%@",[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding]);
                    
                    return [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                }
                return response1;
            }else
            {
                return nil;
            }
            
        }
        
        return nil;
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
