// Dated (commercial tweak)
// Created by Julian (insanj) Weiss 2014
// Source and license available on GitHub

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <objc/runtime.h>

#define CKDRAWERWIDTH 78.232
#define MODERN_IOS ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

// Global
@interface NSObject (Dated)
+ (NSString *)templateStringFromSavedComponents;
+ (NSString *)stringFromDate:(NSDate *)date usingTemplate:(NSString *)components;
@end

// iOS 7
@interface CKAutoupdatingDateFormatter
- (id)initWithTemplate:(id)arg1;
- (id)stringFromDate:(id)arg1;
@end

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

@interface IMChat
- (BOOL)shouldAppendTimestampAfterChatItem:(id)arg1 andBeforeChatItem:(id)arg2;
@end

// iOS 6
@interface CKTimestampCell {
    UILabel *_label;
}

- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2;
- (void)setDate:(id)arg1;
@end

@interface CKTranscriptBubbleData
- (BOOL)_shouldShowTimestampForDate:(id)arg1;
@end
