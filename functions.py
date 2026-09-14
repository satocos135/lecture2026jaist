import MeCab
from typing import NamedTuple


tagger = MeCab.Tagger()


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


def tokenize(text: str, tagger: MeCab.Tagger = tagger) -> list[Token]:
    parsed = tagger.parse(text)
    return [convert(x) for x in parsed.split('\n')[:-2]]
