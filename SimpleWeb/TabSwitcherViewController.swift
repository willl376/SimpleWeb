import UIKit
import WebKit

class TabSwitcherViewController: UICollectionViewController {

    private let manager = TabManager.shared
    private let cellId = "TabCell"
    var didSelectTab: ((Int) -> Void)?

    private let layout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.minimumInteritemSpacing = 16
        l.minimumLineSpacing = 16
        l.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return l
    }()

    init() {
        super.init(collectionViewLayout: layout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tabs"
        collectionView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        collectionView.register(TabCell.self, forCellWithReuseIdentifier: cellId)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                           target: self,
                                                           action: #selector(addNewTab))
    }

    @objc private func dismissSelf() {
        dismiss(animated: true)
    }

    @objc private func addNewTab() {
        let config = WKWebViewConfiguration()
        _ = manager.addTab(configuration: config)
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.didSelectTab?(self.manager.count - 1)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return manager.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TabCell
        let tab = manager.tabs[indexPath.row]
        let title = tab.title
        cell.titleLabel.text = title
        cell.urlLabel.text = tab.url?.absoluteString ?? "about:blank"
        cell.isCurrent = indexPath.row == manager.currentIndex
        cell.onClose = { [weak self] in
            self?.manager.removeTab(at: indexPath.row)
            collectionView.deleteItems(at: [indexPath])
            if self?.manager.count == 0 {
                self?.addNewTab()
            }
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismiss(animated: true) { [weak self] in
            self?.didSelectTab?(indexPath.row)
        }
    }
}

extension TabSwitcherViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 48
        return CGSize(width: width, height: 80)
    }
}

// MARK: - Tab Cell

class TabCell: UICollectionViewCell {

    let titleLabel = UILabel()
    let urlLabel = UILabel()
    let closeButton = UIButton(type: .roundedRect)
    var onClose: (() -> Void)?

    var isCurrent: Bool = false {
        didSet {
            backgroundColor = isCurrent ? UIColor(white: 0.85, alpha: 1.0) : .white
            layer.borderWidth = isCurrent ? 2 : 0.5
            layer.borderColor = isCurrent ? UIColor.systemBlue.cgColor : UIColor.lightGray.cgColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.cgColor

        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        urlLabel.font = UIFont.systemFont(ofSize: 12)
        urlLabel.textColor = .gray
        urlLabel.translatesAutoresizingMaskIntoConstraints = false

        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        contentView.addSubview(titleLabel)
        contentView.addSubview(urlLabel)
        contentView.addSubview(closeButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),

            urlLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            urlLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            urlLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),

            closeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    @objc private func closeTapped() {
        onClose?()
    }
}
