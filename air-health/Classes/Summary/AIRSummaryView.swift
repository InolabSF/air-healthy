/// MARK: - AIRSummaryViewDelegate
@objc protocol AIRSummaryViewDelegate {

    /**
     * called when button is touched up inside
     * @param summaryView AIRSummaryView
     * @param button UIButton
     */
    func touchedUpInside(summaryView summaryView: AIRSummaryView, button: UIButton)

}


/// MARK: - AIRSummaryView
class AIRSummaryView: UIView {

    /// MARK: - constant


    /// MARK: - property

    @IBOutlet weak var delegate: AnyObject?

    @IBOutlet weak var summaryButtonView: UIView!
    @IBOutlet weak var summaryButton: UIButton!
    @IBOutlet weak var summaryStatusLabel: UILabel!

    @IBOutlet weak var masksView: UIView!
    @IBOutlet weak var masksButton: UIButton!
    @IBOutlet weak var masksLabel: UILabel!

    @IBOutlet weak var summaryLabelWrapperView: UIView!
    @IBOutlet weak var summaryTitleWrapperView: UIView!
    @IBOutlet weak var summaryLabel: UILabel!

    @IBOutlet weak var sportsView: UIView!
    @IBOutlet weak var sportsButton: UIButton!
    @IBOutlet weak var sportsLabel: UILabel!


    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()

        self.setUp()
    }


    /// MARK: - event listener

    /**
     * called when button is touched up inside
     * @param button UIButton
     **/
    @IBAction func touchedUpInside(button button: UIButton) {
        if button == self.summaryButton {
            if self.delegate != nil {
                (self.delegate as! AIRSummaryViewDelegate).touchedUpInside(summaryView: self, button: button)
            }
        }
        else if button == self.masksButton {
        }
        else if button == self.sportsButton {
        }
    }


    /// MARK: - notification


    /// MARK: - public api

    /**
     * set values
     * @param values [Double]
     **/
    func setValues(values: [Double]) {
        var average = 0.0
        let count = values.count
        for value in values { average += value }
        if count > 0 { average = average / Double(count) }

        self.masksView.hidden = true
        self.sportsView.center = CGPointMake(self.sportsView.frame.width, self.sportsView.center.y)

        var paragraph = ""
        if average < AIRSensorManager.Basement_1 {
            self.summaryButton.setImage(UIImage(named: "home_summary_good"), forState: .Normal)
            self.summaryStatusLabel.text = "Good"
            self.sportsButton.setImage(UIImage(named: "home_summary_sports_good"),  forState: .Normal)
            self.sportsLabel.text = "Go for it"
            paragraph = "The air is fresh. It is good for outdoor activities!"
        }
        else if average < AIRSensorManager.Basement_2 {
            self.summaryButton.setImage(UIImage(named: "home_summary_normal"), forState: .Normal)
            self.summaryStatusLabel.text = "Normal"
            self.sportsButton.setImage(UIImage(named: "home_summary_sports_normal"),  forState: .Normal)
            self.sportsLabel.text = "Take it easy"
            paragraph = "The air is polluted above WHO recommendation. Long term exposure can affect the cardiovascular and respiratory health."
        }
        else {
            self.summaryButton.setImage(UIImage(named: "home_summary_bad"), forState: .Normal)
            self.summaryStatusLabel.text = "Bad"
            self.sportsButton.setImage(UIImage(named: "home_summary_sports_bad"),  forState: .Normal)
            self.sportsLabel.text = "Don't run"
            self.masksView.hidden = false
            self.sportsView.frame = CGRectMake(
                self.masksView.frame.width, self.sportsView.frame.origin.y,
                self.sportsView.frame.width, self.sportsView.frame.height
            )
            paragraph = "The air is highly polluted above WHO Air quality guidelines. It can cause the burden of disease from stroke, heart disease, lung cancer, and both chronic and acute respiratory diseases, including asthma. Find an alternative route next time or leave after the rush hour to avoid harmful air."
        }

        let top = self.summaryLabel.frame.origin.y
        self.summaryLabel.attributedText = paragraph.air_justifiedString(font: self.summaryLabel.font)
        self.summaryLabel.textAlignment = NSTextAlignment.Justified
        self.summaryLabel.preferredMaxLayoutWidth = self.summaryLabel.frame.width
        self.summaryLabel.sizeToFit()
        let center = CGPointMake(self.center.x, top + self.summaryLabel.frame.height / 2.0)
        self.summaryLabel.center = center
    }


    /// MARK: - private api

    /**
     * set up
     **/
    private func setUp() {
        self.summaryButtonView.layer.cornerRadius = self.summaryButtonView.frame.size.width / 2.0
        self.summaryButtonView.layer.masksToBounds = true
        self.summaryButtonView.clipsToBounds = true

        self.summaryButton.layer.shadowOffset = CGSizeMake(0, 0)
        self.summaryButton.layer.shadowOpacity = 0.15
        self.summaryButton.layer.shadowRadius = 2.0
        self.summaryButton.layer.shadowPath = UIBezierPath(roundedRect: self.summaryButton.bounds, cornerRadius: self.summaryButton.bounds.width/2.0).CGPath

        self.summaryTitleWrapperView.layer.cornerRadius = 18.0
        self.summaryTitleWrapperView.layer.masksToBounds = true
        self.summaryTitleWrapperView.clipsToBounds = true

        self.summaryLabelWrapperView.layer.shadowOffset = CGSizeMake(0, 0)
        self.summaryLabelWrapperView.layer.shadowOpacity = 0.3
        self.summaryLabelWrapperView.layer.shadowRadius = 2.0
        self.summaryLabelWrapperView.layer.shadowPath = UIBezierPath(
            roundedRect: CGRectMake(self.summaryLabelWrapperView.bounds.origin.x, self.summaryLabelWrapperView.bounds.origin.y, UIScreen.mainScreen().bounds.width, self.summaryLabelWrapperView.bounds.height),
            cornerRadius: 18.0
        ).CGPath

    }

}
