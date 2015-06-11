#!/bin/sh

# for i in out/*.eps ; do 
#     echo $i
#     # epstopdf $i --outfile=tmp.pdf
#     epstopdf --nocompress --nogs  $i | gs -q -sDEVICE=pdfwrite -dColorImageFilter=/FlateEncode -dUseFlateCompression=false -dAutoRotatePages=/None -dAutoFilterColorImages=false -sOutputFile="tmp.pdf" - -c quit

# #   convert -density 288 -resample 108 tmp.pdf out/`echo $i | sed 's/\.eps/.png/'`
# #    convert -density 288 -resample 108 tmp.pdf out/`echo $i | sed 's/\.eps/.png/'`
#     convert -density 576 -resize 640x480 tmp.pdf `echo $i | sed 's/\.eps/.sgi/'`
# done

for i in out/*.png ; do 
    echo $i
    convert -quality 100 -resize 800x600 $i `echo $i | sed 's/\.png/.jpg/'`
done

# fairly frequent frame drops
ffmpeg -y -intra -r 30 -qscale .01 -i out/out%05d.jpg -vcodec mpeg4 output.mp4
# Fewer frame drops, pretty good quality
#ffmpeg -y -intra -r 30 -qscale .01 -i out/out%05d.jpg -vcodec xvid output.avi
# Sucks
#ffmpeg -y -intra -r 30 -qscale .01 -i out/out%05d.sgi -vcodec h264 output.avi
# jpegls - does not work with mac
#ffmpeg -y -intra -r 30 -qscale .01 -i out/out%05d.sgi -vcodec jpegls output.avi
# ljpeg - lossless mjpeg (is broken in this build)
#ffmpeg -y -intra -r 30 -qscale .01 -i out/out%05d.sgi -vcodec ljpeg output.avi
# motion jpeg, seems best overall for this type of stuff
#ffmpeg -y -intra -r 30 -qscale .01 -i out/out%05d.jpg -vcodec mjpeg output.avi
