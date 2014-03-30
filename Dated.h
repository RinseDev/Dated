// Dated (commercial tweak)
// Created by Julian (insanj) Weiss 2014
// Source and license available on GitHub

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <objc/runtime.h>

#define CKDRAWERWIDTH 78.232
#define MODERN_IOS ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define INSPECT(item) NSLog((@"%s [Line %d] %@\n%@"), __PRETTY_FUNCTION__, __LINE__, item, [NSThread callStackSymbols])


// iOS 7
// For overriding all timestamps generated, much cleaner than iOS 6, as it
// only has to be done when a thread is loading (and all the formatting is
// being warmed up for drawer-writing).
@interface CKAutoupdatingDateFormatter
- (id)initWithTemplate:(id)arg1;
- (id)stringFromDate:(id)arg1;
@end

// For configuring the size of the drawer (and the label's font-size), so
// we don't get clipping when the new date's format is way too big (or small).
// The annotationed numbers are explained in Dated.xm.
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

// For the "Show All" timestamps option.
@interface CKIMMessage : NSObject

@property(readonly) NSDate *date;
@property(readonly) NSString *guid;
@property(readonly) BOOL hasBeenSent;
@property(readonly) BOOL isDelivered;
@property(readonly) unsigned int messagePartCount;
@property(readonly) NSArray *parts;
@property(readonly) BOOL supportsDeliveryReceipts;
@property(readonly) BOOL wantsSendStatus;

- (int)compare:(id)arg1;
- (NSDate *)date;
- (NSString *)guid;
- (BOOL)hasBeenSent;
- (BOOL)isDelivered;
- (unsigned int)messagePartCount;
- (id)parts;
- (BOOL)postMessageReceivedIfNecessary;
- (BOOL)supportsDeliveryReceipts;
- (BOOL)wantsSendStatus;

@end


// iOS 6
// For all of the above. Individually replaces the date label's text-setting
// with the equivalent to iOS 7's global AutoupdatingDateFormatter. This is
// actually quite interesting... it appears that CKADF is just a quick way to
// do what I do with the -dateFormatFromTemplate:options:locale, with maybe
// some goodies thrown in that are particular to MobileSMS.
@interface CKTimestampCell {
    UILabel *_label;
}

- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2;
- (void)setDate:(id)arg1;
@end

// For the "Show All" timestamps option. The only remaining trace of the
// grandfather to Dated (before Dater), Stamper.
@interface CKTranscriptBubbleData
- (BOOL)_shouldShowTimestampForDate:(id)arg1;
@end
