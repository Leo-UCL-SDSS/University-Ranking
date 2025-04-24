# Empty your environment by removing all objects
rm(list = ls())

# Setup: Install and load necessary packages for web scraping, data manipulation, and visualization
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(
  RSelenium,  # For interacting with a web browser
  rvest,      # For web scraping
  purrr,      # For functional programming
  dplyr,      # For data manipulation
  ggplot2,    # For data visualization
  plotly,     # For interactive plots
  countrycode, # For country code conversions
  shiny,      # For building interactive apps
  stringr,    # For string manipulation
  ggrepel,    # For improved text placement in ggplot2
  leaflet,    # For mapping
  tidygeocoder # For geocoding
)

# Connecting to the Firefox browser via RSelenium
driver <- rsDriver(browser = "firefox")  # Specify Firefox browser
remote_driver <- driver$client

# Navigating to the target URL to fetch the university rankings
url <- "https://www.usnews.com/education/best-global-universities/rankings"
remote_driver$navigate(url)

# Handle cookie consent pop-up by clicking the consent button
webElems <- remote_driver$findElements(using = "id", 'onetrust-accept-btn-handler')
webElems[[1]]$clickElement()
Sys.sleep(2)  # Wait for the page to load

# Create a function to scroll the page and click "Load More" button to reveal more rankings
scroll_and_load <- function(i) {
  cat("Cycle", i, "of", 25, "\n")
  
  # Scroll down the page to load more content
  remote_driver$executeScript('window.scrollTo(0, document.body.scrollHeight * 0.8);')
  Sys.sleep(5)
  
  # Attempt to click the "Load More" button
  tryCatch({
    load_button <- remote_driver$findElement(using = "xpath", '//button[@rel="next"]//span')
    load_button$clickElement()
    cat("Load More button found. Clicking...\n")
    Sys.sleep(5)
  }, error = function(e) {
    cat("No more 'Load More' button found. Exiting...\n")
  })
}

# Use the map function to iterate over 25 cycles of scrolling and clicking the "Load More" button
map(1:25, scroll_and_load)

# Extract the necessary data elements from the webpage
name <- remote_driver$findElements(using = "xpath", '//h2[@class="Heading-sc-1w5xk2o-0 erfdut md-mb2"]')
country <- remote_driver$findElements(using = "xpath", '//p[@class="Paragraph-sc-1iyax29-0 fbFZrE"]/span[1]')
city <- remote_driver$findElements(using = "xpath", '//p[@class="Paragraph-sc-1iyax29-0 fbFZrE"]/span[3]')
rank <- remote_driver$findElements(using = "xpath", '//div[@class="RankList__Rank-sc-2xewen-2 ieuiBj ranked has-badge"]//strong')
score_Enrollment <- remote_driver$findElements(using = "xpath", '//div[@class="Box-w0dun1-0 QuickStatHug__Container-hb1bl8-0 bcZeaE fkvuin QuickStatHug-hb1bl8-2 fyaies QuickStatHug-hb1bl8-2 fyaies"]//dd[1]')
abstract <- remote_driver$findElements(using = "xpath", '//p[@class="Paragraph-sc-1iyax29-0 fBaaRL sm-hide"]')

# Extract scores and enrollment details, handling alternate data elements
score_Enrollment <- sapply(score_Enrollment, function(x) x$getElementText()[[1]])
score <- score_Enrollment[seq(1, length(score_Enrollment), by = 2)]  # Odd indices for scores
enrollment <- score_Enrollment[seq(2, length(score_Enrollment), by = 2)]  # Even indices for enrollment numbers

# Create a tibble (data frame) to store the extracted information
usNews_ranking <- tibble(
  rank = sapply(rank, function(x) x$getElementText()[[1]]),
  university = sapply(name, function(x) x$getElementText()[[1]]),
  country = sapply(country, function(x) x$getElementText()[[1]]),
  city = sapply(city, function(x) x$getElementText()[[1]]),
  enrollment = enrollment,
  score = score,
  abstract = sapply(abstract, function(x) x$getElementText()[[1]])
)

#remote_driver$close()  # Close the remote driver
#driver$server$stop()  # Stop the Selenium server

# Clean and process enrollment data
usNews_ranking$enrollment[usNews_ranking$enrollment == "N/A"] <- NA  # Replace "N/A" with NA
usNews_ranking$enrollment <- gsub(",", "", usNews_ranking$enrollment)  # Remove commas in enrollment numbers

# Clean the data: Convert character columns to appropriate data types
usNews_ranking <- usNews_ranking %>%
  as.data.frame() %>%
  mutate_all(~ ifelse(. == "", NA, .)) %>%  # Replace empty strings with NA
  mutate(
    numeric_rank = as.numeric(gsub("#", "", rank)),  # Convert rank to numeric (remove "#" symbol)
    score = as.numeric(score),  # Convert score to numeric
    enrollment = as.numeric(enrollment),  # Convert enrollment to numeric
    year_founded = as.numeric(str_extract(abstract, "\\d{4}"))  # Extract and convert year founded
  )

# Remove text within brackets (including brackets) from the 'city' column
# The regular expression matches text inside parentheses and removes it
usNews_ranking$city <- gsub("\\s*\\(.*?\\)", "", usNews_ranking$city)

# Remove the last 20 rows from the dataset (if necessary to remove incomplete data)
usNews_ranking <- usNews_ranking[1:(length(usNews_ranking$rank) - 20), ]

# Geocode location to get latitude and longitude for each university
usNews_ranking <- usNews_ranking %>%
  mutate(location = paste(city, ",", country))  # Combine city and country to create a location field

# Perform geocoding using OpenStreetMap (osm) to obtain coordinates for each location
geo_data <- usNews_ranking %>%
  distinct(location) %>%
  geocode(location, method = "osm")

# Merge geocode data back into the main dataset to add latitude and longitude information
usNews_ranking <- usNews_ranking %>%
  left_join(geo_data, by = "location")

# Display a summary of the final dataset
summary(usNews_ranking)

# Save the cleaned data to a CSV file for later use
write.csv(usNews_ranking, "usNews_ranking.csv", row.names = FALSE)
