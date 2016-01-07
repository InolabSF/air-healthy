/// MARK: - AIRLoadingView
class AIRLoadingView: UIView {

    /// MARK: - property

    @IBOutlet weak var indicatorView: BLMultiColorLoader!


    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()

        self.indicatorView.colorArray = [
            UIColor.redColor(),
            UIColor.purpleColor(),
            UIColor.greenColor(),
            UIColor.blueColor(),
        ]
    }


    /// MARK: - event listener


    /// MARK: - public api

    func startAnimation() {
        self.hidden = false
        self.indicatorView.startAnimation()
    }

    func stopAnimation() {
        self.hidden = true
        self.indicatorView.stopAnimation()
    }


    /// MARK: - private api
}
