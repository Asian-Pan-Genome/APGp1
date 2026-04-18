library(ggplot2)
library(ggfortify)
library(useful)

pca <- read.table("./pca_full.class_v1.eigenvec", sep=" ", header = FALSE, comment.char = "", check.names = FALSE)
names(pca)[1] <- "ind"
names(pca)[2] <- "ids"
names(pca)[3:ncol(pca)] <- paste0("PC", 1:(ncol(pca)-2))
b <- ggplot(pca, aes(PC1, PC2, color=cls)) +
geom_point(size=0.2) +
coord_equal()
b
ggsave("pca_cls_v1.pdf")