#!/bin/bash
./processresults.py testresults/*+rptest+gcc-4.*txt.compressresults > /usr/share/nginx/www/bz2_compression_shakespere.html
./processresults.py testresults/*+rptest+gcc-4.*bmp.compressresults > /usr/share/nginx/www/bz2_compression_bitmap.html
./processresults.py testresults/*+rptest+gcc-4.*jpg.compressresults > /usr/share/nginx/www/bz2_compression_jpeg.html
./processresults.py testresults/*+rptest+gcc-4.*tar.compressresults > /usr/share/nginx/www/bz2_compression_software.html

./processresults.py testresults/*+rptest+gcc-4.*txt.decompressresults > /usr/share/nginx/www/bz2_decompression_shakespere.html
./processresults.py testresults/*+rptest+gcc-4.*bmp.decompressresults > /usr/share/nginx/www/bz2_decompression_bitmap.html
./processresults.py testresults/*+rptest+gcc-4.*jpg.decompressresults > /usr/share/nginx/www/bz2_decompression_jpeg.html
./processresults.py testresults/*+rptest+gcc-4.*tar.decompressresults > /usr/share/nginx/www/bz2_decompression_software.html
