#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <UIKit/UIKit.h>

@interface UIApplication (Private)
- (void)suspend;
@end

@interface SBApplication : UIApplication
@end

@interface SBApplicationController
+ (id)sharedInstance;
- (SBApplication *)applicationWithPid:(NSString *)arg1;
@end

@interface DDPrefsListController : PSListController
@end

@interface DDListItemsController : PSListItemsController
@end
