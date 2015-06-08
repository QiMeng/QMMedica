//
//  Service.m
//  QMMedica
//
//  Created by Lin on 15/6/8.
//  Copyright (c) 2015年 QiMENG. All rights reserved.
//

#import "Service.h"

@implementation Service
+ (instancetype)sharedClient {
    static Service *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[Service alloc] initWithBaseURL:[NSURL URLWithString:kBaseURLString]];
        
        _sharedClient.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [_sharedClient.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    
                    break;
                    
                case AFNetworkReachabilityStatusReachableViaWiFi:
                {
                    [SVProgressHUD showErrorWithStatus:@"已链接wifi"];
                    
                    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"已链接wifi" message:nil delegate:nil
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                }
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                {
                    [SVProgressHUD showErrorWithStatus:@"网络中断.请检查网络设置."];
                }
                    break;
                default:
                    break;
            }
        }];
        
    });
    
    return _sharedClient;
}

+ (id)medicaPage:(int)aPage
       withBlock:(void (^)(NSArray *array, NSError *error))block{
    
    return [[Service sharedClient] GET:[NSString stringWithFormat:@"china.asp?id=1&page=%d",aPage]
                            parameters:nil
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   
                                   block([self parseMedicaList:responseObject],nil);
                                   
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   
                                   [SVProgressHUD showErrorWithStatus:@"数据错误,请稍后再试"];
                                   
                               }];
    
}

+ (NSArray *)parseMedicaList:(id)response {
    
    NSMutableArray * mainArray = [NSMutableArray array];
    
    @autoreleasepool {
        GDataXMLDocument * doc = [[GDataXMLDocument alloc]initWithHTMLData:response
                                                                  encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)
                                                                     error:NULL];
        if (doc) {
            
            NSArray * trArray = [doc nodesForXPath:@"//table" error:NULL];
            
            for (GDataXMLElement * item0 in trArray) {
                
                NSArray * tr = [item0 elementsForName:@"tr"];
                
                for (GDataXMLElement * item1 in tr) {
                    
                    NSArray * td = [item1 elementsForName:@"td"];
                    
                    for (GDataXMLElement * item2 in td) {
                        
                        NSArray * a = [item2  elementsForName:@"a"];
                        
                        for (GDataXMLElement * element in a) {

                            if ([element attributeForName:@"target"]) {
                                
                                Model * m = [Model new];
                                
                                m.title = element.stringValue;
                                m.href = [[element attributeForName:@"href"] stringValue];
                                
                                [mainArray addObject:m];
                            }
                        }
                    }
                }
            }
        }
    }
    
    return mainArray;
    
}



#pragma mark - 信息详情
+ (id)info:(Model *)aModel withBlock:(void (^)(id infoModel, NSError *error))block {
    
    return [[Service sharedClient] GET:aModel.href
                            parameters:nil
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   
                                   block([self parseInfoModel:aModel withData:responseObject],nil);
                                   
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   [SVProgressHUD showErrorWithStatus:@"数据错误,请稍后再试"];
                               }];
    
}

+ (Model *)parseInfoModel:(Model *)aModel withData:(id)response {
    
    aModel.info = @"";
    
    @autoreleasepool {
        GDataXMLDocument * doc = [[GDataXMLDocument alloc]initWithHTMLData:response
                                                                  encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)
                                                                     error:NULL];
        if (doc) {
            
            NSArray * trArray = [doc nodesForXPath:@"//table" error:NULL];
            
            for (GDataXMLElement * item0 in trArray) {
                
                NSArray * tr = [item0 elementsForName:@"tr"];
                
                for (GDataXMLElement * item1 in tr) {
                    
                    NSArray * td = [item1 elementsForName:@"td"];

                    if (td) {
                        
                        for (GDataXMLElement * item2 in td) {
                            
                            NSArray * dr = [item2 elementsForName:@"br"];
                            
                            if (dr) {

                                NSString * xmlString = [item2.XMLString stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
                                xmlString = [xmlString stringByReplacingOccurrencesOfString:@"<td>" withString:@""];
                                xmlString = [xmlString stringByReplacingOccurrencesOfString:@"</td>" withString:@""];
                                
                                
                                aModel.info = xmlString;
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    return aModel;
}





@end
