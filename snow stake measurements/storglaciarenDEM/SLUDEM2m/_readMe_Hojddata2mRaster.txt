Your extracted raster file(s) from the GSD-Höjddata, grid 2+ has been successfully processed.

Contents of the delivery:

The Hojddata2m_xxxx_xxxx folder:
The folder is named according to the following structure Database_yymm_CoordinateSystem where
yymm: is the year and month when the data was delivered to SLU (not necessarily the year produced!)
CoordinateSystem:
3006    SWEREF99TM
3021    RT90 2.5 gon V

The folder contains the following:
- One or more LZW compressed GeoTiff files with a corresponding .tfw worldfile. If the area you ordered would result in a file bigger than 4 Gb, the image will be split into multiple files.
The files are named according to the following structure Layername_nnnnnnn_eeeeee where nnnnnnn and eeeeee are the north and east coordinates of the lower left corner of the image.

The Docs folder:
- Metadata documents.

For more information about the data, see the Lantmäteriet web site:
http://www.lantmateriet.se/Kartor-och-geografisk-information/Hojddata/GSD-Hojddata-grid-2/

NOTE! If you are using ArcGIS 9.x, the program will not be able to read the coordinate system information in the file.

To define the coordinate system do the following:
- Start ArcCatalog
- Right click on the downloaded raster
- Select properties
- Scroll down to "Spatial Reference", it shoud say <Undefined>
- Click the Edit.. button
- Click the Select.. button
- Browse to Projected Coordinate Systems > National Grids > Sweden
- Select the coordinate system corresponding to the epsg code in the file name
- Click Add > OK > OK

For more information about FUK:
http://www.geodata.se/sv/Ga-med/Forskning-utbildning-och-kulturverksamhet/

If you want to contact us, send an email to:
get.support@slu.se

Follow us on Twitter to get the latest information about the GET service:
https://twitter.com/support_get

Enjoy your data!

/The GET team.