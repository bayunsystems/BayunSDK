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

@interface ListFilesViewController ()<AWSManagerDelegate, UIActionSheetDelegate ,UIDocumentPickerDelegate,UIDocumentMenuDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate,UIDocumentInteractionControllerDelegate>

@property (strong , nonatomic) UIBarButtonItem *createButton;
@property (strong,nonatomic) NSArray *s3BucketObjectArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong , nonatomic) NSIndexPath *indexPathOfRowToDelete;
@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;
@property (nonatomic,strong) QLPreviewController *previewController;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

/**
 Lists all the files in AWSS3 bucket
 */
@implementation ListFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Files";
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.hidden = NO;
    
    self.s3BucketObjectArray = [[NSMutableArray alloc] init];
    
    [SVProgressHUD show];
    
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
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationItem setHidesBackButton:YES];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kBucketExists]) {
        [self getS3BucketObjects];
    } else {
        [self createS3BucketWithName];
    }
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

- (IBAction)uploadButtonIsPressed:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Upload",@"Logout", nil];
    actionSheet.destructiveButtonIndex = 1;
    
    [actionSheet showInView:self.view];
    
}

- (void)createS3BucketWithName {
    AWSManager *awsManagerInstance = [AWSManager sharedInstance];
    awsManagerInstance.delegate = self;
    NSString *bucketName = [NSString stringWithFormat:@"bayun-test-%@",[[NSUserDefaults standardUserDefaults] valueForKey:kCompanyName]];
    [awsManagerInstance createS3BucketWithName:[bucketName lowercaseString]];
}

- (void)getS3BucketObjects {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.isNetworkReachable) {
        AWSManager *awsManagerInstance = [AWSManager sharedInstance];
        awsManagerInstance.delegate = self;
        [awsManagerInstance getS3FileList];
    } else {
        [self endRefreshing];
        [SVProgressHUD showErrorWithStatus:kErrorMsgInternetConnection];
    }
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission Denied"
                                                        message:kErrorMsgUserInActive
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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
        //logout is opted
        AppDelegate *delegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        [delegate showLoginScreen];
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
    
    [[AWSManager sharedInstance] downloadFileToURL:[NSURL fileURLWithPath:filePath]];
    
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
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete File"
                                                                message:[NSString stringWithFormat:@"Delete %@ permanently?",s3Object.key]
                                                               delegate:self cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"OK",nil];
            [alertView show];
        } else if ([BayunCore sharedInstance].employeeStatus == BayunEmployeeStatusUnknown) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                message:[NSString stringWithFormat:@"Sorry, cannot delete file at the moment"]
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


-(void)s3BucketObjectListDownload:(AWSS3ListObjectsOutput *)bucketObjectsList {
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

- (void)s3UploadProgress:(float)progress {
    [SVProgressHUD showProgress:progress status:@"Uploading"];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
}

- (void)s3UploadCompleted {
    [SVProgressHUD dismiss];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    [self getS3BucketObjects];
}

- (void)s3DownloadProgress:(float)progress {
    [SVProgressHUD showProgress:progress status:@"Downloading"];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
}

- (void)s3DownloadCompleted {
    [SVProgressHUD dismiss];
    [self.previewController refreshCurrentPreviewItem];
}

- (void)s3FileDeletionCompleted {
    [SVProgressHUD dismiss];
    [self.tableView reloadData];
    [self getS3BucketObjects];
    self.indexPathOfRowToDelete = nil;
    [SVProgressHUD showSuccessWithStatus:@"File is deleted sucessfully."];
}

- (void)s3BucketCreated {
    [self getS3BucketObjects];
}

- (void)s3BucketAlreadyExists {
    [self getS3BucketObjects];
}

- (void)s3FileDeletionFailed {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:kErrorMsgFileDeletionFailed];
        [self.tableView reloadRowsAtIndexPaths:@[self.indexPathOfRowToDelete] withRowAnimation:UITableViewRowAnimationNone];
        self.indexPathOfRowToDelete = nil;
    });
}

- (void)s3FileTransferFailed:(NSString *)errorMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self endRefreshing];
        [SVProgressHUD dismiss];
        if (errorMessage) {
            if (errorMessage == kErrorMsgUserInActive) {
                [self notifyInactiveUser];
            } else {
                [SVProgressHUD showErrorWithStatus:errorMessage];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:kErrorMsgSomethingWentWrong];
        }
    });
}

- (void) s3BucketCreationFailed {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:kErrorMsgSomethingWentWrong];
    });
}

#pragma mark - alert view delegate method

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {  // OK button is pressed to delete a file
        AWSS3Object *s3Object = (AWSS3Object*)[self.s3BucketObjectArray objectAtIndex:self.indexPathOfRowToDelete.row];
        [[AWSManager sharedInstance]deleteFileWithName:s3Object.key];
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
    
    [[AWSManager sharedInstance] uploadFile:url];
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
            [[AWSManager sharedInstance] uploadFile:[NSURL fileURLWithPath:filePath]];
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

@end
