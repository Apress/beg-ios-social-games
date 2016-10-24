//
//  UFOStoreViewController.m
//  UFOs
//
//  Created by Kyle Richter on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UFOStoreViewController.h"

@implementation UFOStoreViewController

@synthesize productArray;

-(IBAction)dismiss;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    if([SKPaymentQueue canMakePayments])
    {
        NSSet *productIdentifiers = [NSSet setWithObjects:@"com.dragonforged.ufo.newShip1", @"com.dragonforged.ufo.subscription",@"com.dragonforged.ufo.newShip2", nil];
        productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
        productsRequest.delegate = self;
        [productsRequest start];
    }
    
    else    
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Unable to make purchases with this device." delegate:nil cancelButtonTitle:@"Dimiss" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

- (void)viewDidUnload
{
    productsRequest.delegate = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
		return YES;
	
	return NO;
}

#pragma mark - Store Delegate


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    self.productArray = [response products];
    
    for(SKProduct *product in self.productArray)
    {
        NSLog(@"Product title: %@" , product.localizedTitle);
        NSLog(@"Product description: %@" , product.localizedDescription);
        NSLog(@"Product price: %@" , product.price);
        NSLog(@"Product id: %@\n\n" , product.productIdentifier);    
    }
    
    for (NSString *invalidProduct in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid: %@" , invalidProduct);
    }
    
    [request release];
    [storeTable reloadData];
}

- (void)recordTransactionData:(SKPaymentTransaction *)transaction
{
    //error checking
    if(transaction.transactionReceipt == nil)
        return;
    
    NSMutableArray *transactionArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"transactions"]];
    [transactionArray addObject: transaction.transactionReceipt];
    [[NSUserDefaults standardUserDefaults] setObject:transactionArray forKey:@"transactions"];
    [transactionArray release];
}

- (void)unlockContent:(NSString *)productId
{
    if ([productId isEqualToString:@"com.dragonforged.ufo.newShip1"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shipPlusAvailable" ];
    }
    
    if ([productId isEqualToString:@"com.dragonforged.ufo.subscription"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"subscriptionAvailable" ];
    }
}

- (void)finishTransaction:(SKPaymentTransaction *)transaction withSuccess:(BOOL)success
{
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSString *string = [[NSString alloc] initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding];
    
    NSLog(@"Receipt: %@\n\n\n\n", string);
    
    NSDictionary *transactionDictionary = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    
    if (success)
    {
        NSLog(@"Transaction was successful: %@", transactionDictionary);
        
    }
    else
    {
        NSLog(@"Transaction was unsuccessful: %@", transactionDictionary);
    }
}

- (void)transactionDidComplete:(SKPaymentTransaction *)transaction
{
    [self recordTransactionData:transaction];
    [self unlockContent:[[transaction payment] productIdentifier]];
    [self finishTransaction:transaction withSuccess:YES];
}


- (void)transactionDidRestore:(SKPaymentTransaction *)transaction
{
    [self recordTransactionData:transaction.originalTransaction];
    [self unlockContent:[[[transaction originalTransaction] payment] productIdentifier]];
    [self finishTransaction:transaction withSuccess:YES];
}

- (void)transactionDidFail:(SKPaymentTransaction *)transaction
{
    if([[transaction error] code] != SKErrorPaymentCancelled)
    {
        [self finishTransaction:transaction withSuccess:NO];
    }
    
    //SKErrorPaymentCancelled
    else
    {
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        
        if([transaction transactionState] == SKPaymentTransactionStatePurchased)
        {
            [self transactionDidComplete:transaction];
        }
        
        else if([transaction transactionState] == SKPaymentTransactionStateFailed)
        {
            [self transactionDidFail:transaction];
        }
        
        else if([transaction transactionState] == SKPaymentTransactionStateRestored)
        {
            [self transactionDidRestore:transaction];
        }
        
        else
        {
            NSLog(@"Unhandled case: %@", transaction);
        }
    }
}



#pragma mark - Tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	
	return [productArray count];
}	

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
    SKProduct *product = [self.productArray objectAtIndex: [indexPath row]];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - $%@", product.localizedTitle, product.price];
    cell.detailTextLabel.text = product.localizedDescription;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SKProduct *product = [self.productArray objectAtIndex: [indexPath row]];
    SKPayment *payment = [SKPayment paymentWithProduct:product]; //code updated since book publication
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

-(void)dealloc
{
    [productArray release]; productArray = nil;
    [super dealloc];
}


@end
