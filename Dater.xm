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

/************************* UILabel Custom Class *************************/

@interface DRAutoupdatingDateLabel : UILabel
@end

@implementation DRAutoupdatingDateLabel

- (void)setAttributedText:(id)text {
	NSLog(@"[Dater] Autoupdating size of %@ to fit expanded contents of %@.", self, text);

	CGRect expanded = self.frame;
	expanded.size.width = [self.text sizeWithFont:self.font].width;
	[self setFrame:expanded];

	[super setAttributedText:text];
}

@end

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

- (void)setDrawerLabel:(UILabel *)arg1 {
	NSLog(@"[Dater] Reassigning drawer label %@ to be a DRAutoupdatingDateLabel.", arg1);
	DRAutoupdatingDateLabel *label = (DRAutoupdatingDateLabel *) arg1;
	%orig(label);
}

%end
