"""notebook JSON 读写的公共工具。

Jupyter 保存 .ipynb 时的排版是：字典缩进 1、数组逐项一行。
直接用 json.dump(indent=1) 会得到不同的空白风格，导致整个文件被视为重写、
diff 噪声极大。这里复刻 Jupyter 的风格，保证只改真正变动的内容。
"""
import json
from pathlib import Path

CELL_ORDER = ["cell_type", "execution_count", "id", "metadata", "outputs", "source"]
NOTEBOOK_ORDER = ["cells", "metadata", "nbformat", "nbformat_minor"]


def dumps(value, indent=0):
    pad = " " * indent
    if isinstance(value, dict):
        if not value:
            return "{}"
        inner = " " * (indent + 1)
        items = [f"{inner}{json.dumps(k, ensure_ascii=False)}: {dumps(v, indent + 1)}"
                 for k, v in value.items()]
        return "{\n" + ",\n".join(items) + "\n" + pad + "}"
    if isinstance(value, list):
        if not value:
            return "[]"
        inner = " " * (indent + 1)
        items = [f"{inner}{dumps(v, indent + 1)}" for v in value]
        return "[\n" + ",\n".join(items) + "\n" + pad + "]"
    return json.dumps(value, ensure_ascii=False)


def reorder(d, order):
    return {**{k: d[k] for k in order if k in d},
            **{k: v for k, v in d.items() if k not in order}}


def lines_of(text):
    """把多行文本转成 notebook 的 source 数组（末行不带换行）。"""
    rows = text.strip("\n").splitlines()
    return [r + "\n" for r in rows[:-1]] + [rows[-1]]


def load(path):
    return json.loads(Path(path).read_text(encoding="utf-8"))


def save(path, nb):
    nb = reorder(nb, NOTEBOOK_ORDER)
    nb["cells"] = [reorder(c, CELL_ORDER) for c in nb["cells"]]
    nb["metadata"] = reorder(nb["metadata"], ["kernelspec", "language_info"])
    Path(path).write_text(dumps(nb) + "\n", encoding="utf-8")


def find_cell(nb, pred):
    for i, c in enumerate(nb["cells"]):
        if pred("".join(c.get("source", []))):
            return i
    raise LookupError("未找到目标单元")


def set_source(cell, text):
    cell["source"] = lines_of(text)
