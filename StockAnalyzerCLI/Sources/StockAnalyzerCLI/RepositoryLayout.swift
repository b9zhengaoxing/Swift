import Foundation

enum PortfolioRepository: String {
    case mine
    case others

    var title: String {
        switch self {
        case .mine:
            return "我的集思录"
        case .others:
            return "关联账户"
        }
    }
}

struct RepositoryLayout {
    let root: URL

    static var `default`: RepositoryLayout {
        RepositoryLayout(root: repositoryRootURL())
    }

    func jisiluFolder(for repository: PortfolioRepository) -> URL {
        root
            .appendingPathComponent(repository.rawValue, isDirectory: true)
            .appendingPathComponent("Jisilu", isDirectory: true)
    }

    func imageFolder(for repository: PortfolioRepository) -> URL {
        root
            .appendingPathComponent(repository.rawValue, isDirectory: true)
            .appendingPathComponent("image", isDirectory: true)
    }

    /// Stores Jisilu exports received directly from other people.
    /// Screenshot-generated XLS files remain in `others/Jisilu` so the two
    /// sources do not overwrite or obscure each other.
    func receivedJisiluFolder() -> URL {
        root
            .appendingPathComponent(PortfolioRepository.others.rawValue, isDirectory: true)
            .appendingPathComponent("关联账户jisilu", isDirectory: true)
    }

    private static func repositoryRootURL() -> URL {
        if let customPath = ProcessInfo.processInfo.environment["PORTFOLIO_REPOSITORIES_ROOT"],
           !customPath.isEmpty {
            return URL(fileURLWithPath: customPath, isDirectory: true)
        }

        let currentURL = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath,
            isDirectory: true
        ).standardizedFileURL

        if let discovered = firstRepositoryRoot(startingAt: currentURL) {
            return discovered
        }

        let sourceFileURL = URL(fileURLWithPath: #filePath)
        if sourceFileURL.path.hasPrefix("/") {
            var packageURL = sourceFileURL
            for _ in 0..<3 {
                packageURL.deleteLastPathComponent()
            }
            let repositoryRoot = packageURL.deletingLastPathComponent()
                .appendingPathComponent("repositories", isDirectory: true)
            if repositoryRootExists(repositoryRoot) {
                return repositoryRoot
            }
        }

        return currentURL.appendingPathComponent("repositories", isDirectory: true)
    }

    private static func firstRepositoryRoot(startingAt startURL: URL) -> URL? {
        var currentURL = startURL
        while true {
            let candidate = currentURL.appendingPathComponent("repositories", isDirectory: true)
            if repositoryRootExists(candidate) {
                return candidate
            }

            let parentURL = currentURL.deletingLastPathComponent()
            if parentURL.path == currentURL.path {
                return nil
            }
            currentURL = parentURL
        }
    }

    private static func repositoryRootExists(_ rootURL: URL) -> Bool {
        folderExists(
            rootURL
                .appendingPathComponent("mine", isDirectory: true)
                .appendingPathComponent("Jisilu", isDirectory: true)
        )
    }

    private static func folderExists(_ folderURL: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(
            atPath: folderURL.path,
            isDirectory: &isDirectory
        ) && isDirectory.boolValue
    }
}
