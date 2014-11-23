//
//  TMTText.m
//  TextAnalysis
//
//  Created by Greg on 3/13/2014.
//  Copyright (c) 2014 Tasty Morsels. All rights reserved.
//

#import "TMTText.h"
#import "TMTNode.h"

@interface TMTText ()

@end

@implementation TMTText


-(id)init{
    self = [super init];
    if (self){
        _decomposedText = [[NSMutableArray alloc] init];
        _uniqueWords = [[NSMutableArray alloc] init];
        _unsortedUniqueWords = [[NSMutableSet alloc] init];
        _wordFrequency = [[NSMutableDictionary alloc] init];
        _root = [[TMTNode alloc] initWithName:@""];
    }
    return self;
}




- (void) encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.fileURL forKey:@"TMTTextFileURL"];
    [aCoder encodeObject:self.fileContents forKey:@"TMTTextFileContents"];
    [aCoder encodeObject:self.uniqueWords forKey:@"TMTTextUniqueWords"];
    [aCoder encodeObject:self.wordFrequency forKey:@"TMTTextWordFrequency"];
    [aCoder encodeObject:self.root forKey:@"TMTTextRoot"];
    [aCoder encodeObject:self.decomposedText forKey:@"TMTTextDecomposedText"];
    [aCoder encodeObject:self.unsortedUniqueWords forKey:@"TMTTextUnsortedUniqueWords"];
}

- (id) initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self){
        _fileURL = [aDecoder decodeObjectForKey:@"TMTTextFileURL"];
        _fileContents = [aDecoder decodeObjectForKey:@"TMTTextFileContents"];
        _uniqueWords = [aDecoder decodeObjectForKey:@"TMTTextUniqueWords"];
        _wordFrequency = [aDecoder decodeObjectForKey:@"TMTTextWordFrequency"];
        _root = [aDecoder decodeObjectForKey:@"TMTTextRoot"];
        _decomposedText = [aDecoder decodeObjectForKey:@"TMTTextDecomposedText"];
        _unsortedUniqueWords = [aDecoder decodeObjectForKey:@"TMTTextUnsortedUniqueWords"];
    }
    return self;
}


-(void)resetAnalysis{
    
    
    [self.uniqueWords removeAllObjects];
    [self.unsortedUniqueWords removeAllObjects];
    [self.decomposedText removeAllObjects];
    [self.wordFrequency removeAllObjects];
    [self.root reinitialize];
}

-(void)decomposeText{
    
    NSCharacterSet *nonLetters = [[NSCharacterSet letterCharacterSet] invertedSet];
    
    //Tokenize the text into sequences of letters.  Contiguous non-letter characters
    //add empty strings to the array that will have to be stripped out.
    [self.decomposedText addObjectsFromArray:[self.fileContents componentsSeparatedByCharactersInSet:nonLetters]];
    
    //Strip out the empty strings by keeping only those that do not match @""
    //by filtering using a predicate
    [self.decomposedText filterUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != %@", @""]];
    
    //make all the tokens lower case only
    for (int i=0; i < [self.decomposedText count]; i++){
        
        self.decomposedText[i] = [self.decomposedText[i] lowercaseString];
        
    }
    NSLog(@"Number of tokens: %lu", (unsigned long)[self.decomposedText count]);
   
}





-(void)identifyUniqueWords{
    
    //Go through the list of tokens and check to set if each token is already in the set
    //of words.  If it is not (this is the first occurrance), add it to the set.
    [self.decomposedText enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([self.unsortedUniqueWords containsObject:obj] == NO ){
            [self.unsortedUniqueWords addObject:obj];
        }
    }];
    
    //Make an array from the resulting set and then store the sorted array as the list of
    //unique words.
    NSArray *unsortedList = [[NSArray alloc] initWithArray:[self.unsortedUniqueWords allObjects]];
    [self.uniqueWords addObjectsFromArray:[unsortedList sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    
    
    NSLog(@"Number of unique tokens:  %lu", (unsigned long)[self.uniqueWords count]);
    
}


-(void)computeWordFrequency{
   int wordOccurances = 0;
    for ( int i=0; i < [self.uniqueWords count]; i++){
        wordOccurances = 0;
        for (int j=0; j < [self.decomposedText count]; j++){
            if ([self.decomposedText[j] compare:self.uniqueWords[i] options:
                 (NSCaseInsensitiveSearch)] == NSOrderedSame){
                
                
                wordOccurances++;
            }
        }
        [self.wordFrequency setObject:[NSNumber numberWithInt:wordOccurances]
                               forKey:self.uniqueWords[i]];
        
        
    }
/*
    NSArray *temp = [NSArray arrayWithArray:[self.wordFrequency keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
       
        if ([obj1 integerValue] > [obj2 integerValue]){
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 integerValue] < [obj2 integerValue]){
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }]];
*/

    //Sorting the words by number of occurrances
    /*
    NSArray *temp = [NSArray arrayWithArray:[self.wordFrequency keysSortedByValueUsingSelector:@selector(compare:)]];
    
    
    
    
    NSLog(@"%@",temp[0]);
    for (int i=0; i < [temp count]; i++){
        NSLog(@"%@ %@",temp[i], [self.wordFrequency valueForKey:temp[i]]);
    }
     */
    
}




-(void)buildTree{
    //For each word in the list of unique words, add each letter to the ngram tree
    //as it is encountered for the first time or update count of occurrences of that letter.
    //Then for each of those letters, build or update the descendant node in the tree.
    //For example, for the "cat", we check to see if "c" is in the tree.  If it isn't, we add
    //it.  If it is, we increase the count of occurrences of that letter by one.  Then we look at the existing
    //branches from the "c" to see if "a" is there already.  If it is, we update the count.  Otherwise,
    //we add that branch.  Then we look at branches from "a" to see if "t" is there.  Lastly, we
    //look at branches from "t" for "terminal".  Then we start all over with "a".
    //
    //       ---- c ---- a --- t --- terminal
    //       ---- a ---- t --- terminal
    //       ---- t ---- terminal
    //
    // This is the resulting tree, where each of the --- would have a count of 1 associated
    // with it.  If the next unique word were "bad", the tree would look like this
    // after analysis:
    //
    //      -2- a --- t --- terminal
    //            --- d --- terminal
    //      --- b --- a --- d --- terminal
    //      --- c --- a --- t --- terminal
    //      --- d --- terminal
    //      --- t --- terminal
    //
    // Counts are still 1 except where indicated.  Adding "bid", makes a tree that looks like this:
    //
    //      -2- a --- t --- terminal
    //            --- d --- terminal
    //      -2- b --- a --- d --- terminal
    //            --- i --- d --- terminal
    //      --- c --- a --- t --- terminal
    //      --- d --- terminal
    //      --- i --- d --- terminal
    //      --- t --- terminal
    //
    // If this were the full set of words, the tree would tell us that given an initial "a", there is
    // a 50% chance if will be followed by a "t".
    //
    // Building/traversing the tree is done recursively.

    //unichar singleLetter [1];
    
    //Loop over the list of unique words
    for (int i=0; i < [self.uniqueWords count]; i++){
        
        NSString *word = [NSString stringWithString:self.uniqueWords[i]];
        NSLog(@"Building tree for word %i of %lu: %@", i+1, [self.uniqueWords count], word);
        while (![word  isEqual: @""]) {
            word = [self checkTree:self.root forString:word];
        }
    }
    
    //Traverse the tree and normalize
    [self.root normalizeTree];
    
}


-(NSString *)checkTree:(TMTNode *)aNode forString:(NSString *)aString{
    
    NSString *firstLetter = [aString substringWithRange:NSMakeRange(0, 1)];
    NSString *remainingString = [aString substringWithRange:NSMakeRange(1, [aString length]-1)];
   /*
    if ([remainingString length]==0){
        NSLog(@"%@:  %@ + terminal",aNode.name,firstLetter);
    } else {
        NSLog(@"%@:  %@ + %@",aNode.name, firstLetter,remainingString);
    }
    */
    
    //Check tree under aNode to see if firstLetter is there as a key
    if ( aNode.tree[firstLetter] == nil){
        //It's not there, so add it.  Count is initialized to 1.
        NSMutableString *name = [NSMutableString stringWithString:aNode.name];
        [name appendString:firstLetter];
        [aNode.tree setObject:[[TMTNode alloc]initWithName:name] forKey:firstLetter];
    } else {
        [aNode.tree[firstLetter] incrementOccurrenceCount];
    }
    
    //Pass remainder of string to this node unless this was a terminal letter
    if ( [remainingString length] == 0){
        //This was a terminal letter (i.e. last letter in a word).
        if ( [[(TMTNode *)aNode.tree[firstLetter] tree]  objectForKey:@"terminal"] != nil){
            //The terminal branch for this letter exists for just increase the count.
            [[[(TMTNode *)aNode.tree[firstLetter] tree]  objectForKey:@"terminal"] incrementOccurrenceCount];
        } else {
            //Add the terminal branch
            NSMutableString *name = [NSMutableString stringWithString:[(TMTNode *)aNode.tree[firstLetter] name]];
            [name appendString:@" terminal"];
            [[(TMTNode *)aNode.tree[firstLetter] tree] setObject:[[TMTNode alloc] initWithName:name] forKey:@"terminal"];
        }
    } else {
        [self checkTree:aNode.tree[firstLetter] forString:remainingString];
    }
    
    return remainingString;
    
}

-(NSNumber *)computeProbabilityForLeftFragment:(NSString *)leftFrag
                                 rightFragment:(NSString *)rightFrag{

    float leftProb=1.0;
    float comboProb = 1.0;
    
    TMTNode *node = self.root; //just don't change anything in the tree!
    NSString *frag = [NSString stringWithString:leftFrag];
  
    while ([frag length] != 0) {
        NSString *key = [frag substringWithRange:NSMakeRange(0, 1)];
        frag = [frag substringWithRange:NSMakeRange(1, [frag length]-1)];
        if (node.tree[key] != nil){
            leftProb = leftProb * [[node.tree[key] frequency] floatValue];
            node = node.tree[key];
        } else {
            //the left fragment sequence does not exist in the tree
            //so all bets are off
            leftProb = 0.0;
            comboProb = 0.0;
            frag = @"";
            leftFrag = @""; //set this to an empty string so
                            //marginal prob will not be computed
        }
    } //coming out of this loop, the node corresponds to the end
    //of the path through the tree for the left fragment
    
    if ([leftFrag length] != 0){
        if ([rightFrag compare:@"terminal"]==NSOrderedSame){
            comboProb = [[node.tree[@"terminal"] frequency] floatValue];
        } else {
            frag = rightFrag;
            while ([frag length] != 0) {
                NSString *key = [frag substringWithRange:NSMakeRange(0, 1)];
                frag = [frag substringWithRange:NSMakeRange(1, [frag length]-1)];
                if (node.tree[key] != nil){
                    comboProb = comboProb * [[node.tree[key] frequency] floatValue];
                    node = node.tree[key];
                } else {
                    //the right fragment sequence does not occur following the
                    //left fragment,
                    comboProb = 0.0;
                    frag = @"";
                }
            }
        }
    }
   
    
    if ([rightFrag length]==0){
        return [NSNumber numberWithFloat:leftProb];
    } else {
        return [NSNumber numberWithFloat:comboProb];
    }
}


@end
