//
//  PhotoToPdfViewController.swift
//  TestImageToPdf
//
//  Created by Bart van Kuik on 17/03/2017.
//  Copyright © 2017 DutchVirtual. All rights reserved.
//

import UIKit


class PhotoToPdfViewController: UIViewController {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var convertToPdfButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    private var pdfFilePath: String?
    private let a4 = CGSize(width: 595.2, height: 841.8)

    var image: UIImage?
    
    // MARK: - Actions
    
    @IBAction func convertToPdfTapped(_ sender: UIButton) {
        self.spinner.startAnimating()
        self.performSelector(inBackground: #selector(convert), with: nil)
    }
    
    func convert() {
        self.pdfFilePath = nil
        if let path = self.createPdf() {
            self.pdfFilePath = path
            self.performSelector(onMainThread: #selector(navigate), with: nil, waitUntilDone: false)
        } else {
            fatalError()
        }
    }
    
    func navigate() {
        self.performSegue(withIdentifier: "PdfPreview", sender: nil)
    }
    
    // MARK: - Private functions
    
    private func createPdf() -> String? {
        let imageSize = self.imageView.frame.size
        
        // Creates a mutable data object for updating with binary data, like a byte array
        let pdfData = NSMutableData()
        // A4, 72 dpi
        let page = CGRect(x: 0, y: 0, width: a4.width, height: a4.height)
        
        // Points the pdf converter to the mutable data object and to the UIView to be converted
        UIGraphicsBeginPDFContextToData(pdfData, page, nil)
        UIGraphicsBeginPDFPage()
        
        // draws rect to the view and thus this is captured by UIGraphicsBeginPDFContextToData
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        let horizontalScale = a4.width * imageSize.width
        let verticalScale = a4.height / imageSize.height
        let scale: CGFloat = min(horizontalScale, verticalScale)
        print("imageSize=\(imageSize), a4=\(a4)")
        print("horizontalScale=\(horizontalScale), verticalScale=\(verticalScale), scale=\(scale)")
        
        context.scaleBy(x: scale, y: scale)
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

        self.imageView.contentMode = .scaleAspectFit
        self.imageView.image = self.image
        self.view.addSubview(self.imageView)

        self.imageView.layer.borderColor = UIColor.black.cgColor
        self.imageView.layer.borderWidth = 2

        // Leading and trailing space constraints are removed at build time, so create a ratio
        let widthConstraint = NSLayoutConstraint(item: self.imageView, attribute: .width, relatedBy: .equal,
                                                 toItem: self.imageView, attribute: .height,
                                                 multiplier: (self.a4.width/self.a4.height), constant: 1.0)
        self.imageView.addConstraint(widthConstraint)
        
        self.view.sendSubview(toBack: self.imageView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.spinner.stopAnimating()
    }

}
