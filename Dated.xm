#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

#define CKDRAWERWIDTH 78.232

/**************************** Timestamp Hooks ****************************/

@interface CKAutoupdatingDateFormatter : NSDateFormatter
- (id)initWithTemplate:(id)arg1;
@end

%hook CKAutoupdatingDateFormatter

// CKAutoupdatingDateFormatter templates don't strictly follow NSDateFormatter,
// instead, they steal away the components specified in the template, and arrage
// them based on the system localization (the translation follows %orig(XXX)).

// Templates come in four variants:
//	EEEE (@"Saturday")
//	EEEEjm (@"Saturday 11:42 AM")
//	jm (@"11:42 AM")

- (id)initWithTemplate:(id)arg1 {
	if ([arg1 isEqualToString:@"jm"]) {
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

		NSLog(@"[Dater] Heard initialization attempt on per-message dateFormatter, replacing with long form...");
		return %orig(components); // default is @"Mdjmm" -> @"3/15, 11:44 AM"
	}

	else {
		return %orig(arg1);
	}
}

%end

/*************************** Drawer Size Hooks ***************************/

// The method I chose for expanding the label size with %hook'ing the
// -layoutSubviews for the entire ballon. This method is guaranteed to work,
// although it may not be the most efficient. The numbered methods were other
// tempting methods, but didn't get called as consistently.

@interface CKTranscriptBalloonCell

@property(copy) NSAttributedString *drawerAttributedText;
@property(retain) UILabel *drawerLabel;

- (void)configureForRow:(id)arg1;
- (void)configureForRowObject:(id)arg1;
- (UILabel *)drawerLabel; // [1]
- (id)initWithFrame:(CGRect)arg1;
- (void)layoutSubviewsForContents; // [2]
- (void)layoutSubviewsForDrawer; // [3]
- (void)setDrawerAttributedText:(NSAttributedString *)arg1;
- (void)setDrawerLabel:(UILabel *)arg1; // [4]
- (void)setDrawerTextChanged:(BOOL)arg1;
- (void)setDrawerWasVisible:(BOOL)arg1;

@end

%hook CKTranscriptBalloonCell

- (void)layoutSubviews {
	%orig();

	UILabel *label = self.drawerLabel;

	CGFloat requiredWidth =  [label.text sizeWithFont:label.font].width; // Will be invalidated by CKUIBehavior if too large.
	[label setFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y, fmin(requiredWidth, CKDRAWERWIDTH), label.frame.size.height)];

	label.minimumScaleFactor = 0.5;
	label.adjustsFontSizeToFitWidth = YES;
}

%end
