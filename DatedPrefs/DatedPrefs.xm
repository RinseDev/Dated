#import "DatedPrefs.h"

#define URL_ENCODE(string) (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)(string), NULL, CFSTR(":/=,!$& '()*+;[]@#?"), kCFStringEncodingUTF8)
#define DD_TINTCOLOR [UIColor colorWithRed:46/255.0 green:204/255.0 blue:64/255.0 alpha:1.0]

static void dated_refreshText(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"DDRefresh" object:nil];
}

@implementation DDPrefsListController

- (NSArray *)specifiers{
	if(!_specifiers)
		_specifiers = [[self loadSpecifiersFromPlistName:@"DatedPrefs" target:self] retain];

	return _specifiers;
}

- (void)loadView{
	[super loadView];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped:)];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &dated_refreshText, CFSTR("com.insanj.dated/RefreshText"), NULL, 0);
}

- (void)viewDidLoad{
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [(UITableView *)self.view deselectRowAtIndexPath:((UITableView *)self.view).indexPathForSelectedRow animated:YES];

	self.view.tintColor =
	self.navigationController.navigationBar.tintColor =
	[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = DD_TINTCOLOR;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	self.view.tintColor = nil;
	self.navigationController.navigationBar.tintColor = nil;
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

@implementation DDPreviewTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])){
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(dated_refreshDateText) name:@"DDRefresh" object:nil];
		self.textLabel.text = [self dated_previewDateText];
	}

	return self;
}

- (NSString *)dated_previewDateText {
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.dated.plist"]];

	NSString *components = @"";
	if ([[settings objectForKey:@"year"] boolValue]) {
		components = [components stringByAppendingString:@"y"];
	}

	if (![[settings objectForKey:@"month"] boolValue]) {
		components = [components stringByAppendingString:@"M"];
	}

	if (![[settings objectForKey:@"day"] boolValue]) {
		components = [components stringByAppendingString:@"d"];
	}

	if (![[settings objectForKey:@"hour"] boolValue]) {
		components = [components stringByAppendingString:@"H"];
	}

	if (![[settings objectForKey:@"minute"] boolValue]) {
		components = [components stringByAppendingString:@"m"];
	}

	if ([[settings objectForKey:@"second"] boolValue]) {
		components = [components stringByAppendingString:@"s"];
	}

	if (![[settings objectForKey:@"ampm"] boolValue]) {
		components = [components stringByAppendingString:@"j"];
	}

	CKAutoupdatingDateFormatter *formatter = [[[CKAutoupdatingDateFormatter alloc] initWithTemplate:components] autorelease];
	return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:-468650652]];
}

- (void)dated_refreshDateText {
	system("killall -9 MobileSMS");
	NSString *newDateText = [self dated_previewDateText];

	NSLog(@"[Dated] Refreshing preview text label (%@), and killing Messages app to apply...", newDateText);
	self.textLabel.text = newDateText;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
