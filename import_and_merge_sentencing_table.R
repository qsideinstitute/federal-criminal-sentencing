#' These are some lines to import the Sentencing Table and merge it with the
#' sentencing data. This opens an alternative direction for modeling: rather 
#' than treating each grid cell as its own category, we can control for  the 
#' min or max recommended sentence length, and then see what explains values 
#' that deviate from that. This has the advantage of having far fewer 
#' parameters, but has the possible disadvantage of assuming that the Sentencing
#' Table is  meaningful, i.e., it takes that table seriously in assuming that 
#' it ought to be a good baseline empirical description of judges' behavior. 
#' This may or may not be an assumption we want to make.

df <- read.csv("cleaned_data_renamed.csv")

sentencing_table <- as.data.frame(tidyr::pivot_longer(read.csv("Sentencing_Table.csv"), 
                                                      cols = c("I", "II", "III", "IV", "V", "VI")))
names(sentencing_table)[names(sentencing_table)=="X"] <- "all_adjustments"
names(sentencing_table)[names(sentencing_table)=="name"] <- "criminal_history"
sentencing_table$criminal_history <- factor(sentencing_table$criminal_history,
                                            labels = 1:6, 
                                            levels = c("I", "II", "III", "IV", "V", "VI"))
sentencing_table$criminal_history <- as.numeric(sentencing_table$criminal_history)
dash <- substr(sentencing_table$value[1], 2,2)
sentencing_table$value <- gsub("life", "470", sentencing_table$value)
sentencing_table <- cbind(sentencing_table, 
                          Reduce(rbind, strsplit(sentencing_table$value, dash)))
names(sentencing_table)[names(sentencing_table)=="1"] <- "guideline_range_min"
names(sentencing_table)[names(sentencing_table)=="2"] <- "guideline_range_max"
sentencing_table$guideline_range_min <- as.integer(sentencing_table$guideline_range_min)
sentencing_table$guideline_range_max <- as.integer(sentencing_table$guideline_range_max)
rownames(sentencing_table) <- NULL
sentencing_table$value <- NULL

# In order to merge the two dataframes, we need to convert the columns to numeric. 
df$all_adjustments <- as.integer(df$all_adjustments)
df$criminal_history <- as.integer(df$criminal_history)

df <- dplyr::left_join(df, sentencing_table)

# Once merged, we can convert back to factors (although we may not want to 
# use all_adjustments or criminal_history when we have the min and max from
# sentencing guidelines.)
df$all_adjustments <- factor(df$all_adjustments)
df$criminal_history <- factor(df$criminal_history)
