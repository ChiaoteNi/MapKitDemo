//
//  UITableView + Extension.swift
//  MapKitDemo
//
//  Created by Chiaote Ni on 2023/5/28.
//

import UIKit

extension UITableView {

    @discardableResult
    func register<T: UITableViewCell>(cellType: T.Type) -> Self {
        register(cellType, forCellReuseIdentifier: cellType.reuseIdentifier)
        return self
    }

    func dequeueReusableCell<T: UITableViewCell>(with cellType: T.Type, for indexPath: IndexPath) -> T? {
        return dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? T
    }

    func getCell<T: UITableViewCell>(with cellType: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(with: cellType, for: indexPath) ?? T()
    }
}

extension UITableViewCell {
    static var reuseIdentifier: String { NSStringFromClass(self) }
}

