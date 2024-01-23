################################################################################
# cgMLST等位基因, 样本, 分组 热图
################################################################################
library(tidyverse)
library(RColorBrewer)


df <- read_tsv('data/cgMLST.tsv')

# 去除文件名和 cgMLST 中的 '.fasta'
df$FILE <- gsub('.fasta', '', df$FILE)
colnames(df) <- gsub('.fasta', '', colnames(df))

# 删除 cgmlst 值相同的列
df <- df %>%
  select(-names(which(sapply(df, n_distinct) == 1)))

# 格式化 dataframe
df <- as.data.frame(df)
rownames(df) <- df$FILE
df <- df %>% 
  select(-1) %>%
  t()
df <- as.matrix(df)

# 热图, 添加分组, 删除行进化树
mygrp <- sapply(strsplit(colnames(df), '_'), function(x) x[2]) %>% 
  as.factor() %>% 
  as.numeric()
colSide <- brewer.pal(9, "Set1")[mygrp]

png('figure/cgmlst.png', width = 800, height = 1200, res = 150)
heatmap(df, Rowv = NA, ColSideColors = colSide, 
             xlab = 'Sample', ylab = 'Allele', main = 'cgMLST',
             margins = c(8,6))
dev.off()