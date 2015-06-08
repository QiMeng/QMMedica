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
 *  @param aPage   搜索页码
 */
+ (id)medicaPage:(int)aPage
   withBlock:(void (^)(NSArray *array, NSError *error))block;

@end
