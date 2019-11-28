import Foundation
import CommandLineKit

let cli = CommandLineKit.CommandLine()

let help = BoolOption(shortFlag: "h", longFlag: "help",
  helpMessage: "Prints a help message.")
let verbosity = CounterOption(shortFlag: "v", longFlag: "verbose",
  helpMessage: "Print verbose messages. Specify multiple times to increase verbosity.")





let filePathx = StringOption(shortFlag: "i", longFlag: "input", required: true,
  helpMessage: "Path to the input file.")
let spamCodeOutPathx = StringOption(shortFlag: "s", longFlag: "spamCodeOut",
  helpMessage: "Generate spam code output path.For example:path,paramName,oldFunc,newClass")
let handleXcassetsx = BoolOption(shortFlag: "x", longFlag: "handleXcassets",
helpMessage: "Handle xcassets confuse.")
let deleteCommentsx = BoolOption(shortFlag: "d", longFlag: "deleteComments",
helpMessage: "Delete comments.")
let modifyProjectNamex = StringOption(shortFlag: "m", longFlag: "modifyProjectName",
helpMessage: "Modify ProjectName.Format:OldName>NewName.For example:DDApp>CCApp.")
let modifyClassNamePrefixx = StringOption(shortFlag: "p", longFlag: "modifyClassNamePrefix",
helpMessage: "Modify Project ClassNamePrefix.Format:Project OldClassNamePrefix>NewClassNamePrefix.For example:DDAppPath DDApp>CCApp.")
let ignoreDirNamesx = StringOption(shortFlag: "g", longFlag: "ignoreDirNames",
helpMessage: "Ignore dirNames.Format:A,B,C....For example:DDApp,CCApp,BBApp....")


cli.addOptions(filePathx,spamCodeOutPathx,handleXcassetsx,deleteCommentsx,modifyProjectNamex,modifyClassNamePrefixx,ignoreDirNamesx)
do {
  try cli.parse()
} catch let error{
  cli.printUsage(error)
}


print("File Path is \(filePathx.value ?? "")")

let input = Recursiver().validInput(filePathx.value)
Recursiver().swift_recursiveDirectory(directory: input ?? "", ignoreDirNames: [], handleMFile: { (mFilePath) in
    print(mFilePath ?? "")
}) { (swiftFilePath) in
    print(swiftFilePath ?? "")
}
