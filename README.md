# Olist 电商数据分析项目

## 项目简介

本项目基于 Olist 巴西电商公开数据，使用 MySQL、Python、Pandas、Matplotlib 和 Pyecharts，完成用户、订单、商品、卖家、支付、评价及营销漏斗数据的清洗、分析与可视化。

项目采用 Jupyter Notebook 作为主要分析载体，便于按单元格逐步执行、调整参数和复用分析代码。

## 数据来源

- [Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- [Marketing Funnel by Olist](https://www.kaggle.com/datasets/olistbr/marketing-funnel-olist)

主要数据表：

`customers`、`orders`、`order_items`、`order_payments`、`order_reviews`、`products`、`sellers`、`geolocation`、`product_category_translation`、`marketing_qualified_leads`、`closed_deals`。

## 分析内容

1. **数据清洗**：处理缺失值、重复记录、日期格式和异常数据，统一字段类型。
2. **指标构建**：基于有效订单计算订单量、GMV、客单价、复购率、准时交付率和营销转化率。
3. **订单分析**：统计订单量、销售额、客单价、订单状态和支付方式。
4. **商品分析**：分析商品类别、销量、销售额及热销品类。
5. **卖家分析**：比较卖家订单量、销售额和运费占比表现（3D 散点图）。
6. **州域分析**：按客户所在州统计订单量、GMV 与客户规模。
7. **用户 RFM 分层**：
   - `R`（Recency）：用户最近一次下单距分析截止日的天数；
   - `F`（Frequency）：用户订单数量；
   - `M`（Monetary）：用户累计消费金额。

   根据 R、F、M 五分位评分，将用户划分为核心客户、忠诚客户、高消费客户、新近客户、流失风险客户等群体。
8. **营销漏斗分析**：基于 `mql_id` 和 `closed_deals` 分析线索与成交情况。
9. **可视化展示**：使用 Matplotlib 输出静态图表，使用 Pyecharts 输出可交互的二维和三维图表。

## 技术栈

- MySQL 8.0：数据存储与查询
- Python：数据清洗、统计分析和可视化
- Pandas：数据处理
- Matplotlib：静态可视化
- Pyecharts：交互式可视化
- Jupyter Notebook：交互式分析环境
- SSH 隧道：安全连接云端 MySQL

## 项目结构

```text
olist-ecommerce-analysis/
├─ config/
│  ├─ application.yml        # 配置占位符（${VAR} 形式）
│  ├─ .env.example           # 可提交的配置模板
│  └─ .env                   # 本地真实连接配置，已被 .gitignore 排除
├─ data/
│  └─ raw/                   # Olist 原始 CSV（transactions / marketing）
├─ notebooks/
│  ├─ olist_analysis.ipynb   # 主分析 Notebook
│  └─ exports/               # Matplotlib 静态图导出目录
├─ sql/
│  └─ navicat_mysql8_import.sql   # 建表 + LOAD DATA 导入脚本
├─ requirements.txt          # Python 依赖
├─ .gitignore                # 排除 .env、.venv、原始数据等
└─ README.md
```

> `notebooks/olist_analysis_rebuild.ipynb` 是早期带执行输出的历史版本，已不再维护；
> 请统一使用 `notebooks/olist_analysis.ipynb`。

## 运行方式

1. 准备 Python 环境并安装依赖：

   ```bash
   pip install -r requirements.txt
   ```

   本项目在 Anaconda base 环境（Python 3.13）下验证通过。
   根目录的 `.venv` 仅安装了 `ipykernel`/`pip`，**缺少 pandas、pyecharts 等库，不要选作 kernel**。

2. 用 `sql/navicat_mysql8_import.sql` 建库建表并导入 CSV。
   注意：脚本中 `CREATE DATABASE` 的库名必须与 `config/.env` 的 `MYSQL_DATABASE` 保持一致。

3. 复制 `config/.env.example` 为 `config/.env`，填写 SSH 和 MySQL 连接信息。
   真实密码只放在 `.env`，不要写入 Notebook 或代码。

4. 使用 VS Code、PyCharm 或 Jupyter 打开 `notebooks/olist_analysis.ipynb`。

5. 按 Notebook 单元格顺序执行：2.1 连接数据库 → 3 清洗 → 5 指标构建 → 6 可视化函数
   → 7–11 图表与 RFM → 12 业务结论。

## 指标口径

- 销售额：订单明细中的商品金额与运费金额按项目分析口径统计。
- 订单量：按有效订单编号去重统计。
- 客单价：销售额除以订单量。
- 用户消费金额：按用户汇总其有效订单明细金额。
- RFM：以数据中有效订单的最大订单日期作为分析截止日进行计算。
- 线索转化率：成交线索数除以营销合格线索数，仅用于描述性分析。

## 项目限制

- Olist 数据为公开历史数据，不能代表当前真实业务状况。
- 部分订单存在取消、缺失评价或日期缺失，需要结合业务口径解释。
- 营销漏斗数据与交易数据缺少稳定、完整的用户级关联关系，不能用于严格广告 ROI、用户级广告归因或因果推断。
- RFM 分层属于客户运营分析方法，分位数和标签边界会受到样本时间范围及数据清洗规则影响。

## 项目成果

完成从 MySQL 数据读取、Python 清洗、用户 RFM 分层、业务指标分析到交互式可视化展示的完整流程，为商品运营、卖家管理、客户分层和履约服务优化提供数据支持。
