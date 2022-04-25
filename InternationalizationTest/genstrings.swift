//
//  genstrings.swift
//  InternationalizationTest
//
//  Created by Push on 2022/2/10.
//


import Foundation

class GenStrings {
    
    var str = "Hello, playground"
    let fileManager = FileManager.default
    let acceptedFileExtensions = ["swift"]
    let excludedFolderNames = ["Carthage"]
    let excludedFileNames = ["genstrings.swift"]
    var regularExpresions = [String:NSRegularExpression]()
    
    let localizedRegex = "(?<=\")([^\"]*)(?=\".(localized|localizedFormat))|(?<=(Localized|NSLocalizedString)\\(\")([^\"]*?)(?=\")"
    let commentedRegex = "(?<=.commented\\(\")([^\"]*)(?=\")"
    
    enum GenstringsError: Error {
        case Error
    }
    
    // Performs the genstrings functionality
    func perform(path: String? = nil) {
        // 获得沙盒的根路径
        let home = NSHomeDirectory() as NSString
        // 获得Documents路径，使用NSString对象的stringByAppendingPathComponent()方法拼接路径
        let docPath = home.appendingPathComponent("Documents") as NSString
        let filePath = docPath.appendingPathComponent("Localizable.strings");

        
        
        let directoryPath = path ?? fileManager.currentDirectoryPath
        let rootPath = URL(fileURLWithPath:filePath)
        let allFiles = fetchFilesInFolder(rootPath: rootPath)
//        let allFiles = [Bundle.main.url(forResource: "Localizable", withExtension: ".strings")]
        // We use a set to avoid duplicates
        var localizableStrings = Set<String>()
        var comments = [String:String]()
//        for filePath in allFiles {
//            let (stringsInFile, commentsInFile) = localizableStringsInFile(filePath: filePath)
//            localizableStrings = localizableStrings.union(stringsInFile)
//            comments = comments.merging(commentsInFile, uniquingKeysWith: { (_, last) in last })
//        }
        let (stringsInFile, commentsInFile) = localizableStringsInFile(filePath: rootPath)
        localizableStrings = localizableStrings.union(stringsInFile)
        comments = comments.merging(commentsInFile, uniquingKeysWith: { (_, last) in last })
        // We sort the strings
        let sortedStrings = localizableStrings.sorted(by: { $0 < $1 })
        var processedStrings = String()
        for string in sortedStrings {
            if let comment = comments[string] {
                processedStrings.append("/* \(comment) */ \n")
            }
            processedStrings.append("\"\(string)\" = \"\(string)\"; \n")
        }
        print(processedStrings)
    }
    
    // Applies regex to a file at filePath.
    func localizableStringsInFile(filePath: URL) -> (Set<String>, [String:String]) {
        do {
            let fileContentsData = try Data(contentsOf: filePath)
            guard let fileContentsString = NSString(data: fileContentsData, encoding: String.Encoding.utf16.rawValue) else {
                return (Set<String>(), [String:String]())
            }
            
            let localizedMatches = try regexMatches(pattern: localizedRegex, string: fileContentsString as String)
            let commentedMatches = try regexMatches(pattern: commentedRegex, string: fileContentsString as String)
            
            let localizedStringsArray = localizedMatches.map({fileContentsString.substring(with: $0.range)})
            var comments = [String:String]()
            for m in commentedMatches {
                let comment = fileContentsString.substring(with: m.range)
                let localizedRange = localizedMatches.filter { $0.range.location + $0.range.length <= m.range.location }.last?.range
                if localizedRange != nil {
                    let localized = fileContentsString.substring(with: localizedRange!)
                    comments[localized] = comment
                }
            }
            
            return (Set(localizedStringsArray), comments)
        } catch {}
        return (Set<String>(), [String:String]())
    }
    
    //MARK: Regex
    
    func regexWithPattern(pattern: String) throws -> NSRegularExpression {
        var safeRegex = regularExpresions
        if let regex = safeRegex[pattern] {
            return regex
        }
        else {
            do {
                let currentPattern: NSRegularExpression
                currentPattern =  try NSRegularExpression(pattern: pattern, options:NSRegularExpression.Options.caseInsensitive)
                safeRegex.updateValue(currentPattern, forKey: pattern)
                regularExpresions = safeRegex
                return currentPattern
            }
            catch {
                throw GenstringsError.Error
            }
        }
    }
    
    func regexMatches(pattern: String, string: String) throws -> [NSTextCheckingResult] {
        do {
            let internalString = string
            let currentPattern =  try regexWithPattern(pattern: pattern)
            // NSRegularExpression accepts Swift strings but works with NSString under the hood. Safer to bridge to NSString for taking range.
            let nsString = internalString as NSString
            let stringRange = NSMakeRange(0, nsString.length)
            let matches = currentPattern.matches(in: internalString, options: [], range: stringRange)
            return matches
        }
        catch {
            throw GenstringsError.Error
        }
    }
    
    //MARK: File manager
    
    func fetchFilesInFolder(rootPath: URL) -> [URL] {
        var files = [URL]()
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: rootPath as URL, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
            for urlPath in directoryContents {
                let stringPath = urlPath.path
                let lastPathComponent = urlPath.lastPathComponent
                let pathExtension = urlPath.pathExtension
                var isDir : ObjCBool = false
                if fileManager.fileExists(atPath: stringPath, isDirectory:&isDir) {
                    if isDir.boolValue {
                        if !excludedFolderNames.contains(lastPathComponent) {
                            let dirFiles = fetchFilesInFolder(rootPath: urlPath)
                            files.append(contentsOf: dirFiles)
                        }
                    } else {
                        if acceptedFileExtensions.contains(pathExtension) && !excludedFileNames.contains(lastPathComponent)  {
                            files.append(urlPath)
                        }
                    }
                }
            }
        } catch {}
        return files
    }
    
}

