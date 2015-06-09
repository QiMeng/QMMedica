//
//  Model.h
//  QMMedica
//
//  Created by Lin on 15/6/8.
//  Copyright (c) 2015年 QiMENG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * href;

@property (nonatomic, copy) NSString * info;

- (instancetype)initWithTitle:(NSString *)aTitle href:(NSString *)aHref info:(NSString *)aInfo;

@end
