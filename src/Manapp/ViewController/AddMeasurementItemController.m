//
//  AddMeasurementItemController.m
//  Manapp
//
//  Created by Demigod on 23/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "AddMeasurementItemController.h"
#import "HomepageViewController.h"
#import "Partner.h"
#import "PartnerMeasurement.h"
#import "PartnerMeasurementItem.h"
#import "UIPlaceHolderTextView.h"
#import "UIView+Additions.h"
#import "NSString+Additional.h"
#import "DatabaseHelper.h"
#import "MASession.h"
#import "MAUserProcessManager.h"
#import "UITextField+Additional.h"
#import "UIButton+Additions.h"
#import "NSArray+Additions.h"

@interface AddMeasurementItemController ()
- (void) initialize;

- (void) loadUI;
- (void) reloadUI;
- (void) loadData;

- (void)deleteItem:(id)sender;
- (void)deleteCategory:(id)sender;
- (void)saveItemClicked:(id)sender;

- (void) fillViewWithInformation:(PartnerMeasurementItem*) information;

- (PartnerMeasurement *) addNewCategory:(NSString *) category;

- (void) deleteSelectedCategory;

- (void) toggleDeleteState:(BOOL) state;

- (void) backToHome;
@end

@implementation AddMeasurementItemController
@synthesize measurementItem = _measurementItem;
@synthesize partnerMeasurements = _partnerMeasurements;
@synthesize scrollViewBackground = _scrollViewBackground;
@synthesize textViewContent = _textViewContent;
@synthesize btnDelete = _btnDelete;

- (void)dealloc {
    [_scrollViewBackground release];
    [_textViewContent release];
    [_btnDelete release];
    [_measurementItem release];
    [_partnerMeasurements release];
    [_lblTitle release];
    [_lblDetail release];
    [_lblCatalogue release];
    [_btnBackground release];
    [_txtCategory release];
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
-(void)initialize {
    _deleteState = NO;
}

#pragma mark - UI functions
- (void) loadUI { 
    //add gesture
    [self addSwipeBackGesture];
    
    //navigation bar and its items
    [self setNavigationBarHidden:YES animated:NO];
    
    // check if partnerMeasurementItems == 0 => click button cancel will back homepage
    if([[MASession sharedSession] currentPartner]){
        NSArray *partnerMeasurementItems = [[DatabaseHelper sharedHelper] getAllItemMeasurementForPartner:[[MASession sharedSession] currentPartner]];
        SEL action = @selector(back);
        if([partnerMeasurementItems count] == 0){
            action = @selector(backToHome);
        }
        [self createBackNavigationWithTitle:MA_CANCEL_BUTTON_TEXT action:action];
    }
    
    
    [self createRightNavigationWithTitle:MA_SAVE_BUTTON_TEXT action:@selector(saveItemClicked:)];
    
    [self moveNavigationButtonsToView:self.scrollViewBackground];
    
    [self.txtCategory paddingLeftByValue:5];
    
    //change font
    [self.lblTitle setFont:[UIFont fontWithName:kAppFont size:16]];
    [self.lblCatalogue setFont:[UIFont fontWithName:kAppFont size:14]];
    [self.lblDetail setFont:[UIFont fontWithName:kAppFont size:14]];
    
    [self.btnDelete.titleLabel setFont:[UIFont fontWithName:kAppFont size:16]];
    
    [self.txtCategory setFont:[UIFont fontWithName:kAppFont size:12]];
    [self.textViewContent setFont:[UIFont fontWithName:kAppFont size:13]];
    //set the text view graphics
    [self.textViewContent makeBorderWithWidth:1.0f andColor:[UIColor lightGrayColor]];
    [self.textViewContent makeRoundCorner:5.0f];
    self.textViewContent.placeholder = @"Enter measurement data here...";
    
    //set the scrollview
    self.scrollViewBackground.contentSize = self.view.bounds.size;
    
    if(self.currentMeasurement){
        self.txtCategory.text = self.currentMeasurement.name;
    }
    
    //if the measurementItem is nil, it mean we are in the creation state
    if (!self.measurementItem) {
        // Add new information
        self.lblTitle.text = @"Add Size/Measurement";
    }
    //if the measurement item isn't nil, it mean we are in the editional state
    else {
        // fill the information to the form
        self.lblTitle.text = @"Edit Size/Measurement";
        [self fillViewWithInformation:self.measurementItem];
    }
}

-(void) reloadUI{
    self.txtCategory.text = self.currentMeasurement.name;
    if(self.pickerCategory){
        [self.pickerCategory reloadAllComponents];
    }
}

//load the data
- (void) loadData{
    //load preference list
    if([[MASession sharedSession] currentPartner]){
        self.partnerMeasurements = [[DatabaseHelper sharedHelper] getAllPartnerMeasurementForPartner:[[MASession sharedSession] currentPartner]];
        if([[MASession sharedSession] currentPartner].sex.boolValue == MANAPP_SEX_MALE) {
            for (PartnerMeasurement *partnerMea in self.partnerMeasurements) {
                DLogInfo(@"partnerMea.name: %@",partnerMea.name);
                if (partnerMea.name && [partnerMea.name isEqualToString:@"Panty"]) {
                    [self.partnerMeasurements removeObject:partnerMea];
                    break;
                }
            }
        }
    }
    else{
        _partnerMeasurements = [NSMutableArray array];
    }
    
    if(self.partnerMeasurements){
        self.currentMeasurement = [self.partnerMeasurements firstObject];
    }
}

#pragma mark - private function
//toggle between the delete states
- (void) toggleDeleteState:(BOOL) state{
    _deleteState = state;
    if(!state){
        //change the delete button's label
        [self.btnDelete changeTitle:@"Delete"];
        
        // animation to resize the text view and hide the delete button
        //remove the delete buttons from view
        UIButton *deleteDetailButton = (UIButton *)[self.view viewWithTag:MANAPP_ADD_MEASUREMENT_ITEM_DELETEBUTTON_INFORMATION_DETAIL_TAG];
        UIButton *deleteCategoryButton = (UIButton *)[self.view viewWithTag:MANAPP_ADD_MEASUREMENT_ITEM_DELETEBUTTON_INFORMATION_CATEGORY_TAG];
        
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
        UIButton *deleteDetailButton = (UIButton *)[self.view viewWithTag:MANAPP_ADD_MEASUREMENT_ITEM_DELETEBUTTON_INFORMATION_DETAIL_TAG];
        UIButton *deleteCategoryButton = (UIButton *)[self.view viewWithTag:MANAPP_ADD_MEASUREMENT_ITEM_DELETEBUTTON_INFORMATION_CATEGORY_TAG];
        
        //create the button if not existed
        if(deleteDetailButton == nil)
        {
            deleteDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
            deleteDetailButton.tag = MANAPP_ADD_MEASUREMENT_ITEM_DELETEBUTTON_INFORMATION_DETAIL_TAG;
            [deleteDetailButton setImage:[UIImage imageNamed:@"deleteicon"] forState:UIControlStateNormal];
            [deleteDetailButton setImage:[UIImage imageNamed:@"deleteicon"] forState:UIControlStateHighlighted];
            [deleteDetailButton addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
            
            deleteDetailButton.frame = CGRectMake(self.textViewContent.frame.origin.x + self.textViewContent.frame.size.width + MANAPP_ADD_MEASUREMENT_ITEM_TEXT_VIEW_RESIZE_DISTANCE, self.textViewContent.frame.origin.y + self.textViewContent.frame.size.height/2 - 7, 18, 15);
            [self.view addSubview:deleteDetailButton];
            [self.view bringSubviewToFront:deleteDetailButton];
        }
        
        if(deleteCategoryButton == nil)
        {
            deleteCategoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
            deleteCategoryButton.tag = MANAPP_ADD_MEASUREMENT_ITEM_DELETEBUTTON_INFORMATION_CATEGORY_TAG;
            [deleteCategoryButton setImage:[UIImage imageNamed:@"deleteicon"] forState:UIControlStateNormal];
            [deleteCategoryButton setImage:[UIImage imageNamed:@"deleteicon"] forState:UIControlStateHighlighted];
            [deleteCategoryButton addTarget:self action:@selector(deleteCategory:) forControlEvents:UIControlEventTouchUpInside];
            
            deleteCategoryButton.frame = CGRectMake(self.txtCategory.frame.origin.x + self.txtCategory.frame.size.width + MANAPP_ADD_MEASUREMENT_ITEM_TEXT_VIEW_RESIZE_DISTANCE, self.txtCategory.frame.origin.y + self.txtCategory.frame.size.height/2 - 7, 18, 15);
            [self.view addSubview:deleteCategoryButton];
            [self.view bringSubviewToFront:deleteCategoryButton];
        }
    }
}

-(void)resignAllTextField {
    // error on ios7
//    [self.textViewContent resignFirstResponder];
    [self.txtCategory resignFirstResponder];
    [self resignAllPicker];
}

- (void) resignAllPicker{
    if([self.pickerCategory.superview isEqual: self.view]){
        [self hideModalView:self.pickerCategory direction:MAModalViewDirectionBottom autoAddSubView:YES];
        [self resizeScrollView:self.scrollViewBackground withView:self.pickerCategory viewState:NO];
        [self.btnBackground setSize:self.scrollViewBackground.contentSize];
    }
}

#pragma mark - data handler
//fll the view with information
- (void) fillViewWithInformation:(PartnerMeasurementItem*) information{
    if(information){
        self.textViewContent.text = information.name;
        self.currentMeasurement = information.measurement;
        [self reloadUI];
    }
    //if the information is nil, reset the view
    else{
        self.textViewContent.text = @"";
        self.currentMeasurement = nil;
        [self reloadUI];
    }
}

//add category to database
- (PartnerMeasurement *) addNewCategory:(NSString *) category{
    //get current parent category
    if([category isEqualToString:@""])
    {
        [self showMessage:@"Category name cannot be blank!"];
        return nil;
    }
    else{
        //check if these is any duplicate measurement
        NSArray *sameNameCategories = [[DatabaseHelper sharedHelper] getPartnerMeasurementsWithName:category forPartner:[[MASession sharedSession] currentPartner]];
        if(sameNameCategories.count > 0){
            [self showMessage:@"A category with the same name exists"];
            return nil;
        }
        
        // add new category and reload the picker
        PartnerMeasurement * newMeasurement = [[DatabaseHelper sharedHelper] addNewMeasurementCategoryForPartner:[[MASession sharedSession] currentPartner] withName:category forSex:[[MASession sharedSession] currentPartner].sex.integerValue];
        if(newMeasurement){
            [self showMessage:@"Add new category successfully!"];
            
            //reload the UI
            if(newMeasurement){
                //reload
                self.partnerMeasurements = [[DatabaseHelper sharedHelper] getAllPartnerMeasurementForPartner:[[MASession sharedSession] currentPartner]];
                self.currentMeasurement = newMeasurement;
                [self reloadUI];
            }
            
            return newMeasurement;
        }
        else{
            [self showMessage:@"Fail to add new category!"];
            return nil;
        }
    }
}

//delete the current category which is selected by picker
- (void) deleteSelectedCategory{
    if (self.currentMeasurement) {
        [[DatabaseHelper sharedHelper] deleteManagedObject:self.currentMeasurement];
        [self showMessage:@"Category Deleted"];
        [self back];
    }
    else{
        [self showMessage:@"Cannot delete this category!"];
    }
}

//restore all default categories that were deleted
- (void) restoreDefaultCategories{
    if([[MASession sharedSession] currentPartner]){
        NSInteger noOfRestore = [[DatabaseHelper sharedHelper] restoreDefaultMeasurementCategoryForPartner:[[MASession sharedSession] currentPartner]];
        [self showMessage:[NSString stringWithFormat:@"%d categories restored",noOfRestore]];
        
        self.partnerMeasurements = [[DatabaseHelper sharedHelper] getAllPartnerMeasurementForPartner:[[MASession sharedSession] currentPartner]];
        [self reloadUI];
    }
}

#pragma mark - event handler
- (IBAction)btnDelete_touchUpInside:(id)sender {
    //hide the keyboard
    [self.textViewContent resignFirstResponder];
    
    [self toggleDeleteState:!_deleteState];
}

//click delete item button (delete the current item)
- (void)deleteItem:(id)sender{
    if (self.measurementItem) {
        [[DatabaseHelper sharedHelper] deleteManagedObject:self.measurementItem];
        [self showMessage:@"Measurement Deleted"];
        [self back];
    }
    else{
        self.textViewContent.text = @"";
        [self toggleDeleteState:!_deleteState];
    }
    
}

//click delete category button
- (void)deleteCategory:(id)sender{
    //confirm to make sure we want to delete category
    
    //confirm to make sure we want to delete category
    if (self.currentMeasurement) {
        [self showMessage:[NSString stringWithFormat:Translate(@"You are about to delete the %@ Category and any saved data within it from your app"),self.currentMeasurement.name] title:kAppName cancelButtonTitle:@"Delete all" otherButtonTitle:@"Cancel" delegate:self tag:MANAPP_ADD_MEASUREMENT_ITEM_CONFIRM_DELETE_CATEGORY_ALERT_TAG];
    }
    else{
        [self showMessage:@"Cannot delete this category!"];
    }
    
}

//save click (on navigation bar)
- (void)saveItemClicked:(id)sender{
    [self.textViewContent resignFirstResponder];
    
    //cannot add empty item
    if (self.textViewContent.text.length == 0) {
        [self showErrorMessage:@"You can't save what's not there."];
        return;
    }
    
    if(self.currentMeasurement)
    {
        if (self.measurementItem) {
            self.measurementItem.measurement = self.currentMeasurement;
            self.measurementItem.name = self.textViewContent.text;
        } else {
            _measurementItem = (id)[[DatabaseHelper sharedHelper] newManagedObjectForEntity:@"PartnerMeasurementItem"];
            self.measurementItem.itemID = [NSString generateGUID];
            self.measurementItem.name = self.textViewContent.text;
            self.measurementItem.measurement = self.currentMeasurement;
            self.measurementItem.timestamp = [NSDate date];
        }
        [[DatabaseHelper sharedHelper] saveContext];
        
        [self showMessage:@"Successfully Saved" title:kAppName cancelButtonTitle:@"OK" otherButtonTitle:nil delegate:self tag:MANAPP_ADD_MEASUREMENT_ITEM_SUCCESSFULLY_CREATION_ALERT_TAG];
    }
    else{
        [self showMessage:@"Cannot save measurement!"];
    }
}

#pragma mark - custom picker view
-(NSInteger)numberOfComponentsInCustomPickerView:(CustomPickerView *)pickerView{
    return 1;
}

-(NSInteger)customPickerView:(CustomPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    //additional items : restore and add new 
    return self.partnerMeasurements.count + 2;
}

-(NSString *)customPickerView:(CustomPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    //last row is the add new category item
    if(row == self.partnerMeasurements.count + 1)
    {
        return LSSTRING(@"Add new category");
    }
    //second last row is the restore category
    else if(row == (self.partnerMeasurements.count))
    {
        return LSSTRING(@"Restore Default Categories");
    }
    
    PartnerMeasurement *pMeasurement = [self.partnerMeasurements objectAtIndex:row];
    return pMeasurement.name;
}

-(void)customPickerView:(CustomPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{

}

-(void)didClickDoneInCustomPickerView:(CustomPickerView *)pickerView{
    NSInteger row = [pickerView.pickerView selectedRowInComponent:0];
    if(row == self.partnerMeasurements.count + 1)
    {
        // COMMENT: show the alertview with textfield
        [self showMessageWithTextInput:@"Please select a name for your new category." title:kAppName cancelButtonTitle:@"Cancel" otherButtonTitle:@"Add Measurement" delegate:self tag:MANAPP_ADD_MEASUREMENT_ITEM_NEW_CATEGORY_ALERT_TAG];
    }
    else if(row == (self.partnerMeasurements.count))
    {
        // COMMENT: show the alertview with textfield
        
        [self showMessage:@"Are you sure you want to restore all the default measurement categories?" title:kAppName cancelButtonTitle:@"OK" otherButtonTitle:@"Cancel" delegate:self tag:MANAPP_ADD_MEASUREMENT_ITEM_CONFIRM_RESTORE_CATEGORY_ALERT_TAG];
    }
    else{
        self.currentMeasurement = [self.partnerMeasurements objectAtIndex:row];
        [self reloadUI];
    }
    
    //resign the picker
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

-(void)textViewDidBeginEditing:(UITextView *)textView{
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
            
            [self.pickerCategory selectRow:[self.partnerMeasurements indexOfObject:self.currentMeasurement] inComponent:0 animated:YES];
            
            [self showModalView:self.pickerCategory direction:MAModalViewDirectionBottom autoAddSubView:YES];
            [self resizeScrollView:self.scrollViewBackground withView:self.pickerCategory viewState:YES];
            [self.btnBackground setSize:self.scrollViewBackground.contentSize];
            return NO;
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
    // Any new character added is passed in as the "text" parameter
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
    if(alertView.tag == MANAPP_ADD_MEASUREMENT_ITEM_NEW_CATEGORY_ALERT_TAG){
        // add button clicked
        if(buttonIndex == 1)
        {
            UITextField *newCategoryTextField = [alertView textFieldAtIndex:0];
            if(newCategoryTextField.text && ![newCategoryTextField.text isEqualToString:@""]){
                [self addNewCategory:newCategoryTextField.text];
            }
            else{
                [self showMessage:@"Category name cannot be blank."];
                [self resignAllPicker];
                [self resignAllTextField];
            }
        }
    }
    //after save, return to the previous view
    else if(alertView.tag == MANAPP_ADD_MEASUREMENT_ITEM_SUCCESSFULLY_CREATION_ALERT_TAG){
        [self back];
    }
    //delete category if user select yes
    else if(alertView.tag == MANAPP_ADD_MEASUREMENT_ITEM_CONFIRM_DELETE_CATEGORY_ALERT_TAG){
        if(buttonIndex == 0){
            [self deleteSelectedCategory];
        }
    }
    else if(alertView.tag == MANAPP_ADD_MEASUREMENT_ITEM_CONFIRM_RESTORE_CATEGORY_ALERT_TAG){
        if(buttonIndex == 0){
            [self restoreDefaultCategories];
        }
    }
}

- (void) backToHome {
    [self popToView:[HomepageViewController class]];
}

@end
