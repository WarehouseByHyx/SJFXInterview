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
2. **订单分析**：统计订单量、销售额、客单价、订单状态和支付方式。
3. **商品分析**：分析商品类别、销量、销售额及热销品类。
4. **卖家分析**：比较卖家订单量、销售额和客户评价表现。
5. **履约分析**：结合发货、预计送达和实际送达时间，分析配送时效及延迟情况。
6. **用户 RFM 分层**：
   - `R`（Recency）：用户最近一次下单距分析截止日的天数；
   - `F`（Frequency）：用户订单数量；
   - `M`（Monetary）：用户累计消费金额。

   根据 R、F、M 五分位评分，将用户划分为高价值用户、重要发展用户、重要挽留用户、潜力用户和低活跃用户等群体。
7. **营销漏斗分析**：基于 `mql_id` 和 `closed_deals` 分析线索与成交情况。
8. **可视化展示**：使用 Matplotlib 输出静态图表，使用 Pyecharts 输出可交互的二维和三维图表。

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
│  ├─ application.yml       # 配置占位符
│  └─ .env                   # 本地真实连接配置，不提交到 Git
├─ notebooks/
│  └─ olist_analysis.ipynb   # 主分析 Notebook
├─ README.md
└─ start_jupyter.bat         # 启动 Jupyter
```

## 运行方式

1. 准备 Python、Jupyter、Pandas、Matplotlib、Pyecharts、PyMySQL、Paramiko 和 sshtunnel 环境。
2. 在 `config/.env` 中填写 SSH 和 MySQL 连接信息，真实密码不要写入 Notebook 或代码。
3. 使用 VS Code、PyCharm 或 Jupyter 打开 `notebooks/olist_analysis.ipynb`。
4. 按 Notebook 单元格顺序执行，完成数据读取、清洗、RFM 分层、统计分析和图表展示。

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
