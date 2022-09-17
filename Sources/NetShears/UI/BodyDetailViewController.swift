//
//  BodyDetailViewController.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/11/21.
//
//

import UIKit

final class BodyDetailViewController: UIViewController, ShowLoaderProtocol {

    @IBOutlet weak var bottomViewInputConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var labelWordFinded: UILabel!
    @IBOutlet weak var textView: NSTextView!
    @IBOutlet weak var buttonPrevious: UIBarButtonItem!
    @IBOutlet weak var buttonNext: UIBarButtonItem!

    static let kPadding: CGFloat = 10.0
    
    var bodyExportType: BodyExportType = .default
    var textColor: UIColor {
        guard #available(iOS 13.0, *) else {
            return .black
        }
        return UIColor(dynamicProvider: { trait in
            switch trait.userInterfaceStyle {
            case .light:
                return .black
            case .dark:
                return .white
            case .unspecified:
                return .gray
            @unknown default:
                return .gray
            }
        })
    }
    var searchController: UISearchController?
    var highlightedWords: [NSTextCheckingResult] = []
    var data: Data?
    var indexOfWord: Int = 0

    let jsonValidatorOnline = JSONValidatorOnline()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupObservers()
        setupTextView()
        setupNavigationItems()
        setupNextPreviousButtons()
        addSearchController()
        hideViewInValidatorButtonIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setBody()
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(BodyDetailViewController.handleKeyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BodyDetailViewController.handleKeyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func setupTextView() {
        textView.font = UIFont(name: "Courier", size: 14)
        textView.dataDetectorTypes = UIDataDetectorTypes.link
        setupAlignmentAndColor()
    }

    private func setupAlignmentAndColor() {
        textView.textAlignment = .left
        textView.textColor = textColor
    }

    private func setupNavigationItems() {
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareContent(_:)))
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearch))
        navigationItem.rightBarButtonItems = [searchButton, shareButton]
    }

    private func setupNextPreviousButtons() {
        buttonPrevious.isEnabled = false
        buttonNext.isEnabled = false
        guard UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft, var items = toolBar.items else {
            return
        }
        items.reverse()
        toolBar.items = items
    }

    private func setBody() {
        let hud = showLoader(view: view)
        RequestExporter.body(data, bodyExportType: bodyExportType) { [weak self] stringData in
            let formattedJSON = stringData
            DispatchQueue.main.async {
                self?.textView.text = formattedJSON
                self?.hideLoader(loaderView: hud)
            }
        }
    }

    //  MARK: - Search
    func addSearchController(){
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.returnKeyType = .done
        searchController?.searchBar.delegate = self
        if #available(iOS 9.1, *) {
            searchController?.obscuresBackgroundDuringPresentation = false
        } else {
            // Fallback
        }
        searchController?.searchBar.placeholder = "Search"
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            navigationItem.titleView = searchController?.searchBar
        }
        definesPresentationContext = true
    }

    func hideViewInValidatorButtonIfNeeded() {
        if #available(iOS 11.0, *) {
            return
        }
        let irRTL = view.semanticContentAttribute == .forceRightToLeft
        _ = irRTL ? toolBar.items?.removeLast() : toolBar.items?.removeFirst()
    }

    @IBAction func previousStep(_ sender: UIBarButtonItem?) {
        indexOfWord -= 1
        if indexOfWord < 0 {
            indexOfWord = highlightedWords.count - 1
        }
        getCursor()
    }

    @IBAction func nextStep(_ sender: UIBarButtonItem?) {
        indexOfWord += 1
        if indexOfWord >= highlightedWords.count {
            indexOfWord = 0
        }
        getCursor()
    }

    @IBAction func openValidatorTapped(_ sender: Any) {
        jsonValidatorOnline.open(jsonString: textView.text, on: self)
    }

    func getCursor() {
        let value = highlightedWords[indexOfWord]
        if let range = textView.convertRange(range: value.range) {
            let rect = textView.firstRect(for: range)

            labelWordFinded.text = "\(indexOfWord + 1) of \(highlightedWords.count)"
            let focusRect = CGRect(origin: textView.contentOffset, size: textView.frame.size)
            if !focusRect.contains(rect) {
                textView.setContentOffset(CGPoint(x: 0, y: rect.origin.y - BodyDetailViewController.kPadding), animated: true)
            }
            cursorAnimation(with: value.range)
            setupAlignmentAndColor()
        }
    }

    func performSearch(text: String?) {
        highlightedWords.removeAll()
        highlightedWords = textView.highlights(text: text, with: Colors.UI.wordsInEvidence, font: UIFont(name: "Courier", size: 14)!, highlightedFont: UIFont(name: "Courier-Bold", size: 14)!)

        indexOfWord = 0

        if highlightedWords.count != 0 {
            getCursor()
            buttonPrevious.isEnabled = true
            buttonNext.isEnabled = true
        }
        else {
            buttonPrevious.isEnabled = false
            buttonNext.isEnabled = false
            labelWordFinded.text = "0 of 0"
        }
    }

    @objc func shareContent(_ sender: UIBarButtonItem){
        if let text = textView.text{
            let textShare = [text]
            let activityViewController = UIActivityViewController(activityItems: textShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.barButtonItem = sender
            self.present(activityViewController, animated: true, completion: nil)
        }
    }

    @objc func showSearch() {
        searchController?.isActive = true
    }

    // MARK: - Keyboard

    @objc func handleKeyboardWillShow(_ sender: NSNotification) {
        guard let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size else { return }

        animationInputView(with: -keyboardSize.height, notification: sender)
    }

    @objc func handleKeyboardWillHide(_ sender: NSNotification) {
        animationInputView(with: 0.0, notification: sender)
    }

    func animationInputView(with height: CGFloat, notification: NSNotification) {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber

        self.bottomViewInputConstraint.constant = height

        UIView.animate(withDuration: duration?.doubleValue ?? 0.0, delay: 0.0, options: UIView.AnimationOptions(rawValue: UIView.AnimationOptions.RawValue((curve?.intValue)!)), animations: {
            self.view.layoutIfNeeded()
        })
    }

}

extension BodyDetailViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text?.isEmpty == false {
            performSearch(text: searchController.searchBar.text)
        }
        else {
            resetSearchText()
        }
    }
}

extension BodyDetailViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension BodyDetailViewController {
    func resetSearchText() {
        let prettyString = textView.attributedText.string.prettyPrintedJSON ?? textView.attributedText.string
        let attributedString = NSMutableAttributedString(string: prettyString)
            attributedString.addAttribute(.backgroundColor, value: UIColor.clear, range: NSRange(location: 0, length: self.textView.attributedText.length))
            attributedString.addAttribute(.font, value: UIFont(name: "Courier", size: 14)!, range: NSRange(location: 0, length: self.textView.attributedText.length))

        self.textView.attributedText = attributedString
        self.labelWordFinded.text = "0 of 0"
        self.buttonPrevious.isEnabled = false
        self.buttonNext.isEnabled = false
        setupAlignmentAndColor()
    }

    func cursorAnimation(with range: NSRange) {
        let attributedString = NSMutableAttributedString(attributedString: self.textView.attributedText)

        highlightedWords.forEach {
            attributedString.addAttribute(.backgroundColor, value: Colors.UI.wordsInEvidence, range: $0.range)
            attributedString.addAttribute(.font, value: UIFont(name: "Courier-Bold", size: 14)!, range: $0.range)
        }
        self.textView.attributedText = attributedString

        attributedString.addAttribute(.backgroundColor, value: Colors.UI.wordFocus, range: range)
        self.textView.attributedText = attributedString
    }
}
