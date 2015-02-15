// Dated (commercial tweak)
// Created by Julian (insanj) Weiss 2014
// Source and license available on Git

#import "DatedPrefs.h"

static UIColor *kDatedTintColor = [UIColor colorWithRed:46/255.0 green:204/255.0 blue:64/255.0 alpha:1.0];

/*
              .-'''-.                                               
             '   _    \                                             
           /   /` '.   \          __  __   ___                      
     _.._ .   |     \  '         |  |/  `.'   `.                    
   .' .._||   '      |  '.-,.--. |   .-.  .-.   '              .|   
   | '    \    \     / / |  .-. ||  |  |  |  |  |    __      .' |_  
 __| |__   `.   ` ..' /  | |  | ||  |  |  |  |  | .:--.'.  .'     | 
|__   __|     '-...-'`   | |  | ||  |  |  |  |  |/ |   \ |'--.  .-' 
   | |                   | |  '- |  |  |  |  |  |`" __ | |   |  |   
   | |                   | |     |__|  |__|  |__| .'.''| |   |  |   
   | |                   | |                     / /   | |_  |  '.' 
   | |                   |_|                     \ \._,\ '/  |   /  
   |_|                                            `--'  `"   `'-'   
*/
static NSString *dated_templateStringFromSavedComponents() {
	HBPreferences *settings = [%c(HBPreferences) preferencesForIdentifier:@"com.insanj.dated"];
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

static NSString *dated_stringFromDateUsingTemplate(NSDate *date, NSString *components) {
	NSLog(@"[Dated] Creating string from date %@ using components string: %@", date, components);

	if (MODERN_IOS) {
		CKAutoupdatingDateFormatter *formatter = [[%c(CKAutoupdatingDateFormatter) alloc] initWithTemplate:components];
		return [formatter stringFromDate:date];
	}

	else {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:components options:0 locale:[NSLocale currentLocale]]];
		return [formatter stringFromDate:date];
	}
}

/*
               .-'''-.                         
              '   _    \                       
   _..._    /   /` '.   \       .--.           
 .'     '. .   |     \  '       |__|     _.._  
.   .-.   .|   '      |  '  .|  .--.   .' .._| 
|  '   '  |\    \     / / .' |_ |  |   | '     
|  |   |  | `.   ` ..' /.'     ||  | __| |__   
|  |   |  |    '-...-'`'--.  .-'|  ||__   __|  
|  |   |  |               |  |  |  |   | |     
|  |   |  |               |  |  |__|   | |     
|  |   |  |               |  '.'       | |     
|  |   |  |               |   /        | |     
'--'   '--'               `'-'         |_|     
*/
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

/*                                                                                                                                             
   _..._                                       .--.   _..._              
 .'     '.                                     |__| .'     '.   .--./)   
.   .-.   .                        .|  .-,.--. .--..   .-.   . /.''\\    
|  '   '  |                      .' |_ |  .-. ||  ||  '   '  || |  | |   
|  |   |  |       _         _  .'     || |  | ||  ||  |   |  | \`-' /    
|  |   |  |     .' |      .' |'--.  .-'| |  | ||  ||  |   |  | /("'`     
|  |   |  |    .   | /   .   | / |  |  | |  '- |  ||  |   |  | \ '---.   
|  |   |  |  .'.'| |// .'.'| |// |  |  | |     |__||  |   |  |  /'""'.\  
|  |   |  |.'.'.-'  /.'.'.-'  /  |  '.'| |         |  |   |  | ||     || 
|  |   |  |.'   \_.' .'   \_.'   |   / |_|         |  |   |  | \'. __//  
'--'   '--'                      `'-'              '--'   '--'  `'---'   
*/
@interface NSString (Dated)

- (BOOL)notEmpty;

@end

@implementation NSString (Dated)

- (BOOL)notEmpty {
	return self && [self length] > 0;
}

@end

/*                                                                                                                                
_________   _...._                    __.....__                       
\        |.'      '-.             .-''         '.        _.._         
 \        .'```'.    '. .-,.--.  /     .-''"'-.  `.    .' .._|        
  \      |       \     \|  .-. |/     /________\   \   | '            
   |     |        |    || |  | ||                  | __| |__     _    
   |      \      /    . | |  | |\    .-------------'|__   __|  .' |   
   |     |\`'-.-'   .'  | |  '-  \    '-.____...---.   | |    .   | / 
   |     | '-....-'`    | |       `.             .'    | |  .'.'| |// 
  .'     '.             | |         `''-...... -'      | |.'.'.-'  /  
'-----------'           |_|                            | |.'   \_.'   
*/                                                     
@implementation DDPrefsListController

+ (NSString *)hb_specifierPlist {
	return MODERN_IOS ? @"DatedPrefsNoAll" : @"DatedPrefsWithAll";
}

+ (UIColor *)hb_tintColor {
	return kDatedTintColor;
}

- (void)loadView{
	[super loadView];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped:)];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &dated_refreshApp, CFSTR("com.insanj.dated/RefreshApp"), NULL, 0);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &dated_refreshPreview, CFSTR("com.insanj.dated/RefreshPreview"), NULL, 0);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &dated_refreshAll, CFSTR("com.insanj.dated/RefreshAll"), NULL, 0);
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, CFSTR("com.insanj.dated/RefreshApp"), NULL);
	CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, CFSTR("com.insanj.dated/RefreshPreview"), NULL);
	CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, CFSTR("com.insanj.dated/RefreshAll"), NULL);
}

- (void)shareTapped:(UIBarButtonItem *)sender {
	NSString *text = @"Configurable, reliable timestamps are all mine with #Dated";
	NSURL *url = [NSURL URLWithString:@"https://github.com/rinsedev"];

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

- (void)twitterTapped {
	NSString *user = @"insanj";
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]]];
	}

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name="  stringByAppendingString:user]]];
	}

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:user]]];
	}

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]]];
	}

	else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]]];
	}
}

- (void)githubTapped {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/rinsedev"]];
}

@end

/*
       _..._                                  
    .-'_..._''.                    .---..---. 
  .' .'      '.\     __.....__     |   ||   | 
 / .'            .-''         '.   |   ||   | 
. '             /     .-''"'-.  `. |   ||   | 
| |            /     /________\   \|   ||   | 
| |            |                  ||   ||   | 
. '            \    .-------------'|   ||   | 
 \ '.          .\    '-.____...---.|   ||   | 
  '. `._____.-'/ `.             .' |   ||   | 
    `-.______ /    `''-...... -'   '---''---' 
*/                                             
@implementation DDPreviewTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];

	if (self) {
		self.textLabel.text = dated_stringFromDateUsingTemplate([NSDate dateWithTimeIntervalSince1970:-468650652], dated_templateStringFromSavedComponents());
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPreview) name:@"DDRefreshPreview" object:nil];
	}

	return self;
}

- (void)refreshPreview {
	NSString *newDateText = dated_stringFromDateUsingTemplate([NSDate dateWithTimeIntervalSince1970:-468650652], dated_templateStringFromSavedComponents());
	NSLog(@"[Dated] Refreshing preview text label (%@), and killing Messages app to apply...", newDateText);
	self.textLabel.text = newDateText;
}

@end
