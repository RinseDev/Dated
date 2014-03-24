// Dated (commercial tweak)
// Created by Julian (insanj) Weiss 2014
// Source and license available on Git

#import "Dated.h"

/**************************** Timestamp Hooks ****************************/

%group Modern

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
// although it may not be the most efficient. The numbered methods in the .h
// were other tempting methods, but didn't get called as consistently.

%hook CKTranscriptBalloonCell

- (void)layoutSubviews {
	%orig();

	UILabel *label = self.drawerLabel;

	// Will be invalidated by CKUIBehavior if too large.
	CGFloat requiredWidth =  [label.text sizeWithFont:label.font].width;
	[label setFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y, fmin(requiredWidth, CKDRAWERWIDTH), label.frame.size.height)];

	label.minimumScaleFactor = 0.5;
	label.adjustsFontSizeToFitWidth = YES;
}

%end

%end // %group Modern


%group Ancient

%hook CKTimestampCell

- (void)setDate:(NSDate *)date {
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

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:components];
	UILabel *label = MSHookIvar<UILabel *>(self, "_label");

	[label setText:[formatter stringFromDate:date]];
}

%end

%hook CKTranscriptBubbleData

- (BOOL)_shouldShowTimestampForDate:(id)arg1 {
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.dated.plist"]];
	return %orig() || [[settings objectForKey:@"allmessages"] boolValue];
}

%end

%end // %group Ancient


%ctor {
	if (MODERN_IOS) {
		NSLog(@"[Dated] Injecting modern hooks into ChatKit...");
		%init(Modern);
	}

	else {
		NSLog(@"[Dated] Injecting ancient hooks into ChatKit...");
		%init(Ancient);
	}
}
