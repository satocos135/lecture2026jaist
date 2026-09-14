###### preprocessing.r
### インストールされている必要のあるパッケージ
###     - dplyr
###     - stringr
###     - RMeCab
### 事前準備
### - setwd()でこのファイルが入ったフォルダの絶対パスを指定する


### RMecabの基礎

# + MeCab: 形態素解析エンジン
# + RMeCab: MeCabをR上で使うためのパッケージ


library('dplyr')
library('RMeCab')

(test = RMeCabC('今日は本を読んだ') %>% unlist())
getwd()
setwd('c:/Users/satoc/Documents/GitHub/lecture2026shimane/')

# %in%との組み合わせ
# names(): ベクトルについているラベルを抜き出す
test[names(test) %in% c('名詞', '動詞')] # 結果から名詞と動詞を抜き出す

# names(test) %in% c('名詞', '動詞')] # names()で抜き出したラベルが名詞または動詞であるか

RMeCabC('今日は本を読んだ', 1) %>% unlist()　# 第二引数に1を入力すると、動詞が原形になる


## クリーニングの実際

# 例文：
## 「切ってきて、丸めて、家の屋根にしげておくん。それはてんかごめんけどどこのやまいってきってきてもよいということになっちょった。」

text = '切ってきて、丸めて、家の屋根にしげておくん。それはてんかごめんけどどこのやまいってきってきてもよいということになっちょった。'
RMeCabC(text) %>% unlist()


# 表現を変える
text = '切ってきて、丸めて、家の屋根にすげておくん。それは天下御免でどこの山に行って切ってきてもよいということになっていた。'
RMeCabC(text) %>% unlist()


# 辞書の使い方
RMeCabC('まあそういうことで、余分な話はいいけん。') %>% unlist() # 辞書なし（デフォルト）

RMeCabC('まあそういうことで、余分な話はいいけん。', dic='dict/example.dic')  %>% unlist() # 辞書使用


# 活用のある語は活用ごとに登録しないといけないことに注意


