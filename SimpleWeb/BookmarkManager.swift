import UIKit

struct Bookmark: Codable {
    let title: String
    let url: String
}

class BookmarkManager {
    static let shared = BookmarkManager()
    private let defaults = UserDefaults.standard
    private let key = "bookmarks"

    private init() {}

    var bookmarks: [Bookmark] {
        get {
            guard let data = defaults.data(forKey: key) else { return [] }
            return (try? JSONDecoder().decode([Bookmark].self, from: data)) ?? []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: key)
            }
        }
    }

    func add(_ bookmark: Bookmark) {
        var list = bookmarks
        list.append(bookmark)
        bookmarks = list
    }

    func remove(at index: Int) {
        var list = bookmarks
        guard list.indices.contains(index) else { return }
        list.remove(at: index)
        bookmarks = list
    }
}
