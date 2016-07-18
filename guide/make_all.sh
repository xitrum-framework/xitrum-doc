#!/bin/sh

./make_latexpdf.sh
./make_html.sh

rm -rf all
mkdir -p all/html
mkdir -p all/singlehtml

mv en/_build/html all/html/en
mv ja/_build/html all/html/ja
mv ko/_build/html all/html/ko
mv ru/_build/html all/html/ru
mv vi/_build/html all/html/vi

mv en/_build/singlehtml all/singlehtml/en
mv ja/_build/singlehtml all/singlehtml/ja
mv ko/_build/singlehtml all/singlehtml/ko
mv ru/_build/singlehtml all/singlehtml/ru
mv vi/_build/singlehtml all/singlehtml/vi

mv en/_build/latex/xitrum.pdf all/xitrum-en.pdf
mv ja/_build/latex/xitrum.pdf all/xitrum-ja.pdf
mv ko/_build/latex/xitrum.pdf all/xitrum-ko.pdf
mv ru/_build/latex/xitrum.pdf all/xitrum-ru.pdf
mv vi/_build/latex/xitrum.pdf all/xitrum-vi.pdf

sed '/<\/a><\/h1>/ r download_pdf/en.html' all/html/en/index.html > t.html && mv t.html all/html/en/index.html
sed '/<\/a><\/h1>/ r download_pdf/ja.html' all/html/ja/index.html > t.html && mv t.html all/html/ja/index.html
sed '/<\/a><\/h1>/ r download_pdf/ko.html' all/html/ko/index.html > t.html && mv t.html all/html/ko/index.html
sed '/<\/a><\/h1>/ r download_pdf/ru.html' all/html/ru/index.html > t.html && mv t.html all/html/ru/index.html
sed '/<\/a><\/h1>/ r download_pdf/vi.html' all/html/vi/index.html > t.html && mv t.html all/html/vi/index.html

sed '/<\/a><\/h1>/ r download_pdf/en.html' all/singlehtml/en/index.html > t.html && mv t.html all/singlehtml/en/index.html
sed '/<\/a><\/h1>/ r download_pdf/ja.html' all/singlehtml/ja/index.html > t.html && mv t.html all/singlehtml/ja/index.html
sed '/<\/a><\/h1>/ r download_pdf/ko.html' all/singlehtml/ko/index.html > t.html && mv t.html all/singlehtml/ko/index.html
sed '/<\/a><\/h1>/ r download_pdf/ru.html' all/singlehtml/ru/index.html > t.html && mv t.html all/singlehtml/ru/index.html
sed '/<\/a><\/h1>/ r download_pdf/vi.html' all/singlehtml/vi/index.html > t.html && mv t.html all/singlehtml/vi/index.html
