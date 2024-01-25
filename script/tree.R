library(ggtree)
library(ggplot2)
library(cowplot)
library(hash)


# 配色方案
nrc_pal <- c("#E64B35FF", "#4DBBD5FF", "#00A087FF", "#3C5488FF", "#F39B7FFF",
             "#8491B4FF", "#91D1C2FF", "#DC0000FF", "#7E6148FF", "#B09C85FF")
lancet_pal <- c("#00468BFF", "#ED0000FF", "#42B540FF", "#0099B4FF",
                "#925E9FFF", "#FDAF91FF", "#AD002AFF", "#ADB6B6FF", "#1B1919FF")

# 导入数据
tree <- read.tree('./data/Brucella_suis.tre')
# data <- fortify(tree)


# 分组
# 按组装策略
group <- sapply(strsplit(tree$tip.label, '_'), function(x) x[2])
# 按样本
# group <- sapply(strsplit(tree$tip.label, '_'), function(x) x[1])

# 按类分组
groupInfo <- split(tree$tip.label, group)
# 将分组信息添加到树中
tree <- groupOTU(tree, groupInfo)


# 绘制进化树
# 分组
# set.seed(123)
group_colors <- sample(lancet_pal, size = 6)
names(group_colors) <- unique(group)
# 等距直方
ggtree(tree, ladderize = FALSE, branch.length = "none", aes(color=group)) +
  geom_tiplab(size=3) +
  labs(title = 'cgSNP Phylogenetic Tree') +
  # 限制进化树高度宽度
  coord_cartesian(xlim = c(0, 10), ylim = c(0, 24)) +
  # 分组颜色
  scale_color_manual(values = group_colors, breaks = names(group_colors)) +
  # 图例位置, 删除图例标题
  theme(legend.position = "bottom", legend.title = element_blank())
