import Foundation
import RealmSwift

final class RealmFeed: Object {
	@objc dynamic var timestamp: Date = .init()
	var realmFeedImages: List<RealmFeedImage> = .init()

	convenience init(timestamp: Date, realmFeedImages: [RealmFeedImage]) {
		self.init()
		self.timestamp = timestamp
		self.realmFeedImages.append(objectsIn: realmFeedImages)
	}
}
