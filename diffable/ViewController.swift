//
//  ViewController.swift
//  diffable
//
//  Created by Davit K. on 10.12.24.
//

import UIKit

struct Group: Hashable {
    let id: String
    let title: String
    let description: String
    let items: [Single]
    var isexpanded: Bool = false
    
    static func == (lhs: Group, rhs: Group) -> Bool {
        lhs.id == rhs.id
    }
}

struct Single: Hashable {
    let id: String
    let title: String
    let description: String
}

struct Datasource: Hashable {
    var sections: [Group]
    let items: [Single]
}

var datasource: Datasource = .init(
    sections: [
        .init(id: "1", title: "Group 1", description: "Description 1", items: [
            .init(id: "1", title: "Item 1", description: "Description 1"),
            .init(id: "2", title: "Item 2", description: "Description 2"),
            .init(id: "3", title: "Item 3", description: "Description 3"),
            .init(id: "4", title: "Item 4", description: "Description 4"),
        ]),
        .init(id: "2", title: "Group 2", description: "Description 2", items: [
            .init(id: "21", title: "Item 21", description: "Description 1"),
        ]),
    ],
    items: [
        .init(id: "1", title: "Single Item 1", description: "Single Description 1"),
        .init(id: "2", title: "Single Item 2", description: "Single Description 2"),
    ]
)

class ViewController: UIViewController {
    enum Section: Hashable {
        case group(Group)
        case single
    }
    
    enum Item: Hashable {
        case group(Group)
        case single(Single)
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(HorizontalAlignedCell.self, forCellWithReuseIdentifier: HorizontalAlignedCell.reuseIdentifier)
        collectionView.register(
            GroupSupplementaryBackgroundView.self,
            forSupplementaryViewOfKind: "group-background",
            withReuseIdentifier: "GroupSupplementaryBackgroundView"
        )
        
        collectionView.register(
            SectionBackgroundDecorationView.self,
            forSupplementaryViewOfKind: "section-background",
            withReuseIdentifier: "SectionBackgroundDecorationView"
        )
        collectionView.register(
            SectionBackgroundDecorationView.self,
            forSupplementaryViewOfKind: "section-background2",
            withReuseIdentifier: "SectionBackgroundDecorationView"
        )
        collectionView.register(
            HorizontalAlignedView.self,
            forSupplementaryViewOfKind: "section-header",
            withReuseIdentifier: HorizontalAlignedView.reuseIdentifier
        )
        collectionView.backgroundColor = .systemGray3
        
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        collectionView.setCollectionViewLayout(createListStyleLayout(), animated: true)
        setupDataSource()
        updateSnapshot(with: datasource)
    }

    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HorizontalAlignedCell.reuseIdentifier, for: indexPath) as! HorizontalAlignedCell
            
            switch item {
            case .single(let item):
                cell.configure(with: item.title, image: .actions) {
//                    print("Section", indexPath.section, "Item", indexPath.item)
                }
            case .group(let group):
//                print("Section", indexPath.section, "Item", indexPath.item)
                cell.configure(with: group.title, image: .strokedCheckmark) {
//                    datasource.sections[indexPath.section].isexpanded.toggle()
//                    self.updateSnapshot(with: datasource)
                    
//                    var snap = self.dataSource.snapshot(for: .group(group))
//                    var snapsho = snap.snapshot(of: .group(group), includingParent: false)
//                    if snapsho.items.isEmpty {
//                        snapsho.append(group.items.map(Item.single))
//                        self.dataSource.apply(snapsho, to: .group(group))
//                    } else {
//                        snapsho.deleteAll()
//                        self.dataSource.apply(snapsho, to: .group(group))
//                    }
                }
            }

            return cell
        }
        
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            if elementKind == "section-header" {
                let view = collectionView.dequeueReusableSupplementaryView(
                    ofKind: elementKind,
                    withReuseIdentifier: HorizontalAlignedView.reuseIdentifier,
                    for: indexPath
                ) as? HorizontalAlignedView
                view?.configure(with: "Yle", image: .add) {
                    datasource.sections[indexPath.section].isexpanded.toggle()
                    self.updateSnapshot(with: datasource)

                }
                return view

            }
            
            if elementKind == "group-background" {
                let view = collectionView.dequeueReusableSupplementaryView(
                    ofKind: elementKind,
                    withReuseIdentifier: "GroupSupplementaryBackgroundView",
                    for: indexPath
                ) as? GroupSupplementaryBackgroundView
                view?.backgroundColor = .blue.withAlphaComponent(1)
                return view
            } else if elementKind == "section-background" {
                let view = collectionView.dequeueReusableSupplementaryView(
                    ofKind: elementKind,
                    withReuseIdentifier: "SectionBackgroundDecorationView",
                    for: indexPath
                ) as! SectionBackgroundDecorationView
                view.configureColor(.red)
                
                return view
            }
            
            if elementKind == UICollectionView.elementKindSectionHeader {
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: elementKind,
                    withReuseIdentifier: "SectionBackgroundDecorationView",
                    for: indexPath
                ) as? SectionBackgroundDecorationView
                
                return header
            }
            return nil
        }

    }
    
    func updateSnapshot(with items: Datasource) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        
        items.sections.forEach { group in
            let groupRow = Item.group(group)
            let rows = group.items.map(Item.single)

            sectionSnapshot.append(rows, to: groupRow)
            
        }
        
//        
//        snapshot.appendSections(items.sections.map(Section.group))
//        snapshot.appendSections([.single])
//        
//        items.sections.forEach { group in
//            let groupRow = Item.group(group)
//            let rows = group.items.map(Item.single)
//
//            if group.isexpanded {
//                snapshot.appendItems([groupRow] + rows, toSection: .group(group))
//            }
//            else {
//                snapshot.appendItems([groupRow], toSection: .group(group))
//            }
//        }
//        
//        snapshot.appendItems(items.items.map(Item.single), toSection: .single)
        
        /// Apply
        dataSource.apply(snapshot)
    }
    
    func update(_ section: Section, items: [Item]) {
//        var snapshot = dataSource.snapshot(for: section)
//        snapshot.append(items)
//        snapshot.
//        dataSource.apply(snapshot)
    }
}

extension ViewController {
    func createListStyleLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            // Item size
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(80)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
//            item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)

            // Group size
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(80)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )

            // Section background
            let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem
                .background(elementKind: "section-background")
            let sectionBackgroundDecoration2 = NSCollectionLayoutDecorationItem
                .background(elementKind: "section-background2")

            // Section
            let section = NSCollectionLayoutSection(group: group)
            

            section.decorationItems = [sectionBackgroundDecoration2]
        
//            print(datasource.sections[sectionIndex].id)
//            let section = datasource.sections[sectionIndex]
            
            let sec = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
            switch sec {
            case .group:
                if datasource.sections[sectionIndex].isexpanded {
                    section.decorationItems = [sectionBackgroundDecoration2, sectionBackgroundDecoration]
                }

                // Header
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .absolute(60)) // Adjust height as needed
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: "section-header",
                    alignment: .top
                )
//                section.boundarySupplementaryItems = [header]

            case .single:
                ()
            }

            return section
        }
        .addingDecorationViews()
        
        func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            header.pinToVisibleBounds = true // Optional: Makes the header sticky
            header.extendsBoundary = true   // Optional: Extend the header beyond section insets
            return header
        }
        
        return layout
    }
    
}

// Helper to register the decoration views
extension UICollectionViewCompositionalLayout {
    func addingDecorationViews() -> UICollectionViewCompositionalLayout {
        self.register(GroupSupplementaryBackgroundView.self, forDecorationViewOfKind: "group-background")
        self.register(SectionBackgroundDecorationView.self, forDecorationViewOfKind: "section-background")
        self.register(ItemBackgroundDecorationView.self, forDecorationViewOfKind: "section-background2")
        return self
    }
}

// Custom decoration views
class ItemBackgroundDecorationView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.masksToBounds = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Custom supplementary and decoration views
class GroupSupplementaryBackgroundView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SectionBackgroundDecorationView: UICollectionReusableView {
    let paddedBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .lightGray.withAlphaComponent(0.4)
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(paddedBackgroundView)
        
        // Add constraints to pad the background view
        paddedBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            paddedBackgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            paddedBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            paddedBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            paddedBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureColor(_ color: UIColor) {
        paddedBackgroundView.backgroundColor = color
    }
}
import SwiftUI

#Preview(body: {
    ViewController()
})
