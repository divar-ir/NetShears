import XCTest

#if !canImport(ObjectiveC)
func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(NetShearsTests.allTests),
    ]
}
#endif
