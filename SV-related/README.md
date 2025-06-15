### A collection of SV-related scripts





#### Benchmark for SV merging approaches

We conducted the SV merging at the caller level then followed by the individual level. To determine the merge method and threshold used for caller merge, a precision-recall curve was generated across various quality scores by comparing with the GIAB SV benchmark set for HG002 against CHM13v2. Consequently, the mixed strategy (see below), bcftools merge plus SURVIVOR has the best performance. At the individual level, SURVIVOR was employed to merge SVs from different samples. After that, ‘SURVIVOR merge’ was used to cluster the adjacent SVs and remove redundancy. Finally, different SV sets were compared with each other using ‘truvari bench’.



![pipeline](./AsmSV-merge.method.png)
