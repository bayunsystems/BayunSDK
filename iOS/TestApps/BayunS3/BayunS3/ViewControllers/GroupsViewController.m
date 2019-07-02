//
//  GroupsViewController.m
//  BayunS3
//
//  Created by Preeti Gaur on 06/03/17.
//  Copyright © 2017 bayun. All rights reserved.
//

#import "GroupsViewController.h"
#import "DropDownView.h"
#import "DLAVAlertViewTheme.h"
#import "DLAVAlertView.h"
#import "MKDropdownMenu.h"
#import <Bayun/BayunCore.h>
#import "GroupFilesViewController.h"



@interface GroupsViewController () <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate,UITextFieldDelegate,MKDropdownMenuDataSource, MKDropdownMenuDelegate>

@property (strong,nonatomic) UILabel *createGroupLabel;
@property (strong,nonatomic) UITextField *groupNameTextField;
@property (strong, nonatomic) NSArray *userGroups;
@property (strong, nonatomic) NSArray *publicGroups;
@property (strong,nonatomic) MKDropdownMenu *dropDownMenu;
@property (strong,nonatomic) NSArray *groupTypes;
@property (nonatomic) NSUInteger selectedGroupTypeRow;
@property (strong,nonatomic) NSString *selectedGroupType;
@property (strong,nonatomic) NSDictionary *selectedGroup;

@end

@implementation GroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Groups";
    
    self.groupTypes = @[@"Public Group",@"Private Group"];
    
    self.dropDownMenu = (MKDropdownMenu*)[[MKDropdownMenu alloc]initWithFrame:CGRectMake(0.0, 80.0, 200.0, 40.0)];
    self.dropDownMenu.backgroundDimmingOpacity = 0.0;
    self.dropDownMenu.delegate = self;
    self.dropDownMenu.dataSource =  self;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init] ;
    
    self.segmentControl.selectedSegmentIndex = 0;
    self.segmentControl.enabled =  true;
    self.segmentControl.translatesAutoresizingMaskIntoConstraints = false;
    self.segmentControl.layer.cornerRadius = 0.0;
    self.segmentControl.layer.borderWidth = 1.5f;
    self.segmentControl.layer.borderColor = [[UIColor colorWithRed:0/255.0f green:109/255.0f blue:152/255.0f alpha:1.0] CGColor];
    
    
    // Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setUpView];
    [self getUserGroups];
}

- (void) setUpView {
    NSArray *groups;
    if (self.segmentControl.selectedSegmentIndex == 0) {
        groups =  self.userGroups;
    } else {
        groups = self.publicGroups;
    }

    if(groups.count > 0) {
        self.noItemsView.hidden = true;
        self.tableView.hidden = false;
        [self.tableView reloadData];
    } else {
        self.noItemsView.hidden = false;
        self.tableView.hidden = true;
    }
}


- (void) getUserGroups {
    [SVProgressHUD show];
    [[BayunCore sharedInstance] getMyGroups:^(NSArray *myGroups) {
        [SVProgressHUD dismiss];
        self.userGroups = myGroups;
        [self setUpView];
    } failure:^(BayunError error) {
         [self showMessageForError:error];
    }];
}

- (void) getPublicGroups {
    [SVProgressHUD show];
    [[BayunCore sharedInstance] getUnjoinedPublicGroups:^(NSArray *publicGroups) {
        [SVProgressHUD dismiss];
        self.publicGroups = publicGroups;
        [self setUpView];
    } failure:^(BayunError error) {
        [self showMessageForError:error];
    }];
}

- (void)showMessageForError:(BayunError) error {
    if (error == BayunErrorUserInActive) {
        [SVProgressHUD showErrorWithStatus:kErrorMsgUserInActive];
    } else if (error == BayunErrorReAuthenticationNeeded ||
               error == BayunErrorInvalidAppSecret ||
               error == BayunErrorPasscodeAuthenticationCanceledByUser) {
        
        if (error == BayunErrorInvalidAppSecret) {
            [SVProgressHUD showErrorWithStatus:kErrorMsgInvalidAppSecret];
        } else if (error == BayunErrorReAuthenticationNeeded){
            [SVProgressHUD showErrorWithStatus:kErrorMsgBayunReauthenticationNeeded];
        } else if (error == BayunErrorPasscodeAuthenticationCanceledByUser){
            [SVProgressHUD showErrorWithStatus:kErrorMsgPasscodeAuthenticationFailed];
        }
            
        [Utilities logoutUser:self.user];
    } else {
        [SVProgressHUD showErrorWithStatus:kErrorMsgSomethingWentWrong];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createButtonIsPressed:(id)sender {
    [self showNewGroupAlertView];
}

- (void)showNewGroupAlertView{
    
    //show new group creation alert view
    
    DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:nil
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Ok", nil];
    alertView.alertViewStyle = DLAVAlertViewStyleDefault;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 120.0)];
    
    //Create label for New Group
    CGRect createGroupLabelFrame = CGRectMake(0.0, 0.0, 200.0, 40.0);
    self.createGroupLabel = [[UILabel alloc] initWithFrame:createGroupLabelFrame];
    self.createGroupLabel.text = @"New Group";
    self.createGroupLabel.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:self.createGroupLabel];
    
    //Create textfield for Group Name
    CGRect groupNameTextFieldFrame = CGRectMake(0.0, 40.0, 200.0, 40.0);
    self.groupNameTextField = [[UITextField alloc] initWithFrame:groupNameTextFieldFrame];
    self.groupNameTextField.delegate = self;
    self.groupNameTextField.placeholder = @"Group Name";
    self.groupNameTextField.textAlignment = NSTextAlignmentCenter;
    self.groupNameTextField.returnKeyType = UIReturnKeyDone;
    [contentView addSubview:self.groupNameTextField];
    
    [contentView addSubview:self.dropDownMenu];
    
    
    DLAVAlertViewTheme *theme = [DLAVAlertViewTheme defaultTheme];
    theme.backgroundColor = [UIColor whiteColor];
    [alertView applyTheme:theme];
    alertView.contentView = contentView;
    
    [alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            //Create Button is pressed
            
            NSString *groupName = self.groupNameTextField.text;
            GroupType groupType = self.selectedGroupTypeRow;
            
            [SVProgressHUD show];
            [[BayunCore sharedInstance] createGroup:groupName groupType:groupType success:^(NSString *groupId){
                
                [SVProgressHUD dismiss];
                if (self.segmentControl.selectedSegmentIndex == 0) {
                    [self getUserGroups];
                }
                
            } failure:^(BayunError bayunError) {
                
                    [self showMessageForError:bayunError];
        
               
            }];
            
        }
    }];
}

#pragma mark - MKDropdownMenuDataSource

- (NSInteger)numberOfComponentsInDropdownMenu:(MKDropdownMenu *)dropdownMenu {
    return 1;
}

- (NSInteger)dropdownMenu:(MKDropdownMenu *)dropdownMenu numberOfRowsInComponent:(NSInteger)component {
    return self.groupTypes.count;
}

#pragma mark - MKDropdownMenuDelegate

- (CGFloat)dropdownMenu:(MKDropdownMenu *)dropdownMenu rowHeightForComponent:(NSInteger)component {
    return 0; // use default row height
}

- (CGFloat)dropdownMenu:(MKDropdownMenu *)dropdownMenu widthForComponent:(NSInteger)component {
    return 0; // use automatic width
}

- (BOOL)dropdownMenu:(MKDropdownMenu *)dropdownMenu shouldUseFullRowWidthForComponent:(NSInteger)component {
    return NO;
}

- (NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForComponent:(NSInteger)component {
    NSString *groupType = self.groupTypes[self.selectedGroupTypeRow];
    self.selectedGroupType = groupType;
    return [[NSAttributedString alloc] initWithString:groupType
                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16 weight:UIFontWeightLight],
                                                        NSForegroundColorAttributeName: [UIColor blackColor]}];
}

- (NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForSelectedComponent:(NSInteger)component {
    NSString *groupType = self.groupTypes[self.selectedGroupTypeRow];
    return [[NSAttributedString alloc] initWithString:groupType
                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16 weight:UIFontWeightRegular],
                                                        NSForegroundColorAttributeName: [UIColor blackColor]}];
}

- (UIView *)dropdownMenu:(MKDropdownMenu *)dropdownMenu
              viewForRow:(NSInteger)row
            forComponent:(NSInteger)component
             reusingView:(UIView *)view {
    DropDownView *dropDownView = (DropDownView*) view;
    if (dropDownView == nil || ![DropDownView isKindOfClass:[DropDownView class]]) {
        dropDownView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DropDownView class]) owner:nil options:nil] firstObject];
    }
    
    NSString *groupType = self.groupTypes[row];
    dropDownView.textLabel.text = groupType;
    return dropDownView;
}

- (UIColor *)dropdownMenu:(MKDropdownMenu *)dropdownMenu backgroundColorForRow:(NSInteger)row forComponent:(NSInteger)component {
    return nil;
}

- (void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedGroupTypeRow = row;
    [dropdownMenu reloadComponent:component];
    
}

#pragma mark - Table View Delegate methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.segmentControl.selectedSegmentIndex == 0) {
        return self.userGroups.count;
    } else {
        return self.publicGroups.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] ;
    }
    
    NSDictionary *group;
    
    if (self.segmentControl.selectedSegmentIndex == 0) {
        group= [self.userGroups objectAtIndex:indexPath.row];
    } else {
        group= [self.publicGroups objectAtIndex:indexPath.row];
    }
    
    
    if (![[group objectForKey:@"name"] isEqualToString:@""]) {
        cell.textLabel.text = [group objectForKey:@"name"];
    } else {
        cell.textLabel.text = @"Untitled";
    }
    
    
    cell.imageView.image = [UIImage imageNamed:@"GroupIcon"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *group;
    
    if (self.segmentControl.selectedSegmentIndex == 0) {
        group= [self.userGroups objectAtIndex:indexPath.row];

        self.selectedGroup = group;
        [self performSegueWithIdentifier:@"groupFiles" sender:nil];
        
    } else {
        group= [self.publicGroups objectAtIndex:indexPath.row];
        self.selectedGroup = group;
     
        [self showAlertViewToJoinPublicGroup];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //can delete joined groups
    if (self.segmentControl.selectedSegmentIndex == 0) {
         return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([[BayunCore sharedInstance] isEmployeeActive]) {
            
            
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:kDeleteFile
                                         message:kConfirmationMsgToDeleteGroup
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            //Add Buttons
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"Yes"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            
                                            NSDictionary *group;
                                            
                                            if (self.segmentControl.selectedSegmentIndex == 0) {
                                                group= [self.userGroups objectAtIndex:indexPath.row];
                                            } else {
                                                group= [self.publicGroups objectAtIndex:indexPath.row];
                                            }
                                            
                                            [[BayunCore sharedInstance] deleteGroup:[group valueForKey:@"id"] success:^{
                                                
                                                [self getUserGroups];
                                                [SVProgressHUD showSuccessWithStatus:kGroupDeleted];
                                                
                                            } failure:^(BayunError error) {
                                                
                                                if (error == BayunErrorEmployeeDoesNotBelongToGroup) {
                                                    [SVProgressHUD showErrorWithStatus:kErrorMsgDeleteGroupForNonMember];
                                                } else {
                                                    [SVProgressHUD showErrorWithStatus:kErrorMsgSomethingWentWrong];
                                                }
                                            
                                            }];
                                            
                                        }];
            
            UIAlertAction* noButton = [UIAlertAction
                                       actionWithTitle:@"Cancel"
                                       style:UIAlertActionStyleDefault
                                       handler:nil];
            
            //Add your buttons to alert controller
            
            [alert addAction:yesButton];
            [alert addAction:noButton];
            
            [self presentViewController:alert animated:YES completion:nil];
            
        } else if ([BayunCore sharedInstance].employeeStatus == BayunEmployeeStatusUnknown) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                message:kErrorMsgGroupDeletionFailed
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            [self notifyInactiveUser];
        }
    }
}

- (void)notifyInactiveUser {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kPermissionDenied
                                                        message:kErrorMsgUserInActive
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)showAlertViewToJoinPublicGroup
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:kConfirmationMsgToJoinPublicGroup
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    
                                    [[BayunCore sharedInstance] joinPublicGroup:[self.selectedGroup valueForKey:@"id"] success:^{
                                        [self getPublicGroups];
                                        [SVProgressHUD showSuccessWithStatus:kGroupJoined];
                                    } failure:^(BayunError error) {
                                        [SVProgressHUD showErrorWithStatus:kErrorMsgSomethingWentWrong];
                                    }];
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:nil];
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"groupFiles"]) {
        GroupFilesViewController *vc = segue.destinationViewController;
        vc.user = self.user;
        vc.group = self.selectedGroup;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -  UISegment Control Delegate Method

- (IBAction)segmentIsSelected:(id)sender {
    
    if (self.segmentControl.selectedSegmentIndex == 0) {
        [self getUserGroups];
    } else {
        [self getPublicGroups];
    }
    
}

#pragma mark - Textfield Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.groupNameTextField) {
        [self.groupNameTextField resignFirstResponder];
        return NO;
    }
    return YES;
}
@end
