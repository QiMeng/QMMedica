//
//  Model.m
//  QMMedica
//
//  Created by Lin on 15/6/8.
//  Copyright (c) 2015年 QiMENG. All rights reserved.
//

#import "Model.h"

@implementation Model

- (instancetype)initWithTitle:(NSString *)aTitle href:(NSString *)aHref info:(NSString *)aInfo
{
    self = [super init];
    if (self) {
        _title = aTitle;
        _href = aHref;
        _info = aInfo;
    }
    return self;
}

@end
