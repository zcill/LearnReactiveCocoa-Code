//
//  ViewController.m
//  LearnReactiveCocoa-Day1
//
//  Created by 朱立焜 on 16/1/26.
//  Copyright © 2016年 朱立焜. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if 0
    NSArray *array = @[@1, @2, @3];
    
    // 把数组化成一个流stream，注意流不能包含nil
    RACSequence *stream = [array rac_sequence];
    // 打印数组
    NSLog(@"sequence ---> %@", [stream array]);
    
    // 合并上面两个方法，先把array转化成流，再把流中每个元素的平方转化成数组打印出来
    NSLog(@"sequence ---> %@", [[[array rac_sequence] map:^id(id value) {
        return @(pow([value integerValue], 2));
    }] array]);
    
    // 过滤数组，判断每个元素与2求余是否为0
    NSLog(@"filter ---> %@", [[[array rac_sequence] filter:^BOOL(id value) {
        return [value integerValue] % 2 == 0;
    }] array]);
    
    // 把一个序列流合并为单个值 folding
    NSLog(@"folding ---> %@", [[[array rac_sequence] map:^id(id value) {
        return [value stringValue];
        
        // 这里foldLeft是左折叠，表示从头到尾遍历数组，反之则是右折叠
    }] foldLeftWithStart:@"" reduce:^id(id accumulator, id value) {
        return [accumulator stringByAppendingString:value];
    }]);
#endif
    
    
    // 监听textField
    [self.textField.rac_textSignal subscribeNext:^(id x) {
        NSLog(@"New Value: %@", x);
    }];
    
    // 绑定信号，只允许textField中输入的内容包含@才可以enable这个button
    //    RAC(self.button, enabled) = [self.textField.rac_textSignal map:^id(id value) {
    //        return @([value rangeOfString:@"@"].location != NSNotFound);
    //    }];
    
    // RAC()这个宏，需要两个参数：'对象'以及这个对象的某个属性KeyPath。然后将表达式右边的值和'keyPath'做一个单向的绑定，这个值必须是NSObject类型，所以我们会把boolean量封装成NSNumber。
    
    // 重构代码
    // 绑定信号
    RACSignal *validEmailSignal = [self.textField.rac_textSignal map:^id(id value) {
        return @([value rangeOfString:@"@"].location != NSNotFound);
    }];
    
    // 设置button的enabled属性与validEmailSignal信号变化
    RAC(self.button, enabled) = validEmailSignal;
    
    // 设置textField的textColor根据validEmailSignal信号变化
    RAC(self.textField, textColor) = [validEmailSignal map:^id(id value) {
        if ([value boolValue]) {
            return [UIColor greenColor];
        } else {
            return [UIColor redColor];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
