library(shiny)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(magrittr)
library(plotly)

# Leaflet bindings are a bit slow; for now we'll just sample to compensate
set.seed(100)
business_data <- business.df[sample.int(nrow(business.df), 60000),]
# By ordering by centile, we ensure that the (comparatively rare) SuperZIPs
# will be drawn last and thus be easier to see
business_data <- business_data[order(business.df$stars),]

cleantable <- business_data %>%
  select(
    City = city,
    State = state,
    Zipcode = zip_code,
    Stars = stars,
    Lat = latitude,
    Long = longitude
  )

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
      return(business_data[FALSE,])
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    subset(business_data,
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
           review_count >= reviews )
    # Filter by category
    if (input$business_category != "All") {
      business_data <- m[which(grepl(input$business_category, m$categories)), ]
    }else
      business_data <- m
    
    # Filter open business
    if (input$open_checkbox==TRUE) {
      business_data <- m[which(m$open==TRUE), ]
    }else
      business_data <- m[which(business_data$open==FALSE), ]
    
  })
  
  output$histRanking <- renderPlotly({
    colorBy <- input$color
    colorData <- zipsIFiltered()[[colorBy]]
    
    if (nrow(zipsIFiltered()) == 0)
      return(NULL)
    
    pal<-colorPalette(colorData,colorBy)
    #p<-plot_ly(zipsIFiltered(), x = zipsIFiltered()[[input$color]], y = zipsIFiltered()[[input$size]], name = label,
     #       mode = "markers", color= colorData,colors = "Spectral" , size = zipsIFiltered()[[input$size]],showlegend = FALSE)
    
    labelx <- paste(input$business_category, "business", input$color , "(visible business)", sep=" ")
    ax <- list(
      title = labelx,
      showticklabels = TRUE
    )
    
    ay <- list(
      title = input$size,
      showticklabels = TRUE
    )
    
    p<-plot_ly(zipsIFiltered(),type = "bar", x = zipsIFiltered()[[input$color]], y = zipsIFiltered()[[input$size]], 
           marker= list(color=pal(colorData)), size = zipsIFiltered()[[input$size]],showscale = FALSE)%>%
           layout(xaxis = ax, yaxis = ay)
    
  })
  
  output$scatterRanking <- renderPlotly({
    colorBy <- input$color
    colorData <- zipsIFiltered()[[colorBy]]
    
    if (nrow(zipsIFiltered()) == 0)
      return(NULL)
    
    pal<-colorPalette(colorData,colorBy)
    
    labelx <- paste(input$business_category, "business", input$color , "(visible business)", sep=" ")
    ax <- list(
      title = labelx,
      showticklabels = TRUE
    )
    
    ay <- list(
      title = input$size,
      showticklabels = TRUE
    )
    
    p<-plot_ly(zipsIFiltered(), x = zipsIFiltered()[[input$color]], y = zipsIFiltered()[[input$size]],
           mode = "markers", color= colorData,colors = "Spectral" , size = zipsIFiltered()[[input$size]],showscale = FALSE)%>%
    layout(xaxis = ax, yaxis = ay)
  })
  
  # This observer is responsible for maintaining the circles and legend,
  # according to the variables the user has chosen to map to color and size.
  observe({
    sizeBy <- input$size
    sizeRange <- input$size_scale
    colorBy <- input$color
    
    colorData <- zipsIFiltered()[[colorBy]]

    pal<-colorPalette(colorData,colorBy)
    radius <- zipsIFiltered()[[sizeBy]] * sizeRange 
    
    leafletProxy("map", data = zipsIFiltered()) %>%
      clearShapes() %>%
      addCircles(~longitude, ~latitude, radius=radius, layerId=~zip_code,
                 stroke=FALSE, fillOpacity=0.4, fillColor=pal(colorData)) %>%
      addLegend("bottomleft", pal=pal, values=colorData, title=colorBy,
                layerId="colorLegend")
  })
  
  
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
  
  # Show a popup at the given location
  showZipcodePopup <- function(zipcode, lat, lng) {
    selectedZip <- business_data[business_data$zip_code == zipcode,]
    content <- as.character(tagList(
      tags$h4(as.character(selectedZip$name)),
      tags$h5("Categories:", as.character(selectedZip$categories)),
      sprintf("Number of reviews: %s", as.integer(selectedZip$review_count)), tags$br(),
      sprintf("Stars score: %s%%", as.integer(selectedZip$stars))
    ))
    leafletProxy("map") %>% addPopups(lng, lat, content, layerId = zipcode)
  }
  
  # Calculate the color palette
  colorPalette <- function(colorData, colorBy) {
    if(colorBy=="stars" || colorBy=="review_count"){
      pal <- colorBin("Spectral", colorData, 4, pretty=TRUE,alpha = FALSE)
    }else{
      pal <- colorBin("Spectral", colorData, 4, pretty=TRUE,alpha = FALSE)
    }
    return (pal)
  }
  
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
        Stars >= input$minScore,
        Stars <= input$maxScore,
        is.null(input$states) | State %in% input$states,
        is.null(input$cities) | City %in% input$cities,
        is.null(input$zipcodes) | Zipcode %in% input$zipcodes
      ) %>%
      mutate(Action = paste('<a class="go-map" href="" data-lat="', Lat, '" data-long="', Long, '" data-zip="', Zipcode, '"><i class="fa fa-crosshairs"></i></a>', sep=""))
    action <- DT::dataTableAjax(session, df)
    
    DT::datatable(df, options = list(ajax = list(url = action)), escape = FALSE)
  })
})
