//
//  ViewController.m
//  async-http-client-test
//
//  Created by Bob Wall on 12/31/12.
//  Copyright (c) 2012 Wall Mobile Solutions. All rights reserved.
//

#import "ViewController.h"
#import "ItemModel.h"

@implementation ViewController

@synthesize resultsTextView = _resultsTextView;
@synthesize items = _items;

- (IBAction)addItemClicked:(id)sender {
    ItemModel *item = [[ItemModel alloc] init];
    
    item.name = @"test";
    item.description = @"@testing adding an item";
    
    [ItemModel item:item finished:^(WebServiceResponse *response) {
        if (!response.systemError)
            self.resultsTextView.text = @"Item successfully added.";
        else
           self.resultsTextView.text = @"An error occurred adding an item.";
    }];
}

- (IBAction)getItemsClicked:(id)sender {
    [ItemModel getItemsLimit:100
                    finished:^(WebServiceResponse* response){
        if (!response.systemError) {
            self.items = [ItemModel loadItemsFromDictionary:response.dictionary];
            self.resultsTextView.text = @"Items successfully selected.";
        }
        else
            self.resultsTextView.text = @"An error occurred selecting items.";
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    self.resultsTextView = nil;
}

@end
