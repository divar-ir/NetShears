//
//  RequestDetailViewController.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/12/21.
//
//

import UIKit

final class RequestDetailViewController: UIViewController, ShowLoaderProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: BodyExporterDelegate?
    
    var request: NetShearsRequestModel?
    var sections: [NetShearsSection] = [
        NetShearsSection(name: "Overview", type: .overview),
        NetShearsSection(name: "Request Header", type: .requestHeader),
        NetShearsSection(name: "Request Body", type: .requestBody),
        NetShearsSection(name: "Response Header", type: .responseHeader),
        NetShearsSection(name: "Response Body", type: .responseBody)
    ]
    
    var labelTextColor: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let urlString = request?.url{
            title = URL(string: urlString)?.path
        }
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(openActionSheet(_:)))
        navigationItem.rightBarButtonItems = [shareButton]
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: "TextTableViewCell", bundle: Bundle.module), forCellReuseIdentifier: "TextTableViewCell")
        tableView.register(UINib(nibName: "ActionableTableViewCell", bundle: Bundle.module), forCellReuseIdentifier: "ActionableTableViewCell")
        tableView.register(UINib(nibName: "RequestTitleSectionView", bundle: Bundle.module), forHeaderFooterViewReuseIdentifier: "RequestTitleSectionView")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    @objc func openActionSheet(_ sender: UIBarButtonItem){
        let ac = UIAlertController(title: "Wormholy", message: "Choose an option", preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Share", style: .default) { [weak self] (action) in
            self?.shareContent(sender)
        })
        ac.addAction(UIAlertAction(title: "Share (request as cURL)", style: .default) { [weak self] (action) in
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
    
    func shareContent(_ sender: UIBarButtonItem, requestExportOption: RequestResponseExportOption = .flat){
        if let request = request{
            NSHelper.shareRequests(presentingViewController: self, sender: sender, requests: [request], requestExportOption: requestExportOption, delegate: delegate)
        }
    }
    
    private var responseExportType: BodyExportType {
        guard let request = request else { return .default }
        return delegate?.netShears(exportResponseBodyFor: request) ?? .default
    }

    private var requestExportType: BodyExportType {
        guard let request = request else { return .default }
        return delegate?.netShears(exportRequestBodyFor: request) ?? .default
    }
    
    func openBodyDetailVC(title: String?, body: Data?, exportType: BodyExportType) {
        let storyboard = UIStoryboard.NetShearsStoryBoard
        if let requestDetailVC = storyboard.instantiateViewController(withIdentifier: "BodyDetailViewController") as? BodyDetailViewController{
            requestDetailVC.title = title
            requestDetailVC.data = body
            requestDetailVC.bodyExportType = exportType
            self.show(requestDetailVC, sender: self)
        }
    }
    
}

extension RequestDetailViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "RequestTitleSectionView") as! RequestTitleSectionView
        header.titleLabel.text = sections[section].name
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let section = sections[indexPath.section]
        if let req = request{
            switch section.type {
            case .overview:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextTableViewCell", for: indexPath) as! TextTableViewCell
                cell.textView.attributedText = RequestExporter.overview(request: req).changeTextColor(to: labelTextColor)
                return cell
            case .requestHeader:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextTableViewCell", for: indexPath) as! TextTableViewCell
                cell.textView.attributedText = RequestExporter.header(req.headers).changeTextColor(to: labelTextColor)
                return cell
            case .requestBody:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ActionableTableViewCell", for: indexPath) as! ActionableTableViewCell
                cell.labelAction?.text = "View body"
                return cell
            case .responseHeader:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextTableViewCell", for: indexPath) as! TextTableViewCell
                cell.textView.attributedText = RequestExporter.header(req.responseHeaders).changeTextColor(to: labelTextColor)
                return cell
            case .responseBody:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ActionableTableViewCell", for: indexPath) as! ActionableTableViewCell
                cell.labelAction?.text = "View body"
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
}

extension RequestDetailViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        
        switch section.type {
        case .requestBody:
            openBodyDetailVC(title: "Request Body", body: request?.httpBody, exportType: requestExportType)
            break
        case .responseBody:
            openBodyDetailVC(title: "Response Body", body: request?.dataResponse, exportType: responseExportType)
            break
        default:
            break
        }
    }
}
