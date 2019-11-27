
import CommandLineKit

let cli = CommandLineKit.CommandLine()

let help = BoolOption(shortFlag: "h", longFlag: "help",
  helpMessage: "Prints a help message.")
let verbosity = CounterOption(shortFlag: "v", longFlag: "verbose",
  helpMessage: "Print verbose messages. Specify multiple times to increase verbosity.")





let filePathx = StringOption(shortFlag: "i", longFlag: "input", required: true,
  helpMessage: "Path to the input file.")
let spamCodeOutPathx = StringOption(shortFlag: "s", longFlag: "spamCodeOut",
  helpMessage: "Generate spam code output path.")
let handleXcassetsx = BoolOption(shortFlag: "x", longFlag: "handleXcassets",
helpMessage: "Handle xcassets confuse.")
let deleteCommentsx = BoolOption(shortFlag: "d", longFlag: "deleteComments",
helpMessage: "Delete comments.")
let modifyProjectNamex = StringOption(shortFlag: "m", longFlag: "modifyProjectName",
helpMessage: "Modify ProjectName.Format:OldName>NewName.For example:DDApp>CCApp.")
let modifyClassNamePrefixx = StringOption(shortFlag: "p", longFlag: "modifyClassNamePrefix",
helpMessage: "Modify ClassNamePrefix.Format:OldClassNamePrefix>NewClassNamePrefix.For example:DDApp>CCApp.")
let ignoreDirNamesx = StringOption(shortFlag: "g", longFlag: "ignoreDirNames",
helpMessage: "Ignore dirNames.Format:A,B,C....For example:DDApp,CCApp,BBApp....")
cli.addOptions(filePathx,spamCodeOutPathx,handleXcassetsx,deleteCommentsx,modifyProjectNamex,modifyClassNamePrefixx,ignoreDirNamesx)
do {
  try cli.parse()
} catch let error{
  cli.printUsage(error)
}

print("File path is \(filePathx.value ?? "")")
//print("Compress is \(compress.value)")
print("Verbosity is \(verbosity.value)")

//void recursiveDirectory(NSString *directory, NSArray<NSString *> *ignoreDirNames, void(^handleMFile)(NSString *mFilePath), void(^handleSwiftFile)(NSString *swiftFilePath));
//void generateSpamCodeFile(NSString *outDirectory, NSString *mFilePath, GSCSourceType type, NSMutableString *categoryCallImportString, NSMutableString *categoryCallFuncString, NSMutableString *newClassCallImportString, NSMutableString *newClassCallFuncString);
//void generateSwiftSpamCodeFile(NSString *outDirectory, NSString *swiftFilePath);
//NSString *randomString(NSInteger length);
//void handleXcassetsFiles(NSString *directory);
//void deleteComments(NSString *directory, NSArray<NSString *> *ignoreDirNames);
//void modifyProjectName(NSString *projectDir, NSString *oldName, NSString *newName);
//void modifyClassNamePrefix(NSMutableString *projectContent, NSString *sourceCodeDir, NSArray<NSString *> *ignoreDirNames, NSString *oldName, NSString *newName);
