
rm(list = ls())

library("yarrr")
library("dplyr")
library("ggplot2")
library("tidyr")
library(introdataviz)

infile <- "APG_ref_cent_length.txt"
data <- read.csv(infile, header=TRUE, sep="\t")
chrom_order <- c("chr1", "chr2", "chr3", "chr4", "chr5", "chr6", "chr7", 
                 "chr8", "chr9", "chr10", "chr11", "chr12", "chr13", "chr14", 
                 "chr15", "chr16", "chr17", "chr18", "chr19", "chr20", "chr21", "chr22", 'chrX', 'chrY')
data$chrom <- factor(data$chrom, levels = chrom_order)
data <- data %>% mutate(cen_len = len /1000000)


completedata <- data %>% 
  filter(project != "Ref") %>% 
  filter(gapless != 0) %>% 
  filter(filterflag != 1)

filterdata <- data %>%
  filter(project != "Ref") %>% 
  filter(filterflag != 1)

refdata <- data %>% 
  filter(project == "Ref") %>% 
  mutate(
    color = case_when(
      sample == "CHM13" ~ "#008C8C",#65B1AF#008C8C
      sample == "CN1" ~ "#fdb462",#E85827
      sample == "HG002" ~ "#b3de69",#D8DB15
      sample == "YAO" ~ "#bc80bd"#AD218A
    ),
    shape = case_when(
      sample == "CHM13" ~ 23,  # 菱形
      sample == "CN1" & hap == "Mat" ~ 23,  # 菱形
      sample == "CN1" & hap == "Pat" ~ 22,  # 正方形
      sample == "HG002" & hap == "Mat" ~ 23,  # 菱形
      sample == "HG002" & hap == "Pat" ~ 22,  # 正方形
      sample == "YAO" & hap == "Mat" ~ 23,  # 菱形
      sample == "YAO" & hap == "Pat" ~ 22,  # 正方形
    )
  )

######show centromere with gaps and without gaps#####
ggplot(filterdata, aes(chrom, cen_len)) +
  geom_violin(scale = "width")+
  geom_jitter(aes(color = factor(gapless)), 
              width = 0.1, height = 0, alpha = 0.5) +
  scale_color_manual(values = c("0" = "#C2B2A2", "1" = "#86A201")) +
  theme_minimal() +
  labs(color = "Gapless")

#######simplest figure with complete centromeres#####
ggplot(completedata, aes(chrom, cen_len)) +
  geom_violin(scale = "width")+
  geom_jitter( width = 0.1, height = 0, alpha = 0.3, shape = 21, fill = "#525252", color = "#525252") +
  theme_minimal() 

######## main article fig2a ########
pdf("APG_centromere_length_main_fig2a_v1.pdf", width = 12, height = 4)
ggplot(completedata, aes(chrom, cen_len)) +
  
  geom_jitter(width = 0.1, height = 0, alpha = 0.3, shape = 21, fill = "white", color = "#525252") +
  geom_point(
    data = refdata,
    aes(chrom, cen_len, shape = factor(shape), fill = color),
    size = 2.5,
    position = position_nudge(x = 0),
    color = "black"
  ) +
  scale_shape_manual(values = c(22, 23)) +
  scale_fill_identity() + 
  theme_classic()+
  theme(legend.position = "none",
        axis.title.x = element_blank(),
        axis.title.y = element_text(size = 12, face = "plain",color= "black"),
        axis.text.x = element_text(size = 12, face = "plain",color= "black"),
        axis.text.y = element_text(size = 12, face = "plain",color= "black")) + 
  labs(x = "", y = "Centromere Length (Mb)")+
  annotate("point", x = 23.3, y = 40, shape = 22, size = 3, fill = "white", color = "black") + 
  annotate("text", x = 24, y =40 , label = "Pat", size = 3.5, color = "black")+
  annotate("point", x = 23.3, y = 38.5, shape = 23, size = 3, fill = "white", color = "black") + 
  annotate("text", x = 24, y =38.5 , label = "Mat", size = 3.5, color = "black")+
  annotate("point", x = 23.3, y = 37, shape = 21, size = 2.5, fill = "#008C8C", color = "#008C8C") + 
  annotate("text", x = 24, y = 37, label = "CHM13", size = 3.5, color = "black") + 
  annotate("point", x = 23.3, y = 35.5, shape = 21, size = 2.5, fill = "#fdb462", color = "#fdb462") + 
  annotate("text", x = 24, y = 35.5, label = "CN1", size = 3.5, color = "black") +
  annotate("point", x = 23.3, y = 34, shape = 21, size = 2.5, fill = "#b3de69", color = "#b3de69") + 
  annotate("text", x = 24, y = 34, label = "HG002", size = 3.5, color = "black") +
  annotate("point", x = 23.3, y = 32.5, shape = 21, size = 2.5, fill = "#bc80bd", color = "#bc80bd") + 
  annotate("text", x = 24, y = 32.5, label = "YAO", size = 3.5, color = "black")+
  geom_violin(scale = "width",fill = NA, color = "black")
dev.off()

