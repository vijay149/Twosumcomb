//
//  PPEditableTableViewCell.h
//  MedTalk
//
//  Created by Hieu Bui on 6/25/12.
//  Copyright (c) 2012 SETACINQ Vietnam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PPEditableTableViewCell;

@interface PPEditableTableViewCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic, retain) UITextField *txtField;
@property (nonatomic, retain) UILabel *lblTitle;
@property (nonatomic, retain) NSIndexPath *indexPath;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier showTitle:(BOOL) showTitle;

@end
