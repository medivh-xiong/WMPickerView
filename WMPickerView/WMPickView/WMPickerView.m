
//  WMCityPickerView.m
//  CityPickViewDemo
//
//  Created by 熊欣 on 17/2/4.
//  Copyright © 2017年 Norchant. All rights reserved.
//

#import "WMPickerView.h"

static CGFloat const toolBarHeight   = 40;

static CGFloat const textLabelHeight = 30;

static CGFloat const btnWidth        = 80;

static CGFloat const borderWidth     = 0.5f;

static CGFloat const cityComponent   = 3;


@interface WMPickerView ()

/** 省份数组*/
@property (strong, nonatomic, readwrite) NSArray <NSDictionary *> *provinceArray;

/** 城市数组*/
@property (strong, nonatomic, readwrite) NSArray <NSDictionary *> *cityArray;

/** 区域数组*/
@property (strong, nonatomic, readwrite) NSArray <NSDictionary *> *areaArray;

/** 城市选择器*/
@property (strong, nonatomic, readwrite) UIPickerView *cityPickerView;

/** 上方工具栏*/
@property (strong, nonatomic, readwrite) UIView       *toolBarView;

/** 存储整个plist文件信息*/
@property (strong, nonatomic, readwrite) NSDictionary *infoDic;

@property (strong, nonatomic, readwrite) NSArray <NSDictionary *> *allProvinceArray;

@property (strong, nonatomic, readwrite) UIDatePicker *datePicker;

/** 省份字典*/
@property (strong, nonatomic, readwrite) NSDictionary * provinceDic;

/** 城市字典*/
@property (strong, nonatomic, readwrite) NSDictionary * cityDic;

/** 区域字典*/
@property (strong, nonatomic, readwrite) NSDictionary * areaDic;

@end


@implementation WMPickerView


#pragma mark - 懒加载
- (UIDatePicker *)datePicker
{
    if (!_datePicker) {
        
        _datePicker                 = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, toolBarHeight, self.frame.size.width, self.frame.size.height - toolBarHeight)];
        
        [_datePicker addTarget:self action:@selector(pickerValueChanged:) forControlEvents:UIControlEventValueChanged];

        _datePicker.datePickerMode  = UIDatePickerModeDate;
    }
    
    return _datePicker;
}


- (UIPickerView *)cityPickerView
{
    if (!_cityPickerView) {
        
        _cityPickerView                   = [[UIPickerView alloc] initWithFrame:CGRectMake(0, toolBarHeight, self.frame.size.width, self.frame.size.height - toolBarHeight)];
        
        _cityPickerView.delegate          = self;

        _cityPickerView.dataSource        = self;
    }
    
    return _cityPickerView;
}


- (UIView *)toolBarView
{
    if (!_toolBarView) {
        
        _toolBarView                   = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, toolBarHeight)];
        
        _toolBarView.layer.borderWidth = borderWidth;

        _toolBarView.layer.borderColor = [UIColor grayColor].CGColor;
        
        
        UIButton *doneBtn = ({
            
            UIButton *doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - btnWidth, 0, btnWidth, toolBarHeight)];
            
            [doneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            [doneBtn setTitle:@"确定" forState:UIControlStateNormal];
            
            [doneBtn addTarget:self action:@selector(doneSelect) forControlEvents:UIControlEventTouchUpInside];
            
            doneBtn;
            
        });
        
        [_toolBarView addSubview:doneBtn];
        
        
        UIButton *cancelBtn = ({
            
            UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, toolBarHeight)];
            
            [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
            
            [cancelBtn addTarget:self action:@selector(cancelSelect) forControlEvents:UIControlEventTouchUpInside];
            
            cancelBtn;
            
        });
        
        [_toolBarView addSubview:cancelBtn];
        
    }
    
    return _toolBarView;
}


- (NSArray *)provinceArray
{
    if (!_provinceArray) {
        _provinceArray = [NSArray array];
    }
    return _provinceArray;
}


#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    self            = [super initWithFrame:frame];

    self.pickerMode = WMPickerCityMode;
    
    return self;
}


#pragma mark - set方法
- (void)setPickerMode:(WMPickerMode)pickerMode
{
    _pickerMode = pickerMode;
    
    if (_pickerMode == WMPickerCityMode) {
       
        [self loadCityInfoData];
        
        [self addSubview:self.cityPickerView];
        
    }else if (_pickerMode == WMPickerDateMode) {
        
        if (_cityPickerView) {
            [_cityPickerView removeFromSuperview];
        }
        
        [self addSubview:self.datePicker];
    }
    
    [self addSubview:self.toolBarView];
    
}


- (void)setToolBarHide:(BOOL)toolBarHide
{
    _toolBarHide        = toolBarHide;

    _toolBarView.hidden = _toolBarHide;
    
    if (self.isToolBarHidden) {
        _cityPickerView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
}


- (NSDictionary *)setCityName:(NSDictionary *)dic
{
    NSDictionary *tempDic = @{
                              @"areaId": dic[@"areaId"],
                              @"areaName": dic[@"areaName"]
                   
                              };
    return tempDic;
}

- (void)setDefaultAddress:(NSString *)defaultAddress
{
    _defaultAddress = defaultAddress;
    
    NSArray *array = [_defaultAddress componentsSeparatedByString:@"-"];
    
    if (array.count != 3) return;
    
    
    //---- 查找省份
    NSInteger provinceIndex = [self seachIndexWithArray:_provinceArray name:array[0]];
    
    if (provinceIndex < 0) return;
    
    _provinceDic            = _provinceArray[provinceIndex];
    
    [_cityPickerView reloadComponent:0];
    
    [_cityPickerView selectRow:provinceIndex inComponent:0 animated:YES];
    
    
    //---- 根据省份获取城市数组
    _cityArray = [self getCityforProvince:provinceIndex];
    
    [_cityPickerView reloadComponent:1];
    
    //---- 查找城市
    NSInteger cityIndex = [self seachIndexWithArray:_cityArray name:array[1]];

    if (cityIndex < 0) cityIndex = 0;
    
    _cityDic            = _cityArray[cityIndex];
    
    [_cityPickerView selectRow:cityIndex inComponent:1 animated:YES];
    
    
    //---- 查找地区
    _areaArray                   = [_cityArray[cityIndex] objectForKey:@"counties"];

    NSInteger areaIndex          = [self seachIndexWithArray:_areaArray name:array[2]];

    if (areaIndex < 0) areaIndex = 0;
    
    _areaDic                     = _areaArray[areaIndex];

    [_cityPickerView reloadComponent:2];
   
    [_cityPickerView selectRow:areaIndex inComponent:2 animated:YES];
    
}


#pragma mark - pickerView数据源和代理
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return cityComponent;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return self.provinceArray.count;
    }else if (component == 1) {
        return self.cityArray.count;
    }else if (component == 2) {
        return self.areaArray.count;
    }
    
    return 0;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label                  = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/3.0, textLabelHeight)];

    label.adjustsFontSizeToFitWidth = YES;

    label.textAlignment             = NSTextAlignmentCenter;
    
    if (component == 0) {
        label.text = [_provinceArray[row] objectForKey:@"areaName"];
    }else if (component == 1){
        label.text = [_cityArray[row] objectForKey:@"areaName"];
    }else if (component == 2){
        label.text = [_areaArray[row] objectForKey:@"areaName"];
    }
    
    return label;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //---- 这里是选中了省-然后根据省获取城市--在根据城市
    if (component == 0 ) {
        
        _cityArray   = [self getCityforProvince:row];

        _areaArray   = [_cityArray[0] objectForKey:@"counties"];

        [_cityPickerView reloadComponent:1];

        [_cityPickerView selectRow:0 inComponent:1 animated:YES];

        [_cityPickerView reloadComponent:2];

        [_cityPickerView selectRow:0 inComponent:2 animated:YES];

        _provinceDic = [self setCityName:_provinceArray[row]];

        _cityDic     = [self setCityName:_cityArray[0]];

        _areaDic     = _areaArray[0];

    }else if (component == 1) {
        
        _areaArray = [self.allProvinceArray[row] objectForKey:@"counties"];

        [_cityPickerView reloadComponent:2];

        [_cityPickerView selectRow:0 inComponent:2 animated:YES];

        _cityDic   = [self setCityName:_cityArray[row]];

        _areaDic   = _areaArray[0];
        
    }else if (component == 2) {
        _areaDic = _areaArray[row];
    }
    
     if (self.scrollBlock) {
         self.scrollBlock(_provinceDic,_cityDic,_areaDic);
     }
    
}


#pragma mark - 点击事件
- (void)doneSelect
{
    if (_pickerMode == WMPickerCityMode) {
        
        if (self.doneBtnBlock) {
            self.doneBtnBlock(_provinceDic,_cityDic,_areaDic);
        }
        
    }else if (_pickerMode == WMPickerDateMode) {
        
        NSArray *strArray = [self getDateArray:_datePicker];
        
        if (self.dateDoneBtnBlock) {
            self.dateDoneBtnBlock(strArray[0], strArray[1], strArray[2]);
        }
    }
    
}


- (void)cancelSelect
{
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}


- (void)pickerValueChanged:(UIDatePicker *)datePicker
{
    NSArray *strArray = [self getDateArray:datePicker];
    
    if (self.dateScrollBlock) {
        self.dateScrollBlock(strArray[0], strArray[1], strArray[2]);
    }
    
}


#pragma mark - 获取城市信息方法
- (void)loadCityInfoData
{
    NSString *path       = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"plist"];
    
    self.infoDic         = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.infoDic.allKeys.count; i++) {
        
        NSDictionary *dic = [self.infoDic objectForKey:[@(i) stringValue]];
        
        [temp addObject:dic];
    }
    
    //---- 获取省份数组
    self.provinceArray = temp;
    
    //取第1个省字典
    _provinceDic       = [self setCityName:self.provinceArray[0]];
    
    /** 从省份信息中获取城市数字*/
    _cityArray         = [self getCityforProvince:0];
    
    _areaArray         = [_cityArray[0] objectForKey:@"counties"];
    
    _cityDic           = [self setCityName:self.cityArray[0]];
    
    _areaDic           = self.areaArray[0] ;

}


- (NSArray *)getCityforProvince:(NSInteger)row
{
    self.allProvinceArray = [[self.infoDic objectForKey:[@(row) stringValue]] objectForKey:@"cities"];
    
    NSMutableArray *tempMutArray = [NSMutableArray array];
    
    for (int i = 0; i < self.allProvinceArray.count; i++) {
        
        NSDictionary *dic = self.allProvinceArray[i];
        
        [tempMutArray addObject:dic];
    }
    
    return tempMutArray;
}


- (NSArray *)getDateArray:(UIDatePicker *)datePicker
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *dateStr = [formatter stringFromDate:datePicker.date];
    
    NSArray *strArray = [dateStr componentsSeparatedByString:@"-"];
    
    return strArray;
}


- (NSInteger)seachIndexWithArray:(NSArray *)arr name:(NSString *)name
{
    NSInteger index = -1;
    
    //---- 如果没有查找到就结束
    for (NSInteger i = 0; i < arr.count; i++) {
        
        NSDictionary *dic = arr[i];
        
        if ([dic[@"areaName"] isEqualToString:name]) {
            index = i;
        }
        
    }
    
    return index;
}


@end
