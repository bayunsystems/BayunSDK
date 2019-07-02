//
//  ListFilesViewController.m
//  Bayun
//
//  Created by Preeti Gaur on 02/06/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import "ListFilesViewController.h"
#import "CreateTextFileViewController.h"
#import <AWSS3/AWSS3Model.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuickLook/QuickLook.h>
#import <Bayun/BayunCore.h>
#import "ALAlertBanner.h"
#import "AWSManager.h"
#import "AppDelegate.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "DropDownView.h"
#import "DLAVAlertViewTheme.h"
#import "DLAVAlertView.h"
#import "MKDropdownMenu.h"
#import <Bayun/BayunCore.h>
#import "SecureAWSS3TransferManager.h"
#import "SecureAuthentication.h"
#import "GroupsViewController.h"

@interface ListFilesViewController ()<AWSManagerDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate ,UIDocumentPickerDelegate,UIDocumentMenuDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate,UIDocumentInteractionControllerDelegate,MKDropdownMenuDataSource, MKDropdownMenuDelegate>

@property (strong , nonatomic) UIBarButtonItem *createButton;
@property (strong,nonatomic) NSArray *s3BucketObjectArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong , nonatomic) NSIndexPath *indexPathOfRowToDelete;
@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;
@property (nonatomic,strong) QLPreviewController *previewController;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (strong,nonatomic) UILabel *selectPolicyLabel;
@property (strong,nonatomic) MKDropdownMenu *dropDownMenu;
@property (strong,nonatomic) NSArray *encryptionPolicies;
@property (strong,nonatomic) NSArray *keyGenerationPolicies;
@property (nonatomic) NSUInteger selectedEncryptionPolicyRow;
@property (strong,nonatomic) NSString *selectedEncryptionPolicy;
@property (nonatomic) NSUInteger selectedKeyGenPolicyRow;
@property (strong,nonatomic) NSString *selectedKeyGenPolicy;
@property (strong, nonatomic) NSString *bucketName;
@property (strong, nonatomic) NSString *companyName;

@property (nonatomic, strong) AWSCognitoIdentityUser * user;
@property (nonatomic,strong) AWSCognitoIdentityUserGetDetailsResponse * response;
@property (nonatomic, strong) AWSCognitoIdentityUserPool * pool;

@end

typedef NS_ENUM(NSUInteger, DropDownMenuTag) {
    DropDownMenuEncryptionPolicy = 0,
    DropDownMenuKeyGenPolicy
};

/**
 Lists all the files in AWSS3 bucket
 */
@implementation ListFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Files";
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController setNavigationBarHidden:NO];
    
    self.s3BucketObjectArray = [[NSMutableArray alloc] init];
    self.companyName = [[NSUserDefaults standardUserDefaults] valueForKey:kCompany];
    self.bucketName = [[NSString stringWithFormat:@"bayun-test-%@",self.companyName] lowercaseString];
    self.encryptionPolicies = @[@"None",@"Default",@"Company",@"Employee"];
    self.keyGenerationPolicies = @[@"Default",@"Static",@"Envelope",@"Chain"];
    
    self.dropDownMenu = (MKDropdownMenu*)[[MKDropdownMenu alloc]initWithFrame:CGRectMake(0, 40, 200, 40)];
    self.dropDownMenu.backgroundDimmingOpacity = 0.0;
    self.dropDownMenu.delegate = self;
    self.dropDownMenu.dataSource =  self;
    
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
    [self.navigationItem setHidesBackButton:YES];
    
    self.pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"UserPool"];
    //on initial load set the user and refresh to get attributes
    if(!self.user)
        self.user = [self.pool currentUser];
   
    [self refresh];
}

-(void) refresh {
    [[self.user getDetails] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserGetDetailsResponse *> * _Nonnull task) {
        if(task.error){
            [SVProgressHUD showErrorWithStatus:task.error.userInfo[NSLocalizedDescriptionKey]];
            [self.navigationController setToolbarHidden:YES];
        }else {
            self.response = task.result;
            [SVProgressHUD show];
            //if bucket already exists, files in the bucket are loaded.
            [self createS3Bucket];
        }
        return nil;
    }];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //default encryption policy is BayunEncryptionPolicyDefault
    self.selectedEncryptionPolicyRow = [[NSUserDefaults standardUserDefaults] integerForKey:kSelectedEncryptionPolicy];
    self.selectedKeyGenPolicyRow = [[NSUserDefaults standardUserDefaults] integerForKey:kSelectedKeyGenPolicy];
    [self.navigationItem setHidesBackButton:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)moreButtonIsPressed:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Upload",@"Groups",@"Encryption Policy",@"Key Generation Policy",@"Logout", nil];
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
    if (self.companyName) {
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        if (appDelegate.isNetworkReachable) {
            AWSManager *awsManagerInstance = [AWSManager sharedInstance];
            awsManagerInstance.delegate = self;
            
            [SVProgressHUD show];
            [awsManagerInstance getBucketFiles:self.bucketName success:^(AWSS3ListObjectsOutput *bucketObjectsList) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
                [self performSelectorOnMainThread:@selector(renderFiles:)
                                       withObject:bucketObjectsList
                                    waitUntilDone:YES];
            } failure:^(NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showMessageForAWSError:error.code];
                });
            }];
        } else {
            [self endRefreshing];
            [SVProgressHUD showErrorWithStatus:kErrorMsgInternetConnection];
        }
    }
}

-(void)renderFiles:(AWSS3ListObjectsOutput*)bucketObjectsList {
    [SVProgressHUD dismiss];
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

- (void)uploadFileAtPath:(NSURL*)filePath {
    [[AWSManager sharedInstance] uploadFile:filePath bucketName:self.bucketName success:^{
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

- (void)endRefreshing {
    if ([self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
    }
}

- (void)refreshInvoked:(id)sender forState:(UIControlState)state {
    [self getS3BucketObjects];
}

- (void)notifyInactiveUser {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kPermissionDenied
                                                        message:kErrorMsgUserInActive
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)showDropdownWithTag:(DropDownMenuTag)tag{
    
    //show encryption policy to encrypt the file
    DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:nil
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Ok", nil];
    alertView.alertViewStyle = DLAVAlertViewStyleDefault;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 80.0)];
    
    
    CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
    self.selectPolicyLabel = [[UILabel alloc] initWithFrame:frame];
    if (tag == DropDownMenuEncryptionPolicy) {
        self.selectPolicyLabel.text = @"Select Encryption Policy";
    } else {
        self.selectPolicyLabel.text = @"Select Key Generation Policy";
        self.selectPolicyLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    }
    self.selectPolicyLabel.textAlignment = NSTextAlignmentCenter;
    
    self.dropDownMenu.tag = tag;
    [contentView addSubview:self.selectPolicyLabel];
    [contentView addSubview:self.dropDownMenu];
    
    DLAVAlertViewTheme *theme = [DLAVAlertViewTheme defaultTheme];
    theme.backgroundColor = [UIColor whiteColor];
    [alertView applyTheme:theme];
    alertView.contentView = contentView;
    
    [alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            //Ok button is pressed
            if (tag == DropDownMenuEncryptionPolicy) {
                [[NSUserDefaults standardUserDefaults] setInteger:self.selectedEncryptionPolicyRow forKey:kSelectedEncryptionPolicy];
                [[AWSManager sharedInstance] setEncryptionPolicy:self.selectedEncryptionPolicyRow];
            } else if(tag == DropDownMenuKeyGenPolicy) {
                [[NSUserDefaults standardUserDefaults] setInteger:self.selectedKeyGenPolicyRow forKey:kSelectedKeyGenPolicy];
                [[AWSManager sharedInstance] setKeyGenerationPolicy:self.selectedKeyGenPolicyRow];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
}

- (void)showMessageForAWSError :(SecureAWSS3TransferManagerErrorType) errorType {
    if (errorType == SecureAWSS3TransferManagerErrorUserInactive) {
        [SVProgressHUD showErrorWithStatus:kErrorMsgUserInActive];
    } else if (errorType == SecureAWSS3TransferManagerErrorAccessDenied) {
        [SVProgressHUD showErrorWithStatus:kErrorMsgAccessDenied];
    } else if (errorType == SecureAWSS3TransferManagerErrorNoInternetConnection) {
        [SVProgressHUD showErrorWithStatus:kErrorMsgInternetConnection];
    } else if (errorType == SecureAWSS3TransferManagerErrorUnlockingFailed) {
        [SVProgressHUD showErrorWithStatus:kErrorMsgFileDecryptionFailed];
    } else if(errorType == SecureAWSS3TransferErrorReAuthenticationNeeded ||
              errorType == SecureAWSS3TransferErrorPasscodeAuthenticationCanceledByUser ||
              errorType == SecureAWSS3TransferManagerErrorInvalidAppSecret) {
       
        if (errorType == BayunErrorInvalidAppSecret) {
            [SVProgressHUD showErrorWithStatus:kErrorMsgInvalidAppSecret];
        } else if (errorType == BayunErrorReAuthenticationNeeded){
            [SVProgressHUD showErrorWithStatus:kErrorMsgBayunReauthenticationNeeded];
        } else if (errorType == SecureAWSS3TransferErrorPasscodeAuthenticationCanceledByUser){
            [SVProgressHUD showErrorWithStatus:kErrorMsgPasscodeAuthenticationFailed];
        }
        [Utilities logoutUser:self.user];
    } else  {
        [SVProgressHUD showErrorWithStatus:kErrorMsgSomethingWentWrong];
    }
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
    }else if(buttonIndex == 1) {
        [self performSegueWithIdentifier:@"groupsListSegue" sender:nil];
    } else if(buttonIndex == 2) {
        //encryption policy is opted
        [self showDropdownWithTag:DropDownMenuEncryptionPolicy];
        
    } else if(buttonIndex == 3) {
        //encryption policy is opted
        [self showDropdownWithTag:DropDownMenuKeyGenPolicy];
        
    } else if (buttonIndex == 4) {
        //logout is opted
        [[SecureAuthentication sharedInstance] signOut:self.user];
        self.title = nil;
        self.response = nil;
        [self.tableView reloadData];
        [self logout];
    }
}

-(void)logout {
    [[self.user getDetails] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserGetDetailsResponse *> * _Nonnull task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(task.error){
                [Utilities  clearKeychainAndUserDefaults];
                [[BayunCore sharedInstance] deauthenticate];
                [SVProgressHUD showErrorWithStatus:task.error.userInfo[NSLocalizedDescriptionKey]];
                [self.navigationController setToolbarHidden:YES];
            }else {
                self.response = task.result;
                self.title = self.user.username;
                [self.tableView reloadData];
                [self.navigationController setToolbarHidden:NO];
            }
        });
        return nil;
    }];
}

- (void)presentDocumentPicker {
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
        vc.bucketName = self.bucketName;
    } else if ([segue.identifier isEqualToString:@"groupsListSegue"]) {
        GroupsViewController *vc = segue.destinationViewController;
        vc.user = self.user;
    }
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
    
    [[AWSManager sharedInstance] downloadFile:[NSURL fileURLWithPath:filePath] bucketName:self.bucketName success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
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
    
    
    [[self navigationController] pushViewController:self.previewController animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([[BayunCore sharedInstance] isEmployeeActive]) {
            self.indexPathOfRowToDelete = indexPath;
            AWSS3Object *s3Object = (AWSS3Object*)[self.s3BucketObjectArray objectAtIndex:indexPath.row];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kDeleteFile
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


#pragma mark - AWSManager Delegate Methods

- (void)s3UploadProgress:(float)progress {
    [SVProgressHUD showProgress:progress status:@"Uploading"];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
}

- (void)s3DownloadProgress:(float)progress {
    [SVProgressHUD showProgress:progress status:@"Downloading"];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
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
            
            //Setting groupId and encryption policy to BayunEncryptionPolicyGroup
            [[AWSManager sharedInstance] setKeyGenerationPolicy:self.selectedKeyGenPolicyRow];
            [[AWSManager sharedInstance] setEncryptionPolicy:self.selectedEncryptionPolicyRow];
            [[AWSManager sharedInstance] setGroupId:nil];
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

#pragma mark - MKDropdownMenuDataSource

- (NSInteger)numberOfComponentsInDropdownMenu:(MKDropdownMenu *)dropdownMenu {
    return 1;
}

- (NSInteger)dropdownMenu:(MKDropdownMenu *)dropdownMenu numberOfRowsInComponent:(NSInteger)component {
     if (dropdownMenu.tag == DropDownMenuEncryptionPolicy) {
         return self.encryptionPolicies.count;
     } else {
         return self.keyGenerationPolicies.count;
     }
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
    
    if (dropdownMenu.tag == DropDownMenuEncryptionPolicy) {
        NSString *encryptionPolicy = self.encryptionPolicies[self.selectedEncryptionPolicyRow];
        self.selectedEncryptionPolicy = encryptionPolicy;
        return [[NSAttributedString alloc] initWithString:encryptionPolicy
                                               attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16 weight:UIFontWeightLight],
                                                            NSForegroundColorAttributeName: [UIColor blackColor]}];
    } else if (dropdownMenu.tag == DropDownMenuKeyGenPolicy) {
        NSString *keyGenPolicy = self.keyGenerationPolicies[self.selectedKeyGenPolicyRow];
        self.selectedKeyGenPolicy = keyGenPolicy;
        return [[NSAttributedString alloc] initWithString:keyGenPolicy
                                               attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16 weight:UIFontWeightLight],
                                                            NSForegroundColorAttributeName: [UIColor blackColor]}];
    }
    return nil;
}

- (NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForSelectedComponent:(NSInteger)component {
    
    if (dropdownMenu.tag == DropDownMenuEncryptionPolicy) {
        NSString *encryptionPolicy = self.encryptionPolicies[self.selectedEncryptionPolicyRow];
        return [[NSAttributedString alloc] initWithString:encryptionPolicy
                                               attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16 weight:UIFontWeightRegular],
                                                            NSForegroundColorAttributeName: [UIColor blackColor]}];
    } else if (dropdownMenu.tag == DropDownMenuKeyGenPolicy)  {
        NSString *keyGenPolicy = self.keyGenerationPolicies[self.selectedKeyGenPolicyRow];
        return [[NSAttributedString alloc] initWithString:keyGenPolicy
                                               attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16 weight:UIFontWeightRegular],
                                                            NSForegroundColorAttributeName: [UIColor blackColor]}];
    }
    return nil;
}

- (UIView *)dropdownMenu:(MKDropdownMenu *)dropdownMenu
              viewForRow:(NSInteger)row
            forComponent:(NSInteger)component
             reusingView:(UIView *)view {
    DropDownView *dropDownView = (DropDownView*) view;
    
    if (dropDownView == nil || ![DropDownView isKindOfClass:[DropDownView class]]) {
        dropDownView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DropDownView class]) owner:nil options:nil] firstObject];
    }
    if (dropdownMenu.tag == DropDownMenuEncryptionPolicy) {
        NSString *encryptionPolicy = self.encryptionPolicies[row];
        dropDownView.textLabel.text = encryptionPolicy;
    } else if (dropdownMenu.tag == DropDownMenuKeyGenPolicy) {
        NSString *keyGenPolicy = self.keyGenerationPolicies[row];
        dropDownView.textLabel.text = keyGenPolicy;
    }
    
    return dropDownView;
}

- (UIColor *)dropdownMenu:(MKDropdownMenu *)dropdownMenu backgroundColorForRow:(NSInteger)row forComponent:(NSInteger)component {
    return nil;
}

- (void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
     if (dropdownMenu.tag == DropDownMenuEncryptionPolicy) {
         self.selectedEncryptionPolicyRow = row;
     } else if (dropdownMenu.tag == DropDownMenuKeyGenPolicy) {
         self.selectedKeyGenPolicyRow = row;
     }
    [dropdownMenu reloadComponent:component];
}

@end

