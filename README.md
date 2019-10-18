# 「作って理解するOS x86系コンピュータを動かす理論と実装」の写経

## 書籍との違い

* Mac環境なのでnasmはhome brewで導入した
    * brew install nasm
    * version: 2.14.02
* ビルドはMakefileを介して行っている
* 14.6のitoaのflag引数の処理の仕方がわからなかったため、意味づけを変更
* 14.12のコードが気に入らなかったので改変
* 14.13は省略
* 14.14でなんかんやでうまくいかず、無限再起動起こしたので、それらしく動くよう改変
* 14.15はLEDの確認ができないため省略
* 16章のコードに従って書くと、qemuでは描画内容がちっこすぎて視認できないため位置をずらした
* 16.5のdraw_fontの引数を、draw_charと同じcol, rowの順にした