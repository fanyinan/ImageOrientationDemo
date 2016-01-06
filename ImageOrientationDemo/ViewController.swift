//
//  ViewController.swift
//  PhotoBrowserProject
//
//  Created by 范祎楠 on 15/11/25.
//  Copyright © 2015年 范祎楠. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var imageView4: UIImageView!
  @IBOutlet weak var imageView5: UIImageView!
  
  var imagePickerViewController: UIImagePickerController!
  
  var imageViewList: [UIImageView] = []
  
  var value1: CGFloat = 1
  var value2: CGFloat = 1
  var image: UIImage!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //    imagePickerHelper.maxSelectedCount = 4
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func onStart() {
    
    if UIImagePickerController.isSourceTypeAvailable(.Camera){
      
      imagePickerViewController = UIImagePickerController()
      imagePickerViewController.delegate = self
      navigationController?.presentViewController(imagePickerViewController, animated: true, completion: { () -> Void in
      })
    }
  }
  
  func getOrientation(image: UIImage) -> String {
    
    var imageOrientation = ""
    
    switch image.imageOrientation {
    case .Down:
      imageOrientation = "Down"
    case .Up:
      imageOrientation = "Up"
    case .Left:
      imageOrientation = "Left"
    case .Right:
      imageOrientation = "Right"
    case .DownMirrored:
      imageOrientation = "DownMirrored"
    case .UpMirrored:
      imageOrientation = "UpMirrored"
    case .RightMirrored:
      imageOrientation = "RightMirrored"
    case .LeftMirrored:
      imageOrientation = "LeftMirrored"
    }
    
    return imageOrientation
  }
  
  @IBAction func changeValue1(sender: UISlider) {
    value1 = CGFloat(sender.value)
    
    reDraw()
  }
  
  @IBAction func changeValue2(sender: UISlider) {
    value2 = CGFloat(sender.value)
    reDraw()
  }
  
  func getFixTransform(image: UIImage) -> CGAffineTransform {
    
    //    if image.imageOrientation == UIImageOrientation.Up {
    //      return image
    //    }
    var transform = CGAffineTransformIdentity
    let width = image.size.width
    let height = image.size.height
    
    switch (image.imageOrientation) {
    case .Down, .DownMirrored:
      transform = CGAffineTransformTranslate(transform, width * value1, height * value1)
      transform = CGAffineTransformRotate(transform, CGFloat(M_PI) * value2)
    case .Left, .LeftMirrored:
      transform = CGAffineTransformTranslate(transform, width * value1, 0)
      transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2) * value2)
    case .Right, .RightMirrored:
      transform = CGAffineTransformTranslate(transform, 0, height * value1)
      transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2) * value2)
    default: // .Up, .UpMirrored:
      break
    }
    
    switch (image.imageOrientation) {
    case .UpMirrored, .DownMirrored:
      transform = CGAffineTransformTranslate(transform, width, 0)
      transform = CGAffineTransformScale(transform, -1, 1)
    case .LeftMirrored, .RightMirrored:
      transform = CGAffineTransformTranslate(transform, height, 0)
      transform = CGAffineTransformScale(transform, -1, 1)
    default: // .Up, .Down, .Left, .Right
      break
    }
    
    return transform
  }
  
  /**
   旋转图片
   
   - parameter image: 原图
   
   - returns: 旋转后的图片
   */
  func fixOrientation(image: UIImage) -> UIImage {

    let imageRef = image.CGImage
    let width = image.size.width
    let height = image.size.height
    
    let ctx = CGBitmapContextCreate(nil, Int(width), Int(height),
      CGImageGetBitsPerComponent(imageRef), 0,
      CGImageGetColorSpace(imageRef),
      CGImageGetBitmapInfo(imageRef).rawValue)
    
    CGContextConcatCTM(ctx, getFixTransform(image))
    
    switch (image.imageOrientation) {
    case .Left, .LeftMirrored, .Right, .RightMirrored:
      CGContextDrawImage(ctx, CGRectMake(0, 0, height, width), imageRef)
    default:
      CGContextDrawImage(ctx, CGRectMake(0, 0, width, height), imageRef)
    }
    
    let fixImageRef = CGBitmapContextCreateImage(ctx)
    let fixImage = UIImage(CGImage: fixImageRef!)
    return fixImage
    
  }
  
  func dealImage(image: UIImage) {
    
    print("size : \(image.size), orientation: \(getOrientation(image))")
    
//        imageView4.layer.contentsRect = CGRect(x: 0, y: 0, width: 0.5, height: 0.5)
    imageView4.image = image
    
    print("----------------------------")
    
    let image2 = fixOrientation(image)
    //    let image2 = UIImage(CGImage: image.CGImage!, scale: image.scale, orientation: .Up)
    
    print("size : \(image2.size), orientation: \(getOrientation(image2))")
    
//        imageView5.layer.contentsRect = CGRect(x: 0, y: 0, width: 0.5, height: 0.5)
    imageView5.image = image2
    
  }
  
  func reDraw() {
    dealImage(image)
  }
  
  
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    let type : String = info[UIImagePickerControllerMediaType] as! String
    
    if type == "public.image" {
      
      
      image = info[UIImagePickerControllerOriginalImage] as! UIImage
      
      print("image size \(image.size)")
      
      dealImage(image)
      
      dismissViewControllerAnimated(true, completion: nil)
    }
  }
  
}
