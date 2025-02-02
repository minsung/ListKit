//
//  Renderer.swift
//  ListKit
//
//  Created by burt on 2021/09/11.
//

import UIKit


public class ComposeRenderer {
    public static var emptyLayout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return layout
    }
    
    public var target: UICollectionView? {
        didSet {
            if let target = target {
                target.register(cellClass, forCellWithReuseIdentifier: ListKitCell.className)
                target.register(ListKitReusableView.self, forSupplementaryViewOfKind: ListKitReusableView.className, withReuseIdentifier: ListKitReusableView.className)
                target.dataSource = dataSource as? UICollectionViewDataSource
                target.delegate = delegate
                dataSource?.collectionView = target
            }
        }
    }
    
    /// The axis that the content in the collection view layout scrolls along.
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical {
        didSet {
            if self.configuration == nil {
                self.configuration = UICollectionViewCompositionalLayoutConfiguration()
            }
            self.configuration?.scrollDirection = scrollDirection
        }
    }
    
    /// The amount of space between the sections in the layout.
    public var interSectionSpacing: CGFloat = 0 {
        didSet {
            if self.configuration == nil {
                self.configuration = UICollectionViewCompositionalLayoutConfiguration()
            }
            self.configuration?.interSectionSpacing = interSectionSpacing
        }
    }
    
    /// An array of the supplementary items that are associated with the boundary edges of the entire layout, such as global headers and footers.
    public var boundarySupplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem] = [] {
        didSet {
            if self.configuration == nil {
                self.configuration = UICollectionViewCompositionalLayoutConfiguration()
            }
            self.configuration?.boundarySupplementaryItems = boundarySupplementaryItems
        }
    }
    
    /// The boundary to reference when defining content insets.
    public lazy var contentInsetsReference: UIContentInsetsReference = .safeArea {
        didSet {
            if self.configuration == nil {
                self.configuration = UICollectionViewCompositionalLayoutConfiguration()
            }
            self.configuration?.contentInsetsReference = contentInsetsReference
        }
    }
    
    var compose: ComposeLayout?
    private var configuration: UICollectionViewCompositionalLayoutConfiguration?
    var dataSource: ListKitDataSource?
    var delegate: (ListKitDelegate & UICollectionViewDelegate)
    let cellClass: AnyClass

    public init(dataSource: ListKitDataSource, delegate: (ListKitDelegate & UICollectionViewDelegate)? = nil, cellClass: AnyClass? = nil) {
        self.dataSource = dataSource
        self.delegate = delegate ?? ComponentLifeTimeTrackingDelegate()
        self.cellClass = cellClass ?? ListKitCell.self
    }
    
    public func render(animated: Bool = false, @SectionBuilder sections: () -> [SectionBuilderResult]) {
        self.unregisterSupplementaryViewsAndClear()
        let compose = ComposeLayout(configuration: configuration, sections: sections)
        self.compose = compose
        self.registerSupplementaryViews()
        self.dataSource?.layout = self.compose
        self.dataSource?.supplementaryComponents = SupplementaryComponentManager.shared.supplementaryComponentMap
        self.delegate.layout = self.compose
        self.target?.setCollectionViewLayout(compose.layout, animated: animated)
        applySnapshotIfDiffableDatasource(animated: animated)
    }
    
    public func render<T>(of items: [T], animated: Bool = false, builder: (T) -> NSCollectionLayoutSectionConvertible) {
        self.unregisterSupplementaryViewsAndClear()
        let compose = ComposeLayout(configuration: configuration, of: items, builder: builder)
        self.compose = compose
        self.registerSupplementaryViews()
        self.dataSource?.layout = self.compose
        self.dataSource?.supplementaryComponents = SupplementaryComponentManager.shared.supplementaryComponentMap
        self.delegate.layout = self.compose
        self.target?.setCollectionViewLayout(compose.layout, animated: animated)
        applySnapshotIfDiffableDatasource(animated: animated)
    }
    
    private func applySnapshotIfDiffableDatasource(animated: Bool) {
        if let compose = self.compose {
            self.delegate.layout = compose
            if let diffable = dataSource as? DiffableDataSource {
                diffable.layout = compose
                diffable.applySnapshot(animated: animated)
            }
        }
    }
    
    private func unregisterSupplementaryViewsAndClear() {
        SupplementaryComponentManager.shared.supplementaryComponentMap.keys.forEach { kind in
            self.target?.unregisterSupplementaryView(kind: kind, withReuseIdentifier: kind)
        }
        SupplementaryComponentManager.shared.clear()
    }

    private func registerSupplementaryViews() {
        SupplementaryComponentManager.shared.supplementaryComponentMap.keys.forEach { kind in
            self.target?.register(ListKitReusableView.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: kind)
        }
    }
}
