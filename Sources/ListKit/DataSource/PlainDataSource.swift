//
//  ListKitPlainDataSource.swift
//  ListKit
//
//  Created by burt on 2021/09/11.
//

import UIKit

public class PlainDataSource: NSObject, DataSource, UICollectionViewDataSource {
    public var layout: ComposeLayout?
    public weak var collectionView: UICollectionView?
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let layout = layout else { return 0 }
        return layout.sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let layout = layout else { return 0 }
        return layout.sections[section].components.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListKitCell.className, for: indexPath)
        if let wrapper = layout?.sections[indexPath.section].components[indexPath.item], let contentView = wrapper.component.contentView() as? UIView {
            cell.contentView.viewWithTag(Int.max)?.removeFromSuperview()
            contentView.tag = Int.max
            cell.contentView.addSubview(contentView)
            
            contentView.translatesAutoresizingMaskIntoConstraints = false
            let constraints = [
                cell.contentView.topAnchor.constraint(equalTo: contentView.topAnchor),
                cell.contentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                cell.contentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                cell.contentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ]
            NSLayoutConstraint.activate(constraints)
            
            wrapper.component.render(in: contentView)
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let view = collectionView.dequeueReusableSupplementaryView(ofKind: ListKitReusableView.className, withReuseIdentifier: ListKitReusableView.className, for: indexPath)
        if let anySupplementaryComponent = SupplementaryComponentManager.shared[kind], let contentView = anySupplementaryComponent.contentView() as? UIView {
            
            view.viewWithTag(Int.max)?.removeFromSuperview()
            contentView.tag = Int.max
            view.addSubview(contentView)
            
            contentView.translatesAutoresizingMaskIntoConstraints = false
            let constraints = [
                view.topAnchor.constraint(equalTo: contentView.topAnchor),
                view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ]
            NSLayoutConstraint.activate(constraints)
            
            anySupplementaryComponent.render(in: contentView)
        }
        return view
    }
}
