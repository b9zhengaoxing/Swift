# Swift_learning
MJ Switf Code && swift programming language guide
 My wife ask me update everyday

## StockAnalyzerCLI

运行股票分析命令后，终端输出会同时生成美化的本地网页报告，但不会自动打开浏览器。报告按运行时间保存在可见目录 `StockAnalyzerCLI/reports/`，该目录仅供本地查阅，不会提交到 Git。需要运行后立即打开时，可添加 `--open-web`。

在脚本或只需要终端输出时，添加 `--no-web`：

```bash
cd StockAnalyzerCLI
swift run stock-analyzer score --stock-dir ../Stock --no-web
```

关联账户直接提供的集思录 `.xls` 导出文件放在 `repositories/others/关联账户jisilu/`。默认运行时会同时读取其中文件名日期最新的一份，以及 `repositories/others/image/` 中修改时间最新的截图。两种来源的持仓和行业加投建议都会打印到终端，并收录到同一份生成网页。直接收到的文件与截图识别生成的 `repositories/others/Jisilu/` 分开，且不会提交到 Git。
