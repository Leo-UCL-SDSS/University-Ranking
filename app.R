library(shiny)
library(ggplot2)
library(dplyr)
library(leaflet)
library(ggrepel)

# Load dataset
usNews_ranking <- read.csv("usNews_ranking.csv")

# UI
ui <- fluidPage(
  h1("University Ranking Dashboard"),
  
  tabsetPanel(
    # Tab 1: Scatter Plot
    tabPanel("Score vs Enrollment",
             sidebarLayout(
               sidebarPanel(
                 selectInput(
                   inputId = "country",
                   label = "Select Country",
                   choices = c("All", unique(usNews_ranking$country)),
                   selected = "All"
                 ),
                 sliderInput(
                   inputId = "rank_range",
                   label = "Select Rank Range",
                   min = min(usNews_ranking$numeric_rank),
                   max = max(usNews_ranking$numeric_rank),
                   value = c(1,30),
                   step = 1
                 )
               ),
               mainPanel(
                 plotOutput("scatter_plot",height = "700px") # Amplify the graph
               )
             )
            ),
    
    # Tab 2: Year Founded Plots
    tabPanel("Year Founded Analysis",
             sidebarLayout(
               sidebarPanel(
                 selectInput(
                   inputId = "country",
                   label = "Select Country",
                   choices = c("All", unique(usNews_ranking$country)),
                   selected = "All"
                 ),
                 
                 sliderInput(
                   inputId = "rank_range",
                   label = "Select Rank Range",
                   min = min(usNews_ranking$numeric_rank),
                   max = max(usNews_ranking$numeric_rank),
                   value = c(1,30),
                   step = 1
                 )
               ),
               mainPanel(
                 plotOutput("year_rank_plot"),
                 plotOutput("year_score_plot")
               )
             )),
    
    # Tab 3: Map View
    tabPanel("Map View",
             sidebarLayout(
               sidebarPanel(
                 selectInput(
                   inputId = "country",
                   label = "Select Country",
                   choices = c("All", unique(usNews_ranking$country)), 
                   selected = "All"
                 ),
                 
                 # Region Dropdown - Automatically populated based on the selected country
                 selectInput(
                   inputId = "city",
                   label = "Select City",
                   choices = c("All", unique(usNews_ranking$city)),
                   selected = "All"
                 ),
                 
                 sliderInput(
                   inputId = "rank_range",
                   label = "Select Rank Range",
                   min = min(usNews_ranking$numeric_rank),
                   max = max(usNews_ranking$numeric_rank),
                   value = c(1,30),
                   step = 1
                 )
               ),
               mainPanel(
                 leafletOutput("map_output",height = "700px")
               )
             ))
  )
)

# Server
server <- function(input, output, session) {
  
  # Tab 1: Scatter Plot
  output$scatter_plot <- renderPlot({
    filtered_data <- usNews_ranking %>%
      filter((input$country == "All" | country == input$country) &
               numeric_rank >= input$rank_range[1] & 
               numeric_rank <= input$rank_range[2])
    
    ggplot(filtered_data, aes(x = enrollment, y = score, color = country, size = numeric_rank, label = university)) +
      geom_point(alpha = 0.7) +      
      ggrepel::geom_text_repel(size = 2.5, max.overlaps = 100) +  # Add university names
      scale_size_continuous(trans = "reverse") +  # Reverse the size scale
      theme_minimal() +
      labs(
        title = "Score vs. Enrollment",
        x = "Enrollment",
        y = "Score",
        color = "Country",
        size = "Rank"
      )
  })
  
  # Tab 2: Year Founded Analysis
  output$year_rank_plot <- renderPlot({
    filtered_data <- usNews_ranking %>%
      filter((input$country == "All" | country == input$country) &
               numeric_rank >= input$rank_range[1] &
               numeric_rank <= input$rank_range[2])
    
    ggplot(filtered_data, aes(x = year_founded, y = score, color = country)) +
      geom_point(alpha = 0.7) +
      theme_minimal() +
      labs(
        title = "Year Founded vs Score",
        x = "Year Founded",
        y = "Overall Score",
        color = "Country"
      ) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # Plot for Year Founded vs Score
  output$year_score_plot <- renderPlot({
    filtered_data <- usNews_ranking %>%
      filter((input$country == "All" | country == input$country) &
               numeric_rank >= input$rank_range[1] &
               numeric_rank <= input$rank_range[2])
    
    ggplot(filtered_data, aes(x = year_founded, y = enrollment, color = country)) +
      geom_point(alpha = 0.7) +
      theme_minimal() +
      labs(
        title = "Year Founded vs Enrollment",
        x = "Year Founded",
        y = "Enrollment",
        color = "Country"
      ) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # Tab 3: Map View
  output$map_output <- renderLeaflet({
    # Filter the dataset based on selected country and city
    filtered_data <- usNews_ranking %>%
      filter((input$country == "All" | country == input$country) &
               (input$city == "All" | city == input$city) &
               numeric_rank >= input$rank_range[1] & 
               numeric_rank <= input$rank_range[2])  # Apply rank filtering
    
    
    # Aggregate information for overlapping points
    aggregated_data <- filtered_data %>%
      group_by(lat, long) %>%
      summarise(
        universities = paste(university, collapse = "; "),
        rank_range = paste(min(rank), "-", max(rank)),
        scores = paste(score, collapse = "; "),
        enrollment_range = paste(min(enrollment), "-", max(enrollment)),
        location = first(location),
        .groups = "drop"
      )
    
    # Create the map
    leaflet(aggregated_data) %>%
      addTiles() %>%
      addCircleMarkers(
        lat = ~lat,
        lng = ~long,
        radius = 5,
        popup = ~paste(
          "<strong>Universities:</strong><br/>", universities, "<br/><br/>",
          "<strong>Rank Range:</strong> ", rank_range, "<br/>",
          "<strong>Scores:</strong> ", scores, "<br/>",
          "<strong>Enrollment Range:</strong> ", enrollment_range, "<br/>",
          "<strong>Location:</strong> ", location
        ),
        color = "blue",
        fillOpacity = 0.7
      ) %>%
      setView(lng = mean(filtered_data$long, na.rm = TRUE),
              lat = mean(filtered_data$lat, na.rm = TRUE),
              zoom = 2)
  })
}

shinyApp(ui, server)
