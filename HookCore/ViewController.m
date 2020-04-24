//
//  ViewController.m
//  HookCore
//
//  Created by iwalben on 2020/4/24.
//  Copyright © 2020 WM. All rights reserved.
//

#import "ViewController.h"
#import "HViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)click:(id)sender {
    [self presentViewController:[HViewController new] animated:YES completion:nil];
}


@end
