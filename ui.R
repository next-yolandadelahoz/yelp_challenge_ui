library(shiny)
library(leaflet)
library(plotly)


# Choices for drop-downs
color_vars <- c(
  "Stars mark" = "stars",
  "Review count" = "review_count",
  "Categories" = "categories",
  "Neighbourdhoods" = "neighborhoods"
  # difference starts
)

size_vars <- c(
  "Review count" = "review_count",
  "Stars mark" = "stars"
)

category_vars <- c(
   "All" = "All",
   "Restaurant" = "Restaurant",
   "Shopping" = "Shopping",
   "Health & Medical" = "Health & Medical",
   "Hotels" = "Hotels",
   "Home Services" = "Home Services",
   "Food"="Food"
)

week_day_vars <- c(
  "Monday" = "Monday",
  "Tuesday" = "Tuesday",
  "Wednesday" = "Wednesday",
  "Thursday" = "Thursday",
  "Friday" = "Friday",
  "Saturday"="Saturday",
  "Sunday"="Sunday"
)


shinyUI(navbarPage("Yelp Business Reviews", id="nav",

  tabPanel("Interactive map",
    div(class="outer",

      tags$head(
        # Include our custom CSS
        includeCSS("libraries/styles.css"),
        includeScript("libraries/gomap.js")
      ),

      leafletOutput("map", width="100%", height="100%" ),

      # Shiny versions prior to 0.11 should use class="modal" instead.
      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
        draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
        width = 330, height = "auto",
        h4("Business explorer"),

        selectInput("color", "Color", color_vars),
        selectInput("size", "Size", size_vars, selected = "adultpop"),
        sliderInput("size_scale", "Size scale:",
                    min = 10, max = 200, value = 50, step = 5),
        br(),
        sliderInput("reviews", "Minimum number of reviews:",
                    min = 0, max = 500, value = 10, step = 5),
        sliderInput("stars", "Minimum number of stars:",
                    min = 0, max = 5, value = 0, step = 1),
        selectInput("business_category", "Business category", category_vars, selected = "adultpop"),
        selectInput("week_day", "Day of the week", week_day_vars, selected = "adultpop"),
        sliderInput("day_hours", "Hours of the day:",
                    min = 0, max = 24, value = 50, step = 1)

      ),

      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                    draggable = TRUE, top = 400, left = 20, right = 20, bottom = "auto",
                    width = 690, height =  "auto",
                    tabsetPanel(type = "tabs",
                                tabPanel("Histogram",plotlyOutput("histRanking", height = 200)),
                                tabPanel("Scatterplot", plotlyOutput("scatterRanking", height = 250)),
                                tabPanel("Summary",verbatimTextOutput("report"))
                    )
      ),

      tags$div(id="cite",
        'Big Data ', tags$em('Master EIT Digital - Data Science / Technical University of Madrid by Yolanda de la Hoz Simon.')
      )
    )
  ),

  tabPanel("Data explorer",
    fluidRow(
      column(3,
        selectInput("states", "States", c("All states"="", structure(state.abb, names=state.name), "Washington, DC"="DC"), multiple=TRUE)
      ),
      column(3,
        conditionalPanel("input.states",
          selectInput("cities", "Cities", c("All cities"=""), multiple=TRUE)
        )
      ),
      column(3,
        conditionalPanel("input.states",
          selectInput("zipcodes", "Zipcodes", c("All zipcodes"=""), multiple=TRUE)
        )
      )
    ),
    fluidRow(
      column(1,
        numericInput("minScore", "Min score", min=0, max=100, value=0)
      ),
      column(1,
        numericInput("maxScore", "Max score", min=0, max=100, value=100)
      )
    ),
    hr(),
    DT::dataTableOutput("ziptable")
  ),

  conditionalPanel("false", icon("crosshair"))
))
