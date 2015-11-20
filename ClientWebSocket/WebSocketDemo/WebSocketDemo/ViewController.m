//
//  ViewController.m
//  fuckdemo
//
//  Created by da zhan on 13-7-17.
//  Copyright (c) 2013年 da zhan. All rights reserved.
//

 

#import "ViewController.h"
#import "SocketIOPacket.h"
#import "SocketIOJSONSerialization.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.title = @"聊天";

    
    socketIO = [[SocketIO alloc] initWithDelegate:self];
    //socketIO.useSecure = YES;
    [socketIO connectToHost:@"localhost" onPort:8127];
    self.messages = [[NSMutableArray alloc] initWithObjects:nil];

}

-(void)sendMessageToWebSocket:(NSString *)str
{
    SocketIOCallback cb = ^(id argsData) {
        NSDictionary *response = argsData;
        // do something with response
        NSLog(@"ack arrived: %@", response);
    };
    [socketIO sendMessage:str withAcknowledge:cb];
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSLog(@"didReceiveEvent()");
    NSString *receiveData=packet.data;
    NSData *utf8Data = [receiveData dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictemp=(NSDictionary *)[SocketIOJSONSerialization objectFromJSONData:utf8Data error:nil];
    NSDictionary *aadic=(NSDictionary *)[[dictemp objectForKey:@"args"] objectAtIndex:0];
    NSString * temp = [aadic objectForKey:@"text"];
   // tt.text=temp;
    NSLog(@"temp==%@",temp);
    if (![temp isEqualToString:@"connectok"]) {
        [self.messages addObject:temp];
        
        if((self.messages.count - 1) % 2)
            [MessageSoundEffect playMessageSentSound];
        else
            [MessageSoundEffect playMessageReceivedSound];
        
        [self finishSend];
    }
    
}

- (void) socketIO:(SocketIO *)socket failedToConnectWithError:(NSError *)error
{
    NSLog(@"failedToConnectWithError() %@", error);
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

#pragma mark - Messages view controller
- (BubbleMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row % 2) ? BubbleMessageStyleIncoming : BubbleMessageStyleOutgoing;
}

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.row];
}

- (void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
    
    [self sendMessageToWebSocket:text];
    [self.messages addObject:text];
    
    if((self.messages.count - 1) % 2)
        [MessageSoundEffect playMessageSentSound];
    else
        [MessageSoundEffect playMessageReceivedSound];
    
    [self finishSend];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
