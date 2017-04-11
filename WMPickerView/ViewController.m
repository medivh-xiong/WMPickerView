//
//  ViewController.m
//  WMPickerView
//
//  Created by 熊欣 on 11/04/2017.
//  Copyright © 2017 熊欣. All rights reserved.
//

#import "ViewController.h"
#import "WMPickerView.h"

#define WMSCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width

#define WMSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *cityTextField;

@property (weak, nonatomic) IBOutlet UITextField *dateTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //---- 城市选择器
    WMPickerView *pickerView     = [[WMPickerView alloc] initWithFrame:CGRectMake(0, WMSCREEN_HEIGHT - 256, WMSCREEN_WIDTH, 256)];

    pickerView.pickerMode        = WMPickerCityMode;

    
    /** 设置初始显示的省市
     1.标准是江苏省-南京市-玄武区，如果不是，则默认查找失败
     2.如果2级，默认显示2级的第一个
     */
    pickerView.defaultAddress    = @"江苏省-南京市-玄武区";

    pickerView.backgroundColor   = [UIColor whiteColor];
    
    //---- 点击确认后的回调按钮可以拿到3个字典，字典中根据areaName获得名字，areaId获得对应的ID
    __weak ViewController *weakSelf = self;
    
    pickerView.doneBtnBlock = ^(NSDictionary * _Nonnull province, NSDictionary * _Nonnull city, NSDictionary * _Nonnull area) {
       
        NSString *str = [NSString stringWithFormat:@"%@-%@, %@-%@, %@-%@", province[@"areaName"], province[@"areaId"], city[@"areaName"], city[@"areaId"], area[@"areaName"], area[@"areaId"]];
        
        weakSelf.cityTextField.text = str;
        
        [weakSelf.view endEditing:YES];
        
    };
    
    pickerView.scrollBlock       = ^(NSDictionary * _Nonnull province, NSDictionary * _Nonnull city, NSDictionary * _Nonnull area) {
        
        NSString *str = [NSString stringWithFormat:@"%@-%@, %@-%@, %@-%@", province[@"areaName"], province[@"areaId"], city[@"areaName"], city[@"areaId"], area[@"areaName"], area[@"areaId"]];
        
        weakSelf.cityTextField.text = str;
        
    };

    pickerView.cancelBlock       = ^{
        [weakSelf.view endEditing:YES];
    };

    self.cityTextField.inputView = pickerView;
    
    
    //---- 日期选择器
    WMPickerView *datePickerView    = [[WMPickerView alloc] initWithFrame:CGRectMake(0, WMSCREEN_HEIGHT - 256, WMSCREEN_WIDTH, 256)];

    datePickerView.pickerMode       = WMPickerDateMode;

    datePickerView.backgroundColor  = [UIColor whiteColor];

    datePickerView.dateScrollBlock  = ^(NSString * _Nonnull year, NSString * _Nonnull month, NSString * _Nonnull day) {
    weakSelf.dateTextField.text     = [NSString stringWithFormat:@"%@年-%@月-%@日", year, month, day];
    };

    datePickerView.dateDoneBtnBlock = ^(NSString * _Nonnull year, NSString * _Nonnull month, NSString * _Nonnull day) {

    weakSelf.dateTextField.text     = [NSString stringWithFormat:@"%@年-%@月-%@日", year, month, day];

        [weakSelf.view endEditing:YES];

    };


    datePickerView.cancelBlock      = ^{
        [weakSelf.view endEditing:YES];
    };

    self.dateTextField.inputView    = datePickerView;
    
}


@end
