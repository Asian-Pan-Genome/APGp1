setwd("/share/home/zhanglab/user/sunyanqing/human/anno/statistics/satellite_length")
rm(list = ls())

library("dplyr")
library("tidyr")
library("tidyverse")
library("ggplot2")
library("patchwork")
library("pheatmap")
library(ggnewscale)
library(gridExtra)
library(ggthemes)
library(see)
library(scales)

df_cen <- read.csv("../centhap/cent_chrom.txt", header=TRUE, sep="\t")
head(df_cen)

filter_chrs = c(
  'C020-CHA-E20#Mat#chr6',
  'C045-CHA-N05#Mat#chr17',
  'C019-CHA-E19#Pat#chr9',
  'C076-CHA-NE16#Pat#chr14',
  'HG02666_hap2_chr15',
  'HG01114_hap1_chr16',
  'HG02769_hap2_chr20',
  'HG03452_hap1_chr4',
  'NA19036_hap2_chr14',
  'NA19434_hap2_chr20',
  'NA20847_hap2_chr17'
)

complete_df_cen <- df_cen %>%
 filter(filterflag == 0) %>% 
 filter( ! sample_hap_chrom %in% filter_chrs) %>% 
 filter(project != "Ref")
head(complete_df_cen)

chrom_order <- c("chr1", "chr2", "chr3", "chr4", "chr5", "chr6", "chr7", 
                 "chr8", "chr9", "chr10", "chr11", "chr12", "chr13", "chr14", 
                 "chr15", "chr16", "chr17", "chr18", "chr19", "chr20", "chr21", "chr22", 'chrX', 'chrY')
complete_df_cen$chrom <- factor(complete_df_cen$chrom, levels = chrom_order)

popfile <- "/share/home/zhanglab/user/sunyanqing/human/anno/statistics/centhap/populaion.xls"
popdf <- read.csv(popfile, header=TRUE, sep="\t")
popdf <- popdf %>% 
  select(c("sample", "superpopulation")) %>%
  mutate(superpopulation = str_replace(superpopulation, "EAS-APG", "EAS"))
head(popdf,10)


complete_df_cen <- complete_df_cen %>%
  left_join(popdf, by = "sample")
head(complete_df_cen, 10)

complete_df_cen$superpopulation <- factor(complete_df_cen$superpopulation, 
                                          levels = c("AFR", "AMR", "EAS", "EUR", "SAS"))

chr9_complete_cen <- complete_df_cen %>% 
  filter(chrom == "chr9") %>%
  mutate(satellite = "Cent Size") %>%  
  select("sample_hap_chrom", "sample_hap", "sample", "hap", "chrom", "satellite", "len", "project")
head(chr9_complete_cen, 10)
print(length(unique(chr9_complete_cen$sample_hap_chrom)))

chr9_refdata <- refdata %>% 
  filter(chrom == "chr9")
head(chr9_refdata, 10)

sat_df <- read.csv("/share/home/zhanglab/user/sunyanqing/human/anno/statistics/satellite_length/all.sat.length.xls", sep="\t", header=TRUE)
complete_sat_df <- sat_df %>% 
  filter(chrom == "chr9",
         sample_hap_chrom %in% chr9_complete_cen$sample_hap_chrom) 
colnames(complete_sat_df) <- c("sample_hap_chrom", "sample_hap", "sample", "hap", "chrom", "satellite", "len", "project")
head(complete_sat_df)

chr9_combined_df <- bind_rows(chr9_complete_cen, complete_sat_df) %>%
  left_join(popdf, by="sample") %>%
  mutate(satellite = factor(satellite, levels = c("Cent Size", "ASat", "HSat3", "HSat2", "BSat", "GSat")))
head(chr9_combined_df,10)
print(unique(chr9_combined_df$satellite))

unique_counts <- chr9_combined_df %>%
  group_by(superpopulation) %>%
  summarise(unique_sample_hap_chrom = n_distinct(sample_hap_chrom))
print(unique_counts)

library(ggpubr)

superpopulation_colors <- c(
    "AFR" = "#319b62",
    "AMR" = "#939393",
    "EAS" = "#d22e77",
    "EAS-APG" = "#e85827",
    "EUR" = "#0070c0",
    "SAS" = "#893f8b"
)

# Plot
p <- ggplot(chr9_combined_df, aes(x = superpopulation, y = len/1e6, fill = superpopulation)) +
  geom_boxplot(outlier.shape = NA, alpha = 0.6, color = "black") +
  geom_jitter(aes(color = superpopulation),width = 0.2, alpha = 0.6, size = 1) +
  facet_wrap(~ satellite, scales = "free", nrow = 1) +
  stat_compare_means(
    method = "wilcox.test",
    label = "p.format",
    comparisons = list(
      c("AFR", "EAS")
    )
  ) +
  scale_fill_manual(values = superpopulation_colors) +
  scale_color_manual(values = superpopulation_colors) +
  theme_classic() +
  theme(
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    axis.text.x = element_text(size = 10),
    axis.text.y = element_text(size = 12),
    legend.position = "none"
  ) + labs(x ="Superpopulation", y = "Length(Mb)")

print(p)
ggsave(p, filename = "chr9_size_sat_superpopulation_sig.pdf", width = 10, height = 10)