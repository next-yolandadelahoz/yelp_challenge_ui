library(shiny)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)

# Leaflet bindings are a bit slow; for now we'll just sample to compensate
set.seed(100)
zipdata <- business.df[sample.int(nrow(business.df), 60000),]
# By ordering by centile, we ensure that the (comparatively rare) SuperZIPs
# will be drawn last and thus be easier to see
zipdata <- zipdata[order(business.df$stars),]

shinyServer(function(input, output, session) {
  
  ## Interactive Map ###########################################
  
  # Create the map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = -93.85, lat = 37.45, zoom = 4)
  })
  
  # A reactive expression that returns the set of zips that are
  # in bounds right now
  zipsInBounds <- reactive({
    if (is.null(input$map_bounds))
      return(zipdata[FALSE,])
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    subset(zipdata,
           latitude >= latRng[1] & latitude <= latRng[2] &
             longitude >= lngRng[1] & longitude <= lngRng[2])
  })
  
  # Filter the movies, returning a data frame
  zipsIFiltered<- reactive({
    # Due to dplyr issue #318, we need temp variables for input values
    reviews <- input$reviews
    stars_input <- input$stars
    week_day <- input$week_day
    day_hours <- input$day_hours[1]
    
    # Apply filters
    m <- subset(zipsInBounds(),
           review_count >= reviews &
             stars >= stars_input)
    # Filter by category
    if (input$business_category != "All") {
      zipdata <- m[which(grepl(input$business_category, m$categories)), ]
    }else
      zipdata <- m
    
  })
  
  output$histCentile <- renderPlot({
    # Precalculate the breaks we'll need for the two histograms
      histBreaks <- hist(plot = FALSE, zipdata[[input$color]], breaks = 20)$breaks
    # If no zipcodes are in view, don't plot
    if (nrow(zipsIFiltered()) == 0)
      return(NULL)
    
    label <- paste(input$business_category, "business", input$color , "(visible business)", sep=" ")
    hist(zipsIFiltered()[[input$color]],
         breaks = histBreaks,
         main = label,
         xlab = input$color,
         xlim = range(zipsIFiltered()[[input$color]]),
         col = '#00DD00',
         border = 'white')
  })
  
  output$scatterCollegeIncome <- renderPlot({
    # If no zipcodes are in view, don't plot
    if (nrow(zipsIFiltered()) == 0)
      return(NULL)
    xlabel <- paste(input$business_category, "business", input$color, sep=" ")
    ylabel <- paste(input$business_category, "business",input$size, sep=" ")
    print(xyplot(zipsIFiltered()[[input$color]] ~ zipsIFiltered()[[input$size]], xlab=xlabel, ylab=ylabel))
  })
  
  # This observer is responsible for maintaining the circles and legend,
  # according to the variables the user has chosen to map to color and size.
  observe({
    colorBy <- input$color
    sizeBy <- input$size
    sizeRange <- input$size_scale
    
    colorData <- zipdata[[colorBy]]
    if(colorBy=="stars" || colorBy=="review_count"){
      pal <- colorBin("Spectral", colorData, 4, pretty = TRUE)
    }else{
      pal <- colorBin("Spectral", colorData, 4, pretty = TRUE)
    }

    radius <- zipdata[[sizeBy]] * sizeRange 

    leafletProxy("map", data = zipdata) %>%
      clearShapes() %>%
      addCircles(~longitude, ~latitude, radius=radius, layerId=~zip_code,
                 stroke=FALSE, fillOpacity=0.4, fillColor=pal(colorData)) %>%
      addLegend("bottomleft", pal=pal, values=colorData, title=colorBy,
                layerId="colorLegend")
  })
  
  # Show a popup at the given location
  showZipcodePopup <- function(zipcode, lat, lng) {
    selectedZip <- zipdata[zipdata$zip_code == zipcode,]
    content <- as.character(tagList(
      tags$h4("Stars score:", as.integer(selectedZip$stars)),
      tags$strong(HTML(sprintf("%s, %s %s",
                               selectedZip$city.x, selectedZip$state.x, selectedZip$zipcode
      ))), tags$br(),
      sprintf("Number of reviews: %s", as.integer(selectedZip$review_count)), tags$br(),
      sprintf("Category: %s%%", as.character(selectedZip$category))
    ))
    leafletProxy("map") %>% addPopups(lng, lat, content, layerId = zipcode)
  }
  
  # When map is clicked, show a popup with city info
  observe({
    leafletProxy("map") %>% clearPopups()
    event <- input$map_shape_click
    if (is.null(event))
      return()
    
    isolate({
      showZipcodePopup(event$id, event$lat, event$lng)
    })
  })
  
  
  ## Data Explorer ###########################################
  
  observe({
    cities <- if (is.null(input$states)) character(0) else {
      filter(cleantable, State %in% input$states) %>%
        `$`('City') %>%
        unique() %>%
        sort()
    }
    stillSelected <- isolate(input$cities[input$cities %in% cities])
    updateSelectInput(session, "cities", choices = cities,
                      selected = stillSelected)
  })
  
  observe({
    zipcodes <- if (is.null(input$states)) character(0) else {
      cleantable %>%
        filter(State %in% input$states,
               is.null(input$cities) | City %in% input$cities) %>%
        `$`('Zipcode') %>%
        unique() %>%
        sort()
    }
    stillSelected <- isolate(input$zipcodes[input$zipcodes %in% zipcodes])
    updateSelectInput(session, "zipcodes", choices = zipcodes,
                      selected = stillSelected)
  })
  
  observe({
    if (is.null(input$goto))
      return()
    isolate({
      map <- leafletProxy("map")
      map %>% clearPopups()
      dist <- 0.5
      zip <- input$goto$zip
      lat <- input$goto$lat
      lng <- input$goto$lng
      showZipcodePopup(zip, lat, lng)
      map %>% fitBounds(lng - dist, lat - dist, lng + dist, lat + dist)
    })
  })
  
  output$ziptable <- DT::renderDataTable({
    df <- cleantable %>%
      filter(
        Score >= input$minScore,
        Score <= input$maxScore,
        is.null(input$states) | State %in% input$states,
        is.null(input$cities) | City %in% input$cities,
        is.null(input$zipcodes) | Zipcode %in% input$zipcodes
      ) %>%
      mutate(Action = paste('<a class="go-map" href="" data-lat="', Lat, '" data-long="', Long, '" data-zip="', Zipcode, '"><i class="fa fa-crosshairs"></i></a>', sep=""))
    action <- DT::dataTableAjax(session, df)
    
    DT::datatable(df, options = list(ajax = list(url = action)), escape = FALSE)
  })
})
