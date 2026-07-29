import Flutter
import google_mobile_ads

class ListTileNativeAdFactory: FLTNativeAdFactory {
    func createNativeAd(_ nativeAd: GADNativeAd, customOptions: [AnyHashable : Any]?) -> FLTNativeAdView? {
        // Загружаем макет из ListTileNativeAd.xib
        guard let nibView = Bundle.main.loadNibNamed("ListTileNativeAd", owner: nil, options: nil)?.first as? GADNativeAdView else {
            return nil
        }

        // 1. Заголовок (Headline)
        (nibView.headlineView as? UILabel)?.text = nativeAd.headline

        // 2. Описание (Body)
        if let body = nativeAd.body {
            (nibView.bodyView as? UILabel)?.text = body
            nibView.bodyView?.isHidden = false
        } else {
            nibView.bodyView?.isHidden = true
        }

        // 3. Иконка (Icon)
        if let icon = nativeAd.icon {
            (nibView.iconView as? UIImageView)?.image = icon.image
            nibView.iconView?.isHidden = false
        } else {
            nibView.iconView?.isHidden = true
        }

        // 4. Кнопка призыва к действию (Call to Action) — если нужна
        if let callToAction = nativeAd.callToAction, let ctaView = nibView.callToActionView as? UIButton {
            ctaView.setTitle(callToAction, for: .normal)
            nibView.callToActionView?.isHidden = false
        } else {
            nibView.callToActionView?.isHidden = true
        }

        // Передаем объект нативной рекламы в View
        nibView.nativeAd = nativeAd

        return FLTNativeAdView(adView: nibView)
    }
}