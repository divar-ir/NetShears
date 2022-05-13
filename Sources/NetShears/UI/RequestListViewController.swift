//
//  RequestsViewController.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/1/21.
//
//

import UIKit


class RequestsViewController: UIViewController, ShowLoaderProtocol {
    
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: BodyExporterDelegate?

    private var filteredRequests: [NetShearsRequestModel] = Storage.shared.requests
    
    private var searchController: UISearchController?
    private let requestCellIdentifier = String(describing: RequestCell.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNavigationItems()
        addSearchController()
        registerNibs()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NewRequestNotification, object: nil, queue: nil) { [weak self] (notification) in
            DispatchQueue.main.async { [weak self] in
                self?.filteredRequests = self?.filterRequests(text: self?.searchController?.searchBar.text) ?? []
                self?.collectionView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func registerNibs() {
        collectionView?.register(UINib(nibName: String(describing: RequestCell.self), bundle: Bundle.module), forCellWithReuseIdentifier: requestCellIdentifier)
    }
    
    //  MARK: - Search
    
    private func addSearchController(){
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        if #available(iOS 9.1, *) {
            searchController?.obscuresBackgroundDuringPresentation = false
        } else {
            // Fallback
        }
        searchController?.searchBar.placeholder = "Search URL"
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            navigationItem.titleView = searchController?.searchBar
        }
        definesPresentationContext = true
    }
    
    private func filterRequests(text: String?) -> [NetShearsRequestModel]{
        guard let searchText = text, !searchText.isEmpty else { return Storage.shared.requests }
        
        return Storage.shared.requests.filter {
             $0.url.range(of: searchText, options: .caseInsensitive) != nil
        }
    }
    
    // MARK: - Actions
    
    @objc private func openActionSheet(_ sender: UIBarButtonItem){
        let ac = UIAlertController(title: "Wormholy", message: "Choose an option", preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Clear", style: .default) { [weak self] (action) in
            self?.clearRequests()
        })
        ac.addAction(UIAlertAction(title: "Share", style: .default) { [weak self] (action) in
            self?.shareContent(sender)
        })
        
        ac.addAction(UIAlertAction(title: "Share as cURL", style: .default) { [weak self] (action) in
            self?.shareContent(sender, requestExportOption: .curl)
        })
        ac.addAction(UIAlertAction(title: "Share as Postman Collection", style: .default) { [weak self] (action) in
                   self?.shareContent(sender, requestExportOption: .postman)
               })
        ac.addAction(UIAlertAction(title: "Close", style: .cancel) { (action) in
        })
        if UIDevice.current.userInterfaceIdiom == .pad {
            ac.popoverPresentationController?.barButtonItem = sender
        }
        present(ac, animated: true, completion: nil)
    }

    private func clearRequests() {
        Storage.shared.clearRequests()
        filteredRequests = Storage.shared.requests
        collectionView.reloadData()
    }
    
    private func shareContent(_ sender: UIBarButtonItem, requestExportOption: RequestResponseExportOption = .flat){
        NSHelper.shareRequests(presentingViewController: self, sender: sender, requests: filteredRequests, requestExportOption: requestExportOption, delegate: delegate)
    }
    
    // MARK: - Navigation
    
    private func addNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "More", style: .plain, target: self, action: #selector(openActionSheet(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
    }
    
    @objc private func done(){
        self.dismiss(animated: true, completion: nil)
    }
    
    private func openRequestDetailVC(request: NetShearsRequestModel){
        let storyboard = UIStoryboard.NetShearsStoryBoard
        if let requestDetailVC = storyboard.instantiateViewController(withIdentifier: String(describing: RequestDetailViewController.self)) as? RequestDetailViewController{
            requestDetailVC.request = request
            self.show(requestDetailVC, sender: self)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NewRequestNotification, object: nil)
    }
}

extension RequestsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredRequests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: requestCellIdentifier, for: indexPath) as! RequestCell
        
        cell.populate(request: filteredRequests[indexPath.item])
        return cell
    }
}

extension RequestsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openRequestDetailVC(request: filteredRequests[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 76)
        
    }
}

// MARK: - UISearchResultsUpdating Delegate
extension RequestsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredRequests = filterRequests(text: searchController.searchBar.text)
        collectionView.reloadData()
    }
}
