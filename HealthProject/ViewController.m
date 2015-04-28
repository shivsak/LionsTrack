//
//  ViewController.m
//  HealthProject
//
//  Created by Shiv Sakhuja on 4/1/15.
//  Copyright (c) 2015 Shiv Sakhuja. All rights reserved.
//

#import "ViewController.h"
#import <POP/POP.h>
#import <HealthKit/HealthKit.h>
#import <SSKeychain/SSKeychain.h>

@interface ViewController ()

@property (nonatomic, retain) NSString *gender;
@property (nonatomic, retain) NSString *activity;
@property (nonatomic, retain) NSString *sleep;
@property (nonatomic, retain) NSString *health;
@property (nonatomic, retain) NSString *deviceID;
@property (nonatomic, retain) NSString *stepCount;

@end

NSString *ROOT_ADDRESS = @"http://lions-tracks.herokuapp.com/";    //Database Root Address
int age;
int height;
int weight;

@implementation ViewController

@synthesize genderSegmentedControl, healthSegmentedControl, activityLevelSegmentedControl, sleepSegmentedControl;

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setDefaults];
    [self showBasicInfo:self];
    [self routineCheck];
    
}

-(void)firstTimeHealthKitCheck {
    
    [self performSegueWithIdentifier:@"MainToInitial" sender:self];
    
    //If Health Kit is available on the device
    if(NSClassFromString(@"HKHealthStore") && [HKHealthStore isHealthDataAvailable])
    {
        //Ask for Permission
        
        HKHealthStore *healthStore = [[HKHealthStore alloc] init];
        
        // Share body mass, height and body mass index
        NSSet *shareObjectTypes = [self shareTypes];
        
        // Read date of birth, biological sex and step count
        NSSet *readObjectTypes  = [self readTypes];
        
        // Request access
        [healthStore requestAuthorizationToShareTypes:shareObjectTypes
                                            readTypes:readObjectTypes
                                           completion:^(BOOL success, NSError *error) {
                                               
                                               if(success == YES)
                                               {
                                                   // ...
                                               }
                                               else
                                               {
                                                   // Determine if it was an error or if the
                                                   // user just canceld the authorization request
                                               }
                                               
                                           }];
        
    }
    else {
        //Alert the user
        UIAlertView *noHealthKitAlert = [[UIAlertView alloc] initWithTitle:@"Health Data Unavailable" message:@"Sorry! Health data is not available on your device!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [noHealthKitAlert show];
        [self performSegueWithIdentifier:@"InitialToUnavailable" sender:self];
    }
    
}

-(NSSet *)shareTypes {
    // Share body mass, height and body mass index
    NSSet *shareObjectTypes = [NSSet setWithObjects:
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex],
                               nil];
    return shareObjectTypes;
}

-(NSSet *)readTypes {
    NSSet *readObjectTypes  = [NSSet setWithObjects:
                               [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth],
                               [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                               nil];
    
    return readObjectTypes;
}


-(void)routineCheck {
    //If Keychain, then run
    NSArray *keychainArray = [SSKeychain accountsForService:@"DeviceDetails"];
    if ([keychainArray count] > 0) {
        NSString *device = [keychainArray[0] objectForKey:@"acct"];
        self.deviceID = [SSKeychain passwordForService:@"DeviceDetails" account:device];
        [self getUserData:self.deviceID];
        NSLog(@"Device ID (From Keychain) %@", self.deviceID);
    }
    //If no keychain, perform First Time Check
    else {
        [self firstTimeHealthKitCheck];
    }
}

-(void)getUserData:(NSString *)identification {
    HKHealthStore *healthStore = [[HKHealthStore alloc] init];
    // Set your start and end date for your query of interest
    NSDate *endDate = [NSDate date];
    int daysToAdd = -1;
    
    // set up date components
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:daysToAdd];
    
    // create a calendar
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *startDate = [gregorian dateByAddingComponents:components toDate:endDate options:0];
    NSLog(@"Start Date: %@ \n End Date: %@", startDate, endDate);
    
    // Use the sample type for step count
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
    
    // Create a sort descriptor for sorting by start date
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:YES];
    
    
    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:sampleType
                                                                 predicate:predicate
                                                                     limit:HKObjectQueryNoLimit
                                                           sortDescriptors:@[sortDescriptor]
                                                            resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                                                                
                                                                if(!error && results)
                                                                {
                                                                    int steps = 0;
                                                                    for(HKQuantitySample *samples in results) {
                                                                        HKQuantity *quantity = samples.quantity;
                                                                        NSString *qtyString = [NSString stringWithFormat:@"%@", quantity];
                                                                        self.stepCount = [qtyString stringByReplacingOccurrencesOfString:@" count" withString:@""];
                                                                        steps += [self.stepCount integerValue];
                                                                    }
                                                                    NSLog(@"%i Steps", steps);
                                                                    [self postHealthData:steps forDataType:@"Steps" withUnits:@"count"];
                                                                    
                                                                }
                                                            }];
    // Execute the query
    [healthStore executeQuery:sampleQuery];
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

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //Age Picker
    if (pickerView.tag == 1) {
        age = (int) row + 13;
    }
    
    //Height Picker
    if (pickerView.tag == 2) {
        height = (int) row + 12;
    }
    
    //Weight Picker
    if (pickerView.tag == 3) {
        weight = (int) row + 40;
    }
}


-(IBAction)genderValueChanged:(id)sender {
    NSArray *GENDER_VALUES = [[NSArray alloc] initWithObjects:@"M", @"F", @"O", @"D", nil];
    _gender = [NSString stringWithFormat:[@"%@", GENDER_VALUES objectAtIndex:genderSegmentedControl.selectedSegmentIndex]];
    self.view.backgroundColor = [UIColor whiteColor];
}

-(IBAction)activityLevelValueChanged:(id)sender {
    
    NSArray *ACTIVITY_VALUES = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", nil];
    _activity = [NSString stringWithFormat:[@"%@", ACTIVITY_VALUES objectAtIndex:activityLevelSegmentedControl.selectedSegmentIndex]];
    self.view.backgroundColor = [UIColor whiteColor];
}

-(IBAction)sleepValueChanged:(id)sender {
    NSArray *SLEEP_VALUES = [[NSArray alloc] initWithObjects:@"1", @"3", @"5", @"7", @"9", nil];
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
        NSString *post = [NSString stringWithFormat:@"sex=%@&activity=%@&sleep=%@&health=%@&age=%i&height=%i&weight=%i", _gender, _activity, _sleep, _health, age, height, weight];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/signup", ROOT_ADDRESS]];
        NSError *error;
        NSData *data = [self sendPostRequest:post forURL:url];
        
        NSString *stringFromData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"String From Data: %@", stringFromData);
        
        NSDictionary *signupResponseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        self.deviceID = [NSString stringWithFormat:@"%@", [signupResponseDictionary valueForKey:@"id"]];
        NSLog(@"Signup Response Device ID: %@", self.deviceID);
        
        NSLog(@"Device ID (From Database): %@", self.deviceID);
        [SSKeychain setPassword:self.deviceID forService:@"DeviceDetails" account:@"deviceID"];
        //        [SSKeychain setPassword:@"1" forService:@"DeviceDetails" account:@"deviceID"];  //Tester Code
        
        return TRUE;
    }
}

-(BOOL)postHealthData:(int)dataValue forDataType:(NSString *)dataType withUnits:(NSString *)dataUnits {
    NSString *post = [NSString stringWithFormat:@"user_id=%@&data_type=%@&value=%i&unit=%@", self.deviceID, dataType, dataValue, dataUnits];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/update", ROOT_ADDRESS]];
    NSError *error;
    NSData *data = [self sendPostRequest:post forURL:url];
    
    NSString *stringFromData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"String From Data Update: %@", stringFromData);
    
    return TRUE;
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
        
        //        NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        //
        //        NSLog(@"%@", post);
        //
        //        if(conn) {
        //            NSLog(@"Connection Successful – Sign Up");
        //
        //        } else {
        //            NSLog(@"Connection could not be made – Sign Up");
        //        }
        
        // Fetch the JSON response
        NSData *urlData;
        NSURLResponse *response;
        NSError *error;
        
        // Make synchronous request
        urlData = [NSURLConnection sendSynchronousRequest:request
                                        returningResponse:&response
                                                    error:&error];
        
        // Construct a String around the Data from the response
        
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
        [self performSegueWithIdentifier:@"InitialToMain" sender:self];
    }
}

-(IBAction)getHealthData:(id)sender {
    
}


@end
