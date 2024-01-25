################################################################################
# cgMLST等位基因, 样本, 分组 热图
################################################################################
library(tidyverse)
library(RColorBrewer)
library(pheatmap)


df <- read_tsv('data/cgMLST.tsv')

# 去除文件名和 cgMLST 中的 '.fasta'
df$FILE <- gsub('.fasta', '', df$FILE)
colnames(df) <- gsub('.fasta', '', colnames(df))

# 删除 cgmlst 值相同的列
df <- df %>%
  select(-names(which(sapply(df, n_distinct) <= 2)))

# 格式化 dataframe
df <- as.data.frame(df)
rownames(df) <- df$FILE
df <- df %>% 
  select(-1)
df <- as.matrix(df)

# png('figure/cgmlst.png', width = 800, height = 1200, res = 150)

# 添加分组
# mygrp <- sapply(strsplit(rownames(df), '_'), function(x) x[2]) %>% 
#   as.factor() %>% 
#   as.numeric()
# row_colors <- brewer.pal(9, "Set1")[mygrp]
# heatmap 热图, 删除行进化树
# heatmap(df, Colv = NA, RowSideColors = row_colors, 
#              xlab = 'Sample', ylab = 'Allele', main = 'cgMLST',
#              margins = c(6,8))

# pheatmap 分组
mygrp <- sapply(strsplit(rownames(df), '_'), function(x) x[2]) %>% 
  as.factor()
df_anno_row <- data.frame(SampleGroup = mygrp)
rownames(df_anno_row) <- rownames(df)
# pheatmap 热图
# 1.删除行进化树;2.行注释(分组);3.删除注释行名,注释图例,热图主图例
pheatmap(df,
         cluster_rows = TRUE,
         cluster_cols = FALSE,
         fontsize_col = 8,
         angle_col = 90,
         main = 'cgMLST Sample-Allele Heatmap',
         annotation_row = df_anno_row,
         annotation_legend = FALSE,
         annotation_names_row = FALSE,
         legend = FALSE)
# dev.off()
