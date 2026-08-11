# StockAnalyzerCLI

将原 Playground 100、101 页的股票评分、持仓行业统计和投资计划迁移为 macOS 命令行程序。

```bash
cd StockAnalyzerCLI

# 原 100 页
swift run stock-analyzer score --stock-dir ../Stock

# 原 101 页
swift run stock-analyzer portfolio --jisilu-dir ../Jisilu

# 两项一起运行（默认会自动查找仓库根目录的 Stock 和 Jisilu）
swift run stock-analyzer all
```

程序不依赖 Playground Resources 或应用 Bundle。它会在所有候选目录中比较文件名日期，选择全局最新的文件，并打印读取文件的绝对路径。
