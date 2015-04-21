//
//  ViewController.m
//  HealthProject
//
//  Created by Shiv Sakhuja on 4/1/15.
//  Copyright (c) 2015 Shiv Sakhuja. All rights reserved.
//

#import "ViewController.h"
#import <POP/POP.h>

@interface ViewController ()

@property (nonatomic, retain) NSString *gender;
@property (nonatomic, retain) NSString *activity;
@property (nonatomic, retain) NSString *sleep;
@property (nonatomic, retain) NSString *health;

@end

NSString *ROOT_ADDRESS = @"";    //Database Root Address

@implementation ViewController

@synthesize genderSegmentedControl, healthSegmentedControl, activityLevelSegmentedControl, sleepSegmentedControl;

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setDefaults];
    [self showBasicInfo:self];
}

-(void)setDefaults {
    [agePickerView selectRow:7 inComponent:0 animated:YES];
    [heightPickerView selectRow:55 inComponent:0 animated:YES];
    [weightPickerView selectRow:85 inComponent:0 animated:YES];
    
    [genderSegmentedControl setSelectedSegmentIndex:0];
    [activityLevelSegmentedControl setSelectedSegmentIndex:2];
    [sleepSegmentedControl setSelectedSegmentIndex:2];
    [healthSegmentedControl setSelectedSegmentIndex:2];
    
    [self genderValueChanged:self];
    [self activityLevelValueChanged:self];
    [self sleepValueChanged:self];
    [self healthValueChanged:self];
    
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
    //Age Picker
    if (pickerView.tag == 1) {
        return 122;
    }
    
    //Height Picker
    if (pickerView.tag == 2) {
        return 96;
    }
    
    //Weight Picker
    if (pickerView.tag == 3) {
        return 460;
    }
    
    return 100;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //Age Picker
    if (pickerView.tag == 1) {
        return [NSString stringWithFormat:@"%ld",(row+13)];
    }
    
    //Height Picker
    if (pickerView.tag == 2) {
        return [NSString stringWithFormat:@"%ld",(row+12)];
    }
    
    //Weight Picker
    if (pickerView.tag == 3) {
        return [NSString stringWithFormat:@"%ld",(row+40)];
    }
    
    return NULL;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    NSString *title = @"default";
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    //Age Picker
    if (pickerView.tag == 1) {
        title = [self pickerView:agePickerView titleForRow:row forComponent:0];
        attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    }
    
    //Height Picker
    if (pickerView.tag == 2) {
        title = [self pickerView:heightPickerView titleForRow:row forComponent:0];
        attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    }
    
    //Weight Picker
    if (pickerView.tag == 3) {
        title = [self pickerView:weightPickerView titleForRow:row forComponent:0];
        attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    }
    
    
    return attString;
    
}


-(IBAction)genderValueChanged:(id)sender {
    NSArray *GENDER_VALUES = [[NSArray alloc] initWithObjects:@"Male", @"Female", @"Other", @"Decline", nil];
    _gender = [NSString stringWithFormat:[@"%@", GENDER_VALUES objectAtIndex:genderSegmentedControl.selectedSegmentIndex]];
    self.view.backgroundColor = [UIColor whiteColor];
}

-(IBAction)activityLevelValueChanged:(id)sender {
    
    NSArray *ACTIVITY_VALUES = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", nil];
    _activity = [NSString stringWithFormat:[@"%@", ACTIVITY_VALUES objectAtIndex:activityLevelSegmentedControl.selectedSegmentIndex]];
    self.view.backgroundColor = [UIColor whiteColor];
}

-(IBAction)sleepValueChanged:(id)sender {
    NSArray *SLEEP_VALUES = [[NSArray alloc] initWithObjects:@"02", @"24", @"46", @"68", @"8+", nil];
    _sleep = [NSString stringWithFormat:[@"%@", SLEEP_VALUES objectAtIndex:sleepSegmentedControl.selectedSegmentIndex]];
}

-(IBAction)healthValueChanged:(id)sender {
    NSArray *HEALTH_VALUES = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", nil];
    _health = [NSString stringWithFormat:[@"%@", HEALTH_VALUES objectAtIndex:healthSegmentedControl.selectedSegmentIndex]];
}

-(BOOL)postSignUpData {
    if (genderSegmentedControl == NULL || sleepSegmentedControl == NULL || activityLevelSegmentedControl == NULL || healthSegmentedControl == NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Field Empty!" message:@"You must complete all fields!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        NSLog(@"Field empty!");
        return FALSE;
    }
    
    else {
        NSString *post = [NSString stringWithFormat:@"gender=%@&activity=%@&sleep=%@&health=%@", _gender, _activity, _sleep, _health];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/signup", ROOT_ADDRESS]];
        NSError *error;
        NSData *data = [self sendPostRequest:post forURL:url];
        return TRUE;
    }
}

-(BOOL)isInternetConnection {
    //   Check for Internet Connection
    NSString *connect = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.apple.com"]] encoding:NSUTF8StringEncoding error:nil];
    //    NSLog(@"%@", connect);
    if (connect == NULL) {
        //No Internet Connection
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet!" message:@"You don't have an active internet connection. Please connect to the internet and try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        return FALSE;
    }
    else {
        return TRUE;
    }
    
}

-(NSData *)sendPostRequest:post forURL:url {
    if (![self isInternetConnection]) {
        //No Internet Connection
        NSData *data = [[NSData alloc] init];
        return data;
    }
    else {
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        [request setURL:url]; //URL Here
        
        [request setHTTPMethod:@"POST"];
        
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        [request setHTTPBody:postData];
        
        // Setting a timeout
        [request setTimeoutInterval: 20.0];
        
        NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        
        NSLog(@"%@", post);
        
        if(conn) {
            NSLog(@"Connection Successful – Sign Up");
            
        } else {
            NSLog(@"Connection could not be made – Sign Up");
        }
        
        // Fetch the JSON response
        NSData *urlData;
        NSURLResponse *response;
        NSError *error;
        
        // Make synchronous request
        urlData = [NSURLConnection sendSynchronousRequest:request
                                        returningResponse:&response
                                                    error:&error];
        
        // Construct a String around the Data from the response
        NSString *resultDataString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", resultDataString);
        
        return urlData;
    }
}

-(IBAction)showAdditionalInfo:(id)sender {
    POPBasicAnimation *fadeIn = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    fadeIn.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
    fadeIn.toValue = @(1.0);
    fadeIn.duration = 0.3;
    [additionalInfoView pop_addAnimation:fadeIn forKey:@"fadeIn"];
}

-(IBAction)showBasicInfo:(id)sender {
    POPBasicAnimation *fadeOut = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    fadeOut.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
    fadeOut.toValue = @(0.0);
    fadeOut.duration = 0.3;
    [additionalInfoView pop_addAnimation:fadeOut forKey:@"fadeOut"];
}

-(IBAction)submitInfo:(id)sender {
    if ([self postSignUpData]) {
        [self performSegueWithIdentifier:@"presentMainView" sender:self];
    }
}


@end
