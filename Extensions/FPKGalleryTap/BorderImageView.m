//
//  BorderImageView.m
//  Overlay
//
//  Created by Matteo Gavagnin on 10/21/11.
//  Copyright (c) 2011 MobFarm S.r.l. All rights reserved.
//

#import "BorderImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation BorderImageView

-(void)setSelected:(BOOL)selected withColor:(UIColor *)color{
    if (selected) {
        [self.layer setBorderColor:[color CGColor]];
        [self.layer setBorderWidth:2.0];
    } else {
        // [self.layer setBorderWidth:0.0];
        [self.layer setBorderColor:[color CGColor]];
        [self.layer setBorderWidth:1.0];
    }
}

@end
