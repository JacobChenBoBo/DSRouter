//
//  DSRouterTests.m
//  DSRouterTests
//
//  Created by Jacob on 5/26/16.
//  Copyright © 2016 Jacob. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DSRouter.h"

@interface ExtraParamObject : NSObject

@property NSInteger number;
@property NSString *string;

- (id)initWithNumber:(NSInteger)number andString:(NSString *)string;

@end

@implementation ExtraParamObject

- (id)initWithNumber:(NSInteger)number andString:(NSString *)string {
    self = [super init];
    self.number = number;
    self.string = string;
    
    return self;
}

@end

@interface UserController : UIViewController

@property (readwrite, nonatomic, copy) NSString *userId;
@property (readwrite, nonatomic, copy) NSString *userName;
@property (readwrite, nonatomic, copy) NSString *extraParam;
@property (readwrite, nonatomic) ExtraParamObject *epObject;

- (id)initWithRouterParams:(NSDictionary *)params;
@end

@implementation UserController

- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        self.userId = [params objectForKey:@"user_id"];
        self.userName = [params objectForKey:@"user_name"];
        self.extraParam = [params objectForKey:@"keyOne"];
        self.epObject = [params objectForKey:@"epObject"];
    }
    return self;
}

@end

@interface StaticController : UIViewController

@property (readwrite, nonatomic, copy) NSString *userId;

+ (id)allocWithRouterParams:(NSDictionary *)params;
@end

@implementation StaticController

+ (id)allocWithRouterParams:(NSDictionary *)params {
    StaticController *instance = [[StaticController alloc] initWithNibName:nil bundle:nil];
    instance.userId = [params objectForKey:@"user_id"];
    
    return instance;
}

@end

@interface DSRouterTests : XCTestCase

@property (readwrite, nonatomic, strong) DSRouter *router;

@end

#define USER_ID [(UserController *)self.router.navigationController.topViewController userId]
#define USER_NAME [(UserController *)self.router.navigationController.topViewController userName]
#define STATIC_USER_ID [(StaticController *)self.router.navigationController.topViewController userId]
#define USER_EXTRA_PARAM [(UserController *)self.router.navigationController.topViewController extraParam]
#define USER_EPOBJECT [(UserController *)self.router.navigationController.topViewController epObject]

@implementation DSRouterTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.router = [DSRouter newRouter];
    self.router.navigationController = [[UINavigationController alloc] initWithNibName:nil bundle:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self.router.navigationController setViewControllers:[NSArray array]];
    self.router = nil;
    
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
}

- (void)test_basicRoute {
    [self.router map:@"users/:user_id" toController:[UserController class]];
    
    [self.router open:@"users/4"];
    
    XCTAssertTrue([USER_ID isEqualToString:@"4"], @"Should have an ID of 4");
}

- (void)test_basicRouteWithMultipleComponents {
    [self.router map:@"users/:user_id/:user_name" toController:[UserController class]];
    
    [self.router open:@"users/4/clay"];
    
    XCTAssertTrue([USER_ID isEqualToString:@"4"], @"Should have an ID of 4");
    XCTAssertTrue([USER_NAME isEqualToString:@"clay"], @"Name should be Clay");
}

- (void)test_basicRouteWithEmptyComponents {
    [self.router map:@"users/:user_id/:user_name" toController:[UserController class]];
    
    [self.router open:@"users//clay"];
    
    XCTAssertTrue([USER_ID isEqualToString:@""], @"Should have an empty ID");
    XCTAssertTrue([USER_NAME isEqualToString:@"clay"], @"Name should be Clay");
}


- (void)test_basicRouteWithWhitespaceCompnents {
    [self.router map:@"users/:user_id/:user_name" toController:[UserController class]];
    
    [self.router open:@"users/ /clay"];
    XCTAssertTrue([USER_ID isEqualToString:@" "], @"Should have an empty ID");
    XCTAssertTrue([USER_NAME isEqualToString:@"clay"], @"Name should be Clay");
}

- (void)test_emptyRoute {
    [self.router map:@"users" toController:[UserController class]];
    
    [self.router open:@"users"];
    
    XCTAssertNil(USER_ID, @"The user id should be nil, not %@", USER_ID);
}

- (void)test_invalidRoute {
    XCTAssertThrows([self.router open:@"users"], @"Should throw an exception when route not mapped");
}

- (void)test_noNavigationController {
    [self.router map:@"users" toController:[UserController class]];
    
    self.router.navigationController = nil;
    XCTAssertThrows([self.router open:@"users"], @"Should throw an exception when there is no navigation controller");
}

- (void)test_callbacks {
    __block BOOL called = false;
    [self.router map:@"users" toCallback:^(NSDictionary *params) {
        called = true;
    }];
    
    [self.router open:@"users"];
    
    XCTAssertTrue(called, @"Callback block should have been called");
}

- (void)test_callbacksWithParams {
    __block NSString *userId = nil;
    __block BOOL called = false;
    [self.router map:@"users/:id" toCallback:^(NSDictionary *params) {
        called = true;
        userId = [params objectForKey:@"id"];
    }];
    
    [self.router open:@"users/4"];
    
    XCTAssertTrue(called, @"Callback block should have been called");
    XCTAssertTrue([userId isEqualToString:@"4"], @"Callback should have correct id param; was %@", userId);
}

- (void)test_defaultParamsWithCallback {
    __block NSString *userId = nil;
    
    [self.router map:@"users" toCallback:^(NSDictionary *params) {
        userId = [params objectForKey:@"id"];
    } withOptions: [DSRouterOptions forDefaultParams:@{@"id": @"4"}]];
    
    [self.router open:@"users"];
    
    XCTAssertTrue([userId isEqualToString:@"4"], @"Callback should have correct id param; was %@", userId);
}

- (void)test_staticRoute {
    [self.router map:@"users/:user_id" toController:[StaticController class]];
    
    [self.router open:@"users/4"];
    
    XCTAssertTrue([self.router.navigationController.topViewController isKindOfClass:[StaticController class]], @"Should be an instance of StaticController");
    XCTAssertTrue([STATIC_USER_ID isEqualToString:@"4"], @"Should have an ID of 4");
}

- (void)test_noInitializers {
    [self.router map:@"routable" toController:[UIViewController class]];
    
    XCTAssertThrows([self.router open:@"routable"], @"Should throw an exception when no initializer found");
}

- (void)test_openAsRoot {
    [self.router map:@"users/:user_id" toController:[UserController class] withOptions:[DSRouterOptions root]];
    
    [self.router open:@"users/4"];
    
    XCTAssertTrue([self.router.navigationController.viewControllers[0] isKindOfClass:[UserController class]], @"Should be an instance of UserController");
    XCTAssertTrue(self.router.navigationController.viewControllers.count == 1, @"Navigation controller should only have 1 view controller in its stack");
}

- (void)test_openWithExtraStringParam {
    [self.router map:@"users" toController:[UserController class]];
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjects:@[@"objOne"] forKeys:@[@"keyOne"]];
    
    [self.router open:@"users" animated:NO extraParams:params];
    
    XCTAssertEqual(USER_EXTRA_PARAM, @"objOne", @"Should be able to get extra string param in view controller");
}

- (void)test_openWithExtraObjectParam {
    [self.router map:@"users" toController:[UserController class]];
    
    ExtraParamObject *epObject = [[ExtraParamObject alloc] initWithNumber:99 andString:@"secretString"];
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[epObject] forKeys:@[@"epObject"]];
    
    [self.router open:@"users" animated:NO extraParams:params];
    
    XCTAssertEqual((ExtraParamObject *)USER_EPOBJECT, epObject, @"Should be able to get extra param object in view controller");
    
}

- (void)test_openWithURLParamsAndExtraParams {
    [self.router map:@"users/:user_id" toController:[UserController class]];
    
    ExtraParamObject *epObject = [[ExtraParamObject alloc] initWithNumber:99 andString:@"secretString"];
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[epObject] forKeys:@[@"epObject"]];
    
    [self.router open:@"users/4" animated:NO extraParams:params];
    
    XCTAssertTrue([USER_ID isEqualToString:@"4"], @"Should have ID of 4");
    XCTAssertEqual((ExtraParamObject *)USER_EPOBJECT, epObject, @"Should be able to get extra param object in view controller");
}

- (void)test_openWithNilExtraParams {
    [self.router map:@"users" toController:[UserController class]];
    
    [self.router open:@"users" animated:NO extraParams:nil];
    
    XCTAssertNil(USER_EXTRA_PARAM, @"No extra params should be passed if none are specified");
}

// 新增单元测试
- (void)test_openWithQuestionMarkUrl1 {
    [self.router map:@"users/:user_id" toController:[UserController class]];
    
    [self.router open:@"users?user_id=66"];
    
    XCTAssertTrue([USER_ID isEqualToString:@"66"], @"Should have ID of 66");
}

- (void)test_openWithQuestionMarkUrl2 {
    [self.router map:@"dsRouter/users/:user_id/:user_name" toController:[UserController class]];
    
    [self.router open:@"dsRouter/users?user_id=22&user_name=chenbo" animated:YES extraParams:nil];
    
    XCTAssertTrue([USER_ID isEqualToString:@"22"], @"Should have an ID 22");
    XCTAssertTrue([USER_NAME isEqualToString:@"chenbo"], @"Name should be chenbo");
}

@end
