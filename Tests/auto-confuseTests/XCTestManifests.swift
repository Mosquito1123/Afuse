import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(auto_confuseTests.allTests),
    ]
}
#endif
