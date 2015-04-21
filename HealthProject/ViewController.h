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
    
    IBOutlet UIView *basicInfoView;
    IBOutlet UIView *additionalInfoView;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *activityLevelSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sleepSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *healthSegmentedControl;

-(IBAction)genderValueChanged:(id)sender;
-(IBAction)activityLevelValueChanged:(id)sender;
-(IBAction)sleepValueChanged:(id)sender;
-(IBAction)healthValueChanged:(id)sender;

@end

