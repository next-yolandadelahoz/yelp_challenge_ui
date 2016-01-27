library(jsonlite)


## Load data ################################################################################################################

readmyJSON <- function(myfile){
  df <- fromJSON(sprintf("[%s]", paste(readLines(myfile), collapse=",")))
  # Pagesize represents how many number of lines it reads in one iteration
  df <- stream_in(file(myfile), pagesize = 10000)
  dim(df)
  names(df)
  df
}


business.df <- readmyJSON('./yelp_dataset/yelp_academic_dataset_business.json')
saveRDS(business.df, file="./yelp_dataset/business.RData")

checkin.df <- readmyJSON('./yelp_dataset/yelp_academic_dataset_checkin.json')
saveRDS(checkin.df, file="./yelp_dataset/checkin.RData")

review.df <- readmyJSON('./yelp_dataset/yelp_academic_dataset_review.json')
saveRDS(review.df, file="./yelp_dataset/review.RData")

tip.df <- readmyJSON('./yelp_dataset/yelp_academic_dataset_tip.json')
saveRDS(tip.df, file="./yelp_dataset/tip.RData")

user.df <- readmyJSON('./yelp_dataset/yelp_academic_dataset_user.json')
saveRDS(user.df, file="./yelp_dataset/user.RData")

if(!exists("business.df")) business.df <- readRDS("./yelp_dataset/business.RData")
if(!exists("checkin.df")) checkin.df  <- readRDS("./yelp_dataset/checkin.RData")
if(!exists("tip.df")) tip.df <- readRDS("./yelp_dataset/tip.RData")
if(!exists("user.df")) user.df <- readRDS("./yelp_dataset/user.RData")

#Read json file
require(jsonlite)
#See http://www.r-bloggers.com/iterators-in-r/
require(itertools)
myfile <- './yelp_dataset/yelp_academic_dataset_review.json'
con <- ihasNext(ireadLines(myfile))

df <- data.frame()
numfile <- 1

#process each line and store in raw CSV
while (hasNext(con)) {
  d <- nextElem(con)
  df <- as.data.frame(fromJSON(d))
  saveRDS(df, file=paste("./yelp_dataset/reviews", numfile, ".rds", sep=""))
  numfile <- numfile+1
}

#read files and merge
#See http://www.r-bloggers.com/merging-multiple-data-files-into-one-data-frame/
multmerge <- function(){
  myfiles <- list.files(path="./yelp_dataset/reviews/", pattern=".rds", full.names = T)
  datalist <- lapply(myfiles, function(x){readRDS(file=x)})
  Reduce(function(x,y) {merge(x,y)}, datalist)
}

df <- multmerge()
saveRDS(df, file="./yelp_dataset/reviews.rds")
if(!exists("review.df ")) review.df <- readRDS("./yelp_dataset/reviews.rds")

## Clean data ################################################################################################################

# NA starts and review count is considered to be 0 
business.df$stars[is.na(business.df$stars)] <- 0
business.df$review_count[is.na(business.df$review_count)] <- 0

#NA in Hours is considered to be 00:00
hours <- grepl("hours.", names(business.df))
business.df[hours] <- replace(business.df[hours], is.na(business.df[hours]), "00:00")
business.df[hours] <- lapply(business.df[hours], as.factor)

## Filter data ################################################################################################################

business_table <- data.frame(business.df$business_id,business.df$name,business.df$stars,business.df$state,business.df$city,business.df$latitude,business.df$longitude)
business_table <- as.data.frame.table(business_table)
#Flatten the data frame to avoid nested structure,
#which comes from the former json nature of the data
library(jsonlite)
business.df <- flatten(business.df, recursive = TRUE)

##open,
business.df <- business.df[which(business.df$open==TRUE), ]

#NA in Attributes is considered to be FALSE
#See http://stackoverflow.com/questions/2991514/r-preventing-unlist-to-drop-null-values
#to solve NULL creating problems when flattening list variables
business.df$`attributes.Accepts Credit Cards`[sapply(business.df$`attributes.Accepts Credit Cards`, is.null)] <- NA
business.df$`attributes.Accepts Credit Cards` <- unlist(business.df$`attributes.Accepts Credit Cards`,
                                                recursive = T, use.names = T)

attrib <- grepl("attributes.", names(business.df))
business.df[attrib] <- replace(business.df[attrib], is.na(business.df[attrib]), FALSE)
business.df[attrib] <- lapply(business.df[attrib], as.factor)


#Reviews
reviews <- readRDS("review.rds")
##Drop text (left for further analysis, not in this research)
reviews <- reviews[, -c(6, 7)]
reviews <- flatten(reviews, recursive = TRUE)



##exclude friend network, it would be interesting to analyse this,
##but I leave it for another research project
users <- users[,-c(4, 6, 9, 11)] 
users <- flatten(users, recursive = TRUE)
users$yelping_since <- as.factor(users$yelping_since)
users[,c(4:19)][is.na(users[,c(4:19)])] <- 0

# Only business id and likes
tip.df <- tip.df[,-c(1, 2, 5, 6)] 

# Convert NA into 0 in checkins
checkin.df$checkin_info[is.na(checkin.df$checkin_info)] <- 0
checkin.df$business_id[is.na(checkin.df$business_id)] <- 0

# Get total review count for the three states
review_by_state <- aggregate( review_count ~ state, data = business_data, FUN = sum)

#Master
master <- merge(biz, reviews, by = "business_id")
master <- master[,-c(1,2)]
rm(reviews) #always being memory-concious
master$stars.diff <- master$stars.x - master$stars.y

## Get main features ################################################################################################################
# Auxiliar functions ###############

# Function to get the zipcode
getZipcode <- function(business){
  NumOfCols <- length(business$full_address)
  for (index in 1:NumOfCols){
    zip_string<-sub(".*, ", "", business$full_address[index])
    business$zip_code[index]<-substr(zip_string, 4, 8)
  }
  return (business)
}

business.df<-getZipcode(business.df)
business.df$zip_code[is.na(business.df$zip_code)] <- 0











