#import <UIKit/UIKit.h>

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

// Unfortunately, because it'd be inconvenient (mostly for the user) to make
// the drawers larger, sometimes the "AM"/"PM" will be cut off. C'est la vie!

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
