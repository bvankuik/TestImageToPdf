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
    var pdfFilePath: String?
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        NSLog("didFinishNavigation")
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
        
        let url = URL(fileURLWithPath: path)
//        self.webView.load(request: URLRequest(url: url))
        self.webView.loadRequest(URLRequest(url: url))
    }

}
