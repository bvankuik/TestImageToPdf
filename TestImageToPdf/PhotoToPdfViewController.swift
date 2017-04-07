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
    @IBOutlet weak var containerView: UIView!

    private var pdfFilePath: String?
    private let a4 = CGSize(width: 595.2, height: 841.8)

    var image: UIImage?
    
    // MARK: - Actions
    
    @IBAction func method1Tapped(_ sender: UIButton) {
        self.spinner.startAnimating()
        self.performSelector(inBackground: #selector(convert1), with: nil)
    }

    @IBAction func method2Tapped(_ sender: UIButton) {
        self.spinner.startAnimating()
        self.pdfFilePath = nil
        self.performSelector(inBackground: #selector(convert2), with: nil)
    }

    func convert1() {
        guard let path = self.createPdfByRenderingContainerView() else {
            return
        }

        self.pdfFilePath = path
        self.performSelector(onMainThread: #selector(navigate), with: nil, waitUntilDone: false)
    }

    func convert2() {
        guard let path = self.createPdfAndManuallyLayoutImage() else {
            return
        }

        self.pdfFilePath = path
        self.performSelector(onMainThread: #selector(navigate), with: nil, waitUntilDone: false)
    }

    func navigate() {
        self.performSegue(withIdentifier: "PdfPreview", sender: nil)
    }
    
    // MARK: - Private functions
    
    private func createPdfByRenderingContainerView() -> String? {
        let imageSize = self.containerView.frame.size
        
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
        self.containerView.layer.render(in: context)
        
        UIGraphicsEndPDFContext()
        
        let filename = "PhotoToPdfViewController"
        let path = NSTemporaryDirectory() + filename + ".pdf"
        pdfData.write(toFile: path, atomically: true)
        return path
    }

    // Method from: http://stackoverflow.com/a/16132377/1085556
    private func createPdfAndManuallyLayoutImage() -> String? {
        guard let image = self.imageView.image else {
            return nil
        }

        let compression: CGFloat = 0.3
        guard let jpegData = UIImageJPEGRepresentation(image, compression) else {
            return nil
        }

        let jpegCFData = jpegData as CFData
        let dataProvider = CGDataProvider(data: jpegCFData)
        let cgImage = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true,
                              intent: CGColorRenderingIntent.defaultIntent)

        let pdfData = NSMutableData()
        let page = CGRect(x: 0, y: 0, width: a4.width, height: a4.height)
        UIGraphicsBeginPDFContextToData(pdfData, page, nil)
        UIGraphicsBeginPDFPage()

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        let horizontalScale = a4.width / image.size.width
        let verticalScale = a4.height / image.size.height
        let scale: CGFloat = min(horizontalScale, verticalScale)

        context.translateBy(x: 0, y: (a4.height / 2) + ((image.size.height * scale)/2))
        context.scaleBy(x: scale, y: -scale)

        context.draw(cgImage!, in: CGRect(origin: CGPoint(), size: image.size))
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
        if let image = self.image {
            self.imageView.image = image
        }

        // Leading and trailing space constraints are removed at build time, so create a ratio
        let widthConstraint = NSLayoutConstraint(item: self.containerView, attribute: .width, relatedBy: .equal,
                                                 toItem: self.containerView, attribute: .height,
                                                 multiplier: (self.a4.width/self.a4.height), constant: 1.0)
        self.containerView.addConstraint(widthConstraint)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.spinner.stopAnimating()

        // Uncomment for superfast testing
//        self.method2Tapped(UIButton())
    }

}
