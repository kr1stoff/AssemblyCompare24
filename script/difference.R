################################################################################
# 组装参数差异箱线图
# cgMLST missing
# quast 
################################################################################
library(tidyverse)
library(readr)
library(ggpubr)
library(gridExtra)


# 导入数据
# cgMLST 统计文件, 去除结果中'.fasta'
# 保留 missing
df_cgmlst <- read_delim('data/cgMLST-mdata_stats.tsv')
df_cgmlst$FILE <- gsub('.fasta', '', df_cgmlst$FILE)
df_cgmlst$percentage <- NULL
df_cgmlst <- rename(df_cgmlst, Sample = FILE)

# quast 转置表格, 行名生成单独列, 转tibble格式
# 保留 contig, n50, fraction, mismatches, indels
df_quast <- read.delim('data/quast-report.tsv', sep = '\t', row.names = 1) %>%
  t() %>% as.data.frame()
df_quast$Sample <- gsub('^X', '', rownames(df_quast))
df_quast <- as.tibble(df_quast)
df_quast <- df_quast[,c("Sample", "# contigs", "N50", "Genome fraction (%)", "# mismatches per 100 kbp", "# indels per 100 kbp")]

# checkm 保留
df_checkm <- read_delim('data/checkm.tsv')
df_checkm <- df_checkm[, c("Bin Id", "0", "Completeness", "Contamination")]
df_checkm <- rename(df_checkm, Sample = "Bin Id")


# 合并数据
df_merge <- full_join(df_cgmlst, df_quast, by = "Sample")
df_merge <- full_join(df_merge, df_checkm, by = "Sample")
df_merge <- rename(df_merge, 
                   "cgMLST missing" = "missing", 
                   "checkM 0" = "0",
                   "Genome fraction Pct" = "Genome fraction (%)")
df_merge <- df_merge %>%
  mutate(
    N50 = as.numeric(N50),
    `Genome fraction Pct` = as.numeric(`Genome fraction Pct`),
    `# mismatches per 100 kbp` = as.numeric(`# mismatches per 100 kbp`),
    `# indels per 100 kbp` = as.numeric(`# indels per 100 kbp`),
    `# contigs` = as.numeric(`# contigs`),
  )
df_merge$Group <- sapply(strsplit(df_merge$Sample, '_'), function(x) x[2])


# 绘图
# 生成两两组合的列表
combinations <- combn(c("HYB", "IL", "R10", "R9"), 2, simplify = FALSE)
# 创建一个空列表存放所有的ggplot对象
plots <- list()
for (var in colnames(df_merge)[2:10]) {
  # 为每一列数据创建箱线图
  p <- ggboxplot(df_merge, x = "Group", y = var,
                  color = "Group", add = "jitter") +
    stat_compare_means(comparisons = combinations, 
                       label = "p.signif", method = "t.test") +
    labs(y = NULL, x = NULL, title = var) +
    theme_classic2() +
    theme(legend.position = "none")
# 将每个箱线图添加到plots列表中
  plots[[var]] <- p
}
# 使用grid.arrange将所有子图排列起来
do.call(grid.arrange, c(plots, nrow = 3, ncol = 3))
