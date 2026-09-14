
###### 分析① 
### データハンドリング入門：夏目漱石『夢十夜』の分析


### 必要なパッケージ
###     - tidyverse: dplyr, stringr, ggplot2などがまとまったパッケージ
###     - RMeCab
### 事前準備
### - setwd()でこのファイルが入ったフォルダの絶対パスを指定する


library('tidyverse') # dplyrだけでも可
library('RMeCab')


setwd('./GitHub/lecture2025shimane/')
### データ読み込み
# ファイルはtsv（タブ区切り）になっているのでread.delim()で読み込む。
yume = read.delim('data/textmining/yumejuya.tsv', header=T, sep='\t', stringsAsFactors=F, fileEncoding='utf8')

## + section: 第一夜から第十夜までが数字で
## + paragraph: 各話の段落番号
## + content: 本文

yume %>% head()

### 段落の長さの分布

## 各話ごとの段落の長さの分布を箱ひげ図で可視化する

# str_length(): 文字列の長さ
yume[, 'content'] %>% str_length() %>% hist(breaks=25, xlab='Paragraph length', main='Histogram of paragraph length')

yume['length'] = yume[, 'content'] %>% str_length() # 段落の長さを格納する
boxplot(length ~ section_id, data=yume, main='Paragraph length of each section')

## 分析のため各話ごとに文章を結合する

# group_by(): データを集約する
# summarise(): データを特定の関数でまとめる
sections = yume %>% group_by(section_id) %>% summarise(text = paste0(content, collapse='')) # section内の文を全部結合
sections = as.data.frame(sections) # dataframe化



dim(sections) # 構造の確認
colnames(sections) # 列名の確認
sections[, 'text'] %>% str_length() # 各話の文字数を数える

### 単語の頻度を求める
# docMatrixDF(): dataframeの行単位に形態素解析
count_noun = docMatrixDF(sections[,'text'], pos=c('名詞'))

count_noun %>% head() #確認

# 各話ごとの頻度をもとに全体の頻度を集計する
freq_noun = count_noun %>% rowSums()

# 頻度が多い順に並べる
freq_noun %>% sort(decreasing=T) %>% plot(main='Distribution of noun frequency', xlab='Rank', ylab='Frequency') 
freq_noun %>% sort(decreasing=T) %>% plot(main='Distribution of noun frequency', xlab='Rank (log)', ylab='Frequency jj(log)', log='xy') # 両対数グラフ

# cf. Noraml Distribution
dist = rnorm(10000)
dist %>% hist(100, main='Normal distribution (n = 10000)')
dist %>% sort(decreasing=T) %>% plot(main='Normal distribution (n = 10000)', xlab='Rank', ylab='Value')

# cf. Poisson Distribution
dist = rpois(10000, 1) 
dist %>% hist(main='Poisson distribution (n = 10000, lambda=1)')
dist %>% sort(decreasing=T) %>% plot(main='Poisson distribution (n = 10000, lambda=1)', xlab='Rank', ylab='Value')

# 上位の語を表示する
freq_noun %>% sort() %>% tail(30) %>% barplot(horiz=T, las=1, main='Top 30 nouns', xlab='Frequency', cex.name=0.9)

# stopwordsを設定する
stopwords = c('よう', '上', '中',  'もの', 'の', 'それ', '一', '事', '何','ん', 'どこ')

# stopwordsを除いた結果
freq_noun[!names(freq_noun) %in% stopwords] %>% sort() %>% tail(30) %>% barplot(horiz=T, las=1, main='Top 30 nouns', xlab='Frequency')

### tf-idfを求める
# tf(term frequency)の計算
tf = function(df){
    return(t(t(df) / colSums(df)))
}

# idf(inverse document frequency)の計算
idf = function(df){
    doc_sums = (df > 0) %>% rowSums() + 1
    return(log2(ncol(df)/doc_sums))
}

tfidf= tf(count_noun) * idf(count_noun) 

# 夢十夜のそれぞれのTFIDFを一枚のplotにおさめる
par(mfrow=c(2,5)) 

for(i in 1:10){
tfidf[,i] %>% 
    sort() %>% 
    tail(10)  %>%  barplot(horiz=T, las=2, main=character(i))
}

par(mfrow=c(1,1)) # 設定をもとに戻す

