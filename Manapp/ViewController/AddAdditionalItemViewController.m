//
//  AddAdditionalItemViewController.m
//  Manapp
//
//  Created by Demigod on 22/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "AddAdditionalItemViewController.h"
#import "Partner.h"
#import "PartnerInformationItem.h"
#import "PartnerInformation.h"
#import "UIPlaceHolderTextView.h"
#import "UIView+Additions.h"
#import "NSString+Additional.h"
#import "DatabaseHelper.h"
#import "MASession.h"

@interface AddAdditionalItemViewController ()
- (void) initialize;

- (void)deleteItem:(id)sender;
- (void)deleteCategory:(id)sender;
- (void)saveItemClicked:(id)sender;

- (void) fillViewWithInformation:(PartnerInformationItem*) information;

- (BOOL) addNewCategory:(NSString *) category;

- (void) deleteSelectedCategory;

- (void) toggleDeleteState:(BOOL) state;
@end

@implementation AddAdditionalItemViewController
@synthesize backgroundScrollView = _backgroundScrollView;
@synthesize pickerItem = _pickerItem;
@synthesize textViewContent = _textViewContent;
@synthesize btnDelete = _btnDelete;
@synthesize informationItem = _informationItem;
@synthesize partnerInformation = _partnerInformation;

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
    
    [self initialize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_backgroundScrollView release];
    [_pickerItem release];
    [_textViewContent release];
    [_btnDelete release];
    [_informationItem release];
    [_partnerInformation release];
    [super dealloc];
}

#pragma mark - private function
- (void) initialize{
    _deleteState = FALSE;
    
    //add gesture
    [self addTouchBackgroundGesture];
    [self addSwipeBackGesture];
    
    //navigation bar and its items
    [self setNavigationBarHidden:NO animated:YES];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveItemClicked:)];
    
    //set the text view graphics
    [self.textViewContent makeBorderWithWidth:1.0f andColor:[UIColor lightGrayColor]];
    [self.textViewContent makeRoundCorner:5.0f];
    self.textViewContent.placeholder = @"Enter information here...";
    
    //set the scrollview
    self.backgroundScrollView.contentSize = self.view.bounds.size;
    
    //prepare the data
    //get the partner information data
    self.partnerInformation = [[DatabaseHelper sharedHelper] getAllPartnerInformationForPartner:[[MASession sharedSession] currentPartner]];
    
    //if the informationItem is nil, it mean we are in the creation state
    if (!self.informationItem) {
        // Add new information
        self.title = @"Add Information";
    }
    //if the informationItem isn't nil, it mean we are in the editional state
    else {
        // fill the information to the form
        self.title = @"Edit Information";
        [self fillViewWithInformation:self.informationItem];
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
        UIButton *deleteDetailButton = (UIButton *)[self.view viewWithTag:MANAPP_ADD_INFORMATION_ITEM_DELETEBUTTON_INFORMATION_DETAIL_TAG];
        UIButton *deleteCategoryButton = (UIButton *)[self.view viewWithTag:MANAPP_ADD_INFORMATION_ITEM_DELETEBUTTON_INFORMATION_CATEGORY_TAG];
        
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
                             [self.textViewContent setWidth:self.textViewContent.frame.size.width + MANAPP_ADD_INFORMATION_ITEM_TEXT_VIEW_RESIZE_DISTANCE];
                             
                             //resize picker view
                             [self.pickerItem setWidth:self.pickerItem.frame.size.width + MANAPP_ADD_INFORMATION_ITEM_TEXT_VIEW_RESIZE_DISTANCE];
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
            
            deleteDetailButton.frame = CGRectMake(self.textViewContent.frame.origin.x + self.textViewContent.frame.size.width - MANAPP_ADD_INFORMATION_ITEM_TEXT_VIEW_RESIZE_DISTANCE, self.textViewContent.frame.origin.y + self.textViewContent.frame.size.height/2 - 7, 18, 15);
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
            
            deleteCategoryButton.frame = CGRectMake(self.pickerItem.frame.origin.x + self.pickerItem.frame.size.width - MANAPP_ADD_INFORMATION_ITEM_TEXT_VIEW_RESIZE_DISTANCE, self.pickerItem.frame.origin.y + self.pickerItem.frame.size.height/2 - 7, 18, 15);
            [self.view addSubview:deleteCategoryButton];
            [self.view bringSubviewToFront:deleteCategoryButton];
        }
        
        // animation
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             // resize content text view
                             [self.textViewContent setWidth:self.textViewContent.frame.size.width - MANAPP_ADD_INFORMATION_ITEM_TEXT_VIEW_RESIZE_DISTANCE];
                             
                             //resize picker view
                             [self.pickerItem setWidth:self.pickerItem.frame.size.width - MANAPP_ADD_INFORMATION_ITEM_TEXT_VIEW_RESIZE_DISTANCE];
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
}

#pragma mark - data handler
//fll the view with information
- (void) fillViewWithInformation:(PartnerInformationItem*) information{
    if(information){
        self.textViewContent.text = information.name;
        
        //change the picker value
        NSInteger count = self.partnerInformation.count;
        for (NSInteger row = 0; row < count; row++) {
            PartnerInformation *pInformation = [self.partnerInformation objectAtIndex:row];
            if (pInformation == information.information) {
                [self.pickerItem selectRow:row inComponent:0 animated:YES];
                break;
            }
        }
    }
    //if the information is nil, reset the view
    else{
        self.textViewContent.text = @"";
    }
}

//add category to database
- (BOOL) addNewCategory:(NSString *) category{
    //get current parent category
    if([category isEqualToString:@""])
    {
        [self showMessage:@"Category name cannot be blank!"];
        return FALSE;
    }
    else{
        // add new category and reload the picker
        BOOL addResult = [[DatabaseHelper sharedHelper] addNewInformationCategoryForPartner:[[MASession sharedSession] currentPartner] withName:category];
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

//delete the current category which is selected by picker
- (void) deleteSelectedCategory{
    NSInteger selectedRow = [self.pickerItem selectedRowInComponent:0];
    if(selectedRow < self.partnerInformation.count){
        PartnerInformation *selectedCategory = [self.partnerInformation objectAtIndex:selectedRow];
        if (selectedCategory) {
            [[DatabaseHelper sharedHelper] deleteManagedObject:selectedCategory];
            [self showMessage:@"Category Deleted"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [self showMessage:@"Cannot delete this category!"];
        }
    }
    else{
        [self showMessage:@"Cannot delete this category!"];
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
    }
    
    [self showMessage:@"Information Deleted"];
    [self.navigationController popViewControllerAnimated:YES];
}

//click delete category button
- (void)deleteCategory:(id)sender{
    //confirm to make sure we want to delete category
    
    NSInteger selectedRow = [self.pickerItem selectedRowInComponent:0];
    if(selectedRow < self.partnerInformation.count){
        PartnerInformation *selectedCategory = [self.partnerInformation objectAtIndex:selectedRow];
        if (selectedCategory) {
            [self showMessage:[NSString stringWithFormat:@"You will be deleting all informations in %@",selectedCategory.name] title:@"MANAPP" cancelButtonTitle:@"Delete all" otherButtonTitle:@"Cancel" delegate:self tag:MANAPP_ADD_INFORMATION_ITEM_CONFIRM_DELETE_CATEGORY_ALERT_TAG];
        }
        else{
            [self showMessage:@"Cannot delete this category!"];
        }
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
        [self showErrorMessage:@"Name must not be empty"];
        return;
    }
    
    NSInteger selectedRow = [self.pickerItem selectedRowInComponent:0];
    if(selectedRow < self.partnerInformation.count)
    {
        PartnerInformation *pInformation = [self.partnerInformation objectAtIndex:selectedRow];
        if (self.informationItem) {
            self.informationItem.information = pInformation;
            self.informationItem.name = self.textViewContent.text;
        } else {
            self.informationItem = (id)[[DatabaseHelper sharedHelper] newManagedObjectForEntity:@"PartnerInformationItem"];
            self.informationItem.itemID = [NSString generateGUID];
            self.informationItem.name = self.textViewContent.text;
            self.informationItem.information = pInformation;
            self.informationItem.timestamp = [NSDate date];
        }
        [[DatabaseHelper sharedHelper] saveContext];
        
        [self showMessage:@"Information saved" title:@"MANAPP" cancelButtonTitle:@"OK" otherButtonTitle:nil delegate:self tag:MANAPP_ADD_INFORMATION_ITEM_SUCCESSFULLY_CREATION_ALERT_TAG];
        
    }
    else{
        [self showMessage:@"Cannot save information!"];
    }
}

#pragma mark - parent override
//tap background (only if gesture is added)
- (void)tap:(id)sender{
    [self.textViewContent resignFirstResponder];
}

#pragma mark - UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //extra row for add new category
    return self.partnerInformation.count + 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //last row is the add new category item
    if(row == self.partnerInformation.count)
    {
        return @"Add new category";
    }
    
    PartnerInformation *pInformation = [self.partnerInformation objectAtIndex:row];
    return pInformation.name;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    // add new category item was selected
    
    if(row == self.partnerInformation.count)
    {
        // COMMENT: show the alertview with textfield
        NSMutableArray *subsControl = [[[NSMutableArray alloc] init] autorelease];
        
        UITextField *newCategoryTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
        [newCategoryTextField setBackgroundColor:[UIColor whiteColor]];
        newCategoryTextField.tag = MANAPP_ADD_INFORMATION_ITEM_NEW_CATEGORY_TEXT_FIELD;
        [subsControl addObject:newCategoryTextField];
        
        [self showMessage:@"\n\nPlease select a name for your new category." title:@"MANAPP" cancelButtonTitle:@"Cancel" otherButtonTitle:@"Add Information" delegate:self tag:MANAPP_ADD_INFORMATION_ITEM_NEW_CATEGORY_ALERT_TAG subControls:subsControl];
    }
}

#pragma mark - UITextViewDelegate

-(void)keyboardWillShow:(NSNotification *)notification{
    [super keyboardWillShow:notification];
    
    [self resizeScrollView:self.backgroundScrollView withKeyboardState:TRUE willChangeOffset:YES];
}

-(void)keyboardWillHide{
    [super keyboardWillHide];
    
    [self resizeScrollView:self.backgroundScrollView withKeyboardState:FALSE willChangeOffset:YES];
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
    if(alertView.tag == MANAPP_ADD_INFORMATION_ITEM_NEW_CATEGORY_ALERT_TAG){
        // add button clicked
        if(buttonIndex == 1)
        {
            UITextField *newCategoryTextField = (UITextField *)[alertView viewWithTag: MANAPP_ADD_INFORMATION_ITEM_NEW_CATEGORY_TEXT_FIELD];
            
            if([self addNewCategory:newCategoryTextField.text]){
                //reload
                self.partnerInformation = [[DatabaseHelper sharedHelper] getAllPartnerInformationForPartner:[[MASession sharedSession] currentPartner]];
                [self.pickerItem reloadComponent:0];
            }
        }
    }
    //after save, return to the previous view
    else if(alertView.tag == MANAPP_ADD_INFORMATION_ITEM_SUCCESSFULLY_CREATION_ALERT_TAG){
        [self.navigationController popViewControllerAnimated:YES];
    }
    //delete category if user select yes
    else if(alertView.tag == MANAPP_ADD_INFORMATION_ITEM_CONFIRM_DELETE_CATEGORY_ALERT_TAG){
        [self deleteSelectedCategory];
    }
}

@end
