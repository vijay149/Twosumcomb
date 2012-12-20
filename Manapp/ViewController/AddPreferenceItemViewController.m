//
//  AddPreferenceItemViewController.m
//  Manapp
//
//  Created by Demigod on 26/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "AddPreferenceItemViewController.h"
#import "PreferenceItem.h"
#import "PreferenceCategory.h"
#import "UIView+Additions.h"
#import "UIPlaceHolderTextView.h"
#import "DatabaseHelper.h"
#import "MASession.h"
#import "MACheckBoxButton.h"
#import "MADeviceUtil.h"
#import "NSString+Additional.h"

@interface AddPreferenceItemViewController ()
- (void) initialize;
- (void) initializeData;

- (void)deleteItem:(id)sender;
- (void)deleteCategory:(id)sender;
- (void)saveItemClicked:(id)sender;
- (void)toggleDeleteState:(BOOL) state;

- (PreferenceCategory *) getCurrentParentCategory;
- (PreferenceCategory *) getCurrentCategory;

- (void) fillViewWithInformation:(PreferenceItem*) information;
- (BOOL) addNewCategory:(NSString *) category forParent:(PreferenceCategory *) parentCategory;
- (void) deleteSelectedCategory;
@end

@implementation AddPreferenceItemViewController
@synthesize preferenceItem = _preferenceItem;
@synthesize scrollViewBackground = _scrollViewBackground;
@synthesize pickerItem = _pickerItem;
@synthesize textViewContent = _textViewContent;
@synthesize btnDelete = _btnDelete;
@synthesize preferences = _preferences;
@synthesize subPreferences = _subPreferences;
@synthesize preferenceCheckBox = _preferenceCheckBox;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //prepare the data
    [self initializeData];
    
    //prepare the UI
    [self initialize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_scrollViewBackground release];
    [_pickerItem release];
    [_textViewContent release];
    [_btnDelete release];
    [_subPreferences release];
    [_preferences release];
    [_preferenceItem release];
    [_preferenceCheckBox release];
    [super dealloc];
}

#pragma mark - init functions
- (void) initialize{
    _deleteState = FALSE;
    
    //add gesture
    [self addTouchBackgroundGesture];
    [self addSwipeBackGesture];
    
    //navigation bar and its items
    [self setNavigationBarHidden:NO animated:YES];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveItemClicked:)];
    
    //preference check box
    self.preferenceCheckBox = [[MACheckBoxButton alloc] initWithFrame:CGRectMake(285, 215, 30, 30) checkStateImage:[UIImage imageNamed:@"btnLike"] unCheckStateImage:[UIImage imageNamed:@"btnDislike"]];
    self.preferenceCheckBox.isAllowToggle = YES;
    [self.scrollViewBackground addSubview:self.preferenceCheckBox];
    
    //set the text view graphics
    [self.textViewContent makeBorderWithWidth:1.0f andColor:[UIColor lightGrayColor]];
    [self.textViewContent makeRoundCorner:5.0f];
    self.textViewContent.placeholder = @"Enter measurement data here...";
    
    //set the scrollview
    self.scrollViewBackground.contentSize = self.view.bounds.size;
    
    //if the measurementItem is nil, it mean we are in the creation state
    if (!self.preferenceItem) {
        // Add new information
        self.title = @"Add Preference";
    }
    //if the measurement item isn't nil, it mean we are in the editional state
    else {
        // fill the information to the form
        self.title = @"Edit Preference";
        [self fillViewWithInformation:self.preferenceItem];
    }
}

//load the data
- (void) initializeData{
    //load preference list
    if([[MASession sharedSession] currentPartner]){
        self.preferences = [[DatabaseHelper sharedHelper] getAllPartnerPreferenceAtLevel:1 ForPartner:[[MASession sharedSession] currentPartner] parentCategory:nil];
        if([self.preferences count] > 0)
        {
            self.subPreferences = [[DatabaseHelper sharedHelper] getAllPartnerPreferenceAtLevel:2 ForPartner:[[MASession sharedSession] currentPartner] parentCategory:[self.preferences objectAtIndex:0]];
        }
        else{
            self.subPreferences = [[NSArray alloc] init];
        }
    }
    else{
        self.preferences = [[NSArray alloc] init];
        self.subPreferences = [[NSArray alloc] init];
    }
}

#pragma mark - private functions
//fill the view with data
- (void) fillViewWithInformation:(PreferenceItem*) information{
    //item name
    self.textViewContent.text = self.preferenceItem.name;
    
    //set the 2 pickers
    NSInteger count = self.preferences.count;
    for (NSInteger row = 0; row < count; row++) {
        PreferenceCategory *pInformation = [self.preferences objectAtIndex:row];
        if (pInformation == self.preferenceItem.category.parentCategory) {
            // select the parent category
            [self.pickerItem selectRow:row inComponent:0 animated:YES];
            
            //reload the sub category (second component)
            self.subPreferences = [[DatabaseHelper sharedHelper] getAllPartnerPreferenceAtLevel:2 ForPartner:[[MASession sharedSession] currentPartner] parentCategory:pInformation];
            [self.pickerItem reloadComponent:1];
            
            // move to the selected sub category
            NSInteger subCount = self.subPreferences.count;
            for (NSInteger subRow = 0; subRow < subCount; subRow++){
                PreferenceCategory *subInformation = [self.subPreferences objectAtIndex:subRow];
                if (subInformation == self.preferenceItem.category) {
                    
                    [self.pickerItem selectRow:subRow inComponent:1 animated:YES];
                    break;
                }
            }
            break;
        }
    }
    
    //set the check box
    [self.preferenceCheckBox setCheckWithState:[self.preferenceItem.isLike boolValue]];
}

- (BOOL) addNewCategory:(NSString *) category forParent:(PreferenceCategory *) parentCategory{
    //get current parent category
    if([category isEqualToString:@""])
    {
        [self showMessage:@"Category name cannot be blank!"];
        return FALSE;
    }
    else{
        // add new category and reload the picker
        BOOL addResult = [[DatabaseHelper sharedHelper] addNewPreferenceCategoryForCategory:parentCategory withName:category];
        if(addResult){
            [self showMessage:@"Add new category successfully!"];
            return TRUE;
        }
        else{
            [self showMessage:@"Fail to add new category!"];
            return FALSE;
        }
    }
}

//delete the sub category
- (void) deleteSelectedCategory{
    PreferenceCategory *selectedCategory = [self getCurrentCategory];
    if (selectedCategory) {
        [[DatabaseHelper sharedHelper] deleteManagedObject:selectedCategory];
        [self showMessage:@"Category Deleted"];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self showMessage:@"Cannot delete this category!"];
    }
}

//toggle between the delete states
- (void) toggleDeleteState:(BOOL) state{
    _deleteState = state;
    if(!state){
        //change the delete button's label
        [self.btnDelete setTitle:@"Delete" forState:UIControlStateNormal];
        [self.btnDelete setTitle:@"Delete" forState:UIControlStateHighlighted];
        
        // animation to resize the text view and hide the delete button
        //remove the delete buttons from view
        UIButton *deleteDetailButton = (UIButton *)[self.view viewWithTag:MANAPP_ADD_PREFERENCE_ITEM_DELETEBUTTON_INFORMATION_DETAIL_TAG];
        UIButton *deleteCategoryButton = (UIButton *)[self.view viewWithTag:MANAPP_ADD_PREFERENCE_ITEM_DELETEBUTTON_INFORMATION_CATEGORY_TAG];
        
        if(deleteDetailButton != nil){
            [deleteDetailButton removeFromSuperview];
        }
        if(deleteCategoryButton != nil){
            [deleteCategoryButton removeFromSuperview];
        }
        
        //animation
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             // resize content text view
                             [self.textViewContent setWidth:self.textViewContent.frame.size.width + MANAPP_ADD_PREFERENCE_ITEM_TEXT_VIEW_RESIZE_DISTANCE];
                             
                             //resize picker view
                             [self.pickerItem setWidth:self.pickerItem.frame.size.width + MANAPP_ADD_PREFERENCE_ITEM_TEXT_VIEW_RESIZE_DISTANCE];
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
    else{
        //change state and delete button's label
        [self.btnDelete setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.btnDelete setTitle:@"Cancel" forState:UIControlStateHighlighted];
        
        // animation to resize the text view and display the delete button
        
        //show the delete button
        UIButton *deleteDetailButton = (UIButton *)[self.view viewWithTag:MANAPP_ADD_PREFERENCE_ITEM_DELETEBUTTON_INFORMATION_DETAIL_TAG];
        UIButton *deleteCategoryButton = (UIButton *)[self.view viewWithTag:MANAPP_ADD_PREFERENCE_ITEM_DELETEBUTTON_INFORMATION_CATEGORY_TAG];
        
        //create the button if not existed
        if(deleteDetailButton == nil)
        {
            deleteDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
            deleteDetailButton.tag = MANAPP_ADD_PREFERENCE_ITEM_DELETEBUTTON_INFORMATION_DETAIL_TAG;
            [deleteDetailButton setImage:[UIImage imageNamed:@"deleteicon"] forState:UIControlStateNormal];
            [deleteDetailButton setImage:[UIImage imageNamed:@"deleteicon"] forState:UIControlStateHighlighted];
            [deleteDetailButton addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
            
            deleteDetailButton.frame = CGRectMake(self.textViewContent.frame.origin.x + self.textViewContent.frame.size.width - MANAPP_ADD_PREFERENCE_ITEM_TEXT_VIEW_RESIZE_DISTANCE, self.textViewContent.frame.origin.y + self.textViewContent.frame.size.height/2 - 7, 18, 15);
            [self.view addSubview:deleteDetailButton];
            [self.view bringSubviewToFront:deleteDetailButton];
        }
        
        if(deleteCategoryButton == nil)
        {
            deleteCategoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
            deleteCategoryButton.tag = MANAPP_ADD_PREFERENCE_ITEM_DELETEBUTTON_INFORMATION_CATEGORY_TAG;
            [deleteCategoryButton setImage:[UIImage imageNamed:@"deleteicon"] forState:UIControlStateNormal];
            [deleteCategoryButton setImage:[UIImage imageNamed:@"deleteicon"] forState:UIControlStateHighlighted];
            [deleteCategoryButton addTarget:self action:@selector(deleteCategory:) forControlEvents:UIControlEventTouchUpInside];
            
            deleteCategoryButton.frame = CGRectMake(self.pickerItem.frame.origin.x + self.pickerItem.frame.size.width - MANAPP_ADD_PREFERENCE_ITEM_TEXT_VIEW_RESIZE_DISTANCE, self.pickerItem.frame.origin.y + self.pickerItem.frame.size.height/2 - 7, 18, 15);
            [self.view addSubview:deleteCategoryButton];
            [self.view bringSubviewToFront:deleteCategoryButton];
        }
        
        // animation
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             // resize content text view
                             [self.textViewContent setWidth:self.textViewContent.frame.size.width - MANAPP_ADD_PREFERENCE_ITEM_TEXT_VIEW_RESIZE_DISTANCE];
                             
                             //resize picker view
                             [self.pickerItem setWidth:self.pickerItem.frame.size.width - MANAPP_ADD_PREFERENCE_ITEM_TEXT_VIEW_RESIZE_DISTANCE];
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
}

#pragma mark - get,set functions
// get the current category (father)
- (PreferenceCategory *) getCurrentParentCategory{
    NSInteger selectedRow = [self.pickerItem selectedRowInComponent:0];
    PreferenceCategory *parentCategory = [self.preferences objectAtIndex:selectedRow];
    
    return parentCategory;
}

//get the current sub category
- (PreferenceCategory *) getCurrentCategory{
    NSInteger selectedRow = [self.pickerItem selectedRowInComponent:1];
    
    //make sure the selected one isn't "add new category" item
    if(selectedRow < self.subPreferences.count){
        PreferenceCategory *selectedCategory = [self.subPreferences objectAtIndex:selectedRow];
        
        return selectedCategory;
    }
    
    return nil;
}

#pragma mark - event handler
- (IBAction)btnDelete_touchUpInside:(id)sender {
    //hide the keyboard
    [self.textViewContent resignFirstResponder];
    
    [self toggleDeleteState:!_deleteState];
}

//delete the current item
- (void)deleteItem:(id)sender{
    if (self.preferenceItem) {
        [[DatabaseHelper sharedHelper] deleteManagedObject:self.preferenceItem];
    }
    
    [self showMessage:@"Measurement Deleted"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteCategory:(id)sender{
    //confirm to make sure we want to delete category
    
    PreferenceCategory *selectedCategory = [self getCurrentCategory];
    if (selectedCategory) {
        [self showMessage:[NSString stringWithFormat:@"You will be deleting all measurements in %@",selectedCategory.name] title:@"MANAPP" cancelButtonTitle:@"Delete all" otherButtonTitle:@"Cancel" delegate:self tag:MANAPP_ADD_PREFERENCE_ITEM_CONFIRM_DELETE_CATEGORY_ALERT_TAG];
    }
    else{
        [self showMessage:@"Cannot delete this category!"];
    }
}

- (void)saveItemClicked:(id)sender{
    [self.textViewContent resignFirstResponder];
    
    if (self.textViewContent.text.length == 0) {
        [self showErrorMessage:@"Name must not be empty"];
        return;
    }
    
    PreferenceCategory *preferenceCategory = [self getCurrentCategory];
    //in case we edit an exited one
    if (self.preferenceItem) {
        self.preferenceItem.category = preferenceCategory;
        self.preferenceItem.name = self.textViewContent.text;
        self.preferenceItem.isLike = [NSNumber numberWithBool:self.preferenceCheckBox.isChecked];
    }
    //create a new one
    else {
        self.preferenceItem = (id)[[DatabaseHelper sharedHelper] newManagedObjectForEntity:@"PreferenceItem"];
        self.preferenceItem.itemID = [NSString generateGUID];
        self.preferenceItem.name = self.textViewContent.text;
        self.preferenceItem.category = preferenceCategory;
        self.preferenceItem.timestamp = [NSDate date];
        self.preferenceItem.isLike = [NSNumber numberWithBool:self.preferenceCheckBox.isChecked];
    }
    [[DatabaseHelper sharedHelper] saveContext];
    [self showMessage:@"Measurement saved" title:@"MANAPP" cancelButtonTitle:@"OK" otherButtonTitle:nil delegate:self tag:MANAPP_ADD_PREFERENCE_ITEM_SUCCESSFULLY_CREATION_ALERT_TAG];
}

#pragma mark - parent override
//tap background (only if gesture is added)
- (void)tap:(id)sender{
    [self.textViewContent resignFirstResponder];
}

#pragma mark - picker view controller
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0)
    {
        return self.preferences.count;
    }
    else{
        // +1 to "Add new category" item
        return self.subPreferences.count + 1;
    }
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == 0)
    {
        PreferenceCategory *preference = [self.preferences objectAtIndex:row];
        return preference.name;
    }
    else{
        // add new category item
        if(row == self.subPreferences.count)
        {
            return @"Add new category";
        }
        else{
            PreferenceCategory *preference = [self.subPreferences objectAtIndex:row];
            return preference.name;
        }
    }
    
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if(component == 0)
    {
        // change the level 1 category with cause the level 2 category to refresh
        PreferenceCategory *preference = [self.preferences objectAtIndex:row];
        self.subPreferences = [[DatabaseHelper sharedHelper] getAllPartnerPreferenceAtLevel:2 ForPartner:[[MASession sharedSession] currentPartner] parentCategory:preference];
        
        [pickerView reloadComponent:1];
    }
    else{
        // add new category item was selected
        if(row == self.subPreferences.count)
        {
            // show the alertview with textfield
            NSMutableArray *subsControl = [[[NSMutableArray alloc] init] autorelease];
            
            UITextField *newCategoryTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
            [newCategoryTextField setBackgroundColor:[UIColor whiteColor]];
            newCategoryTextField.tag = MANAPP_ADD_PREFERENCE_ITEM_NEW_CATEGORY_TEXT_FIELD;
            
            [subsControl addObject:newCategoryTextField];
            
            [self showMessage:@"\n\nPlease select a name for your new category." title:@"MANAPP" cancelButtonTitle:@"Cancel" otherButtonTitle:@"Add Measurement" delegate:self tag:MANAPP_ADD_PREFERENCE_ITEM_NEW_CATEGORY_ALERT_TAG subControls:subsControl];
        }
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.backgroundColor = [UIColor clearColor];
        pickerLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:14];
        
        if([MADeviceUtil getDeviceIOSVersionNumber] >= 6.0f){
            pickerLabel.textAlignment = NSTextAlignmentCenter;
        }
        else{
            pickerLabel.textAlignment = UITextAlignmentCenter;
        }
        
        [view addSubview:pickerLabel];
    }
    
    if(component == 0)
    {
        PreferenceCategory *preference = [self.preferences objectAtIndex:row];
        pickerLabel.text = preference.name;
    }
    else{
        // add new category item was selected
        if(row == self.subPreferences.count)
        {
            pickerLabel.text = @"Add new category";
        }
        else{
            PreferenceCategory *preference = [self.subPreferences objectAtIndex:row];
            pickerLabel.text =  preference.name;
        }
    }
    
    return pickerLabel;
}

#pragma mark - UITextViewDelegate

-(void)keyboardWillShow:(NSNotification *)notification{
    [super keyboardWillShow:notification];
    
    [self resizeScrollView:self.scrollViewBackground withKeyboardState:TRUE willChangeOffset:YES];
}

-(void)keyboardWillHide{
    [super keyboardWillHide];
    
    [self resizeScrollView:self.scrollViewBackground withKeyboardState:FALSE willChangeOffset:YES];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self toggleDeleteState:NO];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

#pragma mark - alertview delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // add new category alertview
    if(alertView.tag == MANAPP_ADD_PREFERENCE_ITEM_NEW_CATEGORY_ALERT_TAG){
        // add button clicked
        if(buttonIndex == 1)
        {
            UITextField *newCategoryTextField = (UITextField *)[alertView viewWithTag: MANAPP_ADD_PREFERENCE_ITEM_NEW_CATEGORY_TEXT_FIELD];
            
            PreferenceCategory *parentCategory = [self getCurrentParentCategory];
            
            if([self addNewCategory:newCategoryTextField.text forParent:parentCategory]){
                //reload
                self.subPreferences = [[DatabaseHelper sharedHelper] getAllPartnerPreferenceAtLevel:2 ForPartner:[[MASession sharedSession] currentPartner] parentCategory:parentCategory];
                [self.pickerItem reloadComponent:1];
            }
        }
    }
    //after save, return to the previous view
    else if(alertView.tag == MANAPP_ADD_PREFERENCE_ITEM_SUCCESSFULLY_CREATION_ALERT_TAG){
        [self.navigationController popViewControllerAnimated:YES];
    }
    //delete category if user select yes
    else if(alertView.tag == MANAPP_ADD_PREFERENCE_ITEM_CONFIRM_DELETE_CATEGORY_ALERT_TAG){
        [self deleteSelectedCategory];
    }
}


@end
