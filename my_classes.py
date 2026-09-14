from collections import Counter
from itertools import combinations
import re
from typing import NamedTuple, Iterable

import MeCab
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA


class Token(NamedTuple):
    surface: str  # 表層形
    pos: str  # 品詞: POS part of speech
    subtype: str  # 品詞細分類
    lemma: str  # 原型


def convert(row: str) -> Token | None:
    # 1行ずつ処理する
    x = row.split('\t')
    if len(x) == 2:
        surface, body = x
        splitted = body.split(',')
    else:
        # バージョンが上がってタブ区切りになった対応
        surface = x[0]
        splitted = x[1:]
    pos = splitted[0]
    subtype = splitted[1]
    lemma = splitted[6]
    return Token(surface, pos, subtype, lemma)


def resolve(token: Token) -> str:
    if token.lemma != '*':
        return token.lemma
    return token.surface


class Tokenizer:
    # 自作辞書用の処理をまとめるためのクラス
    def __init__(self, dic: str | None = None) -> None:
        try:
            import ipadic
            args = ipadic.MECAB_ARGS
        except ImportError:
            args = ''

        if dic:
            self.tagger = MeCab.Tagger(f'-u {dic} ' + args)
        else:
            self.tagger = MeCab.Tagger(args)

    def tokenize(self, text: str) -> list[Token]:
        parsed = self.tagger.parse(text)
        return [convert(x) for x in parsed.split('\n')[:-2]]

    def count_tokens_df(
            self, data: pd.Series, pos: Iterable[str] | None = None
            ) -> pd.DataFrame:
        # 行ごとに語を集計した結果をデータフレームで結合して返す
        tokenized = data.apply(self.tokenize)
        result = tokenized.apply(count_tokens, pos=pos).fillna(0).astype(int)
        return result.T.sort_index()

    def count_bigrams_df(
            self, data: pd.Series, pos: Iterable[str] | None = None
            ) -> pd.DataFrame:
        # 行ごとにバイグラムを集計した結果をデータフレームで結合して返す
        tokenized = data.apply(self.tokenize)
        result = tokenized.apply(count_bigrams, pos=pos).fillna(0).astype(int)
        return result.T.sort_index()

    def get_cooc(
            self,
            string: str,
            pos: list[str] | None,
            with_pos: bool = False,
            unique: bool = False,
            stopwords: set | None = None,
            regex_exclude: re.Pattern | None = None,
            ):
        if not string:
            return []
        words = self.tokenize(string)

        if pos:
            pos_ = set(pos)
            targets = [x for x in words if x.pos in pos_]
        else:
            targets = words

        if unique:
            targets = list(set(targets))

        if regex_exclude:
            targets = [x for x in targets if not regex_exclude.search(
                resolve(x))]

        if stopwords:
            targets = [x for x in targets if resolve(x) not in stopwords]

        if len(targets) < 2:
            return []

        if with_pos:
            targets = [f'{resolve(x)}/{x.pos}' for x in targets]
        else:
            targets = [resolve(x) for x in targets]
        res = combinations(targets, 2)
        return [f'{t1}-{t2}' for t1, t2 in res]


def filter_tokens(
        data: list[Token], pos: Iterable[str] | None = None) -> list[Token]:
    # 特定の品詞の語のみ抜き出す
    if not pos:
        return data

    pos_ = set(pos)
    return [x for x in data if x.pos in pos_]


def count_tokens(
        data: list[Token], pos: Iterable[str] | None = None) -> pd.Series:
    # 語を表層形に基づいて数える
    tokens = [x.surface for x in filter_tokens(data, pos)]
    return pd.Series(Counter(tokens))


def count_bigrams(
        data: list[Token], pos: Iterable[str] | None = None) -> pd.Series:
    tokens = filter_tokens(data, pos)
    # バイグラムを集計する。RMeCabのdocDFの挙動に合わせて作っているので注意

    # lemmaが未指定の場合表層形を使う
    items = [
            (x.lemma, x.pos, x.subtype) if x.lemma != '*'
            else (x.surface, x.pos, x.subtype)
            for x in tokens]
    bigrams = [
                (
                    items[i][0], items[i+1][0],
                    f'{items[i][1]}-{items[i+1][1]}',
                    f'{items[i][2]}-{items[i+1][2]}',
                ) for i, x in enumerate(items[:-1])
                ]
    return pd.Series(Counter(bigrams))


def pca_biplot(
    X,
    labels=None,
    feature_names=None,
    point_labels=None,
    annotate_points=False,
    n_components=2,
    scale=True,
    pc_x=1,
    pc_y=2,
    scale_arrows=1.0,
    figsize=(8, 8),
    ax=None,
    title="PCA Biplot",
    point_alpha=0.7,
    arrow_color="firebrick",
    cmap="tab10",
    auto_lim=True,
    lim_margin=0.15,
):
    """
    PCAを実行し、biplot(スコア + ローディングベクトル)を描画する。
    Rのbiplot関数の挙動に合わせている

    Parameters
    ----------
    X : array-like または pandas.DataFrame, shape (n_samples, n_features)
        入力データ。pandas.DataFrame を渡した場合、`feature_names` が
        未指定なら列名を、`point_labels` が未指定なら index を自動的に使用する。
    labels : array-like, shape (n_samples,), optional
        各サンプルのクラス/グループラベル。指定すると色分けする。
    feature_names : list of str, optional
        各変数(列)の名前。矢印のラベルに使用。未指定時、X が DataFrame なら
        列名を使用し、それ以外は "x1", "x2", ... となる。
    point_labels : array-like, shape (n_samples,), optional
        各サンプル点に付けるラベル(例: サンプル名)。未指定時、X が
        DataFrame なら index を自動的に使用する。実際に描画するかどうかは
        `annotate_points` で制御する。
    annotate_points : bool, default=False
        True の場合、各点の近くに `point_labels`(またはDataFrameのindex)を
        テキストとして表示する。サンプル数が多いと図が煩雑になるので注意。
    n_components : int, default=2
        PCAで計算する主成分数(2以上を推奨。描画には2つだけ使う)。
    scale : bool, default=True
        True の場合、PCA前にデータを標準化(平均0, 分散1)する。
    pc_x, pc_y : int, default=1, 2
        プロットに使う主成分の番号(1始まり)。例: PC1とPC3を見たい場合は pc_x=1, pc_y=3。
    scale_arrows : float, default=1.0
        ローディング矢印の長さを調整する倍率。
    figsize : tuple, default=(8, 8)
        ax が None のとき生成する図のサイズ。
    ax : matplotlib.axes.Axes, optional
        描画先の Axes。None なら新規作成。
    title : str
        グラフタイトル。
    point_alpha : float
        スコア点の透明度。
    arrow_color : str
        ローディング矢印の色。
    cmap : str
        labels で色分けする際のカラーマップ。
    auto_lim : bool, default=True
        True の場合、スコア点とローディング矢印・ラベルが収まるように
        軸範囲(xlim, ylim)を自動調整する。False の場合は固定で (-1, 1)。
    lim_margin : float, default=0.15
        auto_lim=True のときの余白の割合(矢印ラベルが枠に接触しないための余裕)。

    Returns
    -------
    fig, ax : matplotlib Figure, Axes
    pca : 学習済みの PCA オブジェクト(explained_variance_ratio_ などを参照可能)
    """
    # pandas.DataFrame かどうかを、pandas への依存を必須にせずに判定する
    is_dataframe = hasattr(X, "columns") and hasattr(X, "index") and hasattr(X, "values")

    if is_dataframe:
        if feature_names is None:
            feature_names = list(X.columns)
        if point_labels is None:
            point_labels = [str(i) for i in X.index]

    X = np.asarray(X, dtype=float)
    n_samples, n_features = X.shape

    if feature_names is None:
        feature_names = [f"x{i + 1}" for i in range(n_features)]

    if point_labels is not None:
        point_labels = list(point_labels)
        if len(point_labels) != n_samples:
            raise ValueError(
                f"point_labels の長さ({len(point_labels)})が "
                f"サンプル数({n_samples})と一致しません。"
            )

    if max(pc_x, pc_y) > n_components:
        n_components = max(pc_x, pc_y)

    # 標準化
    if scale:
        X_input = StandardScaler().fit_transform(X)
    else:
        X_input = X - X.mean(axis=0)

    # PCA実行
    pca = PCA(n_components=n_components)
    scores = pca.fit_transform(X_input)

    ix = pc_x - 1
    iy = pc_y - 1

    xs = scores[:, ix]
    ys = scores[:, iy]

    # 表示をきれいにするためのスケーリング係数
    scalex = 1.0 / (xs.max() - xs.min())
    scaley = 1.0 / (ys.max() - ys.min())

    if ax is None:
        fig, ax = plt.subplots(figsize=figsize)
    else:
        fig = ax.figure

    # --- スコア(観測値)のプロット ---
    if labels is not None:
        labels = np.asarray(labels)
        unique_labels = np.unique(labels)
        colors = plt.get_cmap(cmap)(np.linspace(0, 1, len(unique_labels)))
        for lab, color in zip(unique_labels, colors):
            mask = labels == lab
            ax.scatter(
                xs[mask] * scalex,
                ys[mask] * scaley,
                alpha=point_alpha,
                label=str(lab),
                color=color,
                edgecolor="k",
                linewidth=0.3,
            )
        ax.legend(title="Label", loc="best", frameon=True)
    else:
        ax.scatter(
            xs * scalex,
            ys * scaley,
            alpha=point_alpha,
            edgecolor="k",
            linewidth=0.3,
        )

    # --- 各点のラベル(サンプル名など)の表示 ---
    if annotate_points and point_labels is not None:
        for i, name in enumerate(point_labels):
            ax.annotate(
                str(name),
                (xs[i] * scalex, ys[i] * scaley),
                xytext=(3, 3),
                textcoords="offset points",
                fontsize=8,
                alpha=0.75,
            )

    # --- ローディング(変数)ベクトルのプロット ---
    # 軸範囲の自動調整のため、描画される座標(点・矢印ラベル)を記録しておく
    extent_x = list(xs * scalex)
    extent_y = list(ys * scaley)

    loadings = pca.components_.T  # shape (n_features, n_components)
    for i, name in enumerate(feature_names):
        lx = loadings[i, ix] * scale_arrows
        ly = loadings[i, iy] * scale_arrows
        ax.arrow(
            0,
            0,
            lx,
            ly,
            color=arrow_color,
            alpha=0.9,
            head_width=0.02,
            length_includes_head=True,
        )
        label_x = lx * 1.15
        label_y = ly * 1.15
        ax.text(
            label_x,
            label_y,
            name,
            color=arrow_color,
            ha="center",
            va="center",
            fontsize=10,
        )
        extent_x.append(label_x)
        extent_y.append(label_y)

    var_x = pca.explained_variance_ratio_[ix] * 100
    var_y = pca.explained_variance_ratio_[iy] * 100

    ax.axhline(0, color="grey", linewidth=0.5, linestyle="--")
    ax.axvline(0, color="grey", linewidth=0.5, linestyle="--")
    ax.set_xlabel(f"PC{pc_x} ({var_x:.1f}%)")
    ax.set_ylabel(f"PC{pc_y} ({var_y:.1f}%)")
    ax.set_title(title)

    if auto_lim:
        # ラベルの文字幅を厳密には測れないため、マージンで余裕を持たせる
        x_max = max(1e-6, max(abs(v) for v in extent_x)) * (1 + lim_margin)
        y_max = max(1e-6, max(abs(v) for v in extent_y)) * (1 + lim_margin)
        ax.set_xlim(-x_max, x_max)
        ax.set_ylim(-y_max, y_max)
    else:
        ax.set_xlim(-1, 1)
        ax.set_ylim(-1, 1)

    ax.set_aspect("equal", adjustable="box")

    return fig, ax, pca
