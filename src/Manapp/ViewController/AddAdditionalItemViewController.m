//
//  AddAdditionalItemViewController.m
//  Manapp
//
//  Created by Demigod on 22/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "AddAdditionalItemViewController.h"
#import "HomepageViewController.h"
#import "Partner.h"
#import "PartnerInformationItem.h"
#import "PartnerInformation.h"
#import "UIPlaceHolderTextView.h"
#import "UIView+Additions.h"
#import "NSString+Additional.h"
#import "DatabaseHelper.h"
#import "MASession.h"
#import "MAUserProcessManager.h"
#import "UIView+Additions.h"
#import "UITextField+Additional.h"
#import "NSArray+Additions.h"
#import "UIButton+Additions.h"

@interface AddAdditionalItemViewController ()
- (void) initialize;

- (void) loadUI;
- (void) reloadUI;
- (void) loadData;

- (void)deleteItem:(id)sender;
- (void)deleteCategory:(id)sender;
- (void)saveItemClicked:(id)sender;

- (void) fillViewWithInformation:(PartnerInformationItem*) information;

- (PartnerInformation *) addNewCategory:(NSString *) category forParent:(PartnerInformation *) parentCategory;

- (void) deleteSelectedCategory;

- (void) toggleDeleteState:(BOOL) state;
- (void) backToHome;
@end

@implementation AddAdditionalItemViewController
@synthesize backgroundScrollView = _backgroundScrollView;
@synthesize textViewContent = _textViewContent;
@synthesize btnDelete = _btnDelete;
@synthesize informationItem = _informationItem;
@synthesize partnerInformation = _partnerInformation;

- (void)dealloc {
    [_backgroundScrollView release];
    [_textViewContent release];
    [_btnDelete release];
    [_informationItem release];
    [_partnerInformation release];
    [_lblTitle release];
    [_lblCatalogue release];
    [_lblDetail release];
    [_btnBackground release];
    [_txtCategory release];
    [_txtSubCategory release];
    [_lblSubCategory release];
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
    _deleteState = NO;
}

#pragma mark - UI functions
- (void) loadUI{
    //add gesture
    [self addSwipeBackGesture];
    
    //navigation bar and its items
    [self setNavigationBarHidden:YES animated:NO];
    
    // check if partnerInformationItems == 0 => click button cancel will back homepage
    if([[MASession sharedSession] currentPartner]){
        NSArray *partnerInformationItems = [[DatabaseHelper sharedHelper] getAllItemInformationForPartner:[[MASession sharedSession] currentPartner]];        
        SEL action = @selector(back);
        if([partnerInformationItems count] == 0){
            action = @selector(backToHome);
        }
        [self createBackNavigationWithTitle:MA_CANCEL_BUTTON_TEXT action:action];
    }
    [self createRightNavigationWithTitle:MA_SAVE_BUTTON_TEXT action:@selector(saveItemClicked:)];
    
    [self moveNavigationButtonsToView:self.backgroundScrollView];
    
    [self.txtCategory paddingLeftByValue:5];
    [self.txtSubCategory paddingLeftByValue:5];
    
    //change font
    [self.lblTitle setFont:[UIFont fontWithName:kAppFont size:16]];
    [self.lblCatalogue setFont:[UIFont fontWithName:kAppFont size:14]];
    [self.lblSubCategory setFont:[UIFont fontWithName:kAppFont size:14]];
    [self.lblDetail setFont:[UIFont fontWithName:kAppFont size:14]];
    
    [self.btnDelete.titleLabel setFont:[UIFont fontWithName:kAppFont size:16]];
    
    [self.txtCategory setFont:[UIFont fontWithName:kAppFont size:12]];
    [self.txtSubCategory setFont:[UIFont fontWithName:kAppFont size:12]];
    [self.textViewContent setFont:[UIFont fontWithName:kAppFont size:13]];
    //set the text view graphics
    [self.textViewContent makeBorderWithWidth:1.0f andColor:[UIColor lightGrayColor]];
    [self.textViewContent makeRoundCorner:5.0f];
    self.textViewContent.placeholder = LSSTRING(@"Enter Additional Information Here...");
    
    //set the scrollview
    self.backgroundScrollView.contentSize = self.view.bounds.size;
    
    if(self.currentInformation){
        self.txtCategory.text = self.currentInformation.name;
    }

    if(self.currentSubInformation){
        self.txtSubCategory.text = self.currentSubInformation.name;
    }
    
    //if the measurementItem is nil, it mean we are in the creation state
    if (!self.informationItem) {
        // Add new information
        self.lblTitle.text = LSSTRING(@"Add additional Info");
    }
    //if the measurement item isn't nil, it mean we are in the editional state
    else {
        // fill the information to the form
        self.lblTitle.text = LSSTRING(@"Edit additional Info");
        [self fillViewWithInformation:self.informationItem];
    }
}

-(void) reloadUI{
    self.txtCategory.text = self.currentInformation.name;
    self.txtSubCategory.text = self.currentSubInformation.name;
    
    if(self.pickerCategory){
        [self.pickerCategory reloadAllComponents];
    }
    if(self.pickerSubCategory){
        [self.pickerSubCategory reloadAllComponents];
    }
}

//load the data
- (void) loadData{
    
    //load preference list
    if([[MASession sharedSession] currentPartner]){
        self.partnerInformation = [[DatabaseHelper sharedHelper] getAllPartnerInformationAtLevel:1 ForPartner:[[MASession sharedSession] currentPartner] parentCategory:nil];
        if([self.partnerInformation count] > 0)
        {
            self.subPartnerInformation = [[DatabaseHelper sharedHelper] getAllPartnerInformationAtLevel:2 ForPartner:[[MASession sharedSession] currentPartner] parentCategory:[self.partnerInformation objectAtIndex:0]];
        }
        else{
            _subPartnerInformation = [[NSArray alloc] init];
        }
    }
    else{
        _partnerInformation = [[NSArray alloc] init];
        _subPartnerInformation = [[NSArray alloc] init];
    }
    
    if(self.partnerInformation){
        self.currentInformation = [self.partnerInformation firstObject];
    }
    
    if(self.subPartnerInformation){
        self.currentSubInformation = [self.subPartnerInformation firstObject];
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
        UIButton *deleteDetailButton = (UIButton *)[self.view viewWithTag:MANAPP_ADD_INFORMATION_ITEM_DELETEBUTTON_INFORMATION_DETAIL_TAG];
        UIButton *deleteCategoryButton = (UIButton *)[self.view viewWithTag:MANAPP_ADD_INFORMATION_ITEM_DELETEBUTTON_INFORMATION_CATEGORY_TAG];
        
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
        UIButton *deleteDetailButton = (UIButton *)[self.view viewWithTag:MANAPP_ADD_INFORMATION_ITEM_DELETEBUTTON_INFORMATION_DETAIL_TAG];
        UIButton *deleteCategoryButton = (UIButton *)[self.view viewWithTag:MANAPP_ADD_INFORMATION_ITEM_DELETEBUTTON_INFORMATION_CATEGORY_TAG];
        
        //create the button if not existed
        if(deleteDetailButton == nil)
        {
            deleteDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
            deleteDetailButton.tag = MANAPP_ADD_INFORMATION_ITEM_DELETEBUTTON_INFORMATION_DETAIL_TAG;
            [deleteDetailButton setImage:[UIImage imageNamed:@"deleteicon"] forState:UIControlStateNormal];
            [deleteDetailButton setImage:[UIImage imageNamed:@"deleteicon"] forState:UIControlStateHighlighted];
            [deleteDetailButton addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
            
            deleteDetailButton.frame = CGRectMake(self.textViewContent.frame.origin.x + self.textViewContent.frame.size.width + MANAPP_ADD_INFORMATION_ITEM_TEXT_VIEW_RESIZE_DISTANCE, self.textViewContent.frame.origin.y + self.textViewContent.frame.size.height/2 - 7, 18, 15);
            [self.view addSubview:deleteDetailButton];
            [self.view bringSubviewToFront:deleteDetailButton];
        }
        
        if(deleteCategoryButton == nil)
        {
            deleteCategoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
            deleteCategoryButton.tag = MANAPP_ADD_INFORMATION_ITEM_DELETEBUTTON_INFORMATION_CATEGORY_TAG;
            [deleteCategoryButton setImage:[UIImage imageNamed:@"deleteicon"] forState:UIControlStateNormal];
            [deleteCategoryButton setImage:[UIImage imageNamed:@"deleteicon"] forState:UIControlStateHighlighted];
            [deleteCategoryButton addTarget:self action:@selector(deleteCategory:) forControlEvents:UIControlEventTouchUpInside];
            
            deleteCategoryButton.frame = CGRectMake(self.txtSubCategory.frame.origin.x + self.txtSubCategory.frame.size.width + MANAPP_ADD_INFORMATION_ITEM_TEXT_VIEW_RESIZE_DISTANCE, self.txtSubCategory.frame.origin.y + self.txtSubCategory.frame.size.height/2 - 7, 18, 15);
            [self.view addSubview:deleteCategoryButton];
            [self.view bringSubviewToFront:deleteCategoryButton];
        }
    }
}

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
        [self resizeScrollView:self.backgroundScrollView withView:self.pickerCategory viewState:NO];
        [self.btnBackground setSize:self.backgroundScrollView.contentSize];
    }
    
    if([self.pickerSubCategory.superview isEqual: self.view]){
        [self hideModalView:self.pickerSubCategory direction:MAModalViewDirectionBottom autoAddSubView:YES];
        [self resizeScrollView:self.backgroundScrollView withView:self.pickerSubCategory viewState:NO];
        [self.btnBackground setSize:self.backgroundScrollView.contentSize];
    }
}

#pragma mark - data handler
//fll the view with information
- (void) fillViewWithInformation:(PartnerInformationItem*) information{
    if(information){
        self.textViewContent.text = information.name;
        self.currentInformation = information.information.parentCategory;
        self.currentSubInformation = information.information;
        [self reloadUI];
    }
    //if the information is nil, reset the view
    else{
        self.textViewContent.text = @"";
        self.currentInformation = nil;
        self.currentSubInformation = nil;
        [self reloadUI];
    }
}

//add category to database
- (PartnerInformation *)addNewCategory:(NSString *)category forParent:(PartnerInformation *) parentCategory{
    //get current parent category
    if([category isEqualToString:@""])
    {
        [self showMessage:@"Category name cannot be blank!"];
        return FALSE;
    }
    else{
        //check if these is any duplicate measurement
        NSArray *sameNameCategories = [[DatabaseHelper sharedHelper] getPartnerInformationAtLevel:2 withName:category forPartner:[[MASession sharedSession] currentPartner] parentCategory:parentCategory];
        if(sameNameCategories.count > 0){
            [self showMessage:@"A category with the same name exists"];
            return nil;
        }
        
        // add new category and reload the picker
        PartnerInformation* newCategory = [[DatabaseHelper sharedHelper] addNewInformationCategoryForCategory:parentCategory withName:category];
        if(newCategory){
            [self showMessage:@"Add new category successfully!"];
            
            //reload UI
            self.subPartnerInformation = [[DatabaseHelper sharedHelper] getAllPartnerInformationAtLevel:2 ForPartner:[[MASession sharedSession] currentPartner] parentCategory:parentCategory];
            self.currentSubInformation = newCategory;
            [self reloadUI];
            
            return newCategory;
        }
        else{
            [self showMessage:@"Fail to add new category!"];
            return nil;
        }
    }
}

//delete the current category which is selected by picker
- (void) deleteSelectedCategory{
    if (self.currentSubInformation) {
        [[DatabaseHelper sharedHelper] deleteManagedObject:self.currentSubInformation];
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
        NSInteger noOfRestore = [[DatabaseHelper sharedHelper] restoreDefaultInformationCategoryForPartner:[[MASession sharedSession] currentPartner]];
        [self showMessage:[NSString stringWithFormat:@"%d categories restored",noOfRestore]];
        
        //reload UI
        self.subPartnerInformation = [[DatabaseHelper sharedHelper] getAllPartnerInformationAtLevel:2 ForPartner:[[MASession sharedSession] currentPartner] parentCategory:self.currentInformation];
        [self reloadUI];
    }
}

#pragma mark -event handler
- (IBAction)btnDelete_touchUpInside:(id)sender {
    //hide the keyboard
    [self.textViewContent resignFirstResponder];
    
    [self toggleDeleteState:!_deleteState];
}

//click delete item button (delete the current item)
- (void)deleteItem:(id)sender{
    if (self.informationItem) {
        [[DatabaseHelper sharedHelper] deleteManagedObject:self.informationItem];
        [self showMessage:@"Information Deleted"];
        [self back];
    } else {
        self.textViewContent.text = @"";
        [self toggleDeleteState:!_deleteState];
    }
}

//click delete category button
- (void)deleteCategory:(id)sender{
    //confirm to make sure we want to delete category
    
    //confirm to make sure we want to delete category
    if (self.currentInformation) {
        [self showMessage:[NSString stringWithFormat:LSSTRING(@"ou are about to delete the %@ Category and any saved data within it from your app"),self.currentSubInformation.name] title:kAppName cancelButtonTitle:LSSTRING(@"Delete all") otherButtonTitle:@"Cancel" delegate:self tag:MANAPP_ADD_INFORMATION_ITEM_CONFIRM_DELETE_CATEGORY_ALERT_TAG];
    }
    else{
        [self showMessage:@"Cannot delete this category!"];
    }
    
}

//save click (on navigation bar)
- (void)saveItemClicked:(id)sender{
    [self.textViewContent resignFirstResponder];
    
    if (self.textViewContent.text.length == 0) {
        [self showErrorMessage:@"You can't save what's not there."];
        return;
    }
    
    if(!self.currentSubInformation){
        [self showErrorMessage:@"Please select a catagory for this item."];
        return;
    }
    
    //in case we edit an exited one
    if (self.informationItem) {
        self.informationItem.information = self.currentSubInformation;
        self.informationItem.name = self.textViewContent.text;
    }
    //create a new one
    else {
        _informationItem = (id)[[DatabaseHelper sharedHelper] newManagedObjectForEntity:@"PartnerInformationItem"];
        self.informationItem.itemID = [NSString generateGUID];
        self.informationItem.name = self.textViewContent.text;
        self.informationItem.information = self.currentSubInformation;
        self.informationItem.timestamp = [NSDate date];
    }
    [[DatabaseHelper sharedHelper] saveContext];
    [self showMessage:@"Successfully Saved" title:kAppName cancelButtonTitle:@"OK" otherButtonTitle:nil delegate:self tag:MANAPP_ADD_INFORMATION_ITEM_SUCCESSFULLY_CREATION_ALERT_TAG];
}

#pragma mark - custom picker view

-(NSInteger)numberOfComponentsInCustomPickerView:(CustomPickerView *)pickerView{
    return 1;
}

-(NSInteger)customPickerView:(CustomPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if([pickerView isEqual:self.pickerCategory])
    {
        return self.partnerInformation.count;
    }
    else{
        // +2 to "Add new category" item and "Restore default categories"
        return self.subPartnerInformation.count + 2;
    }
}

-(NSString *)customPickerView:(CustomPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    //last row is the add new category item
    
    if([pickerView isEqual:self.pickerCategory])
    {
        PartnerInformation *pInformation = [self.partnerInformation objectAtIndex:row];
        return pInformation.name;
    }
    else{
        // add new category item
        if(row == self.subPartnerInformation.count + 1)
        {
            return LSSTRING(@"Add new category");
        }
        else if(row == self.subPartnerInformation.count)
        {
            return LSSTRING(@"Restore Default Categories");
        }
        else{
            PartnerInformation *pInformation = [self.subPartnerInformation objectAtIndex:row];
            return pInformation.name;
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
        PartnerInformation *information = [self.partnerInformation objectAtIndex:row];
        self.currentInformation = information;
        
        self.subPartnerInformation = [[DatabaseHelper sharedHelper] getAllPartnerInformationAtLevel:2 ForPartner:[[MASession sharedSession] currentPartner] parentCategory:information];
        if(self.subPartnerInformation.count > 0){
            self.currentSubInformation = (PartnerInformation *)[self.subPartnerInformation firstObject];
        }
        
        [self.pickerSubCategory reloadAllComponents];
        [self reloadUI];
    }
    else{
        // add new category item was selected
        if(row == self.subPartnerInformation.count + 1)
        {
            // show the alertview with textfield
            [self showMessageWithTextInput:@"Please select a name for your new category." title:kAppName cancelButtonTitle:@"Cancel" otherButtonTitle:@"Add Category" delegate:self tag:MANAPP_ADD_INFORMATION_ITEM_NEW_CATEGORY_ALERT_TAG];
        }
        else if(row == (self.subPartnerInformation.count))
        {
            // COMMENT: show the alertview with textfield
            
            [self showMessage:@"Are you sure you want to restore all the default preference categories?" title:kAppName cancelButtonTitle:@"OK" otherButtonTitle:@"Cancel" delegate:self tag:MANAPP_ADD_INFORMATION_ITEM_CONFIRM_RESTORE_CATEGORY_ALERT_TAG];
        }
        else{
            PartnerInformation *information = [self.subPartnerInformation objectAtIndex:row];
            self.currentSubInformation = information;
            [self reloadUI];
        }
    }
    
    //resign the textfield and picker
    [self resignAllPicker];
}

-(void)didClickCancelInCustomPickerView:(CustomPickerView *)pickerView{
    [self resignAllPicker];
}

#pragma mark - UITextViewDelegate

-(void)keyboardWillShow:(NSNotification *)notification{
    [super keyboardWillShow:notification];
    
    [self resizeScrollView:self.backgroundScrollView withKeyboardState:TRUE willChangeOffset:NO];
    [self.btnBackground setSize:self.backgroundScrollView.contentSize];
}

-(void)keyboardWillHide{
    [super keyboardWillHide];
    
    [self resizeScrollView:self.backgroundScrollView withKeyboardState:FALSE willChangeOffset:NO];
    [self.btnBackground setSize:self.backgroundScrollView.contentSize];
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    [self resignAllTextField];
    [self toggleDeleteState:NO];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
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
            
            [self.pickerCategory selectRow:[self.partnerInformation indexOfObject:self.currentInformation] inComponent:0 animated:YES];
            
            [self showModalView:self.pickerCategory direction:MAModalViewDirectionBottom autoAddSubView:YES];
            [self resizeScrollView:self.backgroundScrollView withView:self.pickerCategory viewState:YES];
            [self.btnBackground setSize:self.backgroundScrollView.contentSize];
            return NO;
        }
    }
    else if([textField isEqual:self.txtSubCategory]){
        if([self.view.subviews containsObject:self.pickerSubCategory]){
            return NO;
        }
        else{
            [self resignAllTextField];
            
            if(!self.pickerSubCategory){
                self.pickerSubCategory = (CustomPickerView *)[Util getView:[CustomPickerView class]];
                self.pickerSubCategory.delegate = self;
            }
            
            [self.pickerSubCategory selectRow:[self.subPartnerInformation indexOfObject:self.currentSubInformation] inComponent:0 animated:YES];
            
            [self showModalView:self.pickerSubCategory direction:MAModalViewDirectionBottom autoAddSubView:YES];
            [self resizeScrollView:self.backgroundScrollView withView:self.pickerSubCategory viewState:YES];
            [self.btnBackground setSize:self.backgroundScrollView.contentSize];
            return NO;
        }
    }
    else{
        [self resignAllTextField];
        return YES;
    }
    return YES;
}


#pragma mark - alertview delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // add new category alertview
    if(alertView.tag == MANAPP_ADD_INFORMATION_ITEM_NEW_CATEGORY_ALERT_TAG){
        // add button clicked
        if(buttonIndex == 1)
        {
            UITextField *newCategoryTextField = [alertView textFieldAtIndex:0];
            
            PartnerInformation *parentCategory = self.currentInformation;
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
    else if(alertView.tag == MANAPP_ADD_INFORMATION_ITEM_SUCCESSFULLY_CREATION_ALERT_TAG){
        [self back];
    }
    //delete category if user select yes
    else if(alertView.tag == MANAPP_ADD_INFORMATION_ITEM_CONFIRM_DELETE_CATEGORY_ALERT_TAG){
        if(buttonIndex == 0){
            [self deleteSelectedCategory];
        }
    }
    else if(alertView.tag == MANAPP_ADD_INFORMATION_ITEM_CONFIRM_RESTORE_CATEGORY_ALERT_TAG){
        if(buttonIndex == 0){
            [self restoreDefaultCategories];
        }
    }
}

- (void) backToHome {
    [self popToView:[HomepageViewController class]];
}

- (void)viewDidUnload {
    [self setTxtSubCategory:nil];
    [self setLblSubCategory:nil];
    [super viewDidUnload];
}
@end
