//
//  GroupFilesViewController.m
//  BayunS3
//
//  Created by Preeti Gaur on 03/04/17.
//  Copyright © 2017 bayun. All rights reserved.
//

#import "GroupFilesViewController.h"

#import "CreateTextFileViewController.h"
#import <AWSS3/AWSS3Model.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuickLook/QuickLook.h>
#import <Bayun/BayunCore.h>
#import "ALAlertBanner.h"
#import "AWSManager.h"
#import "AppDelegate.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "DLAVAlertViewTheme.h"
#import "DLAVAlertView.h"
#import <Bayun/BayunCore.h>
#import "SecureAWSS3TransferManager.h"
#import "GroupMembersViewController.h"

@interface GroupFilesViewController ()<AWSManagerDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate ,UIDocumentPickerDelegate,UIDocumentMenuDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate,UIDocumentInteractionControllerDelegate,UITextFieldDelegate>

@property (strong , nonatomic) UIBarButtonItem *createButton;
@property (strong,nonatomic) NSArray *s3BucketObjectArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong , nonatomic) NSIndexPath *indexPathOfRowToDelete;
@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;
@property (nonatomic,strong) QLPreviewController *previewController;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UITextField *companyNameTextField;
@property (nonatomic, strong) UITextField *companyEmpIdTextField;
@property (strong, nonatomic) NSString *bucketName;

@end

@implementation GroupFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = [self.group valueForKey:@"name"];
    self.navigationController.navigationBar.hidden = NO;
    
    self.s3BucketObjectArray = [[NSMutableArray alloc] init];
    self.bucketName = [NSString stringWithFormat:@"bayun-group-%@",[self.group valueForKey:@"id"]];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init] ;
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor colorWithRed:3/255.0f
                                                    green:97/255.0f
                                                     blue:134/255.0f
                                                    alpha:1.0];
    
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(getS3BucketObjects)
                                                name:kNewFileCreated
                                              object:nil];
    [SVProgressHUD show];
    [self performSelector:@selector(createS3Bucket) withObject:nil afterDelay:5.0];
}


- (IBAction)manageButtonIsPressed:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Upload",
                                  @"Group Members",
                                  @"Add Member",
                                  @"Remove Member",
                                  @"Leave Group",nil];
    actionSheet.destructiveButtonIndex = 4;
    [actionSheet showInView:self.view];
}

- (void)createS3Bucket {
    AWSManager *awsManagerInstance = [AWSManager sharedInstance];
    awsManagerInstance.delegate = self;
    [awsManagerInstance createS3BucketWithName:[self.bucketName lowercaseString] success:^{
        [self getS3BucketObjects];
    } failure:^(NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:kErrorMsgSomethingWentWrong];
        });
    }];
}

- (void)getS3BucketObjects {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.isNetworkReachable) {
        AWSManager *awsManagerInstance = [AWSManager sharedInstance];
        awsManagerInstance.delegate = self;
        [awsManagerInstance getBucketFiles:self.bucketName success:^(AWSS3ListObjectsOutput *bucketObjectsList) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
            [self performSelectorOnMainThread:@selector(renderFiles:)
                                   withObject:bucketObjectsList
                                waitUntilDone:YES];
        } failure:^(NSError *error){
            [self showMessageForAWSError:error.code];
        }];
    } else {
        [self endRefreshing];
        [SVProgressHUD showErrorWithStatus:kErrorMsgInternetConnection];
    }
}

-(void)uploadFileAtPath:(NSURL*)url {
    //Setting groupId and encryption policy to BayunEncryptionPolicyGroup
    [[AWSManager sharedInstance] setEncryptionPolicy:BayunEncryptionPolicyGroup];
    [[AWSManager sharedInstance] setGroupId:[self.group valueForKey:@"id"]];
    
    [[AWSManager sharedInstance] uploadFile:url bucketName:self.bucketName success:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [self getS3BucketObjects];
        
    } failure:^(NSError *error) {
        
        [self endRefreshing];
        [self showMessageForAWSError:error.code];
        
    }];
}

-(void)renderFiles:(AWSS3ListObjectsOutput*)bucketObjectsList {
    
    [self endRefreshing];
    
    NSMutableArray *objectsArray = [[NSMutableArray alloc] init];
    
    for (AWSS3Object *s3Object in bucketObjectsList.contents) {
        [objectsArray addObject:s3Object];
    }
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastModified" ascending:NO];
    self.s3BucketObjectArray   =  [objectsArray sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    if (self.s3BucketObjectArray.count == 0) {
        self.noItemsView.hidden = NO;
        self.tableView.hidden = YES;
    } else {
        self.noItemsView.hidden = YES;
        self.tableView.hidden = NO;
    }
    [self.tableView reloadData];
}


- (void)endRefreshing {
    if ([self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
    }
}

- (void)refreshInvoked:(id)sender forState:(UIControlState)state {
    [self getS3BucketObjects];
}


- (void)setupDocumentControllerWithURL:(NSURL *)url {
    //checks if docInteractionController has been initialized with the URL
    if (self.docInteractionController == nil) {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.docInteractionController.delegate = self;
    } else {
        self.docInteractionController.URL = url;
    }
}

- (void)showAddOrRemoveMemberAlertView:(NSString*)title{
    
    DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:title
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Ok", nil];
    
    alertView.alertViewStyle = DLAVAlertViewStyleDefault;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 80.0)];
    
    CGRect companyNameTextFieldFrame = CGRectMake(0.0, 0.0, 200.0, 40.0);
    self.companyNameTextField = [[UITextField alloc] initWithFrame:companyNameTextFieldFrame];
    self.companyNameTextField.delegate = self;
    self.companyNameTextField.placeholder = @"Company Name";
    
    CGRect companyEmpIdTextFieldFrame = CGRectMake(0.0, 40.0, 200.0, 40.0);
    self.companyEmpIdTextField = [[UITextField alloc] initWithFrame:companyEmpIdTextFieldFrame];
    self.companyEmpIdTextField.placeholder = @"Member EmployeeId";
    self.companyEmpIdTextField.delegate = self;
    self.companyEmpIdTextField.returnKeyType = UIReturnKeyDone;
    
    //set default company name in the company textfield
    NSString *defaultCompany = [[NSUserDefaults standardUserDefaults] valueForKey:kCompany];
    self.companyNameTextField.text = defaultCompany;
    
    [contentView addSubview:self.companyNameTextField];
    [contentView addSubview:self.companyEmpIdTextField];
    
    DLAVAlertViewTheme *theme = [DLAVAlertViewTheme defaultTheme];
    theme.backgroundColor = [UIColor whiteColor];
    [alertView applyTheme:theme];
    alertView.contentView = contentView;
    
    [alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            //Ok button is pressed
            
            NSString *companyName = self.companyNameTextField.text;
            NSString *companyEmployeeId = self.companyEmpIdTextField.text;
            NSString *groupId = [self.group valueForKey:@"id"];
            
            if ([companyName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] &&
                [companyEmployeeId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]) {
                
                NSDictionary *parameters = @{@"companyName" : companyName,
                                             @"companyEmployeeId" : companyEmployeeId,
                                             @"groupId" : groupId};
                
                if ([title isEqualToString:@"Add Member"]) {
                    
                    [[BayunCore sharedInstance] addGroupMember:parameters success:^{
                        
                        [SVProgressHUD showSuccessWithStatus:kMemberAddedSuccessfully];
                        
                    } failure:^(BayunError error) {
                        [self showMessagForError:error];
                    }];
                    
                } else if ([title isEqualToString:@"Remove Member"]) {
                    
                    [[BayunCore sharedInstance] removeGroupMember:parameters success:^{
                        [SVProgressHUD showSuccessWithStatus:kMemberRemovedSuccessfully];
                    } failure:^(BayunError error) {
                        [self showMessagForError:error];
                    }];
                }
            }
        }
    }];
}

- (void)showAlertViewToLeaveGroup {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:kConfirmationMsgToLeaveGroup
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        [[BayunCore sharedInstance] leaveGroup:[self.group valueForKey:@"id"] success:^{
            [self.navigationController popViewControllerAnimated:true];
        } failure:^(BayunError error) {
            [SVProgressHUD showErrorWithStatus:kErrorMsgSomethingWentWrong];
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
}

- (void)showMessagForError:(BayunError)error {
    if (error == BayunErrorMemberAlreadyExistsInGroup){
        [SVProgressHUD showErrorWithStatus:kMemberAlreadyExists];
    } else if (error == BayunErrorMemberDoesNotExistsInGroup){
        [SVProgressHUD showErrorWithStatus:kMemberDoesNotExists];
    } else if (error == BayunErrorEmployeeDoesNotExists) {
        [SVProgressHUD showErrorWithStatus:kEmployeeDoesNotExist];
    } else if (error ==  BayunErrorCompanyDoesNotExists) {
        [SVProgressHUD showErrorWithStatus:kInvalidCompany];
    } else if (error == BayunErrorReAuthenticationNeeded) {
        [SVProgressHUD dismiss];
        [Utilities logoutUser:self.user];
    } else {
        [SVProgressHUD showErrorWithStatus:kErrorMsgSomethingWentWrong];
    }
}

- (void)showMessageForAWSError:(SecureAWSS3TransferManagerErrorType) errorType {
    if (errorType == SecureAWSS3TransferManagerErrorUserInactive) {
        [SVProgressHUD showErrorWithStatus:kErrorMsgUserInActive];
    } else if (errorType == SecureAWSS3TransferManagerErrorAccessDenied) {
        [SVProgressHUD showErrorWithStatus:kErrorMsgAccessDenied];
    } else if (errorType == SecureAWSS3TransferManagerErrorNoInternetConnection) {
        [SVProgressHUD showErrorWithStatus:kErrorMsgInternetConnection];
    } else if(errorType == SecureAWSS3TransferErrorReAuthenticationNeeded ||
              errorType == SecureAWSS3TransferErrorPasscodeAuthenticationCanceledByUser ||
              errorType == SecureAWSS3TransferManagerErrorInvalidAppSecret) {
        [Utilities logoutUser:self.user];
        [SVProgressHUD dismiss];
    } else {
        [SVProgressHUD showErrorWithStatus:kErrorMsgSomethingWentWrong];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AWSManager Delegate Methods

- (void)s3UploadProgress:(float)progress {
    [SVProgressHUD showProgress:progress status:@"Uploading"];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
}

- (void)s3DownloadProgress:(float)progress {
    [SVProgressHUD showProgress:progress status:@"Downloading"];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
}

- (void)notifyInactiveUser {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kPermissionDenied
                                                        message:kErrorMsgUserInActive
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - Table View Delegate methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.s3BucketObjectArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] ;
    }
    
    AWSS3Object *s3Object = (AWSS3Object*)[self.s3BucketObjectArray objectAtIndex:indexPath.row];
    
    NSString *fileName = [s3Object valueForKey:@"key"];
    cell.textLabel.text = [[fileName stringByReplacingOccurrencesOfString:@".txt" withString:@""] capitalizedString];
    
    NSDate *fileLastModifiedDate = [s3Object valueForKey:@"lastModified"];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Size:%@  Last Modified: %@",
                                 [Utilities getFileSize:[s3Object valueForKey:@"size"]],
                                 [Utilities getCurrentTimeStampDateString:fileLastModifiedDate]];
    cell.detailTextLabel.font=[UIFont fontWithName:@"Helvetica" size:9.0];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = [UIImage imageNamed:@"fileImage"];
    
    NSString *downloadedFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[s3Object valueForKey:@"key"]];
    [self setupDocumentControllerWithURL:[NSURL fileURLWithPath:downloadedFilePath]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AWSS3Object *s3Object = (AWSS3Object*)[self.s3BucketObjectArray objectAtIndex:indexPath.row];
    
    NSString *filePath = [NSTemporaryDirectory()
                          stringByAppendingPathComponent:[s3Object valueForKey:@"key"]];
    
    [[AWSManager sharedInstance] downloadFile:[NSURL fileURLWithPath:filePath]
                                   bucketName:self.bucketName success:^{
                                       
                                       [SVProgressHUD dismiss];
                                       [self.previewController refreshCurrentPreviewItem];
                                       
                                   } failure:^(NSError *error) {
                                       [self showMessageForAWSError:error.code];
                                   }];
    
    self.selectedIndexPath =  indexPath;
    
    self.previewController = [[QLPreviewController alloc] init];
    self.previewController.dataSource = self;
    self.previewController.delegate = self;
    
    // start previewing the document at the current section index
    self.previewController.currentPreviewItemIndex = indexPath.row;
    [[self navigationController] pushViewController:self.previewController animated:NO];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([[BayunCore sharedInstance] isEmployeeActive]) {
            self.indexPathOfRowToDelete = indexPath;
            AWSS3Object *s3Object = (AWSS3Object*)[self.s3BucketObjectArray objectAtIndex:indexPath.row];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete File"
                                                                message:[NSString stringWithFormat:@"Delete %@ permanently?",s3Object.key]
                                                               delegate:self cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"OK",nil];
            [alertView show];
        } else if ([BayunCore sharedInstance].employeeStatus == BayunEmployeeStatusUnknown) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                message:kErrorMsgFileDeletionFailed
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            [self notifyInactiveUser];
        }
    }
}

#pragma mark - alert view delegate method

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {  // OK button is pressed to delete a file
        AWSS3Object *s3Object = (AWSS3Object*)[self.s3BucketObjectArray objectAtIndex:self.indexPathOfRowToDelete.row];
        [[AWSManager sharedInstance]deleteFile:s3Object.key bucketName:self.bucketName success:^{
            [SVProgressHUD dismiss];
            [self.tableView reloadData];
            [self getS3BucketObjects];
            self.indexPathOfRowToDelete = nil;
            [SVProgressHUD showSuccessWithStatus:kFileDeletedSuccessfully];
            
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [SVProgressHUD showErrorWithStatus:kErrorMsgFileDeletionFailed];
                [self.tableView reloadRowsAtIndexPaths:@[self.indexPathOfRowToDelete] withRowAnimation:UITableViewRowAnimationNone];
                self.indexPathOfRowToDelete = nil;
            });
        }];
        [SVProgressHUD show];
    }
}

#pragma mark - UIDocumentMenuDelegate

- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker {
    documentPicker.delegate = self;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    [self uploadFileAtPath:url];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        
        // define the block to call when we get the asset based on the url (below)
        NSURL *imageRefURL = [info valueForKey:UIImagePickerControllerReferenceURL];
        __block NSString *imageName;
        
        // get the asset library and fetch the asset based on the ref url (pass in block above)
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:imageRefURL resultBlock:^(ALAsset *imageAsset) {
            
            ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
            imageName = [imageRep filename];
            
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            NSString *imageExtension = @"png";
            if(imageRefURL){
                imageExtension  = [imageRefURL pathExtension];
            }
            
            NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:imageName];
            NSData *imageData;
            
            if ([[imageExtension uppercaseString] isEqualToString:@"JPG"]) {
                imageData = UIImageJPEGRepresentation(image, 0.8);
            } else {
                imageData = UIImagePNGRepresentation(image);
            }
            
            [imageData writeToFile:filePath atomically:NO];
            
            [self uploadFileAtPath:[NSURL fileURLWithPath:filePath]];
            
        } failureBlock:nil];
    }];
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController {
    return self;
}

#pragma mark - QLPreviewControllerDataSource

// Returns the number of items that the preview controller should preview
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController {
    return 1;
}

// Returns the item that the preview controller should preview
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx {
    NSIndexPath *selectedIndexPath = self.selectedIndexPath;
    AWSS3Object *s3Object = (AWSS3Object*)[self.s3BucketObjectArray objectAtIndex:selectedIndexPath.row];
    NSString *filePath = [NSTemporaryDirectory()
                          stringByAppendingPathComponent:[s3Object valueForKey:@"key"]];
    
    if (![QLPreviewController canPreviewItem:[NSURL fileURLWithPath:filePath]]) {
        ALAlertBanner *banner = [ALAlertBanner alertBannerForView:previewController.view
                                                            style:ALAlertBannerStyleFailure
                                                         position:ALAlertBannerPositionTop
                                                            title:@"Cannot preview file"
                                                         subtitle:@"Please choose an application from Activity menu."];
        [banner show];
    }
    return [NSURL fileURLWithPath:filePath];
}

- (void)previewControllerWillDismiss:(QLPreviewController *)controller {
    AWSManager *awsManagerInstance = [AWSManager sharedInstance];
    awsManagerInstance.delegate = self;
    [awsManagerInstance s3CancelAll];
}

#pragma mark - UIActionSheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        //Upload is opted
        if (self.presentedViewController) {
            [self dismissViewControllerAnimated:NO completion:^{
                [self presentDocumentPicker];
            }];
        } else {
            [self presentDocumentPicker];
        }
    } else if (buttonIndex == 1) {
        
        [self performSegueWithIdentifier:@"groupMembers" sender:nil];
        
    } else if (buttonIndex == 2) {
        [self showAddOrRemoveMemberAlertView:@"Add Member"];
    } else if (buttonIndex == 3) {
        [self showAddOrRemoveMemberAlertView:@"Remove Member"];
    } else if (buttonIndex == 4) {
        [self showAlertViewToLeaveGroup];
    }
}

- (void) presentDocumentPicker {
    UIDocumentMenuViewController *importMenu =
    [[UIDocumentMenuViewController alloc] initWithDocumentTypes:
     @[@"public.image",@"public.data",@"public.content",@"public.text",@"public.plain-text",@"public.composite-​content",@"public.audio",@"public.presentation",@"public.movie"]
                                                         inMode:UIDocumentPickerModeImport];
    
    importMenu.navigationController.navigationBar.translucent = false;
    importMenu.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    importMenu.navigationController.navigationBar.barTintColor =[UIColor colorWithRed:3/255.0f green:97/255.0f blue:134/255.0f alpha:1.0] ;
    
    [importMenu addOptionWithTitle:@"Photos" image:nil order:UIDocumentMenuOrderFirst handler:^{
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.navigationBar.translucent = false;
        imagePickerController.navigationBar.tintColor = [UIColor whiteColor];
        imagePickerController.navigationBar.barTintColor =[UIColor colorWithRed:3/255.0f green:97/255.0f blue:134/255.0f alpha:1.0] ;
        
        imagePickerController.delegate = self;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }];
    
    [importMenu addOptionWithTitle:@"Create New File" image:nil order:UIDocumentMenuOrderFirst handler:^{
        
        [self performSegueWithIdentifier:@"createTextSegue" sender:nil];
        
    }];
    
    importMenu.delegate = self;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor =[UIColor colorWithRed:3/255.0f green:97/255.0f blue:134/255.0f alpha:1.0] ;
    
    if ( [importMenu respondsToSelector:@selector(popoverPresentationController)] ) {
        importMenu.popoverPresentationController.sourceView = self.view;
    }
    
    [self presentViewController:importMenu animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"createTextSegue"]) {
        CreateTextFileViewController *vc = segue.destinationViewController;
        vc.group = self.group;
        vc.bucketName = self.bucketName;
    } else if ([segue.identifier isEqualToString:@"groupMembers"]) {
        GroupMembersViewController *vc = segue.destinationViewController;
        vc.groupId = [self.group valueForKey:@"id"];
    }
}

#pragma mark - Textfield Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.companyNameTextField) {
        [self.companyEmpIdTextField becomeFirstResponder];
        return NO;
    } else if (textField == self.companyEmpIdTextField) {
        [self.companyEmpIdTextField resignFirstResponder];
        return NO;
    }
    return YES;
}

@end

