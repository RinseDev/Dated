//
//  Dated.xm
//  Dated
//	
//  Created by Julian Weiss on 3/20/14.
//  Copyright (c) 2014-2015, insanj. All rights reserved.
//

#import "Dated.h"

static CGFloat kDatedEstimatedDrawerWidth = 78.232;

/*
                                    _..._               
                                 .-'_..._''.            
                     _..._     .' .'      '.\           
     _.._          .'     '.  / .'                      
   .' .._|        .   .-.   .. '                        
   | '            |  '   '  || |                        
 __| |__  _    _  |  |   |  || |                   _    
|__   __|| '  / | |  |   |  |. '                 .' |   
   | |  .' | .' | |  |   |  | \ '.          .   .   | / 
   | |  /  | /  | |  |   |  |  '. `._____.-'/ .'.'| |// 
   | | |   `'.  | |  |   |  |    `-.______ /.'.'.-'  /  
   | | '   .'|  '/|  |   |  |             ` .'   \_.'   
   |_|  `-'  `--' '--'   '--'                           
*/
static NSString *dated_templateStringFromSavedComponents() {
	HBPreferences *settings = [%c(HBPreferences) preferencesForIdentifier:@"com.insanj.dated"];
	NSLog(@"[Dated] Creating template string from saved preferences file: %@", settings);

	NSString *year = [[settings objectForKey:@"year"] boolValue] ? @"y" : @"";
	NSString *month = ![[settings objectForKey:@"month"] boolValue] ? @"M" : @"";
	NSString *day = ![[settings objectForKey:@"day"] boolValue] ? @"d" : @"";
	NSString *dow = [[settings objectForKey:@"dow"] boolValue] ? @"cccccc" : @"";
	NSString *hour = ![[settings objectForKey:@"hour"] boolValue] ? @"H" : @"";
	NSString *min = ![[settings objectForKey:@"minute"] boolValue] ? @"m" : @"";
	NSString *sec = [[settings objectForKey:@"second"] boolValue] ? @"s" : @"";
	NSString *ampm = ![[settings objectForKey:@"ampm"] boolValue] ? @"j" : @"";
	
	return [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", year, month, day, dow, hour, min, sec, ampm];
}

static NSString *dated_stringFromDateUsingTemplate(NSDate *date, NSString *components) {
	NSLog(@"[Dated] Creating string from date %@ using components string: %@", date, components);

	if (MODERN_IOS) {
		CKAutoupdatingDateFormatter *formatter = [[[%c(CKAutoupdatingDateFormatter) alloc] initWithTemplate:components] autorelease];
		return [formatter stringFromDate:date];
	}

	else {
		NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
		[formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:components options:0 locale:[NSLocale currentLocale]]];
		return [formatter stringFromDate:date];
	}
}

%group Modern

/*
              .-'''-.                                               
             '   _    \                                             
           /   /` '.   \          __  __   ___                      
     _.._ .   |     \  '         |  |/  `.'   `.                    
   .' .._||   '      |  '.-,.--. |   .-.  .-.   '              .|   
   | '    \    \     / / |  .-. ||  |  |  |  |  |    __      .' |_  
 __| |__   `.   ` ..' /  | |  | ||  |  |  |  |  | .:--.'.  .'     | 
|__   __|     '-...-'`   | |  | ||  |  |  |  |  |/ |   \ |'--.  .-' 
   | |                   | |  '- |  |  |  |  |  |`" __ | |   |  |   
   | |                   | |     |__|  |__|  |__| .'.''| |   |  |   
   | |                   | |                     / /   | |_  |  '.' 
   | |                   |_|                     \ \._,\ '/  |   /  
   |_|                                            `--'  `"   `'-'   
*/
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
		NSLog(@"[Dated] Heard initialization attempt on per-message dateFormatter, replacing with long form...");
		return %orig(dated_templateStringFromSavedComponents()); // default is @"Mdjmm" -> @"3/15, 11:44 AM"
	}

	else {
		return %orig(arg1);
	}
}

%end

/*
                                                                    
_______                                                             
\  ___ `'.                                   __.....__              
 ' |--.\  \                      _     _ .-''         '.            
 | |    \  ' .-,.--.       /\    \\   ///     .-''"'-.  `. .-,.--.  
 | |     |  '|  .-. |    __`\\  //\\ ///     /________\   \|  .-. | 
 | |     |  || |  | | .:--.'.\`//  \'/ |                  || |  | | 
 | |     ' .'| |  | |/ |   \ |\|   |/  \    .-------------'| |  | | 
 | |___.' /' | |  '- `" __ | | '        \    '-.____...---.| |  '-  
/_______.'/  | |      .'.''| |           `.             .' | |      
\_______|/   | |     / /   | |_            `''-...... -'   | |      
             |_|     \ \._,\ '/                            |_|      
                      `--'  `"                                      
*/
// The method I chose for expanding the label size with %hook'ing the
// -layoutSubviews for the entire ballon. This method is guaranteed to work,
// although it may not be the most efficient. The numbered methods in the .h
// were other tempting methods, but didn't get called as consistently.
%hook CKTranscriptBalloonCell

- (void)layoutSubviews {
	%orig();

	UILabel *label = self.drawerLabel;

	// Will be invalidated by CKUIBehavior if too large.
	CGFloat requiredWidth =  [label.text sizeWithAttributes:@{NSFontAttributeName : label.font}].width;
	label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, fmin(requiredWidth, kDatedEstimatedDrawerWidth), label.frame.size.height);

	label.minimumScaleFactor = 0.5;
	label.adjustsFontSizeToFitWidth = YES;
}

%end

/*
                        .-'''-.                                                
                       '   _    \                                   .---..---. 
             .       /   /` '.   \                                  |   ||   | 
           .'|      .   |     \  '       _     _                    |   ||   | 
          <  |      |   '      |  '/\    \\   //                    |   ||   | 
           | |      \    \     / / `\\  //\\ //               __    |   ||   | 
       _   | | .'''-.`.   ` ..' /    \`//  \'/             .:--.'.  |   ||   | 
     .' |  | |/.'''. \  '-...-'`      \|   |/             / |   \ | |   ||   | 
    .   | /|  /    | |                 '                  `" __ | | |   ||   | 
  .'.'| |//| |     | |                                     .'.''| | |   ||   | 
.'.'.-'  / | |     | |                                    / /   | |_'---''---' 
.'   \_.'  | '.    | '.                                   \ \._,\ '/           
           '---'   '---'                                   `--'  `"            
*/
// Attempted method introspections (of no use):
// UICollectionView-
//	- (id)_createPreparedCellForItemAtIndexPath:(id)arg1 withLayoutAttributes:(id)arg2 applyAttributes:(BOOL)arg3
// CKConversation-
//	- (int)compareBySequenceNumberAndDateDescending:(id)arg1 (too high-level)
// CKTimestamp-
//	- (id)initWithDate:(id)arg1 message:(id)arg2
// CKTranscriptCell-
//	- (id)initWithFrame:(CGRect)arg1
//	- (void)configureForRow:(id)arg1
//	- (void)configureForRowObject:(id)arg1
// CKTranscriptLabelCell-
//	- (id)initWithFrame:(CGRect)arg1
//	- (void)configureForRowObject:(id)arg1
//	- (void)layoutSubviewsForContents
// CKTranscriptCollectionViewController-
//	- (id)collectionView:(id)arg1 cellForItemAtIndexPath:(id)arg2
//	- (id)initWithConversation:(id)arg1
//	- (BOOL)balloonView:(id)arg1 canPerformAction:(SEL)arg2 withSender:(id)arg3
//	- (void)configureCell:(id)arg1 forItemAtIndexPath:(id)arg2
//	- (id)transcriptObjectForBalloonView:(id)arg1
//	- (void)loadView (although I feel like this means something)
// CKTranscriptData-
//	- (id)initWithConversation:(id)arg1
//	- (void)setUpdater:(id)arg1
//	- (id)rows
//	- (BOOL)isHoldingUpdates
//	- (id)messageAtIndex:(unsigned int)arg1
//	- (void)addSendingMessage:(id)arg1 handler:(id)arg2
//	- (id)updater (and all related CKScheduledUpdater/CKManualUpdater methods)
// CKTranscriptDataRow-
//	+ (id)rowWithObject:(id)arg1 forMessage:(id)arg2
//	- (id)initWithObject:(id)arg1 forMessage:(id)arg2 (even flags are nothing)
// CKIMMessage-
//	accessing any of: date:guid:hasBeenSent:isDelivered:messagePartCount:parts:supportsDeliveryReceipts:wantsSendStatus:
// IMChatItem-
//	- (id)_initWithGUID:(id)arg1 date:(id)arg2 datum1:(id)arg3 datum2:(id)arg4 datum3:(id)arg5
//	- (int)_compareToChatItem:(id)arg1
//	- (int)_reverseCompareToChatItem:(id)arg1
// IMMarkChatItem-
//	- (id)initWithDate:(id)arg1
// IMMessage-
//	- (int)_compareIMMessageDates:(id)arg1
//	- (int)compare:(id)arg1
//	- (int)compare:(id)arg1 comparisonType:(int)arg2 (but it is called nicely, and cT == 2)
//	- (id)_dateStampForChatItem:(id)arg1 atIndex:(unsigned int)arg2 (must be legacy!)
//	Message not found-
//		- (BOOL)_doesChatItemContainTimestamp:(id)arg1
//		- (id)_newHeaderChatItemWithDate:(id)arg1 account:(id)arg2
//		- (void)_removeChatItem:(id)arg1 andTimestamp:(BOOL)arg2
//		- (id)_timeStampForChatItem:(id)arg1 atIndex:(unsigned int)arg2
//		- (BOOL)deleteMessageParts:(id)arg1 forMessage:(id)arg2
//		- (BOOL)shouldAppendDatestampAfterChatItem:(id)arg1 andBeforeChatItem:(id)arg2
//		- (BOOL)shouldAppendTimestampAfterChatItem:(id)arg1 andBeforeChatItem:(id)arg2
//		- (id)valueForChatProperty:(id)arg1
//		- (id)valueForProperty:(id)arg1 ofParticipant:(id)arg2
// IMTimestampChatItem-
//	- (id)initWithDate:(id)arg1 (never called?!)
// IMDatestampChatItem-
//	- (id)initWithDate:(id)arg1 (never called, too?!)
// IMHeaderChatItem-
//	- (id)initWithString:(id)arg1 date:(id)arg2 (never called, too too?!)

// Methods deemed unimportant:
// CKTranscriptLabelCell-
//	- (NSAttributedString *)attributedText
//	- (void)setAttributedText:(NSAttributedString *)arg1
//	- (void)setLabel:(UILabel *)arg1
//	- (void)setOrientation:(BOOL)arg1

%end // %group Modern

/*
                                                   _..._                
.---.                                           .-'_..._''.             
|   |      __.....__                          .' .'      '.\            
|   |  .-''         '.     .--./)            / .'       .-.          .- 
|   | /     .-''"'-.  `.  /.''\\            . '          \ \        / / 
|   |/     /________\   \| |  | |      __   | |           \ \      / /  
|   ||                  | \`-' /    .:--.'. | |            \ \    / /   
|   |\    .-------------' /("'`    / |   \ |. '             \ \  / /    
|   | \    '-.____...---. \ '---.  `" __ | | \ '.          . \ `  /     
|   |  `.             .'   /'""'.\  .'.''| |  '. `._____.-'/  \  /      
'---'    `''-...... -'    ||     ||/ /   | |_   `-.______ /   / /       
                          \'. __// \ \._,\ '/            `|`-' /        
                           `'---'   `--'  `"               '..'         
*/
%group Legacy

%hook CKTimestampCell

// Equivalent to the iOS 7 formatting hooks, but for each individual timestamp,
// since there is no global DateFormatter class before the Ive-days.
- (void)setDate:(NSDate *)date {
	UILabel *label = MSHookIvar<UILabel *>(self, "_label");
	[label setText:dated_stringFromDateUsingTemplate(date, dated_templateStringFromSavedComponents())];
}

%end

// "Show All" hook.
%hook CKTranscriptBubbleData

- (BOOL)_shouldShowTimestampForDate:(id)arg1 {
	HBPreferences *settings = [%c(HBPreferences) preferencesForIdentifier:@"com.insanj.dated"];
	return %orig() || [[settings objectForKey:@"allmessages"] boolValue];
}

%end

%end // %group Legacy

/*
       _..._             .-'''-.             
    .-'_..._''.         '   _    \           
  .' .'      '.\      /   /` '.   \          
 / .'                .   |     \  '          
. '               .| |   '      |  '.-,.--.  
| |             .' |_\    \     / / |  .-. | 
| |           .'     |`.   ` ..' /  | |  | | 
. '          '--.  .-'   '-...-'`   | |  | | 
 \ '.          .|  |                | |  '-  
  '. `._____.-'/|  |                | |      
    `-.______ / |  '.'              | |      
             `  |   /               |_|      
                `'-'                         
*/
%ctor {
	BOOL datedEnabled = ![[HBPreferences preferencesForIdentifier:@"com.insanj.dated"] boolForKey:@"disabled"];

	if (datedEnabled) {
		if (MODERN_IOS) {
			%init(Modern);
		}

		else {
			%init(Legacy);
		}
	}
}
