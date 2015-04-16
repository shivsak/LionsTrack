//
//  ViewController.h
//  HealthProject
//
//  Created by Shiv Sakhuja on 4/1/15.
//  Copyright (c) 2015 Shiv Sakhuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
    IBOutlet UIPickerView *agePickerView;
    IBOutlet UIPickerView *heightPickerView;
    IBOutlet UIPickerView *weightPickerView;
}

@property (strong, nonatomic) NSMutableArray *agePickerArray;
@property (strong, nonatomic) NSMutableArray *heightPickerArray;
@property (strong, nonatomic) NSMutableArray *weightPickerArray;

@end

