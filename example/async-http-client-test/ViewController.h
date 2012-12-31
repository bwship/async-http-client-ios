//
//  ViewController.h
//  async-http-client-test
//
//  Created by Bob Wall on 12/31/12.
//  Copyright (c) 2012 Wall Mobile Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (IBAction)addItemClicked:(id)sender;
- (IBAction)getItemsClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *resultsTextView;
@property (strong) NSArray* items;

@end
