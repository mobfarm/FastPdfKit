//
//  DDSocialDialog.h
//
//  Created by digdog on 6/6/10.
//  Copyright 2010 Ching-Lan 'digdog' HUANG and digdog software. All rights reserved.
//  http://digdog.tumblr.com
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//   
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//   
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

/*
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <UIKit/UIKit.h>

typedef enum{
	DDSocialDialogThemeTwitter = 0,
	DDSocialDialogThemePlurk
} DDSocialDialogTheme;

@protocol DDSocialDialogDelegate;

@interface DDSocialDialog : UIView {
@private	
	DDSocialDialogTheme theme_;

	UIButton *closeButton_;
	UILabel *titleLabel_;
	UIView *contentView_;
	UIControl *touchInterceptingControl_;

	CGSize defaultFrameSize_;
    CGRect originalFrame_;
	UIDeviceOrientation orientation_;
	BOOL showingKeyboard_;
	
	id <DDSocialDialogDelegate> dialogDelegate_;
}

@property (nonatomic, readonly) DDSocialDialogTheme theme;
@property (nonatomic, readonly, retain) UILabel *titleLabel;
@property (nonatomic, readonly, retain) UIView *contentView;
@property (nonatomic, assign) id <DDSocialDialogDelegate> dialogDelegate;

- (id)initWithFrame:(CGRect)frame andOriginalFrame:(CGRect)original theme:(DDSocialDialogTheme)theme;
- (void)dismiss:(BOOL)animated;
- (void)show;
- (void)cancel;
@end


@protocol DDSocialDialogDelegate <NSObject>
@optional
- (void)socialDialogDidCancel:(DDSocialDialog *)socialDialog;
@end