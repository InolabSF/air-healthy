// MARK: - AIRTimelineViewDelegate
@objc protocol AIRTimelineViewDelegate {

    /**
     * called when control value changed
     * @param timelineView AIRTimelineView
     * @param control GradientSlider
     */
    func valueChanged(timelineView timelineView: AIRTimelineView, control: GradientSlider)

}


/// MARK: - AIRTimelineView
class AIRTimelineView: UIView {

    /// MARK: - constant

    static let Hour = 6.0


    /// MARK: - property

    @IBOutlet weak var delegate: AnyObject?

    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var datePickerButton: BFPaperButton!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickButton: UIButton!

    @IBOutlet weak var timeSliderView: UIView!

    @IBOutlet weak var timeSliderTitleView: UIView!
    @IBOutlet weak var timeSliderTitleLabel: UILabel!

    @IBOutlet weak var timeSliderContentView: UIView!
    var timelineLineChartView: JTChartView?
    @IBOutlet weak var timelineLineChartBackgroundView: UIView!
    @IBOutlet weak var timeSlider: GradientSlider!
    @IBOutlet weak var timeIndicatorView: UIView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var greenView: UIView!
    @IBOutlet weak var yellowView: UIView!
    @IBOutlet weak var redView: UIView!


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
    @IBAction func touchUpInside(button button: UIButton) {
        if button == self.dateButton {
        }
        if button == self.datePickerButton {
            if self.datePickerView.hidden {
                self.appearDatePicker()
            }
            else {
                self.disappearDatePicker()
            }
        }
        if button == self.datePickButton {
            self.disappearDatePicker()
            AIRSummary.sharedInstance.startLoading()

            let dateFormatter = NSDateFormatter.air_dateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            //let dateString = dateFormatter.stringFromDate(self.datePicker.date.air_daysAgo(days: -1)!)
            let dateString = dateFormatter.stringFromDate(self.datePicker.date)
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = self.datePicker.date.air_isToday() ? NSDate() : dateFormatter.dateFromString("\(dateString) 23:59:59")!
            //let date = dateFormatter.dateFromString("\(dateString) 00:00:00")!

            //let date = self.datePicker.date

            self.setDate(date)
            AIRSummary.sharedInstance.getSensorsFromServer(date: date)
        }
    }

    /**
     * called when control touched down
     * @param control UIControl
     **/
    @IBAction func touchDown(control control: UIControl) {
        if control == self.timeSlider {
            //self.timeIndicatorView.hidden = true
            //self.timeIndicatorView.alpha = 0.35
        }
    }

    /**
     * called when control touched up
     * @param control UIControl
     **/
    @IBAction func touchUp(control control: UIControl) {
        if control == self.timeSlider {
            //self.timeIndicatorView.hidden = false
            //self.timeIndicatorView.alpha = 1.0
        }
    }

    /**
     * called when control value changed
     * @param control UIControl
     **/
    @IBAction func valueChanged(control control: UIControl) {
        if control == self.timeSlider {
            (self.delegate as! AIRTimelineViewDelegate).valueChanged(timelineView: self, control: self.timeSlider)
        }
        if control == self.datePicker {
            if self.datePicker.date.compare(self.datePicker.minimumDate!) == .OrderedAscending {
                self.datePicker.date = self.datePicker.minimumDate!
            }
            if self.datePicker.date.compare(self.datePicker.maximumDate!) == .OrderedDescending {
                self.datePicker.date = self.datePicker.maximumDate!
            }
        }
    }


    /// MARK: - public api

    /**
     * move timeline indicator
     **/
    func moveTimelineIndicator() {
        if self.timeSlider.maximumValue == 0.0 { self.timeSlider.maximumValue = 1.0 }
        //let x = 1.0 + (self.timelineLineChartBackgroundView.frame.width - 3.0) * self.timeSlider.value / self.timeSlider.maximumValue
        let x = (self.timelineLineChartView != nil) ? 1.0 + (self.timelineLineChartView!.frame.width - 3.0) * self.timeSlider.value / self.timeSlider.maximumValue : 1.0 + (self.timelineLineChartBackgroundView.frame.width - 3.0) * self.timeSlider.value / self.timeSlider.maximumValue
        self.timeIndicatorView.frame = CGRectMake(
            x, self.timeIndicatorView.frame.origin.y,
            self.timeIndicatorView.frame.width, self.timeIndicatorView.frame.height
        )
    }

    /**
     * set timeline value
     * @param time String
     * @param color UIColor
     **/
    func setTimeline(time time: String, color: UIColor) {
        // time
        self.timeLabel.text = time
        // color
        self.timeLabel.textColor = color

        self.moveTimelineIndicator()
    }

    /**
     * set line chart
     * @param lineChart line chart
     * @param valuesPerMinute [Double]
     * @param sensorBasements [Double]
     **/
    func setLineChart(passes passes: [CLLocation], valuesPerMinute: [Double], sensorBasements: [Double]) {
        self.timeSliderContentView.hidden = true

        if self.timelineLineChartView != nil {
            self.timelineLineChartView!.removeFromSuperview()
            self.timelineLineChartView = nil
        }
        if passes.count < 2 { return }

        self.timeSliderContentView.hidden = false

        self.initTimelabels(passes: passes)

        // max value
        var maxValue = 0.001
        var values: [NSNumber] = []
        for var i = 0; i < valuesPerMinute.count; i++ {
            let value = valuesPerMinute[i]
            if value > maxValue { maxValue = value }
        }
        // values
        if maxValue < sensorBasements.last! { maxValue = sensorBasements.last! }
        for var i = 0; i < valuesPerMinute.count; i++ {
            let value = valuesPerMinute[i] / maxValue * 100.0
            values.append(NSNumber(double: value))
        }

        // color view
        var topY = CGFloat(0.0)
        var bottomY = self.timelineLineChartBackgroundView.frame.height
        let colorViews = [self.greenView, self.yellowView, self.redView,]
        for var i = 0; i < colorViews.count; i++ {
            if i >= sensorBasements.count || sensorBasements[i] > maxValue { topY = CGFloat(0.0) }
            else { topY = self.timelineLineChartBackgroundView.frame.height * CGFloat(1.0 - sensorBasements[i] / maxValue) }
            colorViews[i].frame = CGRectMake(
                colorViews[i].frame.origin.x, topY,
                colorViews[i].frame.width, bottomY - topY
            )
            bottomY = topY
        }

        // line chart
        var width = self.timelineLineChartBackgroundView.frame.width * CGFloat(passes.last!.timestamp.timeIntervalSinceDate(passes.first!.timestamp) / (60.0 * 60.0 * AIRTimelineView.Hour))
        self.timelineLineChartView = JTChartView(
            //frame: CGRectMake(0, 0, self.timelineLineChartBackgroundView.frame.width, self.timelineLineChartBackgroundView.frame.height),
            frame: CGRectMake(0, 0, width, self.timelineLineChartBackgroundView.frame.height),
            values: values,
            curveColor: UIColor.darkGrayColor(),
            curveWidth: 2.0,
            topGradientColor: UIColor.clearColor(),
            bottomGradientColor: UIColor.clearColor(),
            minY: 0.0,
            maxY: 1.0,
            topPadding: 0
        )
        self.timelineLineChartBackgroundView.addSubview(self.timelineLineChartView!)

        // slider
        width = self.timelineLineChartBackgroundView.frame.width * CGFloat(passes.last!.timestamp.timeIntervalSinceDate(passes.first!.timestamp) / (60.0 * 60.0 * AIRTimelineView.Hour)) + 64.0
        let x = (self.frame.width - (self.timelineLineChartBackgroundView.frame.width + 64.0)) / 2.0
        self.timeSlider.frame = CGRectMake(x, self.timeSlider.frame.origin.y, width, self.timeSlider.frame.height)
    }

    /**
     * init start, end, current time
     * @param passes [CLLocatoin]
     **/
    func initTimelabels(passes passes: [CLLocation]) {
        self.startTimeLabel.text = ""
        self.endTimeLabel.text = ""
        self.timeLabel.text = ""
        if passes.count < 2 { return }

        let dateFormatter = NSDateFormatter.air_dateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        self.startTimeLabel.text = dateFormatter.stringFromDate(passes.first!.timestamp.air_minutesAgo(minutes: -1)!)
        //self.endTimeLabel.text = dateFormatter.stringFromDate(passes.last!.timestamp)
        let last = passes.first!.timestamp.dateByAddingTimeInterval(AIRTimelineView.Hour * 60.0 * 60.0)
        self.endTimeLabel.text = dateFormatter.stringFromDate(last.air_minutesAgo(minutes: -1)!)
        self.timeLabel.text = self.startTimeLabel.text
    }

    /**
     * set date
     * @param date NSDate
     **/
    func setDate(date: NSDate) {
        let dateFormatter = NSDateFormatter.air_dateFormatter()
        // year
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.stringFromDate(date)
        // month
        dateFormatter.dateFormat = "MMMM"
        let month = (dateFormatter.stringFromDate(date) as NSString).substringWithRange(NSRange(location: 0, length: 3))
        // day
        dateFormatter.dateFormat = " dd "
        let day = dateFormatter.stringFromDate(date)

        let yearString = NSAttributedString(
            string: year,
            attributes: [
                NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 16)!,
                NSForegroundColorAttributeName: UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
            ]
        )
        let monthString = NSAttributedString(
            string: month,
            attributes: [
                NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 12)!,
                NSForegroundColorAttributeName: UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
            ]
        )
        let dayString = NSAttributedString(
            string: day,
            attributes: [
                NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 24)!,
                NSForegroundColorAttributeName: UIColor(red: 64.0/255.0, green: 64.0/255.0, blue: 64.0/255.0, alpha: 1.0)
            ]
        )
        let attributedText = NSMutableAttributedString()
        attributedText.appendAttributedString(monthString)
        attributedText.appendAttributedString(dayString)
        attributedText.appendAttributedString(yearString)
        self.dateButton.setAttributedTitle(attributedText, forState: .Normal)
    }


    /// MARK: - private api

    /**
     * set up
     **/
    private func setUp() {
        // slider
        self.timeSliderTitleView.layer.cornerRadius = 18.0
        self.timeSliderTitleView.layer.masksToBounds = true
        self.timeSliderTitleView.clipsToBounds = true
        self.timeSliderView.layer.shadowOffset = CGSizeMake(0, 0)
        self.timeSliderView.layer.shadowOpacity = 0.3
        self.timeSliderView.layer.shadowRadius = 2.0
        self.timeSliderView.layer.shadowPath = UIBezierPath(
            roundedRect: CGRectMake(self.timeSliderView.bounds.origin.x, self.timeSliderView.bounds.origin.y, UIScreen.mainScreen().bounds.width, self.timeSliderView.bounds.height),
            cornerRadius: 18.0
        ).CGPath

        // date view
        self.dateView.layer.shadowOffset = CGSizeMake(0, 0)
        self.dateView.layer.shadowOpacity = 0.1

        //
        self.datePickerButton.isRaised = false
    }

    /**
     * appear date picker
     **/
    private func appearDatePicker() {
        self.datePickerView.hidden = false
        self.datePicker.datePickerMode = .Date
        self.datePicker.minimumDate = NSDate().air_daysAgo(days: 365)
        self.datePicker.maximumDate = NSDate()

        UIView.animateWithDuration(
            0.35,
            delay: 0.0,
            options: .CurveEaseOut,
            animations: { [unowned self] in
                self.datePickerView.frame = CGRectMake(0, 0, self.datePickerView.frame.width, self.datePickerView.frame.height)
            },
            completion: { finished in
            }
        )
    }

    /**
     * disappear date picker
     **/
    private func disappearDatePicker() {
        let top = -(self.datePicker.frame.height+self.datePickButton.frame.height)
        UIView.animateWithDuration(
            0.25,
            delay: 0.0,
            options: .CurveEaseOut,
            animations: { [unowned self] in
                self.datePickerView.frame = CGRectMake(
                    0, top, self.datePickerView.frame.width, self.datePickerView.frame.height
                )
            },
            completion: { [unowned self] (finished) -> Void in
                self.datePickerView.hidden = true
            }
        )
    }

}
