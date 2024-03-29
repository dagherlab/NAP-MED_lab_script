
library(data.table)

args <- commandArgs(trailingOnly = TRUE)

GO_num <- data.frame(fread(args[1]))
GO_num$FID_IID <- paste(GO_num$FID,GO_num$IID, sep = "_")

het_outlier <- data.frame(fread("log/HETEROZYGOSITY_OUTLIERS.txt",header=F))[,c(1,2)]
colnames(het_outlier) <- c("FID","IID")
het_outlier$FID_IID <- paste(het_outlier$FID,het_outlier$IID, sep = "_")

het_outlier$HET <- "Fail"
after_het <- merge(GO_num[c("FID_IID","GOnum")],unique(het_outlier[c("FID_IID","HET")]), all.x = TRUE)
after_het[is.na(after_het$HET),]$HET <- "Pass"

miss <- data.frame(fread("log/CALL_RATE_OUTLIERS.txt",header=F))
colnames(miss) <- c("FID","IID")
miss$FID_IID <- paste(miss$FID,miss$IID, sep = "_")
miss$MISS <- "Fail"
after_miss <- merge(after_het,unique(miss[c("FID_IID","MISS")]), all.x = TRUE)
after_miss[is.na(after_miss$MISS),]$MISS <- "Pass"
after_miss[which(after_het$HET == "Fail"),]$MISS <- "Excluded earlier"


sex <- data.frame(fread("log/GENDER_FAILURES.txt",header=F))[,c(1,2)]
colnames(sex) <- c("FID","IID")
sex$FID_IID <- paste(sex$FID,sex$IID, sep = "_")
sex$GENDER_MISMATCH <- "Fail"
after_gender <- merge(after_miss,unique(sex[c("FID_IID","GENDER_MISMATCH")]), all.x = TRUE)
after_gender[is.na(after_gender$GENDER_MISMATCH),]$GENDER_MISMATCH <- "Pass"
after_gender[which(after_miss$MISS == "Fail"),]$GENDER_MISMATCH <- "Excluded earlier"
after_gender[which(after_miss$MISS == "Excluded earlier"),]$GENDER_MISMATCH <- "Excluded earlier"

result <- merge(GO_num[c(1,2,3,4,6)],after_gender)

write.csv(result, "NeuroX_database.csv", quote = F, row.names = F)
