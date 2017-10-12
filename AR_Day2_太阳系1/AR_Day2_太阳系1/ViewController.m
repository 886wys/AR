//
//  ViewController.m
//  AR_Day2_太阳系1
//
//  Created by 王永顺 on 2017/9/13.
//  Copyright © 2017年 EasonWang. All rights reserved.
//

#import "ViewController.h"
#import "SceneViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)clickBbtn:(id)sender {
    
    SceneViewController *vc = [SceneViewController new];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
