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
* 16.9のデバッグライト目的として、先に17.2のitoaを実装した
* 16.10のdraw_rectの引数を、(左上x, 左上y, 幅、高さ, 表示色)に変更
    * 引数変更により、座標の反転は行わない
* 18.8のdraw_keyの引数の順序を(col, row, buff)に変更
    * 左から読み取り順に表示するようにした
    * バッファ内のゴミは表示しないようにした
* 18.9の回転バーの出力位置を引数で渡すようにした
* 20.2のset_gateをset_call_gate_descに変更
* 21章のFPUは実装順序を変更した
    * タスク2を用意 -> デバイス利用不可例外の発生を確認 -> FPUの初期化 -> FPU計算