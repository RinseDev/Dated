#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>
#import <Twitter/TWTweetComposeViewController.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <Cephei/HBPreferences.h>
#import <Cephei/prefs/HBListController.h>
#import "substrate.h"

#define MODERN_IOS ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define URL_ENCODE(string) (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)(string), NULL, CFSTR(":/=,!$& '()*+;[]@#?"), kCFStringEncodingUTF8)

@interface CKAutoupdatingDateFormatter

- (id)initWithTemplate:(id)arg1;
- (id)stringFromDate:(id)arg1;

@end

@interface DDPrefsListController : HBListController

@end

@interface DDListItemsController : PSListItemsController

@end

@interface DDPreviewTextCell : PSTableCell

@end
