//
//  MPMainController.m
//  MacDown
//
//  Created by Tzu-ping Chung  on 7/06/2014.
//  Copyright (c) 2014 Tzu-ping Chung . All rights reserved.
//

#import "MPMainController.h"
#import <MASPreferences/MASPreferencesWindowController.h>
#import "MPUtilities.h"
#import "MPPreferences.h"
#import "MPMarkdownPreferencesViewController.h"
#import "MPEditorPreferencesViewController.h"
#import "MPHtmlPreferencesViewController.h"


@interface MPMainController ()
@property (readonly) NSWindowController *preferencesWindowController;
@end


@implementation MPMainController

@synthesize preferencesWindowController = _preferencesWindowController;

- (MPPreferences *)prefereces
{
    return [MPPreferences sharedInstance];
}

- (NSWindowController *)preferencesWindowController
{
    if (!_preferencesWindowController)
    {
        NSArray *vcs = @[
            [[MPMarkdownPreferencesViewController alloc] init],
            [[MPEditorPreferencesViewController alloc] init],
            [[MPHtmlPreferencesViewController alloc] init],
        ];
        NSString *title = NSLocalizedString(@"Preferences",
                                            @"Preferences window title.");

        typedef MASPreferencesWindowController WC;
        _preferencesWindowController =
            [[WC alloc] initWithViewControllers:vcs title:title];
    }
    return _preferencesWindowController;
}

- (IBAction)showPreferencesWindow:(id)sender
{
    [self.preferencesWindowController showWindow:nil];
}

- (IBAction)showHelp:(id)sender
{
    NSDocumentController *c =
        [NSDocumentController sharedDocumentController];
    NSURL *source = [[NSBundle mainBundle] URLForResource:@"help"
                                            withExtension:@"md"];
    NSURL *target = [NSURL fileURLWithPathComponents:@[NSTemporaryDirectory(),
                                                       @"help.md"]];
    BOOL ok = NO;
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtURL:target error:NULL];
    ok = [manager copyItemAtURL:source toURL:target error:NULL];
    if (ok)
    {
        [c openDocumentWithContentsOfURL:target display:YES completionHandler:
            ^(NSDocument *document, BOOL wasOpen, NSError *error) {
                if (!document || wasOpen || error)
                    return;
                NSRect frame = [NSScreen mainScreen].visibleFrame;
                for (NSWindowController *wc in document.windowControllers)
                    [wc.window setFrame:frame display:YES];
            }];
    }
}


#pragma mark - Override

- (instancetype)init
{
    self = [super init];
    if (!self)
        return self;

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(showFirstLaunchTips)
                   name:MPDidDetectFreshInstallationNotification
                 object:self.prefereces];
    [self copyFiles];
    return self;
}


#pragma mark - Private

- (void)copyFiles
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *root = MPDataDirectory(nil);
    if ([manager fileExistsAtPath:root])
        return;

    [manager createDirectoryAtPath:root
       withIntermediateDirectories:YES attributes:nil error:NULL];
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *target =
        [NSURL fileURLWithPath:MPDataDirectory(kMPStylesDirectoryName)];
    if (![manager fileExistsAtPath:target.path])
    {
        NSURL *source = [bundle URLForResource:@"Styles" withExtension:@""];
        [manager copyItemAtURL:source toURL:target error:NULL];
    }
    target = [NSURL fileURLWithPath:MPDataDirectory(kMPThemesDirectoryName)];
    if (![manager fileExistsAtPath:target.path])
    {
        NSURL *source = [bundle URLForResource:@"Themes" withExtension:@""];
        [manager copyItemAtURL:source toURL:target error:NULL];
    }
}




#pragma mark - Notification handler

- (void)showFirstLaunchTips
{
    [self showHelp:nil];
}


@end
