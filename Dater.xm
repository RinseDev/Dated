#import <UIKit/UIKit.h>

@interface CKTimestamp : NSObject {
    NSAttributedString *_attributedTranscriptText;
}

@property(readonly) NSAttributedString *attributedTranscriptText;

+ (id)thePastDateFormatter;
+ (id)thisWeekRelativeDateFormatter;
+ (id)thisYearDateFormatter;
+ (id)timestampWithDate:(NSDate *)arg1 message:(id)arg2; // CKMessage
- (NSAttributedString *)attributedTranscriptText;

@end

%hook CKTimestamp

+ (id)thePastDateFormatter {
	NSLog(@"[thepastdateformatter] %@", %orig);
	return %orig();
}

+ (id)thisWeekRelativeDateFormatter {
	NSLog(@"[thisweekrelativedateformatter] %@", %orig);
	return %orig();
}

+ (id)thisYearDateFormatter {
	NSLog(@"[thisyeardateformatter] %@", %orig);
	return %orig();
}

- (NSAttributedString *)attributedTranscriptText {
	NSLog(@"[attributedtranscriptext] %@", %orig);
	return %orig();
}

%end

@interface CKUIBehavior : NSObject
- (float)timestampBodyLeading;
- (float)timestampBodyLeadingFraction:(float)arg1;
- (id)timestampDateFormatter;
- (UIEdgeInsets)timestampTranscriptInsets;
@end

%hook CKUIBehavior

- (float)timestampBodyLeading {
	NSLog(@"[timestampbodyleading] %f", %orig);
	return %orig();
}

- (float)timestampBodyLeadingFraction:(float)arg1 {
	NSLog(@"[timestampbodyleadingfraction %f] %f", arg1, %orig);
	return %orig();
}

- (id)timestampDateFormatter {
	NSLog(@"[timestampdateformatter] %@", %orig);
	return %orig();
}

- (UIEdgeInsets)timestampTranscriptInsets {
	NSLog(@"[timestamptrnscripinsets] %@", NSStringFromUIEdgeInsets(%orig));
	return %orig();
}

%end
