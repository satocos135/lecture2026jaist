# データセットについて

## 概要

都道府県別新型コロナウイルス陽性者数およびワクチン接種状況のオープンデータを分析実習用に加工したもの。

## ファイル詳細

+ cases.csv
    + 日別・都道府県別新規陽性者数（報告日ベース）
        + 元データ: 厚生労働省「新規陽性者数の推移」(newly_confirmed_cases_daily.csv)
        + 変更点
            + long形式に加工
            + 都道府県名をコードに変換
    + 変数
        + `date`: 日付(`YYYY-MM-DD`)
        + `prefecture_code`: 2桁の都道府県コード
        + `cases`: 陽性者数
+ vaccines.csv
    + 日別・都道府県別接種状況の詳細（集計日ベース）
        + 元データ: デジタル庁「新型コロナワクチン接種状況 都道府県別接種回数詳細」(prefecture.ndjson)
        + 変更点
            + ndjsonをcsvに加工
            + `medical_worker`列を削除(データ取得時点ですべてfalseであるため)
            + `prefecture` → `prefecture_code` に改名
            + `age` → `elderly`に変更、値を以下に変換
                + `-64` → 0
                + `65-` → 1
                + `UNK` → NA
    + 変数
        + `date`: 日付(`YYYY-MM-DD`)
        + `prefecture_code`: 2桁の都道府県コード
        + `cases`: 陽性者数
        + `gender`: 性別
            + `F`: 女性
            + `M`: 男性
            + `U`: 不明
        + `elderly`: 高齢者(65歳以上)かどうか
            + 0: 65歳未満
            + 1: 65歳以上
            + NA: 不明
        + `status`: 何回目の接種か(1-4)
        + `count`: ワクチン接種者の人数
+ prefecture.csv
    + 都道府県コードと都道府県名の対応表
    + 変数
        + `prefecture_code`: 2桁の都道府県コード
        + `prefecture`: 都道府県名
+ regions.csv
    + 都道府県コードと地方区分の対応表
    + 変数
        + `prefecture_code`: 2桁の都道府県コード
        + `region`: 地方区分

+ original_data/*
    + 加工前の元データ

## データ出典

+ 厚生労働省「新規陽性者数の推移」 https://www.mhlw.go.jp/stf/covid-19/open-data.html
    + 2022.06.24時点のデータ
+ デジタル庁「新型コロナワクチン接種状況」 https://info.vrs.digital.go.jp/dashboard
    + 2022.06.24時点のデータ


