/// MARK: - AIRSummaryViewController
class AIRSummaryViewController: UIViewController {

    /// MARK: - property

    let headerNib = UINib(nibName: AIRNSStringFromClass(AIRSummaryCollectionCell), bundle: NSBundle.mainBundle())
    @IBOutlet weak var collectionView: UICollectionView!
    var section = [
            [
                "Song 1",
                "Song 2",
                "Song 3",
                "Song 4",
                "Song 5",
                "Song 6",
                "Song 7",
                "Song 8",
                "Song 9",
                "Song 10",
                "Song 11",
                "Song 12",
                "Song 13",
                "Song 14",
                "Song 15",
                "Song 16",
                "Song 17",
                "Song 18",
                "Song 19",
                "Song 20",
            ]
        ]

    /// MARK: - destruction

    deinit {
    }


    /// MARK: - life cycle

    override func loadView() {
        super.loadView()

        if let layout: IOStickyHeaderFlowLayout = self.collectionView.collectionViewLayout as? IOStickyHeaderFlowLayout {
            layout.parallaxHeaderReferenceSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, 274)
            layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, 180)
            layout.itemSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, layout.itemSize.height)
            layout.parallaxHeaderAlwaysOnTop = true
            layout.disableStickyHeaders = true
            self.collectionView.collectionViewLayout = layout
        }

        self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        self.collectionView.registerNib(self.headerNib, forSupplementaryViewOfKind: IOStickyHeaderParallaxHeader, withReuseIdentifier: "header")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    /// MARK: - event listener

    /**
     * called when button is touched up inside
     * @param button UIButton
     **/
    @IBAction func touchUpInside(button button: UIButton) {
    }


    /// MARK: - notification


    /// MARK: - private api
}


/// MARK: - UICollectionViewDataSource
extension AIRSummaryViewController: UICollectionViewDataSource {
}


/// MARK: - UICollectionViewDelegate
extension AIRSummaryViewController: UICollectionViewDelegate {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.section.count
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.section[section].count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(UIScreen.mainScreen().bounds.size.width, 50);
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case IOStickyHeaderParallaxHeader:
            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath)
            return cell
        default:
            assert(false, "Unexpected element kind")
        }
    }
}


/// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension AIRSummaryViewController: UICollectionViewDelegateFlowLayout {
}
