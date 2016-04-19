//
//  ViewController.m
//  RBSandboxDemo
//
//  Created by XL on 16/4/19.
//  Copyright © 2016年 Ran. All rights reserved.
//

#import "ViewController.h"
#import "RBDeviceSandboxViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"sandbox" style:UIBarButtonItemStylePlain target:self action:@selector(gotoSandbox)];
}

- (void)gotoSandbox
{
    [self.navigationController pushViewController:[RBDeviceSandboxViewController controllerWithPath:nil] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
