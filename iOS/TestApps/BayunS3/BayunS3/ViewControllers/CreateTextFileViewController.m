//
//  CreateTextFileViewController.m
//  DemoPhase1
//
//  Created by Preeti Gaur on 29/05/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import "CreateTextFileViewController.h"
#import "AWSManager.h"


@interface CreateTextFileViewController ()<AWSManagerDelegate,UITextFieldDelegate,UITextViewDelegate>

@property (strong , nonatomic) UIBarButtonItem *saveButton;
@property (strong, nonatomic) NSString *encryptedFilePath;
@property (strong,nonatomic) NSString *userProvidedFileName;
@property (nonatomic,assign) BOOL autoPop;

@end

/**
 Creates a  new text file and uploads on s3 after encryption.
 */
@implementation CreateTextFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Untitled";
    self.navigationController.navigationBar.hidden = NO;
    
    [self.textView setText:kPlaceholderTextView];
    [self.textView setTextColor:[UIColor grayColor]];
    self.textView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backarrow"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(backButtonIsPressed:)];
    self.navigationItem.leftBarButtonItem=newBackButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.textView resignFirstResponder];
}

- (void)backButtonIsPressed:(id)sender {
    if ([self.textView.text stringByTrimmingCharactersInSet:
         [NSCharacterSet whitespaceCharacterSet]].length == 0  ||
        [[self.textView.text stringByTrimmingCharactersInSet:
          [NSCharacterSet whitespaceCharacterSet]] isEqualToString:kPlaceholderTextView]) {
         [self.navigationController popViewControllerAnimated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Do you want to save the file?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        
        alert.delegate = self;
        alert.tag = alertViewTagSaveFile;
        [alert show];
    }
}

- (IBAction)saveButtonIsPressed :(id)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    if (appDelegate.isNetworkReachable) {
        if ([self.textView.text stringByTrimmingCharactersInSet:
             [NSCharacterSet whitespaceCharacterSet]].length > 0) {
            [self takeInputForFileName];
            
        } else {
            [self updateTextViewFrame];
            [SVProgressHUD showErrorWithStatus:kErrorMsgNoTextToSave];
        }
    } else {
        [self updateTextViewFrame];
        [SVProgressHUD showErrorWithStatus:kErrorMsgInternetConnection];
    }
}


- (void)keyboardWasShown:(NSNotification *)notification {
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    int keyboardHeight = keyboardSize.height;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    // set text view frame by reducing its height by keyboard height
    [self.textView setFrame:CGRectMake(0, 0, screenSize.width, screenSize.height - keyboardHeight)];
}

- (void)addNavigationBarButton {
    self.saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(saveButtonIsPressed:)];
    self.navigationItem.rightBarButtonItem = self.saveButton;
}


- (void)takeInputForFileName {
    [self.view endEditing:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter File Name"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Done", nil];
    
    alert.delegate = self;
    alert.tag = alertViewTagNameFile;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    textField.placeholder = @"File Name";
    textField.delegate = self;
    [alert show];
}


- (void)updateTextViewFrame {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    //set text view frame size equal to screen size
    [self.textView setFrame:CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.textView.frame.size.width, screenSize.height)];
    [self.textView resignFirstResponder];
}

- (void)uploadTextFile {
    NSString *text = self.textView.text;
    
    self.encryptedFilePath= [NSTemporaryDirectory() stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"%@.txt",self.userProvidedFileName]];
    
    NSError *errorWhileWriting = nil;
    [text writeToFile:self.encryptedFilePath
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:&errorWhileWriting];
    
    if (!errorWhileWriting) {
        [AWSManager sharedInstance].delegate = self;
        // upload file
        [[AWSManager sharedInstance] uploadFileFromPath:self.encryptedFilePath];
    } else {
        [SVProgressHUD showErrorWithStatus:kErrorMsgSomethingWentWrong];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - AWSManager Delegate Methods


- (void)s3UploadCompleted {
    //remove the encrypted file after successful upload
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:self.encryptedFilePath error:&error];
   
    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@ saved.",[self.encryptedFilePath lastPathComponent]]];
    [self.textView setEditable:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewFileCreated object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)s3FileTransferFailed:(NSString *)errorMessage {
    [SVProgressHUD dismiss];
    if (errorMessage) {
        if (errorMessage == kErrorMsgUserInActive) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission Denied"
                                                                message:kErrorMsgUserInActive
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            [SVProgressHUD showErrorWithStatus:errorMessage];
        }
    } else {
        [SVProgressHUD showErrorWithStatus:@"File could not be saved. Please try again."];
    }
}

- (void)s3FileExistsForKey:(BOOL)exists {
    if (!exists) {  // new file
        [self uploadTextFile];
    } else {
        [SVProgressHUD dismiss];
        [self updateTextViewFrame];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"File name already exists."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        alert.delegate = self;
        [alert show];
    }
}

- (void)popView {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIAlertView Delegate method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == alertViewTagNameFile) {
        if (buttonIndex == 1) {
            [self.textView becomeFirstResponder];
            NSString *fileName = [alertView textFieldAtIndex:0].text;
            fileName = [fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (fileName.length > 0) {
                    [SVProgressHUD show];
                    self.userProvidedFileName = fileName;
                    [AWSManager sharedInstance].delegate = self;
                    [[AWSManager sharedInstance]checkFileExistenceForKey:
                     [NSString stringWithFormat:@"%@.txt",self.userProvidedFileName]];
            } else {
                [alertView dismissWithClickedButtonIndex:0 animated:NO];
                [self takeInputForFileName];
            }
        } else {
            [self.textView becomeFirstResponder];
        }
    } else if (alertView.tag == alertViewTagSaveFile) {
        if (buttonIndex == 0) {
            [self performSelector:@selector(popView) withObject:self afterDelay:0.5];
        } else {
            [self takeInputForFileName];
        }
    }
}

#pragma mark - UITextField delegate method

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
                                                        replacementString:(NSString *)string {
    if(textField.text.length > 25) { // file name must be less than 25 characters
        return NO;
    }
    return YES;
}

#pragma mark - UITextView delegate method

- (void)textViewDidBeginEditing:(UITextView *)textView {
    textView.selectedRange = NSMakeRange(0, 0);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
                                                replacementText:(NSString *)text {
    NSString *textViewText = textView.text;
    if ([self firstString:textViewText containsSecond:kPlaceholderTextView]) {
        [textView setText:[textViewText stringByReplacingOccurrencesOfString:kPlaceholderTextView  withString:@""]];
        if ([text isEqualToString:@""]) {
            return NO;
        } else {
            [textView setTextColor:[UIColor blackColor]];
            return YES;
            
        }
    } else if ([textViewText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 1 && [text isEqualToString:@""]) {
        [textView setText:kPlaceholderTextView];
        [textView setTextColor:[UIColor grayColor]];
        textView.selectedRange = NSMakeRange(0, 0);
        return NO;
    }
    [textView setTextColor:[UIColor blackColor]];
    return YES;
}

- (BOOL)firstString:(NSString*)firstString containsSecond:(NSString*)secondString {
    NSRange range = [firstString rangeOfString:secondString];
    return range.length != 0;
}

@end