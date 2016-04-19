//
//  RBDeviceSandboxViewController.m
//  FileDownloadD
//
//  Created by Ran on 16/4/7.
//  Copyright © 2016年 Justice. All rights reserved.
//

#import "RBDeviceSandboxViewController.h"

static NSString *const CELL_REUSE_IDENTIFIER = @"cell";

#pragma mark - ------Model-----

@interface RBDeviceSandboxItemModel : NSObject

@property(nonatomic, copy)NSString *name;
@property(nonatomic, copy)NSString *fullPath;
@property(nonatomic, assign)BOOL isDirectory;
@property(nonatomic, copy)NSString *size;
+ (instancetype)modelWithName: (NSString *)name fullPath: (NSString *)fullPath isDirectory: (BOOL)isDirectory size: (NSString *)size;

@end

@implementation RBDeviceSandboxItemModel

+ (instancetype)modelWithName: (NSString *)name fullPath: (NSString *)fullPath isDirectory: (BOOL)isDirectory size: (NSString *)size
{
    RBDeviceSandboxItemModel *model = [RBDeviceSandboxItemModel new];
    model.name = name;
    model.fullPath = fullPath;
    model.isDirectory = isDirectory;
    model.size = size;
    return model;
}

@end

#pragma mark - ------ViewController-----

@interface RBDeviceSandboxViewController ()<UIDocumentInteractionControllerDelegate>

@property(nonatomic, copy)NSString *path;
@property(nonatomic, strong)NSMutableArray *dataSource;

@end

@implementation RBDeviceSandboxViewController

#pragma mark - lifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = [NSMutableArray array];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:NULL];
    BOOL isDirectory;
    NSString *fullPath;
    NSDictionary *attributesDictionary;
    for (NSString *content in contents)
    {
        isDirectory = YES;
        fullPath = [self.path stringByAppendingPathComponent:content];
        if ([[NSFileManager defaultManager] fileExistsAtPath: fullPath isDirectory:&isDirectory])
        {
            if (!isDirectory)
            {
                attributesDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:NULL];
            }
            [self.dataSource addObject:[RBDeviceSandboxItemModel modelWithName:content fullPath:fullPath isDirectory:isDirectory size:[self stringFromSize:[attributesDictionary fileSize]]]];
        }
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_REUSE_IDENTIFIER];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"ROOT" style:UIBarButtonItemStylePlain target:self action:@selector(popToRoot)];
}

#pragma mark - Private

- (NSString *)stringFromSize: (unsigned long long)size
{
    NSString *string;
    CGFloat value;
    int divisor = 1000;
    if(size < divisor * divisor)
    {// x < 1M
        value = 1.0 * size / divisor;
        string = [NSString stringWithFormat:@"%.1fK", value];
    }
    else if(size >= divisor * divisor && size < divisor * divisor * divisor)
    {// 1M =< x < 1G
        value = 1.0 * size / (divisor * divisor);
        string = [NSString stringWithFormat:@"%.1fM", value];
    }
    else
    {// 1G < x
        value = 1.0 * size / (divisor * divisor * divisor);
        string = [NSString stringWithFormat:@"%.1fG", value];
    }
    return string;
}

#pragma mark - Public

+ (instancetype)controllerWithPath:(NSString *)path
{
    RBDeviceSandboxViewController *controller = [RBDeviceSandboxViewController new];
    controller.path = path? : NSHomeDirectory();
    return controller;
}

#pragma mark - Event

- (void)popToRoot
{
    NSMutableArray *controllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    UIViewController *rootController;
    UIViewController *subController;
    for (NSInteger i = controllers.count - 1; i >= 0; i--)
    {
        subController = controllers[i];
        if (![subController isKindOfClass:[self class]])
        {
            break;
        }
        rootController = subController;
    }
    [self.navigationController popToViewController:rootController animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_REUSE_IDENTIFIER];
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.textLabel.numberOfLines = 0;
    RBDeviceSandboxItemModel *model = indexPath.row < self.dataSource.count? self.dataSource[indexPath.row]: nil;
    cell.textLabel.text = model.name;
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    cell.accessoryView = model.isDirectory? nil: ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 45, 30)];
        label.text = model.size;
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor lightGrayColor];
        label;
    });
    cell.accessoryType = model.isDirectory? UITableViewCellAccessoryDisclosureIndicator: UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark UITabelViewDelegagte

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row >= self.dataSource.count) return;
    RBDeviceSandboxItemModel *model = self.dataSource[indexPath.row];
    if (model.isDirectory)
    {
        RBDeviceSandboxViewController *controller = [RBDeviceSandboxViewController controllerWithPath:model.fullPath];
        controller.title = model.name;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else
    {
        UIDocumentInteractionController *controller = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:model.fullPath]];
        controller.delegate = self;
        [controller presentPreviewAnimated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (indexPath.row >= self.dataSource.count) return;
        RBDeviceSandboxItemModel *model = self.dataSource[indexPath.row];
        NSError *error;
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:model.fullPath error:&error];
        if (success)
        {
            [self.dataSource removeObject:model];
            [self.tableView reloadData];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Fail" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
    }
}

#pragma mark  - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}

@end
