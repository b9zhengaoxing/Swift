# StockAnalyzerCLI

将原 Playground 100、101 页的股票评分、持仓行业统计和投资计划迁移为 macOS 命令行程序。

```bash
cd StockAnalyzerCLI

# 直接运行工程/不传参数：股票分析 + 我的预测 + 别人的持仓报告
swift run stock-analyzer

# 原 100 页
swift run stock-analyzer score --stock-dir ../Stock

# 原 101 页
swift run stock-analyzer portfolio --jisilu-dir ../Jisilu

# 两项一起运行（默认会自动查找仓库根目录的 Stock 和 Jisilu）
swift run stock-analyzer all
```

程序不依赖 Playground Resources 或应用 Bundle。它会在所有候选目录中比较文件名日期，选择全局最新的文件，并打印读取文件的绝对路径。

默认运行时使用两套独立仓库，互不混用：

```text
repositories/
  mine/
    Jisilu/        # 你自己的集思录 XLS
  others/
    image/         # 别人的截图
    Jisilu/        # 别人截图 OCR 后生成的集思录 XLS
```

默认流程会先运行原有股票评分和仓位分析，然后读取 `repositories/mine/Jisilu` 中最新的 XLS，打印“我的集思录”、投资目标测算以及基于我的持仓生成的行业加投建议。最后扫描 `repositories/others/image` 中修改时间最新的图片，支持 `jpg/jpeg/png/heic/heif/tif/tiff/bmp`，生成集思录兼容 `.xls` 到 `repositories/others/Jisilu`，并打印“别人的集思录”和使用相同规则生成的行业加投建议。别人的数据不参与 500 万、1000 万等长期资产目标测算，也不打印对比汇总。

别人的图片请直接以对方姓名命名，例如 `王烨.jpg`。程序会把文件名识别为对方姓名，把图片修改时间识别为数据日期，并生成类似 `集思录_王烨_20260814_102811.xls` 的文件。

`all` 模式会在原有评分表和持仓报告后追加行业加投建议：单个行业按账户总资产的 3% 补足，优先显示尚未持仓的行业，其次显示仍可加仓的行业，并列出行业内全部总分不低于 270 的合格股票供选择。
