// Dated (commercial tweak)
// Created by Julian (insanj) Weiss 2014
// Source and license available on Git

#import "DatedPrefs.h"

static UIColor *kDatedTintColor = [UIColor colorWithRed:46/255.0 green:204/255.0 blue:64/255.0 alpha:1.0];
static BOOL alreadyKilledThisTimeAround = NO;
static NSString *kDatedRefreshPreviewLabelNotificationName = @"Dated.Refresh";
static NSTimeInterval kDatedSteveJobsInterval = -468650652;

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
	NSString *year = [settings boolForKey:@"year"] ? @"y" : @"";
	NSString *month = ![settings boolForKey:@"month"] ? @"M" : @"";
	NSString *day = ![settings boolForKey:@"day"] ? @"d" : @"";
	NSString *dow = [settings boolForKey:@"dow"] ? @"cccccc" : @"";
	NSString *hour = ![settings boolForKey:@"hour"] ? @"H" : @"";
	NSString *min = ![settings boolForKey:@"minute"] ? @"m" : @"";
	NSString *sec = [settings boolForKey:@"second"] ? @"s" : @"";
	NSString *ampm = ![settings boolForKey:@"ampm"] ? @"j" : @"";
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
void dated_killMobileSMS() {
	if (!alreadyKilledThisTimeAround) {
		NSLog(@"[Dated] Killing MobileSMS to refresh display...");
		alreadyKilledThisTimeAround = YES;
		system("killall -9 MobileSMS");
	}
}

void dated_refreshApp(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	dated_killMobileSMS();
}

void dated_refreshPreview(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:kDatedRefreshPreviewLabelNotificationName object:nil];
}

void dated_refreshAll(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	dated_killMobileSMS();
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:kDatedRefreshPreviewLabelNotificationName object:nil];
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
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	alreadyKilledThisTimeAround = NO;
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &dated_refreshApp, CFSTR("com.insanj.dated/RefreshApp"), NULL, 0);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &dated_refreshPreview, CFSTR("com.insanj.dated/RefreshPreview"), NULL, 0);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &dated_refreshAll, CFSTR("com.insanj.dated/RefreshAll"), NULL, 0);
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, CFSTR("com.insanj.dated/RefreshApp"), NULL);
	CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, CFSTR("com.insanj.dated/RefreshPreview"), NULL);
	CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, CFSTR("com.insanj.dated/RefreshAll"), NULL);
}

- (void)shareTapped:(UIBarButtonItem *)sender {
	NSString *text = @"Configurable, reliable timestamps are all mine with #Dated";
	NSURL *url = [NSURL URLWithString:@"http://rinsedev.github.io/Dated/"];

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
		self.textLabel.text = dated_stringFromDateUsingTemplate([NSDate dateWithTimeIntervalSince1970:kDatedSteveJobsInterval], dated_templateStringFromSavedComponents());
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPreview:) name:kDatedRefreshPreviewLabelNotificationName object:nil];
	}

	return self;
}

- (void)refreshPreview:(NSNotification *)notification {
	NSString *newDateText = dated_stringFromDateUsingTemplate([NSDate dateWithTimeIntervalSince1970:kDatedSteveJobsInterval], dated_templateStringFromSavedComponents());
	NSLog(@"[Dated] Refreshing preview text label (%@)...", newDateText);
	self.textLabel.text = newDateText;
}

@end
