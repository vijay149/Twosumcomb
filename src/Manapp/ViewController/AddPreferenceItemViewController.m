//
//  AddPreferenceItemViewController.m
//  Manapp
//
//  Created by Demigod on 26/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "AddPreferenceItemViewController.h"
#import "HomepageViewController.h"
#import "PreferenceItem.h"
#import "PreferenceCategory.h"
#import "UIView+Additions.h"
#import "UIPlaceHolderTextView.h"
#import "DatabaseHelper.h"
#import "MASession.h"
#import "MACheckBoxButton.h"
#import "MADeviceUtil.h"
#import "NSString+Additional.h"
#import "MAUserProcessManager.h"
#import "UIButton+Additions.h"
#import "NSArray+Additions.h"
#import "UITextField+Additional.h"

@interface AddPreferenceItemViewController ()
- (void) initialize;

- (void) loadUI;
- (void) loadData;

- (void) reloadUI;

- (void) resignAllPicker;

- (void)deleteItem:(id)sender;
- (void)deleteCategory:(id)sender;
- (void)saveItemClicked:(id)sender;
- (void)toggleDeleteState:(BOOL) state;

- (void)changePreferenceState:(BOOL) isLike;

- (void) fillViewWithInformation:(PreferenceItem*) information;
- (PreferenceCategory *) addNewCategory:(NSString *) category forParent:(PreferenceCategory *) parentCategory;
- (void) deleteSelectedCategory;

- (void) backToHome;
@end

@implementation AddPreferenceItemViewController
@synthesize preferenceItem = _preferenceItem;
@synthesize scrollViewBackground = _scrollViewBackground;
@synthesize textViewContent = _textViewContent;
@synthesize btnDelete = _btnDelete;
@synthesize preferences = _preferences;
@synthesize subPreferences = _subPreferences;

- (void)dealloc {
    [_scrollViewBackground release];
    [_textViewContent release];
    [_btnDelete release];
    [_subPreferences release];
    [_preferences release];
    [_preferenceItem release];
    [_lblTitle release];
    [_btnLike release];
    [_btnDislike release];
    [_lblCategory release];
    [_lblSubCategory release];
    [_lblDetail release];
    [_txtCategory release];
    [_txtSubCategory release];
    [_currentCategory release];
    [_currentSubCategory release];
    [_pickerCategory release];
    [_pickerSubCategory release];
    [_btnBackground release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initialize];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //prepare the data
    [self loadData];
    
    //prepare the UI
    [self loadUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - init functions
-(void)initialize{
    _isLike = YES;
    _deleteState = NO;
}

#pragma mark - UI functions
- (void) loadUI {
    //add button
    // check if preferenceItems == 0 => click button cancel will back homepage
    if([[MASession sharedSession] currentPartner]){
        NSArray *preferenceItems = [[DatabaseHelper sharedHelper] getAllItemPreferenceForPartner:[[MASession sharedSession] currentPartner]];
        SEL action = @selector(back);
        if([preferenceItems count] == 0){
            action = @selector(backToHome);
        }
        [self createBackNavigationWithTitle:MA_CANCEL_BUTTON_TEXT frame:CGRectMake(4, 17, 54, 23) action:action];
    }
    [self createRightNavigationWithTitle:MA_SAVE_BUTTON_TEXT frame:CGRectMake(251, 17, 55, 23) action:@selector(saveItemClicked:)];
    
    [self moveNavigationButtonsToView:self.scrollViewBackground];
    
    //add gesture
    //[self addTouchBackgroundGesture];
    [self addSwipeBackGesture];
    
    [self.txtCategory paddingLeftByValue:5];
    [self.txtSubCategory paddingLeftByValue:5];
    
    //change font
    [self.lblTitle setFont:[UIFont fontWithName:kAppFont size:16]];
    [self.lblSubCategory setFont:[UIFont fontWithName:kAppFont size:14]];
    [self.lblCategory setFont:[UIFont fontWithName:kAppFont size:14]];
    [self.lblDetail setFont:[UIFont fontWithName:kAppFont size:14]];
    
    [self.btnDelete.titleLabel setFont:[UIFont fontWithName:kAppFont size:16]];
    
    [self.txtCategory setFont:[UIFont fontWithName:kAppFont size:12]];
    [self.txtSubCategory setFont:[UIFont fontWithName:kAppFont size:12]];
    [self.textViewContent setFont:[UIFont fontWithName:kAppFont size:13]];
    //set the text view graphics
    [self.textViewContent makeBorderWithWidth:1.0f andColor:[UIColor lightGrayColor]];
    [self.textViewContent makeRoundCorner:5.0f];
    self.textViewContent.placeholder = @"Enter preference data here...";
    
    //set the scrollview
    self.scrollViewBackground.contentSize = self.view.bounds.size;
    
    if(self.currentCategory){
        self.txtCategory.text = self.currentCategory.name;
    }
    if(self.currentSubCategory){
        self.txtSubCategory.text = self.currentSubCategory.name;
    }
    
    [self changePreferenceState:_isLike];
    
    if(self.preferenceItem){
        [self fillViewWithInformation:self.preferenceItem];
    }
}

//load the data
- (void) loadData{
    //load preference list
    if([[MASession sharedSession] currentPartner]){
        self.preferences = [[DatabaseHelper sharedHelper] getAllPartnerPreferenceAtLevel:1 ForPartner:[[MASession sharedSession] currentPartner] parentCategory:nil];
        if([self.preferences count] > 0)
        {
            self.subPreferences = [[DatabaseHelper sharedHelper] getAllPartnerPreferenceAtLevel:2 ForPartner:[[MASession sharedSession] currentPartner] parentCategory:[self.preferences objectAtIndex:0]];
        }
        else{
            _subPreferences = [[NSArray alloc] init];
        }
    }
    else{
        _preferences = [[NSArray alloc] init];
        _subPreferences = [[NSArray alloc] init];
    }
    
    if(self.preferences){
        self.currentCategory = [self.preferences firstObject];
    }
    
    if(self.subPreferences){
        self.currentSubCategory = [self.subPreferences firstObject];
    }
}

- (void)changePreferenceState:(BOOL) isLike{
    _isLike = isLike;
    if(isLike){
        [self.btnLike setImageWithImageName:@"btnLikeSelected"];
        [self.btnDislike setImageWithImageName:@"btnDislike"];
        //if the measurementItem is nil, it mean we are in the creation state
        if (!self.preferenceItem) {
            // Add new information
            self.lblTitle.text = @"Add Like";
        }
        //if the measurement item isn't nil, it mean we are in the editional state
        else {
            // fill the information to the form
            self.lblTitle.text = @"Edit Like";
        }
    }
    else{
        [self.btnLike setImageWithImageName:@"btnLike"];
        [self.btnDislike setImageWithImageName:@"btnDisLikeSelected"];
        if (!self.preferenceItem) {
            // Add new information
            self.lblTitle.text = @"Add Dislike";
        }
        //if the measurement item isn't nil, it mean we are in the editional state
        else {
            // fill the information to the form
            self.lblTitle.text = @"Edit Dislike";
        }
    }
}

-(void) reloadUI{
    [self changePreferenceState:_isLike];
    self.txtCategory.text = self.currentCategory.name;
    self.txtSubCategory.text = self.currentSubCategory.name;
    
    if(self.pickerCategory){
        [self.pickerCategory reloadAllComponents];
    }
    if(self.pickerSubCategory){
        [self.pickerSubCategory reloadAllComponents];
    }
}

#pragma mark - private functions
//fill the view with data
- (void) fillViewWithInformation:(PreferenceItem*) information{
    //item name
    self.textViewContent.text = self.preferenceItem.name;
    self.txtCategory.text = information.category.parentCategory.name;
    self.txtSubCategory.text = information.category.name;
    
    self.currentCategory = information.category.parentCategory;
    self.currentSubCategory = information.category;
    
    [self changePreferenceState:information.isLike.boolValue];
}

- (PreferenceCategory *) addNewCategory:(NSString *) category forParent:(PreferenceCategory *) parentCategory{
    //get current parent category
    if([category isEqualToString:@""])
    {
        [self showMessage:@"Category name cannot be blank!"];
        return FALSE;
    }
    else{
        //check if these is any duplicate measurement
        NSArray *sameNameCategories = [[DatabaseHelper sharedHelper] getPartnerPreferenceAtLevel:2 withName:category forPartner:[[MASession sharedSession] currentPartner] parentCategory:parentCategory];
        if(sameNameCategories.count > 0){
            [self showMessage:@"A category with the same name exists"];
            return nil;
        }
        
        // add new category and reload the picker
        PreferenceCategory* newCategory = [[DatabaseHelper sharedHelper] addNewPreferenceCategoryForCategory:parentCategory withName:category];
        if(newCategory){
            [self showMessage:@"Add new category successfully!"];
            
            //reload UI
            self.subPreferences = [[DatabaseHelper sharedHelper] getAllPartnerPreferenceAtLevel:2 ForPartner:[[MASession sharedSession] currentPartner] parentCategory:parentCategory];
            self.currentSubCategory = newCategory;
            [self reloadUI];
            
            return newCategory;
        }
        else{
            [self showMessage:@"Fail to add new category!"];
            return nil;
        }
    }
}

//delete the sub category
- (void) deleteSelectedCategory{
    if (self.currentSubCategory) {
        [[DatabaseHelper sharedHelper] deleteManagedObject:self.currentSubCategory];
        [self showMessage:@"Category Deleted"];
        [self back];
    }
    else{
        [self showMessage:@"Cannot delete this category!"];
    }
}

-(void) restoreDefaultCategories{
    if([[MASession sharedSession] currentPartner]){
        NSInteger noOfRestore = [[DatabaseHelper sharedHelper] restoreDefaultPreferenceCategoryForPartner:[[MASession sharedSession] currentPartner]];
        [self showMessage:[NSString stringWithFormat:@"%d categories restored",noOfRestore]];
        
        //reload UI
        self.subPreferences = [[DatabaseHelper sharedHelper] getAllPartnerPreferenceAtLevel:2 ForPartner:[[MASession sharedSession] currentPartner] parentCategory:self.currentCategory];
        [self reloadUI];
    }
}

//toggle between the delete states
- (void) toggleDeleteState:(BOOL) state{
    _deleteState = state;
    if(!state){
        //change the delete button's label
        [self.btnDelete changeTitle:@"Delete"];
        
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
    }
    else{
        //change state and delete button's label
        [self.btnDelete changeTitle:@"Cancel"];
        
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
            
            deleteDetailButton.frame = CGRectMake(self.textViewContent.frame.origin.x + self.textViewContent.frame.size.width + MANAPP_ADD_PREFERENCE_ITEM_TEXT_VIEW_RESIZE_DISTANCE, self.textViewContent.frame.origin.y + self.textViewContent.frame.size.height/2 - 7, 27, 15);
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
            
            deleteCategoryButton.frame = CGRectMake(self.txtSubCategory.frame.origin.x + self.txtSubCategory.frame.size.width + MANAPP_ADD_PREFERENCE_ITEM_TEXT_VIEW_RESIZE_DISTANCE, self.txtSubCategory.frame.origin.y + self.txtSubCategory.frame.size.height/2 - 7, 27, 15);
            [self.view addSubview:deleteCategoryButton];
            [self.view bringSubviewToFront:deleteCategoryButton];
        }
    }
}

#pragma mark - public function
-(void)resignAllTextField{
    // error on ios7
//    [self.textViewContent resignFirstResponder];
    [self.txtCategory resignFirstResponder];
    [self.txtSubCategory resignFirstResponder];
    [self resignAllPicker];
}

- (void) resignAllPicker{
    if([self.pickerCategory.superview isEqual: self.view]){
        [self hideModalView:self.pickerCategory direction:MAModalViewDirectionBottom autoAddSubView:YES];
        [self resizeScrollView:self.scrollViewBackground withView:self.pickerCategory viewState:NO];
        [self.btnBackground setSize:self.scrollViewBackground.contentSize];
    }
    
    if([self.pickerSubCategory.superview isEqual: self.view]){
        [self hideModalView:self.pickerSubCategory direction:MAModalViewDirectionBottom autoAddSubView:YES];
        [self resizeScrollView:self.scrollViewBackground withView:self.pickerSubCategory viewState:NO];
        [self.btnBackground setSize:self.scrollViewBackground.contentSize];
    }
}

#pragma mark - event handler
- (IBAction)btnDelete_touchUpInside:(id)sender {
    //hide the keyboard
    [self resignAllTextField];
    
    [self toggleDeleteState:!_deleteState];
}

- (IBAction)btnLike_touchUpInside:(id)sender {
    [self changePreferenceState:YES];
}

- (IBAction)btnDislike_touchUpInside:(id)sender {
    [self changePreferenceState:NO];
}

//delete the current item
- (void)deleteItem:(id)sender{
    if (self.preferenceItem) {
        [[DatabaseHelper sharedHelper] deleteManagedObject:self.preferenceItem];
        [self showMessage:@"Preference Deleted"];
        [self back];
    }
    else{
        self.textViewContent.text = @"";
        [self toggleDeleteState:!_deleteState];
    }
    
}

- (void)deleteCategory:(id)sender{
    //confirm to make sure we want to delete category
    if (self.currentSubCategory) {
        [self showMessage:[NSString stringWithFormat:Translate(@"You are about to delete the %@ Category and any saved data within it from your app"),self.currentSubCategory.name] title:kAppName cancelButtonTitle:@"Delete all" otherButtonTitle:@"Cancel" delegate:self tag:MANAPP_ADD_PREFERENCE_ITEM_CONFIRM_DELETE_CATEGORY_ALERT_TAG];
    }
    else{
        [self showMessage:@"Cannot delete this category!"];
    }
}

- (void)saveItemClicked:(id)sender{
    [self.textViewContent resignFirstResponder];
    
    if (self.textViewContent.text.length == 0) {
        [self showErrorMessage:@"You can't save what's not there"];
        return;
    }
    
    if(!self.currentSubCategory){
        [self showErrorMessage:@"Please select a catagory for this item."];
        return;
    }
    
    //in case we edit an exited one
    if (self.preferenceItem) {
        self.preferenceItem.category = self.currentSubCategory;
        self.preferenceItem.name = self.textViewContent.text;
        self.preferenceItem.isLike = [NSNumber numberWithBool:_isLike];
    }
    //create a new one
    else {
        _preferenceItem = (id)[[DatabaseHelper sharedHelper] newManagedObjectForEntity:@"PreferenceItem"];
        self.preferenceItem.itemID = [NSString generateGUID];
        self.preferenceItem.name = self.textViewContent.text;
        self.preferenceItem.category = self.currentSubCategory;
        self.preferenceItem.timestamp = [NSDate date];
        self.preferenceItem.isLike = [NSNumber numberWithBool:_isLike];
    }
    [[DatabaseHelper sharedHelper] saveContext];
    [self showMessage:@"Successfully Saved" title:kAppName cancelButtonTitle:@"OK" otherButtonTitle:nil delegate:self tag:MANAPP_ADD_PREFERENCE_ITEM_SUCCESSFULLY_CREATION_ALERT_TAG];
}

#pragma mark - parent override
//tap background (only if gesture is added)
- (void)tap:(id)sender{
    [self resignAllTextField];
}

#pragma mark - custom picker view
-(NSInteger)numberOfComponentsInCustomPickerView:(CustomPickerView *)pickerView{
    return 1;
}

-(NSInteger)customPickerView:(CustomPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if([pickerView isEqual:self.pickerCategory])
    {
        return self.preferences.count;
    }
    else{
        // +2 to "Add new category" item and "Restore default categories"
        return self.subPreferences.count + 2;
    }
}

-(NSString *)customPickerView:(CustomPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if([pickerView isEqual:self.pickerCategory])
    {
        PreferenceCategory *preference = [self.preferences objectAtIndex:row];
        return preference.name;
    }
    else{
        // add new category item
        if(row == self.subPreferences.count + 1)
        {
            return LSSTRING(@"Add new category");
        }
        else if(row == self.subPreferences.count)
        {
            return LSSTRING(@"Restore Default Categories");
        }
        else{
            PreferenceCategory *preference = [self.subPreferences objectAtIndex:row];
            return preference.name;
        }
    }
}

-(void)customPickerView:(CustomPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
}

-(void)didClickDoneInCustomPickerView:(CustomPickerView *)pickerView{
    NSInteger row = [pickerView.pickerView selectedRowInComponent:0];
    if([pickerView isEqual:self.pickerCategory])
    {
        // change the level 1 category with cause the level 2 category to refresh
        PreferenceCategory *preference = [self.preferences objectAtIndex:row];
        self.currentCategory = preference;
        
        self.subPreferences = [[DatabaseHelper sharedHelper] getAllPartnerPreferenceAtLevel:2 ForPartner:[[MASession sharedSession] currentPartner] parentCategory:preference];
        if(self.subPreferences.count > 0){
            self.currentSubCategory = (PreferenceCategory *)[self.subPreferences firstObject];
        }
        
        [self.pickerSubCategory reloadAllComponents];
        [self reloadUI];
    }
    else{
        // add new category item was selected
        if(row == self.subPreferences.count + 1)
        {
            // show the alertview with textfield
            [self showMessageWithTextInput:@"Please select a name for your new category." title:kAppName cancelButtonTitle:@"Cancel" otherButtonTitle:@"Add Category" delegate:self tag:MANAPP_ADD_PREFERENCE_ITEM_NEW_CATEGORY_ALERT_TAG];
        }
        else if(row == (self.subPreferences.count))
        {
            // COMMENT: show the alertview with textfield
            
            [self showMessage:@"Are you sure you want to restore all the default preference categories?" title:kAppName cancelButtonTitle:@"OK" otherButtonTitle:@"Cancel" delegate:self tag:MANAPP_ADD_PREFERENCE_ITEM_CONFIRM_RESTORE_CATEGORY_ALERT_TAG];
        }
        else{
            PreferenceCategory *preference = [self.subPreferences objectAtIndex:row];
            self.currentSubCategory = preference;
            [self reloadUI];
        }
    }
    
    [self resignAllPicker];
}

-(void)didClickCancelInCustomPickerView:(CustomPickerView *)pickerView{
    [self resignAllPicker];
}

#pragma mark - UITextViewDelegate

-(void)keyboardWillShow:(NSNotification *)notification{
    [super keyboardWillShow:notification];
    
    [self resizeScrollView:self.scrollViewBackground withKeyboardState:TRUE willChangeOffset:NO];
    [self.btnBackground setSize:self.scrollViewBackground.contentSize];
}

-(void)keyboardWillHide{
    [super keyboardWillHide];
    
    [self resizeScrollView:self.scrollViewBackground withKeyboardState:FALSE willChangeOffset:NO];
    [self.btnBackground setSize:self.scrollViewBackground.contentSize];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self resignAllTextField];
    [self toggleDeleteState:NO];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self.textViewContent resignFirstResponder];
    if([textField isEqual:self.txtCategory]){
        if([self.view.subviews containsObject:self.pickerCategory]){
            return NO;
        }
        else{
            [self resignAllTextField];
            
            if(!self.pickerCategory){
                self.pickerCategory = (CustomPickerView *)[Util getView:[CustomPickerView class]];
                self.pickerCategory.delegate = self;
            }
            
            [self.pickerCategory selectRow:[self.preferences indexOfObject:self.currentCategory] inComponent:0 animated:YES];
            
            [self showModalView:self.pickerCategory direction:MAModalViewDirectionBottom autoAddSubView:YES];
            [self resizeScrollView:self.scrollViewBackground withView:self.pickerCategory viewState:YES];
            [self.btnBackground setSize:self.scrollViewBackground.contentSize];
            return NO;
        }
    }
    else if([textField isEqual:self.txtSubCategory]){
        //        if (self.pickerSubCategory) {
        if([self.view.subviews containsObject:self.pickerSubCategory]){
            return NO;
        }
        //        }
        else{
            [self resignAllTextField];
            
            if(!self.pickerSubCategory){
                self.pickerSubCategory = (CustomPickerView *)[Util getView:[CustomPickerView class]];
                self.pickerSubCategory.delegate = self;
            }
            NSLog(@"[self.subPreferences indexOfObject:self.currentSubCategory] %d",[self.subPreferences indexOfObject:self.currentSubCategory]);
            //            NSInteger selectRow = [self.subPreferences indexOfObject:self.currentSubCategory];
            //            if (selectRow != kRangeCrashOnSubCategory) {
            [self.pickerSubCategory selectRow:[self.subPreferences indexOfObject:self.currentSubCategory] inComponent:0 animated:YES];
            
            [self showModalView:self.pickerSubCategory direction:MAModalViewDirectionBottom autoAddSubView:YES];
            [self resizeScrollView:self.scrollViewBackground withView:self.pickerSubCategory viewState:YES];
            [self.btnBackground setSize:self.scrollViewBackground.contentSize];
            return NO;
            //            } else {
            //                return YES;
            //            }
            
        }
    }
    else{
        [self resignAllTextField];
        return YES;
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //    // Any new character added is passed in as the "text" parameter
    //    if ([text isEqualToString:@"\n"]) {
    //        // Be sure to test for equality using the "isEqualToString" message
    //        [textView resignFirstResponder];
    //
    //        // Return FALSE so that the final '\n' character doesn't get added
    //        return FALSE;
    //    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

#pragma mark - alertview delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // add new category alertview
    if(alertView.tag == MANAPP_ADD_PREFERENCE_ITEM_NEW_CATEGORY_ALERT_TAG){
        // add button clicked
        if(buttonIndex == 1)
        {
            UITextField *newCategoryTextField = [alertView textFieldAtIndex:0];
            
            PreferenceCategory *parentCategory = self.currentCategory;
            if(newCategoryTextField.text && ![newCategoryTextField.text isEqualToString:@""]){
                [self addNewCategory:newCategoryTextField.text forParent:parentCategory];
            }
            else{
                [self showMessage:@"Category name cannot be blank."];
                [self resignAllPicker];
                [self resignAllTextField];
            }
        }
    }
    //after save, return to the previous view
    else if(alertView.tag == MANAPP_ADD_PREFERENCE_ITEM_SUCCESSFULLY_CREATION_ALERT_TAG){
        [self back];
    }
    //delete category if user select yes
    else if(alertView.tag == MANAPP_ADD_PREFERENCE_ITEM_CONFIRM_DELETE_CATEGORY_ALERT_TAG){
        if(buttonIndex == 0){
            [self deleteSelectedCategory];
        }
    }
    else if(alertView.tag == MANAPP_ADD_PREFERENCE_ITEM_CONFIRM_RESTORE_CATEGORY_ALERT_TAG){
        if(buttonIndex == 0){
            [self restoreDefaultCategories];
        }
    }
}

- (void) backToHome {
    [self popToView:[HomepageViewController class]];
}


@end
