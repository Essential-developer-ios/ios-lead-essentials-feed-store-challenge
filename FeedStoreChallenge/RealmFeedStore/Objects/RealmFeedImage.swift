import Foundation
import RealmSwift

final class RealmFeedImage: Object {
	@objc dynamic private var _id: String = ""
	@objc dynamic private var _url: String = ""
	@objc dynamic var imageDescription: String?
	@objc dynamic var location: String?

	convenience init(id: UUID, imageDescription: String?, location: String?, url: URL) {
		self.init()
		self._id = id.uuidString
		self._url = url.absoluteString
		self.imageDescription = imageDescription
		self.location = location
	}

	var id: UUID? {
		UUID(uuidString: _id)
	}

	var url: URL? {
		URL(string: _url)
	}
}
