//
//  DataController.h
//  QunarClient
//
//  Created by huangqing on 9/29/10.
//  Copyright 2010 nanjing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	"CacheData.h"

// ===================================================================
// 数据存储共享和中转中心
// 这部分应该只存储程序共享的数据状态,采用共享的方式,这样就不需要在不同的模块之间进行数据的传递
// 尽量不要在里面存储一些私有的非共享的数据,够则会导致该对象的功能过分庞大
// 由于后期新增了程序状态备份功能，则在程序状态恢复的时候，DataController中
// 的数据也必须全部保存。否则，可能出现V和C数据不一致的情况。另外，这也表示
// 以后在DataController中增加新的数据结构的时候，必须考虑到保存程序状态的时候
// 如何保存该数据状态
// ===================================================================
@interface DataController : NSObject
{
	CacheData *cacheData;			// 城市数据
}

// 获取数据管理的控制器(单例，防止全局变量的使用)
+ (DataController *)getInstance;

// 保存
- (void)save;

// 销毁
- (void)destroy;

@end
