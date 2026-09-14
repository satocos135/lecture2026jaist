library(RMeCab)
library(stringr)
library(purrr)


# tfを求める関数
tf = function(df){
    return(t(t(df) / colSums(df)))
}

# idfを求める関数
idf = function(df){
    doc_sums = (df > 0) %>% rowSums() + 1
    return(log2(ncol(df)/doc_sums))
}

# 共起を集計する関数
get_cooc = function(string, # 分析する文字列
                    pos=c('名詞', '動詞'), # 対象とする品詞
                    with_pos=F, # 品詞も同時に出力するか
                    unique=T, # 同じ単語同士の組み合わせを許すか
                    stopwords=c(), # ストップワードに設定する語
                    dic='' # MeCabの辞書のパス
                    ){
    if(length(string) == 0){
        return(c())
    }
    words = RMeCabC(string, 1, dic=dic) %>% unlist()
    targets = words[names(words) %in% pos] # 対象となる品詞のみ抽出
    if(unique){
        # 重複なしにする
        targets[!duplicated(targets)]
    }
    if(length(stopwords)){
        # ストップワードを除外
        targets = targets[! targets %in% stopwords]
    }
    
    if(length(targets) < 2){
        return(c())
    }
    
    if(with_pos){
        # 品詞集計用の処理
        targets = str_c(targets,'/',names(targets))
    }

    res = combn(sort(targets),2) # 組み合わせを求める
    
    result = paste(res[1,], '-', res[2,], sep='')
    return(result)
}

# 品詞付きの結果を整形する関数
parse_cooc = function(
                      strings, # 共起のラベル
                      freq # 共起の頻度
                      ){
    res = str_split(strings, '-')
    w1 = str_split(map_chr(res,1), '/')
    w2 = str_split(map_chr(res,2), '/')
    result = as.data.frame(cbind(
        map_chr(w1,1), 
        map_chr(w2,1),
        str_c(map_chr(w1,2), '-', map_chr(w2,2))
    ))
    colnames(result) = c('N1', 'N2', 'POS')
    result['freq'] = freq
    return(result)
}

