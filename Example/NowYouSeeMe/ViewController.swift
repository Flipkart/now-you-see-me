//
//  ViewController.swift
//  NowYouSeeMe-Demo
//
//  Created by Naveen Chaudhary on 24/05/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

import UIKit
import NowYouSeeMe

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var showDismissButton = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.trackView()
        tableView.trackView()
        
        if showDismissButton {
            let button = UIBarButtonItem(title: "Dismiss", style: .plain, target: self, action: #selector(dismissButtonTapped))
            self.navigationItem.leftBarButtonItem = button
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
        
        #if DEBUG
        let button = UIBarButtonItem(title: "Debug", style: .done, target: self, action: #selector(openDebugConsole))
        self.navigationItem.rightBarButtonItem = button
        #endif
    }
    
    @objc func dismissButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    #if DEBUG
    @objc func openDebugConsole() {
        NowYou.debug()
    }
    #endif
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! TableCell
        cell.trackView()
        cell.collectionView.trackView()
        cell.collectionView.reloadData()
        return cell
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)
        cell.backgroundColor = .blue
        cell.trackView(self, conditions: conditions(cell))
        return cell
    }
    
    func conditions(_ view: UIView) -> [ViewCondition] {
        var conditions = [ViewCondition]()
        conditions.append(ScrollIdle(view))
        conditions.append(Viewability(view))
        conditions.append(Tracking(view))
        return conditions
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewController")
        if indexPath.item % 2 == 0 {
            let navVC = UINavigationController(rootViewController: vc)
            if let vc = vc as? ViewController {
                vc.showDismissButton = true
            }
            self.present(navVC, animated: true, completion: nil)
        } else {
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
}

extension ViewController: ViewabilityListener {
    func viewStarted(_ view: UIView) {
        view.backgroundColor = .green
    }
    
    func viewEnded(_ view: UIView, maxPercentage: Float) {
        view.backgroundColor = .red
    }
}

class TableCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
}
