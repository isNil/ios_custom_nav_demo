//
//  ViewController.m
//  cus_nav_demo
//
//  Created by LiRui on 15/11/30.
//  Copyright © 2015年 Lirui. All rights reserved.
//

#import "ViewController.h"
#import "INavVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    [btn setBackgroundColor:[UIColor redColor]];
    [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    
    
    
    UIButton * rbtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 100, 100, 100)];
    [rbtn setBackgroundColor:[UIColor greenColor]];
    [rbtn addTarget:self action:@selector(rclick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rbtn];
    
}


- (void)click{
    
    [self.navVC pushVC:[[ViewController alloc]init]];

}

- (void)rclick{
    
    [self.navVC popVC];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
