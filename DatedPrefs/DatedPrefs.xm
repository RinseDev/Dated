#import "DDPrefs.h"

#define URL_ENCODE(string) (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)(string), NULL, CFSTR(":/=,!$& '()*+;[]@#?"), kCFStringEncodingUTF8)
#define DD_TINTCOLOR [UIColor colorWithRed:46/255.0 green:204/255.0 blue:64/255.0 alpha:1.0]

@implementation DDPrefsListController

- (NSArray *)specifiers{
	if(!_specifiers)
		_specifiers = [self loadSpecifiersFromPlistName:@"DatedPrefs" target:self];

	return _specifiers;
}

- (void)loadView{
	[super loadView];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped:)];
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

- (void)apply {
	[[[%c(SBApplicationController) sharedInstance] applicationWithPid:@"MobileSMS"] suspend];
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

@implementation DDListItemsController

- (void)viewWillAppear:(BOOL)animated{
	self.navigationController.navigationBar.tintColor = DD_TINTCOLOR;
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	self.navigationController.navigationBar.tintColor = nil;
}

@end
