//
//  CoinListController.swift
//  CoinExchanger
//
//  Created by Junior on 03/09/21.
//

import UIKit

class CoinListController: UIViewController {
    var completion: (_ coin: Coin) -> Void = {_ in}
    var kb = false
    let model = CoinListModel()
    
    // MARK: View
    let contentView = CoinListView()
    
    // MARK: Override
    convenience init(_ completion: @escaping (_ coin: Coin) -> Void) {
        self.init()
        self.completion = completion
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "dollarsign.square"),
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(changeOrder))
        reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

private extension CoinListController {
    // MARK: Setup
    func setup() {
        title = L10n.Coin.List.title
        view.backgroundColor = Asset.Colors.primary.color
        
        view.addSubview(contentView)
        contentView.top(equalTo: view, safeArea: true)
        contentView.fillHorizontal(to: view)
        contentView.bottom(equalTo: view, safeArea: false)
        
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
        
        contentView.visualDelegate = self
    }
    
    @objc func changeOrder() {
        switch model.ord {
        case 0:
            model.ord = 1
            self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "a.square")
        case 1:
            model.ord = 0
            self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "dollarsign.square")
        default:
            break
        }
    }
    
    func reloadData() {
        if model.data.isEmpty { contentView.showView(contentView.emptyList) }
        if model.items.isEmpty && !model.search.isEmpty { contentView.showView(contentView.emptyList) }
    }
    
    // MARK: Keyboard
    func setKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if !kb {
                kb = true
                contentView.showKeyboard(with: keyboardSize.height+Helper.safeSize(for: .bottom))
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if kb {
            kb = false
            contentView.hideKeyboard()
        }
    }
}

// MARK: Generic Delegate
extension CoinListController: GenericDelegate {
    func didTouch(_ view: UIView) {
        switch view.tag {
        case 1:
            break
        case 2:
            model.ord = 0
        case 3:
            model.ord = 1
        default:
            break
        }
    }
}

// MARK: VisualInput Delegate
extension CoinListController: VisualInputDelegate {
    func didBeginEditing(_ input: VisualInput) { }
    
    func didChange(_ input: VisualInput) {
        switch input.tag {
        case 1:
            model.search = input.text ?? ""
        default:
            break
        }
    }
    
    func didEndEditing(_ input: VisualInput, _ valid: Bool) { }
    
    func didReturn(_ input: VisualInput) { }
}

// MARK: TableView Delegate
extension CoinListController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = model.items[indexPath.row]
        
        let cell: CoinTableCell = tableView.dequeueReusableCell(for: indexPath)
        cell.set(item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return contentView.tableHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56+Constants.space*2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true) {
            self.completion(self.model.items[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

