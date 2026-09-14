# JAISTサマースクール2026招待チュートリアル「言葉をはかる：テキストマイニング入門」講義資料

JAISTサマースクール2026「言葉をはかる：テキストマイニング入門」の資料です。

講義で使用したスライド、分析用データよびソースコードを公開します。


## ファイルについて

+ テキストマイニング講義関連
    + Rコード
        + r_preprocessing.* ...データ前処理: RMeCabの基礎
        + r_analysis01.* ...分析①『夢十夜』の分析
        + r_analysis02.* ...分析②『こころ』の分析
        + functions.r ...分析で使う関数
    + Pythonコード
        + py_preprocessing.* ...データ前処理: MeCabの基礎
        + py_analysis01.* ...分析①『夢十夜』の分析
        + py_analysis02.* ...分析②『こころ』の分析
        + functions.py ...分析で使う関数
        + my_class.py ...分析で使う関数
    + data/textmining/* ...分析で使うデータ
    + dict/* ...分析用の辞書の例
    + report_example/* ...レポートの例


以下は参考資料

+ 参考: Rブートキャンプ (PCの基本操作とRの復習)
    + exercises/ ... Rブートキャンプ関連ファイルを入れたフォルダ
        + exercises.pdf ...Rブートキャンプ用のエクササイズ（演習問題）
        + exercises.ipynb ...Jupyterで実行する用
        + exercises_answer.pdf ...演習問題の答え
        + exercises_answer.ipynb ...演習問題の答えのJupyterによる出力
        + exercise/* ...エクササイズで使うデータセット
    + slides/20220613_R_bootcamp.pdf ...Rブートキャンプスライド

+ 参考: キャッチアップ＋R実習 (Rを使った簡単な分析)
    + catchup/
        + data ...キャッチアップアップで使うデータ
        + 1-1_titanic.ipynb ... Titanic datasetの分析
        + 1-2_covid19.ipynb ... 新型コロナ関連データの分析
    + slides/20220625_R_catchup.pdf ...キャッチアップ授業スライド

### 分析用コード

rファイル(.r)とipynbファイル(.ipynb)があります。

+ .rファイルはRのソースコードで、より詳しいコードの解説と、ネットワークグラフ用のソースコードが入っています。一行ずつ実行していくことで、分析を再現できます
+ ipynbはJupyterLab(JupyterNotebook)で作成されたファイルで、GitHub上でソースコードとその実行結果をみることができます(R用とPython用を用意しています)
    + うまく見られない場合はJupyter nbviewer( https://nbviewer.jupyter.org/ )を使うとよい
    + GoogleColabratoryで読み込んで実行できる
        + 作業環境が一定時間経過すると消去されるので各パッケージは都度インストール
        + Googl Colab上でのMeCab/RMeCabのインストールは下記を実行

```
system('sudo apt-get install -y mecab', intern=TRUE)
system('sudo apt-get install -y libmecab-dev', intern=TRUE)
system('sudo apt-get install -y mecab-ipadic-utf8', intern=TRUE)
install.packages("RMeCab", repos = "https://rmecab.jp/R")
```

+ GoogleColabratory上での実行例は、[この講義の共有フォルダ内に](https://drive.google.com/drive/folders/1vwC27o3kK1dYroZY-orH7Z1yOmRitrTV?usp=sharing)置いています。


### ソースコードのローカル実行について

1. GitHubからzipファイルをダウンロードする
1. zipファイルをを解凍する
1. Rを起動する
    + (RStudioで分析する場合)
        + RStudioでフォルダ内のrファイルを開く
    + (Rで分析する場合)
        + Rを起動する
1. 解凍したフォルダを作業フォルダに設定する
    + setwd(解凍先のフォルダのパス)を実行する。フォルダのパスは以下のいずれかの方法で取得することができる
        + アドレスバーを右クリックして「アドレスのコピー」を選択
        + フォルダを右クリック→プロパティ。表示される「場所」の内容をコピー
        + 好きなフォルダの配下にフォルダを移動する
    + setwd()実行後、getwd()を実行して、うまくフォルダが設定されていることを確認する
1. ひとつずつコードを実行して確認する

### 分析データについて

各フォルダ内のREADME.mdを参照のこと。

## Further Reading

+ テキスト分析

    + 石田基広. (2017). Rによるテキストマイニング入門 第2版. 森北出版.
        + 実習パートの基礎的な部分および環境構築については本書を参考にした。RMeCab内の関数についても詳しく紹介されているほか、講義で紹介したバイグラムによる分析以外にも対応分析(Corresponding Analysis)やワードクラウド、APIを用いたTwitterへのアクセスなどの事例が紹介されている。
    + Silge, J., & Robinson, D. (2017). Text mining with R: A tidy approach.  O’Reilly Media, Inc.(Julia Silge, David Robinson(著) 大橋真也(監訳) 長尾高弘(訳) (2018) Rによるテキストマイニング : tidytextを活用したデータ分析と可視化の基礎. オライリー・ジャパン)
        + Rを用いた英文テキストマイニングについての本。整然データ tidy dataとしてテキストを扱えるtidytextパッケージを用いた様々な分析法(e.g. トピックモデル)を紹介しているほか、データハンドリングについても内容を多く割いている。
    + 金明哲. (2018). テキストアナリティクス. 共立出版.
        + 『ことばのデータサイエンス』よりもより発展的な分析に重きを置いている。
    + 小林雄一郎. (2019). ことばのデータサイエンス. 朝倉書店.
        + テキストを対象とした分析手法や統計量について紹介している。分析するときに手元に置いておくとよい。
    + 金明哲. (2021). テキストアナリティクスの基礎と実践. 岩波書店.
        + 『テキストデータの統計科学』（金, 2009）をベースに改訂したもの。トピックモデルや分散表現など『テキストアナリティクス』よりも発展的な内容も盛り込んである。
    + 石田基広, & 金明哲 (Eds.). (2012). コーパスとテキストマイニング. 共立出版.
        + コーパス（言語資源）やテキストマイニングを用いた様々な社会科学の研究事例を紹介している。
    + 小林雄一郎. (2023). Rによる やさしいテキストアナリティクス. オーム社
        + 比較的最近出たRとRMeCabによるテキスト分析の本。環境整備と前処理、RMeCabについての詳しい説明がある。
    + 持橋大地. (2025).  統計的テキストモデル. 岩波書店.
        + テキストの持つ統計的・数理的性質の観点からテキストを扱う本。数理に興味が出てきたら手を出してみるのもあり。

+ 自然言語処理

    + 奥野陽, グラム・ニュービッグ, & 萩原正人. (2016). 自然言語処理の基本と技術. 翔泳社.
        + 自然言語処理とはなにか、実社会でどのように使われているかを概説した本。技術的な詳細は少ないので全体を概観するのによい。
    + Bird, S., Klein, E., & Loper, E. (2009). Natural Language Processing with Python. Sebastopol, CA: O’Reilly Media.(Bird, S., Klein, E., & Loper, E.(著) 萩原正人・中山敬広・水野貴明(訳)(2010) 入門自然言語処理 オライリー・ジャパン)
        + 自然言語処理の基本についてPythonコードを用いて解説している。英語のテキストが対象のため、そのまま日本語の処理に転用することはできないが、基本的な概念を学ぶのによい。Pythonコードが古いが、WEB版(https://www.nltk.org/book/ )はPython3版に更新されている。
    + 奥村学. (2010). 自然言語処理の基礎. コロナ社.
        + 自然言語処理に関する基本的な概念を説明している教科書的な本。
    + 高村大也. (2010). 言語処理のための機械学習入門. コロナ社.
        + 自然言語を機械で処理するための理論的準備をするための本。数式が多いので苦手な人にはとっつきづらいかもしれない。最適化や情報量といった基礎的な内容への解説もあり、数理的な側面を学ぶのによい。

+ 研究におけるバイアス
    + Salganik, M. J. (2017). Bit by bit: social research in the digital age. Princeton University Press.(サルガニック, マシュー・J.(著) 瀧川裕貴・常松淳・阪本拓人・大林真也(訳) (2019) ビット・バイ・ビット -- デジタル社会調査入門. 有斐閣)
        + いかにビッグデータを手に入れ、扱い、分析するかといった入門だけでなく、近年のビッグデータを扱った社会科学分野のレビューにもなっている本。特にビッグデータを扱う際の落とし穴について丁寧に書かれているところが素晴らしい。講義中に詳しく紹介する時間がなかったが、「研究倫理」についても多くのページが割かれている。必読の書。

    + Rothman, K. J. (2012). Epidemiology: an introduction. Oxford university press. (Rothman, Kenneth J.(著) 矢野栄二・橋本英樹・大脇和浩(監訳) (2013) ロスマンの疫学 第2版. 篠原出版新社.)
        + 疫学 epidemiologyの初歩的な入門書。医学研究における研究デザイン・分析法について解説している。心理学ではあまり聞きなれないタイプの情報バイアス、誤分類 misclassificationなどについても解説がある。本当はこの本よりはSteiner & Norman『論文が読める!早わかり疫学―研究デザインとその評価』の方がとっつきやすいが、残念ながら絶版。

+ プログラミング関連
    + Boswell, D., & Foucher, T. (2011). The Art of Readable Code: Simple and Practical Techniques for Writing Better Code. O’Reilly Media, Inc.(Dustin Boswell, Trevor Foucher(著) 角 征典(訳) (2012) リーダブルコード――より良いコードを書くためのシンプルで実践的なテクニック. オライリー・ジャパン)
        + コードはいかにあるべきか、よりわかりやすいコードの書き方とはなにかを解説する良著。

## Notes

+ 2026.09.14 資料アップロード

