//
//  Service.h
//  QMMedica
//
//  Created by Lin on 15/6/8.
//  Copyright (c) 2015年 QiMENG. All rights reserved.
//

#import "QMMedica-Bridging-Header.h"
#import "Model.h"

@interface Service : AFHTTPSessionManager

+ (instancetype)sharedClient;

/**
 *  获取纲目列表
 */
+ (id)medicaPage:(int)aPage
   withBlock:(void (^)(NSArray *array, NSError *error))block;

/**
 *  获取本草详细信息
 */
+ (id)info:(Model *)aModel withBlock:(void (^)(id infoModel, NSError *error))block;

@end
