import UIKit


/// MARK: - AIRTutorialViewControllerDelegate
@objc protocol AIRTutorialViewControllerDelegate {

    /**
     * called when tutorial did finish
     * @param tutorialViewController AIRTutorialViewControllerDelegate
     */
    func didFisnish(tutorialViewController tutorialViewController: AIRTutorialViewController)

}


/// MARK: - AIRTutorialViewController
class AIRTutorialViewController: UIViewController {

    /// MARK: - property

    var animated = false // if animate when view appears?

    weak var delegate: AnyObject?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var finishButton: UIButton!

    var backgroundIndex = 0
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var nextBackgroundImageView: UIImageView!

    @IBOutlet var slideViews: [UIView]!


    /// MARK: - class method

    class func air_viewController() -> AIRTutorialViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier(AIRNSStringFromClass(AIRTutorialViewController)) as! AIRTutorialViewController
    }

    /**
     * start tutorial
     * @param parentViewController UIViewController
     * @param animated Bool
     **/
    class func air_viewController(parentViewController parentViewController: UIViewController, animated: Bool) -> AIRTutorialViewController {
        let vc = AIRTutorialViewController.air_viewController()
        vc.animated = animated
        vc.delegate = parentViewController
        let parentView = UIApplication.sharedApplication().keyWindow!
        parentView.addSubview(vc.view)
        vc.view.frame = CGRectMake(0, 0, parentView.frame.width, parentView.frame.height)
        return vc
    }

    /**
     * if it will be tutorial or not
     * @return Bool
     **/
    class func willBeTutorial() -> Bool {
        let doneTutorial = NSUserDefaults().boolForKey(AIRUserDefaults.Tutorial)
        return (!doneTutorial)
    }


    /// MARK: - destruction

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    /// MARK: - life cycle

    override func loadView() {
        super.loadView()

        // background
        self.changeBackgroundImage()

        // scroll view
        self.pageControl.currentPage = 0
        self.scrollView.contentSize = CGSizeMake(self.view.frame.width * CGFloat(self.pageControl.numberOfPages), self.view.frame.height)

        // slides
        for var i = 0; i < self.slideViews.count; i++ {
            self.slideViews[i].frame = CGRectMake(self.slideViews[i].frame.origin.x+self.slideViews[i].frame.width*CGFloat(i), self.slideViews[i].frame.origin.y, self.slideViews[i].frame.width, self.slideViews[i].frame.height)
        }

        if animated { self.appear() }

        // notification
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("tutorialWillMoveSlide:"),
            name: AIRNotificationCenter.TutorialMoveSlide,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("tutorialWillChangeSlide:"),
            name: AIRNotificationCenter.TutorialChangeSlide,
            object: nil
        )
        NSNotificationCenter.defaultCenter().postNotificationName(
            AIRNotificationCenter.TutorialMoveSlide,
            object: nil,
            userInfo: [:]
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    }


    /// MARK: - event listener

    /**
     * called when button is touched up inside
     * @param button UIButton
     **/
    @IBAction func touchUpInside(button button: UIButton) {
        self.disappear()
    }


    /// MARK: - notification

    func tutorialWillMoveSlide(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { [unowned self] in
            self.backgroundImageView.image = self.nextBackgroundImageView.image
            self.backgroundImageView.frame = self.nextBackgroundImageView.frame
            self.nextBackgroundImageView.alpha = 0.0

            // move
            let duration = 25.0
            UIView.animateWithDuration(
                duration,
                animations: { [unowned self] () -> Void in
                    self.moveBackgroundImage()
                },
                completion: { (finished: Bool) -> Void in
                    // notification
                    NSNotificationCenter.defaultCenter().postNotificationName(
                        AIRNotificationCenter.TutorialChangeSlide,
                        object: nil,
                        userInfo: [:]
                    )
                }
            )
        })
    }

    func tutorialWillChangeSlide(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { [unowned self] in
            // change
            self.changeBackgroundImage()
            self.nextBackgroundImageView.alpha = 0.0
            let duration = 2.0
            UIView.animateWithDuration(
                duration,
                animations: { [unowned self] () -> Void in
                    self.nextBackgroundImageView.alpha = 1.0
                },
                completion: { (finished: Bool) -> Void in
                    // notification
                    NSNotificationCenter.defaultCenter().postNotificationName(
                        AIRNotificationCenter.TutorialMoveSlide,
                        object: nil,
                        userInfo: [:]
                    )
                }
            )
        })
    }


    /// MARK: - public api


    /// MARK: - private api

    /**
     * move image
     **/
    private func moveBackgroundImage() {
        let x = self.backgroundImageView.frame.origin.x
        let y = self.backgroundImageView.frame.origin.y
        var move = CGSizeMake(self.view.frame.width-self.backgroundImageView.frame.width, self.view.frame.height-self.backgroundImageView.frame.height)
        if x < 0 && y < 0 {
            move = CGSizeMake(-move.width, -move.height)
        }
        else if x < 0 {
            move = CGSizeMake(-move.width, move.height)
        }
        else if y < 0 {
            move = CGSizeMake(move.width, -move.height)
        }
        let frame = CGRectMake(x+move.width, y+move.height, self.backgroundImageView.frame.width, self.backgroundImageView.frame.height)
        self.backgroundImageView.frame = frame
        self.nextBackgroundImageView.frame = frame
    }

    /**
     * change image
     **/
    private func changeBackgroundImage() {
        // ajust background image size
        let imageCount = 3
        let image = UIImage(named: "tutorial_background_\(self.backgroundIndex)")
        let height = self.view.frame.height * 1.2//width * (image!.size.height) / (image!.size.width)
        let width = height * (image!.size.width) / (image!.size.height)//self.view.frame.width * (image!.size.width+200) / image!.size.width

        let points = [
            CGPointMake(0, 0),
            CGPointMake(self.view.frame.width-width, 0),
            CGPointMake(0, self.view.frame.height-height),
            CGPointMake(self.view.frame.width-width, self.view.frame.height-height),
        ]
        let index = Int(arc4random_uniform(UInt32(points.count)))
        let frame = CGRectMake(points[index].x, points[index].y, width, height)
        self.nextBackgroundImageView.frame = frame
        self.nextBackgroundImageView.image = image

        self.backgroundIndex = (self.backgroundIndex + 1) % imageCount
    }

    /**
     * appearing animation
     **/
    private func appear() {
        self.view.alpha = 0
        UIView.animateWithDuration(
            0.35,
            delay: 0.0,
            options: .CurveEaseOut,
            animations: { [unowned self] in
                self.view.alpha = 1
            },
            completion: { finished in
            }
        )
    }

    /**
     * disappearing animation
     **/
    private func disappear() {
        NSNotificationCenter.defaultCenter().removeObserver(self)

        self.view.alpha = 1
        UIView.animateWithDuration(
            0.20,
            delay: 0.0,
            options: .CurveEaseOut,
            animations: { [unowned self] in
                self.view.alpha = 0
            },
            completion: { [unowned self] finished in
                NSUserDefaults().setObject(true, forKey: AIRUserDefaults.Tutorial)
                NSUserDefaults().synchronize()
                self.view.removeFromSuperview()
                if self.delegate != nil {
                    (self.delegate as! AIRTutorialViewControllerDelegate).didFisnish(tutorialViewController: self)
                }
            }
        )
    }

}


/// MARK: - UIScrollViewDelegate
extension AIRTutorialViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(scrollView: UIScrollView) {
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var currentPage = Int(self.scrollView.contentOffset.x / self.scrollView.frame.width)
        if currentPage < 0 { currentPage = 0 }
        if currentPage > self.pageControl.numberOfPages { currentPage = self.pageControl.numberOfPages }
        self.pageControl.currentPage = currentPage
    }

}
