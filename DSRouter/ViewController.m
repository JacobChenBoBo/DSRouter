//
//  ViewController.m
//  DSRouter
//
//  Created by Jacob on 5/26/16.
//  Copyright © 2016 Jacob. All rights reserved.
//

#import "ViewController.h"
#import "DSRouter.h"

@interface DetailViewController : UIViewController

@end

@implementation DetailViewController

- (id)initWithRouterParams:(NSDictionary *)params {
    if (self = [super init]) {
        NSLog(@"params: %@", params);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Detail";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

@end

@interface ViewController ()

@property (nonatomic, strong) DSRouter *router;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"DSRouter";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.router = [DSRouter newRouter];
    [self.router setNavigationController:self.navigationController];
    
    [self.router map:@"detail/:id/:name" toController:[DetailViewController class] withOptions:[DSRouterOptions routerOptionsHidesBottomBarWhenPushed]];
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(50, 100, 100, 40)];
    [self.view addSubview:button1];
    [button1 setTitle:@"Router1" forState:UIControlStateNormal];
    button1.backgroundColor = [UIColor blueColor];
    [button1 addTarget:self action:@selector(onClickButton1) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(50, 200, 100, 40)];
    [self.view addSubview:button2];
    button2.backgroundColor = [UIColor blueColor];
    [button2 setTitle:@"Router2" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(onClickButton2) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onClickButton1 {
    [self.router open:@"detail/111111/jacob"];
}

- (void)onClickButton2 {
    [self.router open:@"detail?id=22222&name=jacob"];
}

@end


