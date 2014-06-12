//
//  ActivityCell.m
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "ActivityCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "ProfileImageView.h"
#import "ActivityFeedViewController.h"

static TTTTimeIntervalFormatter *timeFormatter;

@interface ActivityCell ()

// Private view components
@property (nonatomic, strong) ProfileImageView *activityImageView;
@property (nonatomic, strong) UIButton *activityImageButton;

// Flag to remove the right-hand side image if not necessary
@property (nonatomic) BOOL hasActivityImage;

// Private setter for the right-hand side image
- (void)setActivityImageFile:(PFFile *)image;

// Button touch handler for activity image button overlay
- (void)didTapActivityButton:(id)sender;

// Static helper method to calculate the space available for text given images and insets
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth;

@end

@implementation ActivityCell

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        horizontalTextSpace = [ActivityCell horizontalTextSpaceForInsetWidth:0];
        
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }
        
        // Create subviews and set cell properties
        self.opaque = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.hasActivityImage = NO; //No until one is set
        
        self.activityImageView = [[ProfileImageView alloc] init];
        [self.activityImageView setBackgroundColor:[UIColor clearColor]];
        [self.activityImageView setOpaque:YES];
        [self.mainView addSubview:self.activityImageView];
        
        self.activityImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.activityImageButton setBackgroundColor:[UIColor clearColor]];
        [self.activityImageButton addTarget:self action:@selector(didTapActivityButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:self.activityImageButton];
    }
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    // Layout the activity image and show it if it is not nil (no image for the follow activity).
    // Note that the image view is still allocated and ready to be dispalyed since these cells
    // will be reused for all types of activity.
    [self.activityImageView setFrame:CGRectMake( [UIScreen mainScreen].bounds.size.width - 48.0f, 14.0f, 35.0f, 35.0f)];
    [self.activityImageButton setFrame:CGRectMake( [UIScreen mainScreen].bounds.size.width - 48.0f, 14.0f, 35.0f, 35.0f)];
    
    // Add activity image if one was set
    if (self.hasActivityImage) {
        [self.activityImageView setHidden:NO];
        [self.activityImageButton setHidden:NO];
    } else {
        [self.activityImageView setHidden:YES];
        [self.activityImageButton setHidden:YES];
    }
    
    // Change frame of the content text so it doesn't go through the right-hand side picture
    CGSize contentSize = [self.contentLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 72.0f - 46.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    [self.contentLabel setFrame:CGRectMake( 49.0f, 7.0f, contentSize.width, contentSize.height)];
    
    // Layout the timestamp label given new vertical
    CGSize timeSize = [self.timeLabel.text sizeWithFont:[UIFont systemFontOfSize:11.0f] forWidth:[UIScreen mainScreen].bounds.size.width - 72.0f - 46.0f lineBreakMode:NSLineBreakByTruncatingTail];
    [self.timeLabel setFrame:CGRectMake( 49.0f, self.contentLabel.frame.origin.y + self.contentLabel.frame.size.height + 2.0f, timeSize.width, timeSize.height)];
}

#pragma mark - PAPActivityCell

- (void)setIsNew:(BOOL)isNew {
    
    if (isNew) {
        //NSLog(@"isNew");
        [self.mainView setBackgroundColor:[UIColor colorWithRed:215.0f/255.0f green:215.0f/255.0f blue:215.0f/255.0f alpha:1.0]];
    } else {
        //NSLog(@"isNotNew");
        [self.mainView setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)setActivity:(PFObject *)activity {
    
    // Set the activity property
    _activity = activity;
    if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeFollow] || [[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeJoined]) {
        [self setActivityImageFile:nil];
    } else {
        [self setActivityImageFile:(PFFile*)[[activity objectForKey:kPAPActivityPhotoKey] objectForKey:kPAPPhotoThumbnailKey]];
    }
    
    NSString *activityString = [ActivityFeedViewController stringForActivityType:(NSString*)[activity objectForKey:kPAPActivityTypeKey]];
    self.user = [activity objectForKey:kPAPActivityFromUserKey];
    
    // Set name button properties and avatar image
    [self.avatarImageView setFile:[self.user objectForKey:kPAPUserProfilePicSmallKey]];
    
    NSString *nameString = @"Someone";
    if (self.user && [self.user objectForKey:kPAPUserDisplayNameKey] && [[self.user objectForKey:kPAPUserDisplayNameKey] length] > 0) {
        nameString = [self.user objectForKey:kPAPUserDisplayNameKey];
    }
    
    [self.nameButton setTitle:nameString forState:UIControlStateNormal];
    [self.nameButton setTitle:nameString forState:UIControlStateHighlighted];
    
    // If user is set after the contentText, we reset the content to include padding
    if (self.contentLabel.text) {
        [self setContentText:self.contentLabel.text];
    }
    
    if (self.user) {
        CGSize nameSize = [self.nameButton.titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:13.0f] forWidth:nameMaxWidth2 lineBreakMode:NSLineBreakByTruncatingTail];
        NSString *paddedString = [BaseTextCell2 padString:activityString withFont:[UIFont systemFontOfSize:13.0f] toWidth:nameSize.width];
        [self.contentLabel setText:paddedString];
    } else { // Otherwise we ignore the padding and we'll add it after we set the user
        [self.contentLabel setText:activityString];
    }
    
    [self.timeLabel setText:[timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:[activity createdAt]]];
    
    [self setNeedsDisplay];
}

- (void)setCellInsetWidth:(CGFloat)insetWidth {
    [super setCellInsetWidth:insetWidth];
    horizontalTextSpace = [ActivityCell horizontalTextSpaceForInsetWidth:insetWidth];
}

- (id<ActivityCellDelegate>)delegate {
    
    return (id<ActivityCellDelegate>)_delegate;
}

- (void)setDelegate:(id<ActivityCellDelegate>)delegate {
    
    if(_delegate != delegate) {
        _delegate = delegate;
    }
}

+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth {
   
    return ([UIScreen mainScreen].bounds.size.width - (insetWidth * 2.0f)) - 72.0f - 46.0f;
}

+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content {
   
    return [self heightForCellWithName:name contentString:content cellInsetWidth:0.0f];
}

+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellInsetWidth:(CGFloat)cellInset {
   
    CGSize nameSize = [name sizeWithFont:[UIFont boldSystemFontOfSize:13.0f] forWidth:200.0f lineBreakMode:NSLineBreakByTruncatingTail];
    NSString *paddedString = [BaseTextCell2 padString:content withFont:[UIFont systemFontOfSize:13.0f] toWidth:nameSize.width];
    CGFloat horizontalTextSpace = [ActivityCell horizontalTextSpaceForInsetWidth:cellInset];
    
    CGSize contentSize = [paddedString sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    CGFloat singleLineHeight = [@"Test" sizeWithFont:[UIFont systemFontOfSize:13.0f]].height;
    
    // Calculate the added height necessary for multiline text. Ensure value is not below 0.
    CGFloat multilineHeightAddition = contentSize.height - singleLineHeight;
    
    return 48.0f + fmax(0.0f, multilineHeightAddition);
}

- (void)setActivityImageFile:(PFFile *)imageFile {
    
    if (imageFile) {
        [self.activityImageView setFile:imageFile];
        [self setHasActivityImage:YES];
    } else {
        [self setHasActivityImage:NO];
    }
}

- (void)didTapActivityButton:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapActivityButton:)]) {
        [self.delegate cell:self didTapActivityButton:self.activity];
    }    
}

@end

