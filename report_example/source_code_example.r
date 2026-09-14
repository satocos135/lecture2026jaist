### 夏目漱石『こころ』の分析

library('tidyverse')
library('igraph')
library('RMeCab')


# データの読み込み
kokoro = read.delim('kokoro.tsv', header=T, sep='\t', stringsAsFactor=F, fileEncoding='utf8')
kokoro[1:2,] 

### 段落の長さの分布
kokoro[, 'content'] %>% str_length() %>% hist(breaks=40, xlab='Paragraph length', main='Histogram of paragraph length')
kokoro['length'] = kokoro[, 'content'] %>% str_length()
boxplot(length ~ part_id, data=kokoro, main='Paragraph length of each part')

# 全体を通すセクション用idを作る
kokoro['section_id2'] = kokoro['part_id'] * 100 + kokoro['section_id']

# 各節ごとの段落の長さの分布
boxplot(length ~ section_id2, data=kokoro, main='Paragraph length of each section')

# 分析のため各部ごとに文章を結合する
parts = kokoro %>% 
    group_by(part_id) %>% 
    summarise(text = paste0(content, collapse=''))
parts = as.data.frame(parts)

dim(parts) # 次元の確認
parts[, 'text'] %>% str_length() # 各部の長さの確認

### 単語の頻度


## 辞書のパスを指定
## 辞書には「Ｋ」が固有名詞として登録されている。
dict = 'kokoro_sjis.dic' # shift-jisの辞書 Windows用

count_noun = docMatrixDF(parts[,'text'], pos=c('名詞'), dic=dict) 


# 全体を集計
freq_noun = count_noun %>% rowSums()

# 通常のプロット
freq_noun %>% sort(decreasing=T) %>% plot(main='Distribution of noun frequency', xlab='Rank', ylab='Frequency')
# 両対数プロット
freq_noun %>% sort(decreasing=T) %>% plot(main='Distribution of noun frequency', xlab='Rank (log)', ylab='Frequency (log)', log='xy')

# 上位30語
freq_noun %>% sort() %>% tail(30) %>% barplot(horiz=T, las=1, main='Top 30 nouns', xlab='Frequency')

# ストップワードの設定
stopwords = c('事','の','よう','それ','もの', '人', '何','一', 'ん','方','二','前','気','中','上','今','ため')
freq_noun[!names(freq_noun) %in% stopwords] %>% sort() %>% tail(30) %>% barplot(horiz=T, las=1, main='Top 30 nouns', xlab='Frequency')

# さらに編集
stopwords = c('事','の','よう','それ','もの', '人', '何','一', 'ん','方','二','前','気','中','上','今','ため', '時', 'そこ', 'どこ', 'これ', 'そう')
freq_noun[!names(freq_noun) %in% stopwords] %>% sort() %>% tail(30) %>% barplot(horiz=T, las=1, main='Top 30 nouns', xlab='Frequency')


### PCA: Principal Component Analysis(主成分分析)

mat = count_noun 
mat = mat[rowSums(mat) > 50, ] # 全体で頻度が50以上ある単語のみを抽出
mat = mat[!row.names(mat) %in% stopwords, ] # ストップワードを除外
colnames(mat) = c('第一部', '第二部', '第三部')

mat_t = t(mat) # 計算の都合上、行と列を入れ替える
mat %>% head()

ratio = mat_t / colSums(mat) # 各部ごとの単語出現割合

# 主成分分析
result = (ratio) %>% prcomp()
biplot(result) # バイプロット。ただし、べき分布なので、頻度の多い単語に引っ張られて他のがよくわからない

## 出現割合の比をとる
ratio_t = t(ratio) # 行と列を入れ替え
result = (ratio_t / colSums(ratio))  %>% prcomp()
biplot(result)


### バイグラムを用いた共起関係の分析
bigram = docDF(parts, col='text', type=1, pos=c('名詞'), N=2, nDF=1, dic=dict) # N=2でバイグラムを指定

## 分布
# 単語の頻度を集計
bigram['freq'] = bigram[,5:7] %>% rowSums() 
bigram[,'freq'] %>% sort(decreasing=T) %>% plot()
bigram[,'freq'] %>% sort(decreasing=T) %>% plot(log='xy')

# データの構造
bigram[1:3,]


## ネットワークグラフの描画
# tkplot(): ネットワークグラフを表示する。各ノードを動かすことが可能
# ※jupyter notebookでは動かないので RStudiio上で実演する
net = bigram %>% 
    select(N1, N2, freq) %>%  
    filter(freq > 10) %>% # 頻度が10以上
    filter(! N1 %in% stopwords) %>% # n1, n2のいずれからもストップワードを除去
    filter(! N2 %in% stopwords)

# データの構造
# 数が多すぎるとネットワークグラフの描画が遅くなるので確認してから描画するのがよい
dim(net)
net[1:3,]

# グラフの描画(別ウィンドウで開く)
net %>% graph_from_data_frame() %>% tkplot(vertex.color='SkyBlue', vertex.size=22)




## 各部の比較

net = bigram %>% 
    select(N1, N2, freq=Row1) %>%  # 第一部を対象に
    filter(freq > 10) %>% # 頻度が10以上
    filter(! N1 %in% stopwords) %>% # n1, n2のいずれからもストップワードを除去
    filter(! N2 %in% stopwords)

# データの構造 
dim(net)
net[1:3,]

# グラフの描画
net %>% graph_from_data_frame() %>% tkplot(vertex.color='SkyBlue', vertex.size=22)



net = bigram %>% 
    select(N1, N2, freq=Row2) %>%  # 第二部
    filter(freq > 5)  %>% 
    filter(! N1 %in% stopwords) %>%  
    filter(! N2 %in% stopwords)

net %>% graph_from_data_frame() %>% tkplot(vertex.color='SkyBlue', vertex.size=22)


net = bigram %>% 
    select(N1, N2, freq=Row3) %>% # 第三部
    filter(freq > 10)  %>% 
    filter(! N1 %in% stopwords) %>%  
    filter(! N2 %in% stopwords)

net %>% graph_from_data_frame() %>% tkplot(vertex.color='SkyBlue', vertex.size=22)




## 登場人物と単語の結びつき

# 品詞の種類を変えてみる
bigram = docDF(parts,col='text', type=1, pos=c('名詞', '動詞', '形容詞', '副詞'), N=2, nDF=1, dic=dict)


# 「お嬢さん」
net = bigram %>% 
    select(N1, N2, freq=Row3) %>% 
    filter(freq > 1)  %>% 
    filter(N1 == 'お嬢さん' | N2 == 'お嬢さん')  %>% 
    filter(! N1 %in% stopwords) %>%  
    filter(! N2 %in% stopwords)

net %>% graph_from_data_frame() %>% tkplot(vertex.color='SkyBlue', vertex.size=22)

stopwords = c('事','の','よう','それ','もの', '人', '何','一', 'ん','方','二','前','気','中','上','今','ため', '時', 'そこ', 'どこ', 'これ', 'そう',
              'いる', 'なる', 'する', 'いう', 'ある')

# 「私」

# 抽出条件を色々試してみる
bigram %>% 
    filter(N1 == '私' | N2 == '私')  %>% 
    filter(! N1 %in% stopwords) %>%  
    filter(! N2 %in% stopwords) %>%
    filter(str_detect(POS2, '非自立')) %>%
    arrange(desc(Row3)) %>% head(50)

bigram %>% 
    filter(N1 == '私' | N2 == '私')  %>% 
    filter(! N1 %in% stopwords) %>%  
    filter(! N2 %in% stopwords) %>%
    filter(!str_detect(POS2, '非自立')) %>%
    arrange(desc(Row3)) %>% head(20)

bigram %>% 
    filter(N1 == '私' | N2 == '私')  %>% 
    filter(! N1 %in% stopwords) %>%  
    filter(! N2 %in% stopwords) %>%
    filter(!str_detect(POS2, '非自立')) %>%
    filter(str_detect(POS2, '動詞')) %>%
    select(everything(), freq=Row3) %>% 
    arrange(desc(freq)) %>% head(30)

bigram %>% 
    filter(N1 == '私' | N2 == '私')  %>% 
    filter(! N1 %in% stopwords) %>%  
    filter(! N2 %in% stopwords) %>%
    filter(!str_detect(POS2, '非自立')) %>%
    filter(str_detect(POS1, '動詞')) %>%
    select(everything(), freq=Row3) %>% 
    arrange(desc(freq)) %>% head(30)


net = bigram %>% 
    filter(N1 == '私' | N2 == '私')  %>% 
    filter(str_detect(POS1, '名詞-名詞')) %>%
    select(N1, N2, freq=Row3) %>% 
    filter(freq > 4)  %>% 
    filter(! N1 %in% stopwords) %>%  
    filter(! N2 %in% stopwords)

net %>% graph_from_data_frame() %>% tkplot(vertex.color='SkyBlue', vertex.size=22)


net = bigram %>% 
    filter(N1 == '私' | N2 == '私') %>% 
    filter(str_detect(POS1, '動詞')) %>%
    select(N1, N2, freq=Row3) %>% 
    filter(freq > 4)  %>% 
    filter(! N1 %in% stopwords) %>%  
    filter(! N2 %in% stopwords)

net %>% graph_from_data_frame() %>% tkplot(vertex.color='SkyBlue', vertex.size=22)


# 登場人物と形容詞の結びつき
net = bigram %>% 
    filter(N1 %in% c('私','Ｋ','お嬢さん') | N2 %in% c('私','Ｋ','お嬢さん')) %>% 
    filter(str_detect(POS1, '形容')) %>%
    select(N1, N2, freq=Row3) %>% 
    filter(freq > 0)  %>% 
    filter(! N1 %in% stopwords) %>%  
    filter(! N2 %in% stopwords)

net %>% graph_from_data_frame() %>% tkplot(vertex.color='SkyBlue', vertex.size=22)




### Bag of wordsを用いた共起関係の分析
## sentenceごとに共起を集計するため、sentenceごとに分けたデータを読み込む

kokoro_sentence = read.delim('data/kokoro_sentence.tsv', header=T, sep='\t', stringsAsFactor=F, fileEncoding='utf8')
kokoro_sentence %>% head()

# 定義済みの関数を読み込む
source('functions.r', encoding='utf8') 

stopwords = c('事','の','よう','それ','もの', '人', '何','一', 'ん','方','二','前','気','中','上','今','ため', '時', 'そこ', 'どこ', 'これ', 'そう',
              'いる', 'なる', 'する', 'いう', 'ある', 'れる', 'られる', 'くれる')

# map(): ベクトルの各要素に関数を適用する
res = map(kokoro_sentence[,'content'], get_cooc, pos=c('名詞'), stopwords=stopwords)  %>% unlist() %>% table() # 共起を集計する

# データ構造と分布
res %>% dim()
res %>% as.vector() %>% sort(decreasing=T) %>% plot()
res %>% as.vector() %>% sort(decreasing=T) %>% plot(log='y') # 片対数
res %>% as.vector() %>% sort(decreasing=T) %>% plot(log='xy')

# 各部ごとに共起を集計する
part1 = map(kokoro_sentence[kokoro_sentence$part_id == 1,'content'], get_cooc, pos=c('名詞'), stopwords=stopwords) %>% unlist() %>% table()
part2 = map(kokoro_sentence[kokoro_sentence$part_id == 2,'content'], get_cooc, pos=c('名詞'), stopwords=stopwords) %>% unlist() %>% table()
part3 = map(kokoro_sentence[kokoro_sentence$part_id == 3,'content'], get_cooc, pos=c('名詞'), stopwords=stopwords) %>% unlist() %>% table()
part3 %>% head()

df1 = as.data.frame(part1)
df2 = as.data.frame(part2)
df3 = as.data.frame(part3)

# １つのdataframeに統合する
res = merge(x=df1, y=df2, by='.', all=T)
res = merge(x=res, y=df3, by='.', all=T)
colnames(res) = c('term', 'df1', 'df2', 'df3')
res[is.na(res)] = 0 # 欠損を埋める

res %>% head()


### 主成分分析

mat = res
row.names(mat) = mat[,1]
mat = mat[2:4]
mat = mat[rowSums(mat) > 50, ]
colnames(mat) = c('第一部','第二部','第三部')

mat_t = t(mat)

ratio = mat_t / colSums(mat)
ratio_t = t(ratio)
result = (ratio_t / colSums(ratio))  %>% prcomp()

biplot(result)


stopwords = c('事','の','よう','それ','もの', '人', '何','一', 'ん','方','二','前','気','中','上','今','ため', '時', 'そこ', 'どこ', 'これ', 'そう',
              'いる', 'なる', 'する', 'いう', 'ある', 'れる', 'られる', 'くれる')


## 名詞と形容詞の結びつき
res = map(kokoro_sentence[kokoro_sentence$part_id==3,'content'], get_cooc, pos=c('名詞', '形容詞'), with_pos=T, stopwords=stopwords, dic='dict/kokoro_sjis.dic')  %>%
    unlist() %>% table() 
res %>% head()


# 描画用データに変換する
# parse_cooc > function.rを参照
df = parse_cooc(names(res), as.vector(res))

# データの形状
df %>% head()
df$freq %>% sort(decreasing=T) %>% plot()
df$freq %>% sort(decreasing=T) %>% plot(log='y')

# ネットワーク図　
net = df %>% 
    filter(N1 %in% c('私','Ｋ','お嬢さん') | N2 %in% c('Ｋ','お嬢さん','私')) %>% # どちらかの単語がK, お嬢さん, 私であるものを抽出
    filter(str_detect(POS, '形容')) %>% # 品詞に形容詞・形容動詞をを利用
    filter(freq > 0)  %>% 
    filter(! N1 %in% stopwords) %>%  
    filter(! N2 %in% stopwords)

net %>% graph_from_data_frame() %>% as.undirected() %>% tkplot(vertex.color='SkyBlue', vertex.size=22)

