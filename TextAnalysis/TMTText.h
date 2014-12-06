//
//  TMTText.h
//  TextAnalysis
//
//  Created by Greg on 3/13/2014.
//  Copyright (c) 2014 Tasty Morsels. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMTNode.h"

@interface TMTText : NSObject <NSCoding>

@property NSURL *fileURL;
@property NSString *fileContents;
@property NSMutableArray *uniqueWords;
@property NSMutableDictionary *wordFrequency;
//@property NSMutableDictionary *tree;
@property TMTNode *root;
@property NSMutableArray *decomposedText;
@property NSMutableSet *unsortedUniqueWords;

@property NSSet *charactersUsed;


-(id)init;
-(void)identifyUniqueWords;
-(void)buildSetOfCharactersUsedInWords;
-(void)decomposeText;
-(void)computeWordFrequency;
-(void)buildTree;
-(void)resetAnalysis;
-(NSString *)checkTree:(TMTNode *)aNode forString:(NSString *)aString;
-(NSNumber *)computeProbabilityForLeftFragment:(NSString *)left rightFragment:(NSString *)right;

- (void) encodeWithCoder:(NSCoder *)aCoder;
- (id) initWithCoder:(NSCoder *)aDecoder;


@end
