//
//  ViewController.m
//  HealthProject
//
//  Created by Shiv Sakhuja on 4/1/15.
//  Copyright (c) 2015 Shiv Sakhuja. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize agePickerArray, heightPickerArray, weightPickerArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.agePickerArray = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10"];
    //    for (int i=13; i<=135; i++) {
    //        [self.agePickerArray addObject:[NSString stringWithFormat:@"%i", i]];
    //    }
    for (int i=12; i<=108; i++) {
        [heightPickerArray addObject:[NSString stringWithFormat:@"%i", i]];
    }
    for (int i=40; i<=500; i+=5) {
        [weightPickerArray addObject:[NSString stringWithFormat:@"%i", i]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return agePickerArray.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //Age Picker
    if (pickerView.tag == 1) {
        return self.agePickerArray[row];
    }
    
    //Height Picker
    if (pickerView.tag == 2) {
        return heightPickerArray[row];
    }
    
    //Weight Picker
    if (pickerView.tag == 3) {
        return weightPickerArray[row];
    }
    
    return NULL;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = agePickerArray[row];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    return attString;
    
}


@end
