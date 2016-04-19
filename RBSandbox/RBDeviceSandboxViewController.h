//
//  RBDeviceSandboxViewController.h
//  FileDownloadD
//
//  Created by Ran on 16/4/7.
//  Copyright © 2016年 gintong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBDeviceSandboxViewController : UITableViewController

//path缺省值NSHomeDirectory()
+ (instancetype)controllerWithPath: (NSString *)path;

@end
