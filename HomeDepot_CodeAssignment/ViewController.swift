//
//  ViewController.swift
//  HomeDepot_CodeAssignment
//
//  Created by Naga Kukunuru on 7/13/18.
//  Copyright © 2018 Naga Kukunuru. All rights reserved.
//

import UIKit

extension UICollectionView {
    func setItemsInRow(items: Int, height: CGFloat) {
        if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            let contentInset = self.contentInset
            let itemsInRow: CGFloat = CGFloat(items);
            let innerSpace = layout.minimumInteritemSpacing * (itemsInRow - 1.0)
            let insetSpace = contentInset.left + contentInset.right + layout.sectionInset.left + layout.sectionInset.right
            let width = floor((frame.width - insetSpace - innerSpace) / itemsInRow)
            layout.itemSize = CGSize(width: width, height: height)
        }
    }
}

class ViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var page: Int!
    var segmentedValue = 0
    var responseArray: [RepositResponse]? = [RepositResponse]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        collectionView.isPagingEnabled = true

        /* Setup delegates*/
        searchBar.delegate = self
        segmentedControl.selectedSegmentIndex = 0
        page = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        WebService.webService.repositResponses = [RepositResponse]()
        getDataFromServer(page: 1)
    }

    @IBAction func indexChanged(_ sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex {
            case 0:
                segmentedValue = 0
            case 1:
                segmentedValue = 1
            default:
                break
        }
        collectionView.reloadData()
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (responseArray?.isEmpty)! && collectionView.backgroundView == nil {
            let noItemLabel = UILabel() //no need to set frame.
            noItemLabel.textAlignment = .center
            noItemLabel.textColor = .lightGray
            noItemLabel.text = "No repositories found."
            collectionView.backgroundView = noItemLabel
        }
        collectionView.backgroundView?.isHidden = !(responseArray?.isEmpty)!
        return (responseArray?.count)!
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: CustomCell
        if segmentedValue == 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "list", for: indexPath) as! CustomCell
            collectionView.setItemsInRow(items: 1, height: 150)
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "grid", for: indexPath) as! CustomCell
            if UIDevice.current.orientation.isLandscape {
                collectionView.setItemsInRow(items: 3, height: 200)
            } else {
                collectionView.setItemsInRow(items: 2, height: 200)
            }
        }
        // Configure the cell
        guard let responses = responseArray else { return UICollectionViewCell() }
        cell.name_lbl.text = responses[indexPath.item].name
        cell.description_lbl.text = responses[indexPath.item].description
        cell.date_lbl.text = formatDate(dateString: responses[indexPath.item].dateCreated!)
        cell.license_lbl.text = responses[indexPath.item].license
        
        return cell
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
        
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: true)
        }
        collectionView.reloadData()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 30 {
            self.getDataFromServer(page: page)
        }
    }
    
    func getDataFromServer(page: Int){
        WebService.webService.getData(org_name: searchBar.text!, page: page) { (success) in
            if success {
                if WebService.webService.repositResponses != nil {
                    self.page = self.page + 1
                    self.responseArray = WebService.webService.repositResponses
                }
                self.collectionView.reloadData()
            } else {
                print("Failure : \(self.searchBar.text!) : \(self.page)")
            }
        }
    }

    func formatDate(dateString:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        
        let dateObj = dateFormatter.date(from: dateString)
        
        dateFormatter.dateFormat = "MMM-dd, yyyy HH:mm:ss"
        return dateObj == nil ? "" : dateFormatter.string(from: dateObj!)
    }
}

