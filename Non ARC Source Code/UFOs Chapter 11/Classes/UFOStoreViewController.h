//
//  UFOStoreViewController.h
//  UFOs
//
//  Created by Kyle Richter on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface UFOStoreViewController : UIViewController <SKProductsRequestDelegate, UITableViewDelegate, UITableViewDataSource, SKPaymentTransactionObserver>
{
    
    SKProductsRequest *productsRequest;
    NSArray *productArray;
    
    IBOutlet UITableView *storeTable;
    
}

@property(nonatomic, retain) NSArray *productArray;

-(IBAction)dismiss;


@end
