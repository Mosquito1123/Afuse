
import CommandLineKit

let cli = CommandLineKit.CommandLine()

let filePath = StringOption(shortFlag: "f", longFlag: "file", required: true,
  helpMessage: "Path to the output file.")
let compress = BoolOption(shortFlag: "c", longFlag: "compress",
  helpMessage: "Use data compression.")
let help = BoolOption(shortFlag: "h", longFlag: "help",
  helpMessage: "Prints a help message.")
let verbosity = CounterOption(shortFlag: "v", longFlag: "verbose",
  helpMessage: "Print verbose messages. Specify multiple times to increase verbosity.")

cli.addOptions(filePath, compress, help, verbosity)

do {
  try cli.parse()
} catch let error{
  cli.printUsage(error)
}

print("File path is \(filePath.value ?? "")")
print("Compress is \(compress.value)")
print("Verbosity is \(verbosity.value)")

//void recursiveDirectory(NSString *directory, NSArray<NSString *> *ignoreDirNames, void(^handleMFile)(NSString *mFilePath), void(^handleSwiftFile)(NSString *swiftFilePath));
//void generateSpamCodeFile(NSString *outDirectory, NSString *mFilePath, GSCSourceType type, NSMutableString *categoryCallImportString, NSMutableString *categoryCallFuncString, NSMutableString *newClassCallImportString, NSMutableString *newClassCallFuncString);
//void generateSwiftSpamCodeFile(NSString *outDirectory, NSString *swiftFilePath);
//NSString *randomString(NSInteger length);
//void handleXcassetsFiles(NSString *directory);
//void deleteComments(NSString *directory, NSArray<NSString *> *ignoreDirNames);
//void modifyProjectName(NSString *projectDir, NSString *oldName, NSString *newName);
//void modifyClassNamePrefix(NSMutableString *projectContent, NSString *sourceCodeDir, NSArray<NSString *> *ignoreDirNames, NSString *oldName, NSString *newName);
