//
//  TMTAppDelegate.m
//  TextAnalysis
//
//  Created by Greg on 3/13/2014.
//  Copyright (c) 2014 Tasty Morsels. All rights reserved.
//

#import "TMTAppDelegate.h"
#import "TMTText.h"

@interface TMTAppDelegate ()
@property BOOL timesUp;
@end

@implementation TMTAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    TMTText *theText = [[TMTText alloc] init];
    //self.text = theText;
    [self setText:theText];
    
    [self.fileContents setFont:[NSFont fontWithName:@"Courier" size:14.0]];
    [self.fileContents setString:@""];
    
    [self.buildTreeButton setAcceptsTouchEvents:NO];
    [self.buildTreeButton setEnabled:NO];
    [self.computeProbability setEnabled:NO];
    [self.saveTreeButton setEnabled:NO];
    

    
}


- (IBAction)selectFile:(id)sender {
    //NSLog(@"select pressed");
    
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result==NSFileHandlingPanelOKButton){
            NSURL *theDoc = [[panel URLs] objectAtIndex:0];
            
            //NSLog(@"%@",theDoc);
            
            [self.text setFileURL:theDoc];
            [self.fileURL setStringValue:[theDoc absoluteString]];
            [self openFileDirectly];
            
        }
    }];

    
}



- (void)openFileDirectly {
    
    
    if ([self.text fileURL] != Nil) {
        
        //Will require new analysis before probabilities can be computed
        //or the analysis saved
        [self.text resetAnalysis];
        [self.computeProbability setEnabled:NO];
        [self.saveTreeButton setEnabled:NO];
        
        
        NSURL *theFileURL = self.text.fileURL;
        NSError *error;
        [self.progressBar startAnimation:self];
        
        // [self performSelector:@selector(turnOffProgressIndicator) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0];
        
        NSString *stringFromFileAtURL= [[NSString alloc] initWithContentsOfURL:theFileURL encoding:NSUTF8StringEncoding error:&error];
        if (stringFromFileAtURL == nil){
            NSLog(@"%@",[error localizedDescription]);
        } else {
            [self.text setFileContents:stringFromFileAtURL];
            [self.fileContents setString:self.text.fileContents];
            NSLog(@"%@",self.text.fileContents);
            [self.buildTreeButton setEnabled:YES];
        }
    } else {
        NSLog(@"fileURL not set");
    }
    [self.progressBar stopAnimation:self];
}

- (IBAction)computeProbability:(id)sender {
    
    
    NSString *leftFrag = [NSString stringWithString:[self.leftFragmentTextField stringValue]];
    NSString *rightFrag = [NSString stringWithString:[self.rightFragmentTextField stringValue]];
    if ([leftFrag isEqualToString:@""]){
        [self.probabilityTextField setStringValue:@"!ERROR"];
    } else {
        NSNumber *prob = [[NSNumber alloc] init];
        prob = [self.text computeProbabilityForLeftFragment:leftFrag rightFragment:rightFrag];
        [self.probabilityTextField setStringValue:[prob stringValue]];
    }
    
}

- (IBAction)setRightFragToTerminal:(id)sender {
    if ([self.terminalRadioButton state]==1){
        [self.rightFragmentTextField setStringValue:@"terminal"];
        [self.rightFragmentTextField setEnabled:NO];
    } else {
        [self.rightFragmentTextField setStringValue:@""];
        [self.rightFragmentTextField setEnabled:YES];
    }
}

- (IBAction)saveState:(id)sender {
    NSSavePanel *panel = [NSSavePanel savePanel];
   
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result==NSFileHandlingPanelOKButton){
            NSURL *stateURL = [panel URL];
            NSString *filePath = [NSString stringWithString:[stateURL resourceSpecifier]];
            filePath = [filePath stringByRemovingPercentEncoding];
            NSLog(@"file path for archiving (remove percent encoding):%@:",filePath);
            
            BOOL success = [NSKeyedArchiver archiveRootObject:_text toFile:filePath];
                if (!success){
                    NSLog(@"Error saving state.");
                }
        }
    }];
}






- (IBAction)restoreState:(id)sender {
    
    [self.text resetAnalysis];
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result==NSFileHandlingPanelOKButton){
            NSURL *stateURL = [panel URL];
            NSString *filePath = [NSString stringWithString:[stateURL resourceSpecifier]];
            filePath = [filePath stringByRemovingPercentEncoding];
            NSLog(@"file path for archiving (remove percent encoding):%@:",filePath);
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
            if (fileExists){
                self.text = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
                [self.fileURL setStringValue:[[self.text fileURL] absoluteString]];
                [self.fileContents setString:self.text.fileContents];
                [self.computeProbability setEnabled:YES];
            }else{
                NSLog(@"Unable to restore state: file not found.");
            }

        }
    }];

    
    NSString *stateFilePath = [NSString stringWithFormat:@"%@/Documents/tree.dat",NSHomeDirectory()];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:stateFilePath];
    if (fileExists){
        self.text = [NSKeyedUnarchiver unarchiveObjectWithFile:stateFilePath];
        [self.fileURL setStringValue:[[self.text fileURL] absoluteString]];
        [self.fileContents setString:self.text.fileContents];
        [self.computeProbability setEnabled:YES];
        
        
    }else{
        NSLog(@"Unable to restore state: file not found.");
    }
}

- (IBAction)saveText:(id)sender {
}


- (IBAction)buildTree:(id)sender {
    
    NSLog(@"Tokenizing...");
    [self.text decomposeText];
    NSLog(@"Identifying unique words...");
    [self.text identifyUniqueWords];
    
    NSLog(@"Identifying characters used in words...");
    [self.text buildSetOfCharactersUsedInWords];
    
    //  NSLog(@"Computing Word Frequency...");
    //  [self.text computeWordFrequency];

    NSLog(@"Building tree:");
    //[self.text buildSequenceTree];
    [self.text buildTree];
    [self.computeProbability setEnabled:YES];
    [self.saveTreeButton setEnabled:YES];
    [self.buildTreeButton setEnabled:NO];//analysis done
    
}


-(void)turnOffProgressIndicator{
    //Using a performSelector:afterDelay call on self to turn off the
    //progress bar animation after a specific delay for testing
    
    //in the end, won't need this...
    [self.progressBar stopAnimation:self];
   }
@end
