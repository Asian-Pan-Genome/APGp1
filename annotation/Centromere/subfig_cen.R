
rm(list = ls())

library("dplyr")
library("ggplot2")
library("tidyr")
library(patchwork)
library(cowplot)

f_gapless <- "gapless_cent_num.txt"
df_gapless <- read.csv(f_gapless, header=TRUE, sep="\t")
chrom_order <- c("chr1", "chr2", "chr3", "chr4", "chr5", "chr6", "chr7", 
                 "chr8", "chr9", "chr10", "chr11", "chr12", "chr13", "chr14", 
                 "chr15", "chr16", "chr17", "chr18", "chr19", "chr20", "chr21", "chr22", 'chrX', 'chrY')

head(df_gapless,10)

df_long <- pivot_longer(df_gapless, cols = c(gapless_cent, cent_with_gap),
                        names_to = "category", values_to = "count")
df_long$chrom <- factor(df_long$chrom, levels = chrom_order)

p1 <- ggplot(df_long, aes(x = chrom, y = count, fill = category)) +
  geom_bar(stat = "identity", position = "stack") +
  labs(x = "", y = "The number of centromeres", fill = NULL) +
  theme_classic() +
  scale_fill_manual(values = c("gapless_cent" = "#1b7837", 
                               "cent_with_gap" = "grey"),
                    labels = c("gapless_cent" = "gapless",
                               "cent_with_gap" = "gap")) +
  theme(legend.position = "none",
        axis.title.x = element_text(size = 12, face = "plain", color = "black"),
        axis.title.y = element_text(size = 12, face = "plain", color = "black"),
        axis.text.x = element_text(size = 12, face = "plain", color = "black"),
        axis.text.y = element_text(size = 12, face = "plain", color = "black")) + 
  coord_flip()
print(p1)

f_cent_ratio <- "APG_cent_percent_each_chromsome.txt"
df_ratio  <- read.csv(f_cent_ratio, header=TRUE, sep="\t")
df_ratio <- df_ratio %>% mutate(percent = percentage * 100)
df_ratio$chrom <- factor(df_ratio$chrom, levels = chrom_order)
head(df_ratio,10)


completedata <- df_ratio %>% 
  filter(project != "Ref") %>% 
  filter(gapless != 0) %>% 
  filter(filterflag != 1)

refdata <- df_ratio %>% 
  filter(project == "Ref") %>% 
  mutate(
    color = case_when(
      sample == "CHM13" ~ "#008C8C",
      sample == "CN1" ~ "#fdb462",
      sample == "HG002" ~ "#b3de69",
      sample == "YAO" ~ "#bc80bd"
    ),
    shape = case_when(
      sample == "CHM13" ~ 23,
      sample == "CN1" & hap == "Mat" ~ 23, 
      sample == "CN1" & hap == "Pat" ~ 22,  
      sample == "HG002" & hap == "Mat" ~ 23,  
      sample == "HG002" & hap == "Pat" ~ 22, 
      sample == "YAO" & hap == "Mat" ~ 23,
      sample == "YAO" & hap == "Pat" ~ 22,
    )
  )


p2 <- ggplot(completedata, aes(chrom, percent)) +
  geom_jitter(width = 0.1, height = 0, alpha = 0.3, shape = 21, fill = "white", color = "#525252") +
  geom_point(
    data = refdata,
    aes(chrom, percent, shape = factor(shape), fill = color),
    size = 2.5,
    position = position_nudge(x = 0),
    color = "black"
  ) +
  scale_shape_manual(values = c(22, 23)) +
  scale_fill_identity() + 
  theme_classic()+
  theme(legend.position = "none",
        axis.title.x = element_text(size = 12, face = "plain", color = "black"),
        axis.title.y = element_text(size = 12, face = "plain",color= "black"),
        axis.text.x = element_text(size = 12, face = "plain",color= "black"),
        axis.text.y = element_text(size = 12, face = "plain",color= "black")) + 
  labs(x = "", y = "% of chromosome size")+
  geom_violin(scale = "width",fill = NA, color = "black")+coord_flip()+
  scale_y_continuous(
    breaks = seq(0, 50, by = 10),  
    limits = c(0, 50)
  )
print(p2)

p2 <- p2+
  annotate("point", x = 23.3, y = 44, shape = 22, size = 3, fill = "white", color = "black") + 
  annotate("text", x = 24, y =44 , label = "Pat", size = 3.5, color = "black")+
  annotate("point", x = 23.3, y = 41.5, shape = 23, size = 3, fill = "white", color = "black") + 
  annotate("text", x = 24, y =41.5 , label = "Mat", size = 3.5, color = "black")+
  annotate("point", x = 23.3, y = 39, shape = 21, size = 2.5, fill = "#008C8C", color = "#008C8C") + 
  annotate("text", x = 24, y = 39, label = "CHM13", size = 3.5, color = "black") + 
  annotate("point", x = 23.3, y = 36.5, shape = 21, size = 2.5, fill = "#fdb462", color = "#fdb462") + 
  annotate("text", x = 24, y = 36.5, label = "CN1", size = 3.5, color = "black") +
  annotate("point", x = 23.3, y = 34, shape = 21, size = 2.5, fill = "#b3de69", color = "#b3de69") + 
  annotate("text", x = 24, y = 34, label = "HG002", size = 3.5, color = "black") +
  annotate("point", x = 23.3, y = 31.5, shape = 21, size = 2.5, fill = "#bc80bd", color = "#bc80bd") + 
  annotate("text", x = 24, y = 31.5, label = "YAO", size = 3.5, color = "black")+
  geom_violin(scale = "width",fill = NA, color = "black")+coord_flip()
print(p2)

f_cent_cv <- "APG_cent_len_cv.txt"
df_cv <- read.csv(f_cent_cv, header=TRUE, sep="\t")
df_cv$chrom <- factor(df_cv$chrom, levels = chrom_order)
p3<- ggplot(df_cv, aes(x = chrom, y = cv_cen_len)) +
  geom_bar(stat = "identity", fill = "#bdbdbd", color = "black") +
  labs(x = "", y = "CV of centromere length") +
  theme_classic() +
  theme(
    axis.title.x = element_text(size = 12, face = "plain", color = "black"),
    axis.title.y = element_text(size = 12, face = "plain", color = "black"),
    axis.text.x = element_text(size = 12, face = "plain", color = "black"),
    axis.text.y = element_text(size = 12, face = "plain", color = "black")
  )+coord_flip()

print(p3)


f_sat_len <- "APG_ref_sat_length.txt"
df_sat_len <- read.csv(f_sat_len, header=TRUE, sep="\t")
df_sat_len$chrom <- factor(df_sat_len$chrom, levels = chrom_order)
print(unique(df_sat_len$chrom))


apg_sat_len <- df_sat_len %>% filter(project == "APG") %>% 
  filter(gapless != 0) %>% 
  filter(filterflag != 1)
ref_sat_len <- df_sat_len %>% filter(project == "Ref") %>% 
  mutate(
    color = case_when(
      sample == "CHM13" ~ "#008C8C",
      sample == "CN1" ~ "#fdb462",
      sample == "HG002" ~ "#b3de69",
      sample == "YAO" ~ "#bc80bd"
    ),
    shape = case_when(
      sample == "CHM13" ~ 23,
      sample == "CN1" & hap == "Mat" ~ 23, 
      sample == "CN1" & hap == "Pat" ~ 22,  
      sample == "HG002" & hap == "Mat" ~ 23,  
      sample == "HG002" & hap == "Pat" ~ 22, 
      sample == "YAO" & hap == "Mat" ~ 23,
      sample == "YAO" & hap == "Pat" ~ 22,
    )
  )
head(ref_sat_len,10)

##alpha satellite
apg_asat_len <- apg_sat_len %>% filter(satellite == "ASat") %>% mutate(sat_len = length / 1000000)
ref_asat_len <- ref_sat_len %>% filter(satellite == "ASat") %>% mutate(sat_len = length / 1000000)
print(unique(apg_asat_len$chrom))
print(unique(ref_asat_len$chrom))

##hsat1 satellite
apg_hsat1_len <- apg_sat_len %>% filter(satellite %in% c("HSat1A", "HSat1B")) %>% 
  group_by(sample_hap_chrom, chrom) %>% 
  summarise(sat_len = sum(length) / 1000000)
ref_hsat1_len <- ref_sat_len %>% filter(satellite %in% c("HSat1A", "HSat1B")) %>% 
  group_by(sample_hap_chrom, chrom, color, shape) %>% 
  summarise(sat_len = sum(length) / 1000000)

unique_chroms <- unique(apg_hsat1_len$chrom)
missing_chroms <- setdiff(chrom_order, unique_chroms)
missing_rows <- data.frame(
  sample_hap_chrom = NA,  
  chrom = missing_chroms,
  sat_len = 0
)
apg_hsat1_len_complete <- rbind(apg_hsat1_len, missing_rows)
apg_hsat1_len_complete$chrom <- factor(apg_hsat1_len_complete$chrom, levels = chrom_order)
ref_hsat1_len_complete <- rbind(ref_hsat1_len, missing_rows)
ref_hsat1_len_complete$chrom <- factor(ref_hsat1_len_complete$chrom, levels = chrom_order)
head(apg_hsat1_len_complete,10)
head(ref_hsat1_len_complete,10)

##hsat2 satellite
apg_hsat2_len <- apg_sat_len %>% filter(satellite == "HSat2") %>% 
  select(sample_hap_chrom, chrom, length) %>% mutate(sat_len = length / 1000000)
ref_hsat2_len <- ref_sat_len %>% filter(satellite == "HSat2") %>% 
  select(sample_hap_chrom, chrom, length, color, shape) %>% mutate(sat_len = length / 1000000)
unique_chroms <- unique(apg_hsat2_len$chrom)
missing_chroms <- setdiff(chrom_order, unique_chroms)
missing_rows <- data.frame(
  sample_hap_chrom = NA, 
  chrom = missing_chroms,
  length = 0,
  sat_len = 0
)
apg_hsat2_len_complete <- rbind(apg_hsat2_len, missing_rows)
apg_hsat2_len_complete$chrom <- factor(apg_hsat2_len_complete$chrom, levels = chrom_order)
missing_rows <- data.frame(
  sample_hap_chrom = NA, 
  chrom = missing_chroms,
  length = 0,
  sat_len = 0, color=NA, shape=NA
)
ref_hsat2_len_complete <- rbind(ref_hsat2_len, missing_rows)
ref_hsat2_len_complete$chrom <- factor(ref_hsat2_len_complete$chrom, levels = chrom_order)



##hsat3 satellite
apg_hsat3_len <- apg_sat_len %>% filter(satellite == "HSat3") %>% 
  select(sample_hap_chrom, chrom, length) %>% mutate(sat_len = length / 1000000)
ref_hsat3_len <- ref_sat_len %>% filter(satellite == "HSat3") %>% 
  select(sample_hap_chrom, chrom, length, color, shape) %>% mutate(sat_len = length / 1000000)
head(apg_hsat3_len)
head(ref_hsat3_len)


unique_chroms <- unique(apg_hsat3_len$chrom)
missing_chroms <- setdiff(chrom_order, unique_chroms)
missing_rows <- data.frame(
  sample_hap_chrom = NA, 
  chrom = missing_chroms,
  length=0,
  sat_len = 0
)
apg_hsat3_len_complete <- rbind(apg_hsat3_len, missing_rows)
apg_hsat3_len_complete$chrom <- factor(apg_hsat3_len_complete$chrom, levels = chrom_order)
missing_rows <- data.frame(
  sample_hap_chrom = NA, 
  chrom = missing_chroms, length=0,
  sat_len = 0, color=NA, shape=NA
)
ref_hsat3_len_complete <- rbind(ref_hsat3_len, missing_rows)
ref_hsat3_len_complete$chrom <- factor(ref_hsat3_len_complete$chrom, levels = chrom_order)


##plot asat
p4 <- ggplot(apg_asat_len, aes(chrom, sat_len)) +
  geom_jitter(width = 0.1, height = 0, alpha = 0.3, shape = 21, fill = "white", color = "#525252") +
  geom_point(
    data = ref_asat_len,
    aes(chrom, sat_len, shape = factor(shape), fill = color),
    size = 2.5,
    position = position_nudge(x = 0),
    color = "black"
  ) +
  scale_shape_manual(values = c(22, 23)) +
  scale_fill_identity() + 
  theme_classic()+
  theme(legend.position = "none",
        axis.title.x = element_text(size = 12, face = "plain", color = "black"),
        axis.title.y = element_text(size = 12, face = "plain",color= "black"),
        axis.text.x = element_text(size = 12, face = "plain",color= "black"),
        axis.text.y = element_text(size = 12, face = "plain",color= "black")) + 
  labs(x = "", y = "ASat length(Mb)") +
  geom_violin(scale = "width",fill = NA, color = "black")+coord_flip()+
  scale_y_continuous(
    breaks = seq(0, 12, by = 2),  
    limits = c(0, 12)
  )
print(p4)


p5 <- ggplot(apg_hsat1_len_complete, aes(chrom, sat_len)) +
  geom_jitter(width = 0.1, height = 0, alpha = 0.3, shape = 21, fill = "white", color = "#525252") +
  geom_point(
    data = ref_hsat1_len_complete,
    aes(chrom, sat_len, shape = factor(shape), fill = color),
    size = 2.5,
    position = position_nudge(x = 0),
    color = "black"
  ) +
  scale_shape_manual(values = c(22, 23)) +
  scale_fill_identity() + 
  theme_classic()+
  theme(legend.position = "none",
        axis.title.x = element_text(size = 12, face = "plain", color = "black"),
        axis.title.y = element_text(size = 12, face = "plain",color= "black"),
        axis.text.x = element_text(size = 12, face = "plain",color= "black"),
        axis.text.y = element_text(size = 12, face = "plain",color= "black")) + 
  labs(x = "", y = "HSat1 length(Mb)") +
  geom_violin(scale = "width",fill = NA, color = "black")+coord_flip()+
  scale_y_continuous(
    breaks = seq(0, 10, by = 2),  
    limits = c(0, 10)
  )

print(p5)

p6 <- ggplot(apg_hsat2_len_complete, aes(chrom, sat_len)) +
  geom_jitter(width = 0.1, height = 0, alpha = 0.3, shape = 21, fill = "white", color = "#525252") +
  geom_point(
    data = ref_hsat2_len_complete,
    aes(chrom, sat_len, shape = factor(shape), fill = color),
    size = 2.5,
    position = position_nudge(x = 0),
    color = "black"
  ) +
  scale_shape_manual(values = c(22, 23)) +
  scale_fill_identity() + 
  theme_classic()+
  theme(legend.position = "none",
        axis.title.x = element_text(size = 12, face = "plain", color = "black"),
        axis.title.y = element_text(size = 12, face = "plain",color= "black"),
        axis.text.x = element_text(size = 12, face = "plain",color= "black"),
        axis.text.y = element_text(size = 12, face = "plain",color= "black")) + 
  labs(x = "", y = "HSat2 length(Mb)") +
  geom_violin(scale = "width",fill = NA, color = "black")+coord_flip()
print(p6)


p7 <- ggplot(apg_hsat3_len_complete, aes(chrom, sat_len)) +
  geom_jitter(width = 0.1, height = 0, alpha = 0.3, shape = 21, fill = "white", color = "#525252") +
  geom_point(
    data = ref_hsat3_len_complete,
    aes(chrom, sat_len, shape = factor(shape), fill = color),
    size = 2.5,
    position = position_nudge(x = 0),
    color = "black"
  ) +
  scale_shape_manual(values = c(22, 23)) +
  scale_fill_identity() + 
  theme_classic()+
  theme(legend.position = "none",
        axis.title.x = element_text(size = 12, face = "plain", color = "black"),
        axis.title.y = element_text(size = 12, face = "plain",color= "black"),
        axis.text.x = element_text(size = 12, face = "plain",color= "black"),
        axis.text.y = element_text(size = 12, face = "plain",color= "black")) + 
  labs(x = "", y = "Hsat3 length(Mb)") +
  geom_violin(scale = "width",fill = NA, color = "black")+coord_flip()+
  scale_y_continuous(
    breaks = seq(0, 30, by = 10),  
    limits = c(0, 30)
  )
print(p7)

pdf("APG_centromere_length_main_subfig.pdf", width = 18, height = 12)
#final_plot <- (p1 | p3 | p2 | p4| p5| p6| p7)
final_plot <- (p1 | p3 | p2 | p4 | p5 | p6 | p7) + 
  plot_layout(widths = c(2, 2, 3, 3, 3, 3, 3))

print(final_plot)
dev.off()