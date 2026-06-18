import UIKit

class BookmarksViewController: UITableViewController {

    private let manager = BookmarkManager.shared
    var didSelectBookmark: ((Bookmark) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bookmarks"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                           target: self,
                                                           action: #selector(addBookmark))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    @objc private func dismissSelf() {
        dismiss(animated: true)
    }

    @objc private func addBookmark() {
        let alert = UIAlertController(title: "Add Bookmark", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Title"
        }
        alert.addTextField { tf in
            tf.placeholder = "URL"
            tf.keyboardType = .URL
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let title = alert.textFields?.first?.text, !title.isEmpty,
                  let url = alert.textFields?.last?.text, !url.isEmpty else { return }
            let bookmark = Bookmark(title: title, url: url)
            self?.manager.add(bookmark)
            self?.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = manager.bookmarks.count
        if count == 0 {
            let label = UILabel()
            label.text = "No bookmarks yet.\nTap + to add one."
            label.numberOfLines = 0
            label.textAlignment = .center
            label.textColor = .gray
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let bookmark = manager.bookmarks[indexPath.row]
        cell.textLabel?.text = bookmark.title
        cell.detailTextLabel?.text = bookmark.url
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let bookmark = manager.bookmarks[indexPath.row]
        didSelectBookmark?(bookmark)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            manager.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
