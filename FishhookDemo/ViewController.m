//
//  ViewController.m
//  FishhookDemo
//
//  Created by Dio Brand on 2023/2/6.
//

#import "ViewController.h"
#import "sys/utsname.h"
#include "fishhook.h"

@interface ViewController ()

@end

/**
 ​​fishhook​​ 是可以 ​​hook​​ 系统的函数 , 并非所有的 ​​C​​ 函数 , 也就是说 ​​fishhook​​ 也只能对带有符号表的系统函数进行重绑定 , 而对自己实现的 C 函数同样是没有办法的.
 */
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

// 定义一个函数指针用来接收并保存系统C函数的实现地址
static int(*oldPrintf)(const char *, ...);

// 定义我们自己的printf函数
int myPrintf(const char * message, ...) {
    char *firstName = "真棒\n";
    char *result = malloc(strlen(message) + strlen(firstName));
    strcpy(result, message);
    strcat(result, firstName);
    
    oldPrintf(result);
    return 1;
}

- (IBAction)hook_sys_func:(UIButton *)sender {
    // hook系统printf函数代码
    struct rebinding rebind;
    rebind.name = "printf";
    rebind.replacement = myPrintf; // 将自定义的函数赋值给replacement
    rebind.replaced = (void *)&oldPrintf; // 使用自定义的函数指针来接收printf函数原有的实现
    
    struct rebinding rebs[1] = {rebind};
    rebind_symbols(rebs, 1);
    
    printf("Dong be rich!\t");
}

// 打印设备内核信息
-(void)uname_printf {
    NSMutableString * info_str = [[NSMutableString alloc] init];
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *sysname = [NSString stringWithCString:systemInfo.sysname encoding:NSUTF8StringEncoding];
    [info_str appendString:[NSString stringWithFormat:@"sysname:%@\n", sysname]];
    NSString *nodename = [NSString stringWithCString:systemInfo. nodename encoding:NSUTF8StringEncoding];
    [info_str appendString:[NSString stringWithFormat:@"nodename:%@\n", nodename]];
    NSString *release = [NSString stringWithCString:systemInfo.release encoding:NSUTF8StringEncoding];
    [info_str appendString:[NSString stringWithFormat:@"release:%@\n", release]];
    NSString *version = [NSString stringWithCString:systemInfo.version encoding:NSUTF8StringEncoding];
    [info_str appendString:[NSString stringWithFormat:@"version:%@\n", version]];
    NSString *machine = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    [info_str appendString:[NSString stringWithFormat:@"machine:%@\n", machine]];
    NSLog(@"darwin:\n%@", info_str);
}

// 保存原来的 uname 函数
static int(*old_uname)(struct utsname *,...);

// 实际替换后执行的 uname 函数
int my_uname(struct utsname * systemInfo) {
    char *sysname = "Darwin_hook";
    strcpy(systemInfo->sysname, sysname);
    char *nodename = "dong_hook";
    strcpy(systemInfo->nodename, nodename);
    char *release = "22.6.0_hook";
    strcpy(systemInfo->release, release);
    char *version = "Darwin Kernel Version 21.6.0: Sun Nov  6 23:04:39 PST 2022; root:xnu-8020.241.14~1/RELEASE_ARM64_T8010 hook";
    strcpy(systemInfo->version, version);
    char *machine = "iPhone9,3 hook";
    strcpy(systemInfo->machine, machine);
    return 0;
}

- (IBAction)hook_uname_func:(UIButton *)sender {
    [self uname_printf];
    struct rebinding darwin;
    darwin.name = "uname";
    darwin.replacement = my_uname;
    darwin.replaced = (void *)&old_uname;
    
    struct rebinding rebs[1] = {darwin};
    
    rebind_symbols(rebs, 1);
    
    [self uname_printf];
}

@end
