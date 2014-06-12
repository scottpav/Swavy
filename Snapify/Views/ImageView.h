//
//  ImageView.h
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

@interface ImageView : UIImageView

@property (nonatomic, strong) UIImage *placeholderImage;

- (void) setFile:(PFFile *)file;

@end
