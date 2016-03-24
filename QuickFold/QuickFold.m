//
//  QuickFold.m
//  QuickFold
//
//  Created by Barden, Daniel on 23/03/16.
//  Copyright © 2016 HERE GmbH. All rights reserved.
//

#import "QuickFold.h"

@interface IDENavigatorArea : NSObject
- (id)currentNavigator;
@end

@interface IDEWorkspaceTabController : NSObject
@property (readonly) IDENavigatorArea *navigatorArea;
@end

@interface IDEEditorContext : NSObject
- (id)editor;
@end

@interface IDEEditorArea : NSObject
- (IDEEditorContext *)lastActiveEditorContext;
@end

@interface IDEWorkspaceWindowController : NSObject
@property (readonly) IDEWorkspaceTabController *activeWorkspaceTabController;
- (IDEEditorArea *)editorArea;
@end

@interface DVTSourceTextStorage : NSTextStorage
@end

@interface DVTSourceLanguageService : NSObject
@end

@protocol DVTSourceLanguageSyntaxTypeService <NSObject>
@end

@interface DVTTextStorage : NSTextStorage
@end

@interface DVTTextView : NSTextView
@end

@interface DVTCompletingTextView : DVTTextView
@property(readonly) DVTTextStorage *textStorage;
@end


@interface DVTDefaultSourceLanguageService : DVTSourceLanguageService
- (id)functionAndMethodRanges;
@end

@interface DVTSourceTextView : DVTCompletingTextView
- (void)fold:(id)arg1;
- (void)setSelectedRange:(struct _NSRange)arg1;
@end

@interface IDESourceCodeDocument : NSDocument
- (DVTSourceTextStorage *)textStorage;
@end

@interface IDESourceCodeEditor : NSObject
@property (retain) NSTextView *textView;
- (IDESourceCodeDocument *)sourceCodeDocument;
@end

@interface IDESourceCodeComparisonEditor : NSObject
@property (readonly) NSTextView *keyTextView;
@property (retain) NSDocument *primaryDocument;
@end

@interface QuickFold()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation QuickFold

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Fold Quick Tests" action:@selector(doMenuAction) keyEquivalent:@""];
        //[actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
    }
}

- (void)doMenuAction
{
    DVTSourceTextView *sourceTextView = (DVTSourceTextView *)[[self class] currentSourceCodeTextView];
    if (!sourceTextView) return;

    __block NSString *allString = [sourceTextView string];

    [allString enumerateSubstringsInRange:NSMakeRange(0, allString.length -1) options:NSStringEnumerationByLines usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        NSString *result = [substring stringByReplacingOccurrencesOfString:@" " withString:@""];

        if ([result hasPrefix:@"beforeSuite("] ||
            [result hasPrefix:@"afterSuite("] ||
            [result hasPrefix:@"beforeEach("] ||
            [result hasPrefix:@"afterEach("] ||
            [result hasPrefix:@"pending("] ||
            [result hasPrefix:@"fit("] ||
            [result hasPrefix:@"xit("] ||
            [result hasPrefix:@"it("])
        {
            [sourceTextView setSelectedRange:NSMakeRange(substringRange.location, 0)];
            [sourceTextView fold:nil];
        }
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Helper Methods

+ (id)currentEditor {
    NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];
    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        IDEWorkspaceWindowController *workspaceController = (IDEWorkspaceWindowController *)currentWindowController;
        IDEEditorArea *editorArea = [workspaceController editorArea];
        IDEEditorContext *editorContext = [editorArea lastActiveEditorContext];
        return [editorContext editor];
    }
    return nil;
}

+ (NSTextView *)currentSourceCodeTextView {
    if ([[[self class] currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
        IDESourceCodeEditor *editor = [[self class] currentEditor];
        return editor.textView;
    }

    if ([[[self class] currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeComparisonEditor")]) {
        IDESourceCodeComparisonEditor *editor = [[self class] currentEditor];
        return editor.keyTextView;
    }

    return nil;
}
@end
