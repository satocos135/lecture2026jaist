# データセットについて

## 概要

タイタニック号の乗客1309名の生存状況に関するデータ。

## ファイル詳細

+ titanic.csv
    + Titanic https://www.openml.org/search?type=data&sort=runs&id=40945&status=active
        + arffをcsvに加工(データ記述部分を削除)
    + 変数
        + `pclass`: 旅客等級
        + `survived`: 生存したか
        + `name`: 氏名
        + `sex`: 性別
        + `age`: 年齢
        + `sibsp`: 乗船していた兄弟(siblings)または配偶者(spousesの数
        + `parch`: 乗船していた親(parents)または子供(children)の数
        + `ticket`: チケット番号
        + `fare`: 運賃
        + `cabin`: 客室番号
        + `embarked`: 出港地
            + `C`: Cherbourg
            + `Q`: Queenstown
            + `S`: Southampton
        + `boat`: 救命ボートの番号
        + `body`: 遺体収容時の識別番号
        + `home.dest`: 自宅または目的地

## データ出典

+ Harrell & Cason (2002) Titanic Data
    + https://hbiostat.org/data/repo/titanic.html

