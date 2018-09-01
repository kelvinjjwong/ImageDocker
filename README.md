# ImageDocker

A desktop application running on macOS to help organize pictures and videos between cameras/mobile devices and Plex Media Server.

## Major objectives:

- Import images from local directories
- Change photo-taken-date and geolocation of images
- Export images to another directory in well-organized directory structure to feed Plex Media Server

## Features:

- A tree view to organize images by directories, dates and places
- A collection view to preview thumbnail of images happened during a day
- A table view to list EXIF infos, such as dates, geolocation and camera models
- Preview picture/video in a bigger size
- A map view for geolocation of an image
- Update multiple images by assigning photo-taken-date and geolocation in a batch

## Dependencies:

- GRDB: to manage data in a SQLite database [The MIT License](https://github.com/groue/GRDB.swift/blob/master/LICENSE)
- ExifTool: to load EXIF info from images [Perl License](https://www.sno.phy.queensu.ca/~phil/exiftool/#license)
- Baidu Map API: to recognize geolocation inside China
- Google Map API: to recognize geolocation outside China [License](https://developers.google.com/terms/site-policies)
- Android Debug Bridge: to detect and access Android devices [License](https://developer.android.com/license)
- libimobiledevice: to detect and pair iOS devices [LGPL License](https://github.com/libimobiledevice/libimobiledevice/blob/master/COPYING)
- ifuse: to access iOS devices [LGPL License](https://github.com/libimobiledevice/ifuse/blob/master/COPYING)
- PXSourceList: tree view [The New BSD License](https://github.com/Perspx/PXSourceList/blob/master/LICENSE)
- SwiftyJSON [The MIT License](https://github.com/SwiftyJSON/SwiftyJSON/blob/master/LICENSE)
- CryptoSwift [Copyright License](https://github.com/krzyzanowskim/CryptoSwift/blob/master/LICENSE)

## License

[The MIT License](LICENSE)
