//
//  PdfPreviewViewController.swift
//  TestImageToPdf
//
//  Created by Bart van Kuik on 17/03/2017.
//  Copyright © 2017 DutchVirtual. All rights reserved.
//

import UIKit
import WebKit


class PdfPreviewViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: UIWebView!
    private var shareButton: UIBarButtonItem!

    var pdfFilePath: String?
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        NSLog("didFinishNavigation")
    }
    
    // MARK: - Actions
    
    func share() {
        guard let path = self.pdfFilePath else {
            return
        }
        
        let fileURL = NSURL(fileURLWithPath: path)
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - View cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let path = self.pdfFilePath else {
            fatalError()
        }

        var fileSize: UInt64 = 0

        do {
            let attr = try FileManager.default.attributesOfItem(atPath: path)
            fileSize = attr[FileAttributeKey.size] as! UInt64
        } catch {
            fatalError(error.localizedDescription)
        }
        fileSize = fileSize / 1024
        self.title = "File size: \(fileSize) KiB"
        
        let url = URL(fileURLWithPath: path)
        self.webView.loadRequest(URLRequest(url: url))
        
        self.shareButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(share))
        self.navigationItem.rightBarButtonItem = self.shareButton
    }

}
