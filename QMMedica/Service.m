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
    
    
    [Service insertArray:mainArray];
    
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
                                
                                
                                aModel.info = xmlString.length?xmlString:@"";
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    return aModel;
}

#pragma mark - 数据库
+ (NSString *)FMDBPath {
    
    NSString* docsdir = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Identifer = [infoDictionary objectForKey:@"CFBundleIdentifier"];
    
    NSLog(@"%@",docsdir);
    return [NSString stringWithFormat:@"%@/%@.db",docsdir,app_Identifer];
    
}
+ (FMDatabase *)db {
    FMDatabase *_db = [FMDatabase databaseWithPath:[Service FMDBPath]];
    if ([_db open]) {
        [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS medica (href TEXT PRIMARY KEY, title TEXT, info TEXT)"];
    }
    
    return _db;
}
+ (void)insertArray:(NSArray *)aArray {
    
    FMDatabase * db = [Service db];
    
    [db beginTransaction];
    
    for (Model * m in aArray) {
        
        [db executeUpdate:@"REPLACE INTO medica (href, title, info) VALUES (?,?,?)",m.href,m.title,m.info];
        
    }
    [db commit];
    [db close];
}

+ (NSArray *)readDB {
    
    NSMutableArray * array = [NSMutableArray array];
    
    FMDatabase * db = [Service db];
    
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM medica"];
    
    while ([rs next]) {
        
        [array addObject:[[Model alloc]initWithTitle:[rs stringForColumn:@"title"]
                                                href:[rs stringForColumn:@"href"]
                                                info:[rs stringForColumn:@"info"]]];
        
        
    }
    
    [db open];
//    [db beginTransaction];
    
    for (int i=0; i< array.count; i++) {
        
        Model * m = array[i];
        
        [Service info:m withBlock:^(Model * infoModel, NSError *error) {
           
            [db executeUpdate:@"REPLACE INTO medica (href, title, info) VALUES (?,?,?)",infoModel.href,infoModel.title,infoModel.info];
            
            [SVProgressHUD showProgress:i/(1.0 * array.count)];
            
        }];
        
    }
    
//    [db commit];
//    [db close];
    return array;
}



@end
