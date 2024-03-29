
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

euro <- data.frame(fread("PCA_filtered_europeans.txt",header=F))
colnames(euro) <- c("FID","IID")
euro$ANCESTRY <- "EUROPEAN"

asian <- data.frame(fread("PCA_filtered_asians.txt",header=F))
colnames(asian) <- c("FID","IID")
asian$ANCESTRY <- "ASIAN"

afr <- data.frame(fread("PCA_filtered_africans.txt",header=F))
colnames(afr) <- c("FID","IID")
afr$ANCESTRY <- "AFRICAN"

mixed <- data.frame(fread("PCA_filtered_mixed_race.txt",header=F))
colnames(mixed) <- c("FID","IID")
mixed$ANCESTRY <- "MIXED_RACE"

ancestry <- rbind(euro,asian,afr,mixed)
ancestry$FID_IID <- paste(ancestry$FID,ancestry$IID, sep = "_")

after_ancestry <- merge(after_gender,unique(ancestry[c("FID_IID","ANCESTRY")]), all.x = TRUE)
after_ancestry[which(after_gender$GENDER_MISMATCH == "Fail"),]$ANCESTRY <- "Excluded earlier"
after_ancestry[which(after_gender$GENDER_MISMATCH == "Excluded earlier"),]$ANCESTRY <- "Excluded earlier"


unrelated <- data.frame(fread("log/IDs_after_relatedness_filter.txt",header=F))[,c(1,2)]
colnames(unrelated) <- c("FID","IID")
unrelated$FID_IID <- paste(unrelated$FID,unrelated$IID, sep = "_")

unrelated$RELATEDNESS <- "Unrelated"
fam <- data.frame(fread("relatedness_results.family.txt",header=F))
colnames(fam) <- c("FID1","IID1","FID2","IID2","PIHAT")
fam$FID_IID1 <- paste(fam$FID1,fam$IID1, sep = "_")
fam$FID_IID2 <- paste(fam$FID2,fam$IID2, sep = "_")

dup <- subset(fam, PIHAT > 0.8)
dup$LABEL <- 1:nrow(dup)
dup_id <- unique(c(dup$FID_IID1,dup$FID_IID2))
dup_exclude_unrelated <- dup_id[!(dup_id %in% unrelated$FID_IID)]

related <- subset(fam, PIHAT <= 0.8)
related$LABEL <- 1:nrow(related)
related_id <- unique(c(related$FID_IID1,related$FID_IID2))
related_exclude_unrelated <- related_id[!(related_id %in% unrelated$FID_IID)]


go_dup1 <- merge(dup[c("FID_IID1","LABEL")], after_ancestry[c("FID_IID","GOnum")], by.x = c("FID_IID1"), by.y = c("FID_IID"))
colnames(go_dup1)[3] <- "GO1"
go_dup2 <- merge(dup[c("FID_IID2","LABEL")], after_ancestry[c("FID_IID","GOnum")], by.x = c("FID_IID2"), by.y = c("FID_IID"))
colnames(go_dup2)[3] <- "GO2"
go_dup <- merge(go_dup1,go_dup2)
go_dup_check <- subset(go_dup, GO1 != GO2)

if(nrow(go_dup_check) > 0){
    for(i in 1:nrow(go_dup_check)){
	    GO_num1 <- go_dup_check[i,c(2,3)]
	    GO_num2 <- go_dup_check[i,c(4,5)]
	    if(GO_num1$GO1 < GO_num2$GO2){
		    after_ancestry[after_ancestry$FID_IID == GO_num2$FID_IID2,]$GOnum <- GO_num1$GO1
	    } else {
		    after_ancestry[after_ancestry$FID_IID == GO_num1$FID_IID1,]$GOnum <- GO_num2$GO2
	    }
    }
}


after_unrelated <- merge(after_ancestry,unrelated[c("FID_IID","RELATEDNESS")], all.x = TRUE)
after_unrelated[which(after_unrelated$FID_IID %in% related_exclude_unrelated),]$RELATEDNESS <- "Related"
after_unrelated[which(after_unrelated$FID_IID %in% dup_exclude_unrelated),]$RELATEDNESS <- "Duplicate"
after_unrelated[which(after_ancestry$ANCESTRY == "ASIAN"),]$RELATEDNESS <- "Non-European"
after_unrelated[which(after_ancestry$ANCESTRY == "AFRICAN"),]$RELATEDNESS <- "Non-European"
after_unrelated[which(after_ancestry$ANCESTRY == "MIXED_RACE"),]$RELATEDNESS <- "Non-European"
after_unrelated[which(after_ancestry$ANCESTRY == "Excluded earlier"),]$RELATEDNESS <- "Excluded earlier"

result <- merge(GO_num[c(1,2,3,4,6)],after_unrelated)

write.csv(result, "NeuroX_database.csv", quote = F, row.names = F)
