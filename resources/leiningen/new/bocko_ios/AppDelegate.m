#import "AppDelegate.h"

#import <JavaScriptCore/JavaScriptCore.h>

#import "ABYContextManager.h"

#ifdef DEBUG
#import "ABYServer.h"
#endif

@interface AppDelegate ()

@property (strong, nonatomic) ABYContextManager* contextManager;

#ifdef DEBUG
@property (strong, nonatomic) ABYServer* replServer;
#endif

@end

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}

@implementation AppDelegate

#ifdef DEBUG
-(void)requireAppNamespaces:(JSContext*)context
{
    [context evaluateScript:@"goog.require('bocko_ios.core');"];
}
#endif

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    // Shut down the idle timer so that you can easily experiment
    // with the demo app from a device that is not connected to a Mac
    // running Xcode. Since this demo app isn't being released we
    // can do this unconditionally.
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // Set up the compiler output directory
    NSURL* compilerOutputDirectory = [[self privateDocumentsDirectory] URLByAppendingPathComponent:@"cljs-out"];
    
    // Ensure private documents directory exists
    [self createDirectoriesUpTo:[self privateDocumentsDirectory]];
    
    // Copy resources from bundle "out" to compilerOutputDirectory
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    fileManager.delegate = self;
    
    // First blow away old compiler output directory
    [fileManager removeItemAtPath:compilerOutputDirectory.path error:nil];
    
    // Copy files from bundle to compiler output driectory
    NSString *outPath = [[NSBundle mainBundle] pathForResource:@"out" ofType:nil];
    [fileManager copyItemAtPath:outPath toPath:compilerOutputDirectory.path error:nil];
    
    // Create an instance of JavaScriptCore to run things
    JSContext* context = [[JSContext alloc] init];
    
    // Use Ambly to manage JavaScriptCore
    
    NSLog(@"Initializing ClojureScript");
    self.contextManager = [[ABYContextManager alloc] initWithContext:[context JSGlobalContextRef]
                                             compilerOutputDirectory:compilerOutputDirectory];
    [self.contextManager setupGlobalContext];
    [self.contextManager setUpConsoleLog];
    [self.contextManager setUpTimerFunctionality];
    
    NSString* mainJsFilePath = [[compilerOutputDirectory URLByAppendingPathComponent:@"main" isDirectory:NO] URLByAppendingPathExtension:@"js"].path;
    
#ifdef DEBUG
    
    // We assume the ClojureScript has been compiled using `lein cljsbuild once dev` to produce :none output
    
    [self.contextManager setUpAmblyImportScript];
    
    NSURL* googDirectory = [compilerOutputDirectory URLByAppendingPathComponent:@"goog"];
    
    [self.contextManager bootstrapWithDepsFilePath:mainJsFilePath
                                      googBasePath:[[googDirectory URLByAppendingPathComponent:@"base" isDirectory:NO] URLByAppendingPathExtension:@"js"].path];
    
    [self requireAppNamespaces:context];
    
#else

    // We assume the ClojureScript has been compiled using `lein cljsbuild once rel` to produce :advanced output
    
    NSError* error = nil;
    NSString* sourceText = [NSString stringWithContentsOfFile:mainJsFilePath encoding:NSUTF8StringEncoding error:&error];
    
    if (!error && sourceText) {
        [context evaluateScript:sourceText];
    }
    
#endif
    
    // Other unconditional app setup goes here
    
#ifdef DEBUG
    // Start up the REPL server
    self.replServer = [[ABYServer alloc] initWithContext:self.contextManager.context
                                 compilerOutputDirectory:compilerOutputDirectory];
    BOOL success = [self.replServer startListening];
    if (!success) {
        NSLog(@"Failed to start REPL server.");
    }
#endif
    
    return YES;
}

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath{
    if ([error code] == 516) //error code for: The operation couldn’t be completed. File exists
        return YES;
    else
        return NO;
}

- (NSURL *)privateDocumentsDirectory
{
    NSURL *libraryDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    
    return [libraryDirectory URLByAppendingPathComponent:@"Private Documents"];
}

- (void)createDirectoriesUpTo:(NSURL*)directory
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[directory path]]) {
        NSError *error = nil;
        
        if (![[NSFileManager defaultManager] createDirectoryAtPath:[directory path]
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error]) {
            NSLog(@"Can't create directory %@ [%@]", [directory path], error);
            abort();
        }
    }
}

- (void)viewReady:(id)view
{
    // Call JS init fn
    JSValue* initFn = [self getValue:@"init" inNamespace:@"bocko-ios.core" fromContext:[JSContext contextWithJSGlobalContextRef:self.contextManager.context]];
    NSAssert(!initFn.isUndefined, @"Could not find the app init function");
    [initFn callWithArguments:@[view]];
}

- (JSValue*)getValue:(NSString*)name inNamespace:(NSString*)namespace fromContext:(JSContext*)context
{
    JSValue* namespaceValue = nil;
    for (NSString* namespaceElement in [namespace componentsSeparatedByString: @"."]) {
        if (namespaceValue) {
            namespaceValue = namespaceValue[[self munge:namespaceElement]];
        } else {
            namespaceValue = context[[self munge:namespaceElement]];
        }
    }
    
    return namespaceValue[[self munge:name]];
}

- (NSString*)munge:(NSString*)s
{
    return [[[s stringByReplacingOccurrencesOfString:@"-" withString:@"_"]
             stringByReplacingOccurrencesOfString:@"!" withString:@"_BANG_"]
            stringByReplacingOccurrencesOfString:@"?" withString:@"_QMARK_"];
}

@end
