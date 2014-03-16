#import <UIKit/UIKit.h>

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
		NSLog(@"[Dater] Heard initialization attempt on per-message dateFormatter, replacing with long form...");
		return %orig(@"Mdjmm"); // @"3/15, 11:44 AM"
	}

	else {
		return %orig(arg1);
	}
}

%end

/*************************** Drawer Size Hooks ***************************/

@interface CKTranscriptBalloonCell

@property(copy) NSAttributedString *drawerAttributedText;
@property(retain) UILabel *drawerLabel;

- (void)configureForRow:(id)arg1;
- (void)configureForRowObject:(id)arg1;
- (UILabel *)drawerLabel;
- (id)initWithFrame:(CGRect)arg1;
- (void)layoutSubviewsForContents;
- (void)layoutSubviewsForDrawer;
- (void)setDrawerAttributedText:(NSAttributedString *)arg1;
- (void)setDrawerLabel:(UILabel *)arg1;
- (void)setDrawerTextChanged:(BOOL)arg1;
- (void)setDrawerWasVisible:(BOOL)arg1;

@end

%hook CKTranscriptBalloonCell

- (UILabel *)drawerLabel {
	UILabel *label = %orig();

	CGFloat requiredWidth =  [label.text sizeWithFont:label.font].width;
	if (requiredWidth - label.frame.size.width > 0.0) {
		NSLog(@"[Dater] Autoupdating size of %@ to fit expanded contents of %@.", label, label.text);
		[label setFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y, requiredWidth, label.frame.size.height)];
	}

	return label;
}

%end
