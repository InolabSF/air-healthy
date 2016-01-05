import UIKit


/// MARK: - AIRSummaryCollectionCell
class AIRSummaryCollectionCell: UICollectionViewCell {

    /// MARK: - property

    var initialSummaryImageViewWidth: CGFloat = 0.0

    @IBOutlet weak var summaryImageView: UIImageView!
    @IBOutlet weak var summaryImageViewConstraint: NSLayoutConstraint!


    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialSummaryImageViewWidth = self.summaryImageView.frame.size.width
    }

    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        guard let layoutAttributes: IOStickyHeaderFlowLayoutAttributes = layoutAttributes as? IOStickyHeaderFlowLayoutAttributes else { return }

        if layoutAttributes.progressiveness < 1 {
            self.summaryImageViewConstraint.constant = self.initialSummaryImageViewWidth
            self.summaryImageView.updateConstraintsIfNeeded()
        }
        else {
            self.summaryImageViewConstraint.constant = self.initialSummaryImageViewWidth * layoutAttributes.progressiveness
            self.summaryImageView.updateConstraintsIfNeeded()
        }
    }

}
