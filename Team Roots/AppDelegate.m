//
//  AppDelegate.m
//  Common Roots
//
//  Created by Spencer Yen on 1/17/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <LayerKit/LayerKit.h>
#import "CRUser.h"
#import "CRLoginViewController.h"
#import "CRConversationManager.h"
#import "CRChatViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIColor+Team_Roots.h"

#define PARSE_APP_ID @"pya3k6c4LXzZMy6PwMH80kJx4HD2xF6duLSSdYUl"
#define PARSE_CLIENT_KEY @"BOOijRRSKlKh5ogT2IaacnnK2eHJZqt8L30VPIcc"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self.window makeKeyAndVisible];

    [Parse setApplicationId:PARSE_APP_ID
                  clientKey:PARSE_CLIENT_KEY];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    LYRClient *layerClient = [CRConversationManager layerClient];

    [layerClient connectWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"Layer Client Connected!");            
        } else {
            NSLog(@"Error in layerClient Connection: %@", [error localizedDescription]);
        }
    }];
    // Checking if app is running iOS 8
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        // Register device for iOS8
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:notificationSettings];
        [application registerForRemoteNotifications];
    } else {
        // Register device for iOS7
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
    }
    [SVProgressHUD setForegroundColor:[UIColor teamRootsGreen]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.window.tintColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLayerObjectsDidChangeNotification:)
                                                 name:LYRClientObjectsDidChangeNotification object:layerClient];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSError *error;
    BOOL success = [[CRConversationManager layerClient] updateRemoteNotificationDeviceToken:deviceToken error:&error];
    if (success) {
        NSLog(@"Application did register for remote notifications");
    } else {
        NSLog(@"Error updating Layer device token for push:%@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // Get Message from Metadata
    __block LYRMessage *message = [self messageFromRemoteNotification:userInfo];
    
    if (application.applicationState == UIApplicationStateInactive && message) {
        //Navigate user to right part of the app here
        CRLoginViewController *loginVC = (CRLoginViewController *)self.window.rootViewController;
        loginVC.receivedConversationToLoad = [[CRConversationManager sharedInstance] CRConversationForLayerConversation:message.conversation client:[CRConversationManager layerClient]];
    }
    
    NSError *error;
    BOOL success = [[CRConversationManager layerClient] synchronizeWithRemoteNotification:userInfo completion:^(NSArray *changes, NSError *error) {
        if (changes)
        {
            if ([changes count])
            {
                // Try navigating once the synchronization completed
                if (application.applicationState == UIApplicationStateInactive && !message) {
                    message = [self messageFromRemoteNotification:userInfo];
                    //Navigate user to right part of the app here
                    CRLoginViewController *loginVC = (CRLoginViewController *)self.window.rootViewController;
                    loginVC.receivedConversationToLoad = [[CRConversationManager sharedInstance] CRConversationForLayerConversation:message.conversation client:[CRConversationManager layerClient]];
                }
                completionHandler(UIBackgroundFetchResultNewData);
            }
            else
            {
                completionHandler(UIBackgroundFetchResultNoData);
            }
        }
        else
        {
            completionHandler(UIBackgroundFetchResultFailed);
        }
    }];
    
    if (success) {
        NSLog(@"Application did complete remote notification sync");
    } else {
        NSLog(@"Failed processing push notification with error: %@", error);
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (LYRMessage *)messageFromRemoteNotification:(NSDictionary *)remoteNotification
{
    static NSString *const LQSPushMessageIdentifierKeyPath = @"layer.message_identifier";
    
    // Retrieve message URL from Push Notification
    NSURL *messageURL = [NSURL URLWithString:[remoteNotification valueForKeyPath:LQSPushMessageIdentifierKeyPath]];
    
    // Retrieve LYRMessage from Message URL
    LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"identifier" operator:LYRPredicateOperatorIsIn value:[NSSet setWithObject:messageURL]];
    
    NSError *error;
    NSOrderedSet *messages = [[CRConversationManager layerClient] executeQuery:query error:&error];
    if (!error) {
        NSLog(@"Query contains %lu messages", (unsigned long)messages.count);
        LYRMessage *message= messages.firstObject;
        LYRMessagePart *messagePart = message.parts[0];
        NSLog(@"Pushed Message Contents: %@",[[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding]);
    } else {
        NSLog(@"Query failed with error %@", error);
    }
    
    return [messages firstObject];
}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    
//    __block LYRMessage *message = [self messageFromRemoteNotification:userInfo];
//    [[CRConversationManager sharedInstance] CRConversationForLayerConversationID:message.conversation.identifier client:[CRConversationManager layerClient] completionBlock:^(CRConversation *conversation, NSError *error) {
//        CRLoginViewController *loginVC = (CRLoginViewController *)self.window.rootViewController;
//        loginVC.receivedConversationToLoad = conversation;
//    }];
//    
//    if (application.applicationState == UIApplicationStateInactive && message) {
//        [[CRConversationManager sharedInstance] CRConversationForLayerConversationID:message.conversation.identifier client:[CRConversationManager layerClient] completionBlock:^(CRConversation *conversation, NSError *error) {
//            CRLoginViewController *loginVC = (CRLoginViewController *)self.window.rootViewController;
//         //   loginVC.receivedConversationToLoad = conversation;
//        }];
//    }
//    
//    BOOL success = [[CRConversationManager layerClient] synchronizeWithRemoteNotification:userInfo completion:^(UIBackgroundFetchResult fetchResult, NSError *error) {
//        if (fetchResult == UIBackgroundFetchResultFailed) {
//            NSLog(@"Failed processing remote notification: %@", error);
//        }
//        
//        // Try navigating once the synchronization completed
//        if (application.applicationState == UIApplicationStateInactive && !message) {
//            message = [self messageFromRemoteNotification:userInfo];
//            [[CRConversationManager sharedInstance] ANConversationForLayerConversationID:message.conversation.identifier client:[ANConversationManager layerClient] completionBlock:^(ANConversation *conversation, NSError *error) {
//                ANLoginViewController *loginVC = (ANLoginViewController *)self.window.rootViewController;
//                loginVC.receivedConversationToLoad = conversation;
//            }];
//        }
//        completionHandler(fetchResult);
//    }];
//
//    if (!success) {
//        completionHandler(UIBackgroundFetchResultNoData);
//    }
// }

- (void)didReceiveLayerObjectsDidChangeNotification:(NSNotification *)notification {
    NSArray *changes = [notification.userInfo objectForKey:LYRClientObjectChangesUserInfoKey];
    for (NSDictionary *change in changes) {
        id changeObject = [change objectForKey:LYRObjectChangeObjectKey];
      //  NSLog(@"change object in app del :%@", changeObject);
        if ([changeObject isKindOfClass:[LYRConversation class]]) {
            LYRObjectChangeType changeKey = (LYRObjectChangeType)[[change objectForKey:LYRObjectChangeTypeKey] integerValue];
            if(changeKey == LYRObjectChangeTypeCreate){
                UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                localNotification.fireDate = [NSDate date];
                localNotification.alertBody = @"New Conversation!";
                localNotification.timeZone = [NSTimeZone defaultTimeZone];
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kConversationChangeNotification object:change];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kMessageChangeNotification object:change];
        }
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        //notification.alertBody
#warning trigger in app notification ui here for new conversation
    }
}

@end
