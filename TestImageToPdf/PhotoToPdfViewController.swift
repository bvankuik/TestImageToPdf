//
//  PhotoToPdfViewController.swift
//  TestImageToPdf
//
//  Created by Bart van Kuik on 17/03/2017.
//  Copyright © 2017 DutchVirtual. All rights reserved.
//

import UIKit


class PhotoToPdfViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?
    
    private var pdfFilePath: String?
    
    // MARK: - Actions
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        self.pdfFilePath = nil
        if let path = self.createPdf() {
            self.pdfFilePath = path
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Private functions
    
    private func createPdf() -> String? {
        // Creates a mutable data object for updating with binary data, like a byte array
        let pdfData = NSMutableData()
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        
        // Points the pdf converter to the mutable data object and to the UIView to be converted
        UIGraphicsBeginPDFContextToData(pdfData, page, nil)
        UIGraphicsBeginPDFPage()
        
        // draws rect to the view and thus this is captured by UIGraphicsBeginPDFContextToData
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        self.imageView.layer.render(in: context)
        
        UIGraphicsEndPDFContext()
        
        let filename = "PhotoToPdfViewController"
        let path = NSTemporaryDirectory() + filename + ".pdf"
        pdfData.write(toFile: path, atomically: true)
        return path
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let path = self.pdfFilePath else {
            fatalError()
        }
        
        let vc = segue.destination as! PdfPreviewViewController
        vc.pdfFilePath = path
    }
    
    // MARK: - View cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageView.image = self.image
    }

}
