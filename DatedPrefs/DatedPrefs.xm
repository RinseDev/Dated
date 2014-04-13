// Dated (commercial tweak)
// Created by Julian (insanj) Weiss 2014
// Source and license available on Git

#import "DatedPrefs.h"

#define URL_ENCODE(string) (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)(string), NULL, CFSTR(":/=,!$& '()*+;[]@#?"), kCFStringEncodingUTF8)
#define DD_TINTCOLOR [UIColor colorWithRed:46/255.0 green:204/255.0 blue:64/255.0 alpha:1.0]

/**************************** Global Converstion Methods ****************************/

NSString *dated_templateStringFromSavedComponents() {
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.dated.plist"]];
	NSLog(@"[Dated] Creating template string from saved preferences file: %@", settings);

	NSString *year = [[settings objectForKey:@"year"] boolValue] ? @"y" : @"";
	NSString *month = ![[settings objectForKey:@"month"] boolValue] ? @"M" : @"";
	NSString *day = ![[settings objectForKey:@"day"] boolValue] ? @"d" : @"";
	NSString *dow = [[settings objectForKey:@"dow"] boolValue] ? @"cccccc" : @"";
	NSString *hour = ![[settings objectForKey:@"hour"] boolValue] ? @"H" : @"";
	NSString *min = ![[settings objectForKey:@"minute"] boolValue] ? @"m" : @"";
	NSString *sec = [[settings objectForKey:@"second"] boolValue] ? @"s" : @"";
	NSString *ampm = ![[settings objectForKey:@"ampm"] boolValue] ? @"j" : @"";
	return [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", year, month, day, dow, hour, min, sec, ampm];
}

NSString *dated_stringFromDateUsingTemplate(NSDate *date, NSString *components) {
	NSLog(@"[Dated] Creating string from date %@ using components string: %@", date, components);

	if (MODERN_IOS) {
		CKAutoupdatingDateFormatter *formatter = [[objc_getClass("CKAutoupdatingDateFormatter") alloc] initWithTemplate:components];
		return [formatter stringFromDate:date];
	}

	else {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:components options:0 locale:[NSLocale currentLocale]]];
		return [formatter stringFromDate:date];
	}
}

/**************************** Global Notif Listener ****************************/

static void dated_refreshApp(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	system("killall -9 MobileSMS");
}

static void dated_refreshPreview(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"DDRefreshPreview" object:nil];
}

static void dated_refreshAll(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	system("killall -9 MobileSMS");
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"DDRefreshPreview" object:nil];
}

/**************************** NSString Category ****************************/

@interface NSString (Dated)
- (BOOL)notEmpty;
@end

@implementation NSString (Dated)

- (BOOL)notEmpty{
	return self && [self length] > 0;
}

@end

/**************************** Preferences Controller ****************************/

@implementation DDPrefsListController

- (NSArray *)specifiers{
	if (!_specifiers)
		_specifiers = [self loadSpecifiersFromPlistName:(MODERN_IOS ? @"DatedPrefsNoAll" : @"DatedPrefsWithAll") target:self];

	return _specifiers;
}

- (void)loadView{
	[super loadView];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped:)];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &dated_refreshApp, CFSTR("com.insanj.dated/RefreshApp"), NULL, 0);
CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &dated_refreshPreview, CFSTR("com.insanj.dated/RefreshPreview"), NULL, 0);
CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &dated_refreshAll, CFSTR("com.insanj.dated/RefreshAll"), NULL, 0);
}

- (void)viewDidLoad{
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
	if (MODERN_IOS) {
		self.view.tintColor =
		self.navigationController.navigationBar.tintColor =
		[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = DD_TINTCOLOR;
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if (MODERN_IOS) {
		self.view.tintColor = nil;
		self.navigationController.navigationBar.tintColor = nil;
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, CFSTR("com.insanj.dated/RefreshApp"), NULL);
CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, CFSTR("com.insanj.dated/RefreshPreview"), NULL);
CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, CFSTR("com.insanj.dated/RefreshAll"), NULL);
}

- (void)shareTapped:(UIBarButtonItem *)sender {
	NSString *text = @"Configurable, reliable timestamps are all mine with #Dated by @insanj.";
	NSURL *url = [NSURL URLWithString:@"http://github.com/insanj/dated"];

	if (%c(UIActivityViewController)) {
		UIActivityViewController *viewController = [[%c(UIActivityViewController) alloc] initWithActivityItems:[NSArray arrayWithObjects:text, url, nil] applicationActivities:nil];
		[self.navigationController presentViewController:viewController animated:YES completion:NULL];
	}

	else if (%c(TWTweetComposeViewController) && [TWTweetComposeViewController canSendTweet]) {
		TWTweetComposeViewController *viewController = [[TWTweetComposeViewController alloc] init];
		viewController.initialText = text;
		[viewController addURL:url];
		[self.navigationController presentViewController:viewController animated:YES completion:NULL];
	}

	else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/intent/tweet?text=%@%%20%@", URL_ENCODE(text), URL_ENCODE(url.absoluteString)]]];
	}
}

- (void)insanj {
	[self twitter:@"insanj"];
}

- (void)twitter:(NSString *)user {
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]]];

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name="  stringByAppendingString:user]]];

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:user]]];

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]]];

	else
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]]];
}

- (void)website {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://github.com/insanj/dated"]];
}

@end

/**************************** Custom Preview PSTableCell ****************************/

@implementation DDPreviewTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPreview) name:@"DDRefreshPreview" object:nil];

		self.textLabel.text = dated_stringFromDateUsingTemplate([NSDate dateWithTimeIntervalSince1970:-468650652], dated_templateStringFromSavedComponents());
			}

	return self;
}

- (void)refreshPreview {
	NSString *newDateText = dated_stringFromDateUsingTemplate([NSDate dateWithTimeIntervalSince1970:-468650652], dated_templateStringFromSavedComponents());
	NSLog(@"[Dated] Refreshing preview text label (%@), and killing Messages app to apply...", newDateText);
	self.textLabel.text = newDateText;
}

@end
