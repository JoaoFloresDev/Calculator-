import UIKit
import CloudKit

class CloudKitItemsViewController: UIViewController {
    private var viewModel = CloudKitImageService()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .yellow
        setupUI()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    var alert = LoadingAlert()
    
    override func viewDidAppear(_ animated: Bool) {
        alert.startLoading(in: self)
        CloudKitImageService.fetchImages { _, _ in
            self.alert.stopLoading {
                self.tableView.reloadData()
            }
        }
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Registrar a classe da célula customizada
        tableView.register(ItemTableViewCell.self, forCellReuseIdentifier: "ItemCell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.reloadData()
    }
    
    @objc private func addButtonTapped() {
        let alertController = UIAlertController(title: "Add Item", message: "Enter item name:", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Item name"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            if let itemName = alertController.textFields?.first?.text {
                CloudKitImageService.saveImage(name: itemName, image: UIImage(named: "iconMrk")!) { success, error in
                    if success {
                        CloudKitImageService.fetchImages { _, _ in
                            self.tableView.reloadData()
                        }
                    } else {
                        // Handle error here
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension CloudKitItemsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CloudKitImageService.images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemTableViewCell
        let (itemName, userImage) = CloudKitImageService.images[indexPath.row]
        cell.itemLabel.text = itemName
        cell.itemImageView.image = userImage
        return cell
    }
}

extension CloudKitItemsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alertController = UIAlertController(title: "Delete Item", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            let (itemName, _) = CloudKitImageService.images[indexPath.row]
            CloudKitImageService.deleteImage(name: itemName) { success, error in
                if success {
                    CloudKitImageService.fetchImages { _, _ in
                        self.tableView.reloadData()
                    }
                } else {
                    // Handle error here
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

class ItemTableViewCell: UITableViewCell {
    let itemLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(itemLabel)
        addSubview(itemImageView)
        
        NSLayoutConstraint.activate([
            itemLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            itemLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            itemImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            itemImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            itemImageView.widthAnchor.constraint(equalToConstant: 30),
            itemImageView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
