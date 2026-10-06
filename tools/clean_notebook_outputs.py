"""清空 notebook 的输出与执行痕迹，便于干净提交。

用 Jupyter/VS Code 运行过 notebook 后，.ipynb 会保存：
  - outputs：图表、表格、报错 traceback（后者还含本机绝对路径，不适合入库）
  - execution_count：执行序号，每次运行都变
  - metadata.ExecuteTime：实际执行时间戳，每次运行都变
这些都会让 diff 变得巨大且充满噪声。

用法（在项目根目录）：
    python tools/clean_notebook_outputs.py
    python tools/clean_notebook_outputs.py notebooks/xxx.ipynb   # 指定文件

随后再 git add / commit。
"""
import json
import sys
from pathlib import Path

CELL_ORDER = ["cell_type", "execution_count", "id", "metadata", "outputs", "source"]
NOTEBOOK_ORDER = ["cells", "metadata", "nbformat", "nbformat_minor"]


def dumps_notebook(value, indent=0):
    """复刻 Jupyter 保存 .ipynb 的排版：字典缩进 1、数组逐项一行。"""
    pad = " " * indent
    if isinstance(value, dict):
        if not value:
            return "{}"
        inner = " " * (indent + 1)
        items = [f"{inner}{json.dumps(k, ensure_ascii=False)}: "
                 f"{dumps_notebook(v, indent + 1)}" for k, v in value.items()]
        return "{\n" + ",\n".join(items) + "\n" + pad + "}"
    if isinstance(value, list):
        if not value:
            return "[]"
        inner = " " * (indent + 1)
        items = [f"{inner}{dumps_notebook(v, indent + 1)}" for v in value]
        return "[\n" + ",\n".join(items) + "\n" + pad + "]"
    return json.dumps(value, ensure_ascii=False)


def reorder(d, order):
    known = {k: d[k] for k in order if k in d}
    return {**known, **{k: v for k, v in d.items() if k not in order}}


def clean(path: Path) -> int:
    nb = json.loads(path.read_text(encoding="utf-8"))
    n_out = n_cnt = n_meta = 0
    for cell in nb.get("cells", []):
        if cell.get("cell_type") != "code":
            continue
        if cell.get("outputs"):
            cell["outputs"] = []
            n_out += 1
        if cell.get("execution_count") is not None:
            cell["execution_count"] = None
            n_cnt += 1
        meta = cell.get("metadata") or {}
        if "ExecuteTime" in meta:
            meta.pop("ExecuteTime")
            n_meta += 1
        cell["metadata"] = meta

    nb = reorder(nb, NOTEBOOK_ORDER)
    nb["cells"] = [reorder(c, CELL_ORDER) for c in nb["cells"]]
    nb["metadata"] = reorder(nb["metadata"], ["kernelspec", "language_info"])
    path.write_text(dumps_notebook(nb) + "\n", encoding="utf-8")

    # 回读确认
    check = json.loads(path.read_text(encoding="utf-8"))
    code = [c for c in check["cells"] if c["cell_type"] == "code"]
    left_out = sum(1 for c in code if c.get("outputs"))
    left_cnt = sum(1 for c in code if c.get("execution_count") is not None)
    print(f"{path}")
    print(f"  清空输出 {n_out} 个单元 / 重置计数 {n_cnt} 个 / 移除 ExecuteTime {n_meta} 处")
    print(f"  回读确认：剩余输出 {left_out}，剩余计数 {left_cnt}")
    return left_out + left_cnt


def main():
    targets = [Path(a) for a in sys.argv[1:]] or [Path("notebooks/olist_analysis.ipynb")]
    bad = 0
    for p in targets:
        if not p.is_file():
            print(f"跳过（不存在）：{p}")
            bad += 1
            continue
        bad += clean(p)
    print("\n结果:", "已清理干净" if bad == 0 else "仍有残留，请检查")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
