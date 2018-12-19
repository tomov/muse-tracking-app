//
//  SimpleController.m
//  MuseStatsIos
//
//  Created by Yue Huang on 2015-09-01.
//  Copyright (c) 2015 InteraXon. All rights reserved.
//

#import "SimpleController.h"

@interface SimpleController ()
@property IXNMuseManagerIos * manager;
@property (weak, nonatomic) IXNMuse * muse;
@property (nonatomic) NSMutableArray* logLines;
@property (nonatomic) BOOL lastBlink;
@end

@implementation SimpleController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    if (!self.manager) {
        self.manager = [IXNMuseManagerIos sharedManager];
    }
}

- (instancetype) initWithNibName:(NSString *)nibNameOrNil
                          bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.manager = [IXNMuseManagerIos sharedManager];
        [self.manager setMuseListener:self];
        //self.tableView = [[UITableView alloc] init];

        //self.logView = [[UITextView alloc] init];
        self.logLines = [NSMutableArray array];
        //[self.logView setText:@""];
        
        [[IXNLogManager instance] setLogListener:self];
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSString * dateStr = [[dateFormatter stringFromDate:[NSDate date]] stringByAppendingString:@".log"];
        NSLog(@"%@", dateStr);
    }
    return self;
}

- (void)log:(NSString *)fmt, ... {
    va_list args;
    va_start(args, fmt);
    NSString *line = [[NSString alloc] initWithFormat:fmt arguments:args];
    va_end(args);
    NSLog(@"%@", line);
    [self.logLines insertObject:line atIndex:0];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        //[self.logView setText:[self.logLines componentsJoinedByString:@"\n"]];
    });
}

- (void)receiveLog:(nonnull IXNLogPacket *)l {
  [self log:@"%@: %llu raw:%d %@", l.tag, l.timestamp, l.raw, l.message];
}

- (void)museListChanged {
    //[self.connecting];
    
    //[self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [[self.manager getMuses] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"nil";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:simpleTableIdentifier];
    }
    NSArray * muses = [self.manager getMuses];
    if (indexPath.row < [muses count]) {
        IXNMuse * muse = [[self.manager getMuses] objectAtIndex:indexPath.row];
        cell.textLabel.text = [muse getName];
        if (![muse isLowEnergy]) {
            cell.textLabel.text = [cell.textLabel.text stringByAppendingString:
                                   [muse getMacAddress]];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray * muses = [self.manager getMuses];
    if (indexPath.row < [muses count]) {
        IXNMuse * muse = [muses objectAtIndex:indexPath.row];
        @synchronized (self.muse) {
            if(self.muse == nil) {
                self.muse = muse;
            }else if(self.muse != muse) {
                [self.muse disconnect:false];
                self.muse = muse;
            }
        }
        [self connect];
        [self log:@"======Choose to connect muse %@ %@======\n",
              [self.muse getName], [self.muse getMacAddress]];
    }
}

- (void)receiveMuseConnectionPacket:(IXNMuseConnectionPacket *)packet
                               muse:(IXNMuse *)muse {
    NSString *state;
    switch (packet.currentConnectionState) {
        case IXNConnectionStateDisconnected:
            state = @"disconnected";
            break;
        case IXNConnectionStateConnected:
            state = @"connected";
            break;
        case IXNConnectionStateConnecting:
            state = @"connecting";
            break;
        case IXNConnectionStateNeedsUpdate: state = @"needs update"; break;
        case IXNConnectionStateUnknown: state = @"unknown"; break;
        default: NSAssert(NO, @"impossible connection state received");
    }
    [self log:@"connect: %@", state];
}

- (void) connect {
    [self.muse registerConnectionListener:self];
    [self.muse registerDataListener:self
                               type:IXNMuseDataPacketTypeArtifacts];
    [self.muse registerDataListener:self
                               type:IXNMuseDataPacketTypeAlphaAbsolute];
    /*
    [self.muse registerDataListener:self
                               type:IXNMuseDataPacketTypeEeg];
     */
    [self.muse runAsynchronously];
}

- (void)receiveMuseDataPacket:(IXNMuseDataPacket *)packet
                         muse:(IXNMuse *)muse {
    if (packet.packetType == IXNMuseDataPacketTypeAlphaAbsolute ||
            packet.packetType == IXNMuseDataPacketTypeEeg) {
        [self log:@"%5.2f %5.2f %5.2f %5.2f",
         [packet.values[IXNEegEEG1] doubleValue],
         [packet.values[IXNEegEEG2] doubleValue],
         [packet.values[IXNEegEEG3] doubleValue],
         [packet.values[IXNEegEEG4] doubleValue]];
        
        //self.Alpha.text = [NSString stringWithFormat: @"%f", [packet.values[IXNEegEEG1] doubleValue]];
    }
}

- (void)receiveMuseArtifactPacket:(IXNMuseArtifactPacket *)packet
                             muse:(IXNMuse *)muse {
    if (packet.blink && packet.blink != self.lastBlink) {
        [self log:@"blink detected"];
    }
    self.lastBlink = packet.blink;
}

- (void)applicationWillResignActive {
    NSLog(@"disconnecting before going into background");
    [self.muse disconnect:true];
}

- (IBAction)disconnect:(id)sender {
    if (self.muse) [self.muse disconnect:true];
}

- (IBAction)scan:(id)sender {
    [self.manager startListening];
    //[self.tableView reloadData];
}

- (IBAction)stopScan:(id)sender {
    [self.manager stopListening];
    //[self.tableView reloadData];
}
@end
