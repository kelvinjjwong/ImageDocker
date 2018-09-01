# ImageDocker

A desktop application help organize pictures and videos between cameras/mobile devices and Plex Media Server.

![Platform](https://img.shields.io/badge/platforms-macOS%2010.13+-333333.svg)

## Major objectives

- Import images from local directories
- Change photo-taken-date and geolocation of images
- Export images to another directory in well-organized directory structure to feed Plex Media Server

## Features

- A tree view to organize images by directories, dates and places
- A collection view to preview thumbnail of images happened during a day
- A table view to list EXIF infos, such as dates, geolocation and camera models
- Preview picture/video in a bigger size
- A map view for geolocation of an image
- Update multiple images by assigning photo-taken-date and geolocation in a batch

## Screenshot

v0.9.3
![Screenshot of v0.9.3](Screenshots/Screenshot_v0.9.3.png)

## Dependencies

- [GRDB](https://github.com/groue/GRDB.swift): to manage data in a SQLite database ([The MIT License](https://github.com/groue/GRDB.swift/blob/master/LICENSE))
- [ExifTool](https://www.sno.phy.queensu.ca/~phil/exiftool/): to load EXIF info from images ([Perl License](https://www.sno.phy.queensu.ca/~phil/exiftool/#license))
- Baidu Map API: to recognize geolocation inside China, and to display maps
- [Google Map API](https://developers.google.com/maps/documentation/): to recognize geolocation outside China ([License](https://developers.google.com/terms/site-policies))
- [Android Debug Bridge](https://developer.android.com/studio/command-line/adb): to detect and access Android devices ([License](https://developer.android.com/license))
- [libimobiledevice](https://github.com/libimobiledevice/libimobiledevice): to detect and pair iOS devices ([LGPL License](https://github.com/libimobiledevice/libimobiledevice/blob/master/COPYING))
- [ifuse](https://github.com/libimobiledevice/ifuse): to access iOS devices ([LGPL License](https://github.com/libimobiledevice/ifuse/blob/master/COPYING))
- [PXSourceList](https://github.com/Perspx/PXSourceList): tree view ([The New BSD License](https://github.com/Perspx/PXSourceList/blob/master/LICENSE))
- [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) ([The MIT License](https://github.com/SwiftyJSON/SwiftyJSON/blob/master/LICENSE))
- [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift) ([License](https://github.com/krzyzanowskim/CryptoSwift/blob/master/LICENSE))

## Prerequisite

- Personal AP key of Baidu Map API is required for displaying maps and recognizing geolocations inside China
- Personal AP key of Google Map API is required for recognizing geolocations outside China

## Declaration

- Any pre-release versions of this software is applied to author only.
- Please backup source images in advance, before using any versions of this software.

## License

[The MIT License](LICENSE)
