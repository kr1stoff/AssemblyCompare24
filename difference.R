################################################################################
# 组装参数差异箱线图
# cgMLST missing
# quast 
################################################################################
library(tidyverse)
library(readr)

# cgMLST 统计文件, 去除结果中'.fasta', 删除percentage列
df_cgmlst <- read_delim('data/cgMLST-mdata_stats.tsv')
df_cgmlst$FILE <- gsub('.fasta', '', df_cgmlst$FILE)
df_cgmlst$percentage <- NULL

# quast 转置表格
df_quast <- read.delim('data/quast-report.tsv', sep = '\t', row.names = 1) %>%
  t() %>% as.data.frame()
df_quast$Sample <- rownames(df_quast)
df_quast <- as.tibble(df_quast)

# checkm 
df_checkm <- read_delim('data/checkm.tsv')
