/// MARK: - AIRTutorialManagerDelegate
@objc protocol AIRTutorialManagerDelegate {

    /**
     * called when tutorial has done
     * @param tutorialManager AIRTutorialManager
     */
    func tutorialDidFinish(tutorialManager tutorialManager: AIRTutorialManager)

}


/// MARK: - AIRTutorialManager
class AIRTutorialManager: NSObject {

    static let sharedInstance = AIRTutorialManager()


    /// MARK: - property

    weak var delegate: AnyObject?

    var introductionView: MYBlurIntroductionView!
    let backgroundColors = [
        UIColor(red: 155.0/255.0, green: 89.0/255.0, blue: 182.0/255.0, alpha: 0.65),
        UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 0.65),
        UIColor(red: 26.0/255.0, green: 188.0/255.0, blue: 156.0/255.0, alpha: 0.65),
    ]


    /// MARK: - initialization
    override init() {
        super.init()
    }

    /// MARK: - destruction

    deinit {
    }


    /// MARK: - public api

    /**
     * if it will be tutorial or not
     * @return Bool
     **/
    func willBeTutorial() -> Bool {
        let doneTutorial = NSUserDefaults().boolForKey(AIRUserDefaults.Tutorial)
        return (!doneTutorial)
    }

    /**
     * start tutorial
     * @param parentView parent view to display tutorial
     **/
    func start(parentView parentView: UIView) {
        self.introductionView = MYBlurIntroductionView(frame: CGRectMake(0, 0, parentView.frame.size.width, parentView.frame.size.height))
        self.introductionView.delegate = self
        self.introductionView.BackgroundImageView.image = UIImage(named: "tutorial_background_0")
        self.introductionView.backgroundColor = self.backgroundColors[0]

        let titles = [
            "HEALTH EFFECTS",
            "LOOK BACK",
            "LET'S GET STARTED",
        ]
        let descriptions = [
            "\nOutdoor air pollution is a major environmental health problem affecting everyone in developed and developing countries alike.\n\nWHO estimates that some 80% of outdoor air pollution-related premature deaths were due to ischaemic heart disease and strokes, while 14% of deaths were due to chronic obstructive pulmonary disease or acute lower respiratory infections; and 6% of deaths were due to lung cancer.",
            "\nYou can look back air you breath from the route you passed today.\nThere are three colors representing air polluted level.\n\n- green:  ideal for outdoor activities\n- yellow: if possible, postpone your activities\n- red:      dangerous for your activities",
            "",
        ]
        let imageNames = [
            "",
            "tutorial_image_1",
            "",
        ]

        var panels: [MYIntroductionPanel] = []
        for var i = 0; i < titles.count; i++ {
            let panel = MYIntroductionPanel(
                frame: self.introductionView.frame,
                title: titles[i],
                description: descriptions[i],
                image: UIImage(named: imageNames[i])
            )
            panel.PanelDescriptionLabel.attributedText = panel.PanelDescriptionLabel.text!.air_justifiedString(font: panel.PanelDescriptionLabel.font)
            panel.PanelDescriptionLabel.textAlignment = NSTextAlignment.Justified
            panels.append(panel)
        }

        self.introductionView.buildIntroductionWithPanels(panels)
        parentView.addSubview(self.introductionView)
    }


    /// MARK: - private api

    /**
     * done tutorial
     **/
    func done() {
        NSUserDefaults().setObject(true, forKey: AIRUserDefaults.Tutorial)
        NSUserDefaults().synchronize()
        UIView.animateWithDuration(0.5, animations: { [unowned self] () -> Void in
            self.introductionView.alpha = 0.0
        })
    }

}


/// MARK: - MYIntroductionDelegate
extension AIRTutorialManager: MYIntroductionDelegate {

    func introduction(
        introductionView: MYBlurIntroductionView,
        didChangeToPanel panel: MYIntroductionPanel,
        withIndex panelIndex: NSInteger
    ) {
        self.introductionView.BackgroundImageView.image = UIImage(named: "tutorial_background_\(panelIndex)")
        self.introductionView.backgroundColor = self.backgroundColors[panelIndex]
    }

    func introduction(introductionView: MYBlurIntroductionView, didFinishWithType finishType: MYFinishType) {
        self.done()
        if self.delegate != nil {
            (self.delegate as! AIRTutorialManagerDelegate).tutorialDidFinish(tutorialManager: self)
        }
    }

}
