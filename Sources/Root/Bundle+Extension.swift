//  Created by Muhammed Mahmood on 03/05/2025.

import Foundation

extension Bundle {
    static var supportingFilesBundle: Bundle {
        let mainBundle = Bundle.main
        
        // First try Sources/Root directory
        if let resourcePath = mainBundle.path(forResource: "Sources/Root", ofType: nil),
           let bundle = Bundle(path: resourcePath) {
            return bundle
        }
        
        // Then try Root directly
        if let resourcePath = mainBundle.path(forResource: "Root", ofType: nil),
           let bundle = Bundle(path: resourcePath) {
            return bundle
        }
        
        // For development in the main bundle
        return mainBundle
    }
    
    // Helper method to get the package-list.json file URL
    static func packageListURL() -> URL? {
        // Get the bundle containing this code
        let thisBundle = Bundle(for: NSClassFromString("iApplied.AppDelegate") ?? NSObject.self)
        
        // Try the current module bundle first
        if let bundleURL = Bundle(for: NSClassFromString("iApplied.Root.SettingsView") ?? NSObject.self).url(forResource: "package-list", withExtension: "json") {
            return bundleURL
        }
        
        // Try looking in the main bundle
        if let fileURL = thisBundle.url(forResource: "package-list", withExtension: "json") {
            return fileURL
        }
        
        // Try with specific paths in the main bundle
        if let fileURL = thisBundle.url(forResource: "package-list", withExtension: "json", subdirectory: "Sources/Root") {
            return fileURL
        }
        
        if let fileURL = thisBundle.url(forResource: "package-list", withExtension: "json", subdirectory: "Root") {
            return fileURL
        }
        
        // Try using resource bundles within the main bundle
        for bundle in [thisBundle, Bundle.main] {
            if let resourcePath = bundle.resourcePath,
               let enumerator = FileManager.default.enumerator(at: URL(fileURLWithPath: resourcePath),
                                                              includingPropertiesForKeys: [.isDirectoryKey],
                                                              options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
                
                for case let fileURL as URL in enumerator {
                    if fileURL.lastPathComponent == "package-list.json" {
                        return fileURL
                    }
                }
            }
        }
        
        return nil
    }
}
