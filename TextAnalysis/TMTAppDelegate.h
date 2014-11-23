//
//  TMTAppDelegate.h
//  TextAnalysis
//
//  Created by Greg on 3/13/2014.
//  Copyright (c) 2014 Tasty Morsels. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TMTText;

@interface TMTAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *fileURL;
@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (unsafe_unretained) IBOutlet NSTextView *fileContents;
@property (weak) IBOutlet NSButton *buildTreeButton;
@property (weak) IBOutlet NSButton *computeProbability;
@property (weak) IBOutlet NSTextField *leftFragmentTextField;
@property (weak) IBOutlet NSTextField *rightFragmentTextField;
@property (weak) IBOutlet NSTextField *probabilityTextField;
@property (weak) IBOutlet NSButton *terminalRadioButton;
@property (weak) IBOutlet NSButton *saveTreeButton;
@property (weak) IBOutlet NSButton *restoreButton;


@property TMTText *text;

- (IBAction)buildTree:(id)sender;
- (void)turnOffProgressIndicator;
- (void)openFileDirectly;
- (IBAction)computeProbability:(id)sender;
- (IBAction)setRightFragToTerminal:(id)sender;
- (IBAction)saveState:(id)sender;
- (IBAction)restoreState:(id)sender;
- (IBAction)saveTextTest:(id)sender;



@end
