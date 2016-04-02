# Yelp Challenge UI 
> ######## https://yolanda93.github.io/yelp_challenge_ui
===============================================================================

[![Build
Status](https://travis-ci.org/yolanda93/yelp_challenge.svg?branch=master)](https://travis-ci.org/yolanda93/yelp_challenge)

The aim of this project is the design and development of an interactive visual application designed to respond the most relevant questions in the small businesses domain taking advantage of the Yelp! business reviews.

![Alt text] (https://lh5.googleusercontent.com/rML-OlpdoI6ZeUgMnfnYyFkYs7sEv2Kh5YnkH2AyTpIjHQB0WrudxJDmDathTPC79d5VLWtnx31E7AV0lfekWq6wdeWoTxLNXb7tQbr8CfazBI1kyMIQwvE1mgbCb52wqQ "General Design")
  
The dataset is provided by Yelp, a service that allows users to review businesses and check other users reviews. They provide a subset of their data in a challenge (which is in its 6th round) to promote the development of innovative visual analytic tools. This dataset contains geolocalized information about businesses, users reviews and scores, etc. Many different analyses could be carried out on these data and they support many of the encoding options seen in class (cartographic arrangement, filtering of data, etc.).

The data can be downloaded from http://www.yelp.com/dataset_challenge.

Table of contents
=================

-   [Example of execution](#Example of execution)
-   [Dataset description](#Dataset-description)
-   [Application domain](#Application-domain)
-   [Application design](#Application-design)
    -   [Components description](#Components-description)
    -   [Interactive map](#Interactive-map)
    -   [Popup message](#Popup-message)
    -   [Business explorer](#Business-explorer)  
    -   [Graph summary](#Graph-summary)
    -   [Data explorer](#Data-explorer)
-   [Functional requirements definition](#Functional-requirements-definition)
    -   [Data and task abstractions](#Data-and-task-abstractions)
    -   [Interaction and visual encoding](#Interaction-and-visual-encoding)
-   [Development](#Development)
-   [Contact information](#Contact-information)
-   [Web page](#Web-page)

<h2 id="Example-of-execution">Example of execution </h2> 

There are many ways to download and run it:

```R
library(shiny)

# Easiest way is to use runGitHub
runGitHub("yelp_challenge_ui", "yolanda93")

# Run a tar or zip file directly
runUrl("https://github.com/yolanda93/yelp_challenge_ui/archive/master.tar.gz")
runUrl("https://github.com/yolanda93/yelp_challenge_ui/archive/master.zip")
```

Or you can clone the git repository, then use `runApp()`:

```R
# First clone the repository with git. If you have cloned it into
# ~/yelp_challenge_ui, first go to that directory, then use runApp().
setwd("~/yelp_challenge_ui")
runApp()
```


To run a Shiny app from a subdirectory in the repo or zip file, you can use the `subdir` argument. This repository happens to contain another copy of the app in `inst/shinyapp/`.

```R
runGitHub("yelp_challenge_ui", "yolanda93", subdir = "inst/shinyapp/")

runUrl("https://github.com/yolanda93/yelp_challenge_ui/archive/master.tar.gz",
  subdir = "inst/shinyapp/")
```

<h2 id="Dataset-description">Dataset description </h2>

The dataset provided by Yelp (http://www.yelp.com/dataset_challenge) is based on 61 million reviews with the aim to help people find the most relevant businesses for everyday needs.
The dataset is provided in JSON format and it includes some interesting features described below.

   * Business: Localization, business category, reviews, starts and open hours.
   * Review: Business, users, starts, review text, date and votes.
   * User: User, reviews, votes, average starts, friends, antiquity, compliments and fans.
   * Check In: Business and check in info (hours).
   * Tip: Tip text, business, user, date and likes.

<h2 id="Application-domain">Application domain </h2>

In this section, it is identified some relevant questions that the application should solve with the purpose of have a user-centered design that better fix the user requirements.

*Business owners*
*Need*: Improve the quality of their services → Offer better services.
*Questions*:

        1. Which is the average rating that users give to my business?
        2. Is the number of hours that a business open affecting their ranking mark?
        3. Is the location of my business affecting the ranking mark?
        4. Is my business getting more users depending of the season of the year?
        5. Is the number of services that my business offers affecting their ranking mark?
        6. Predict when a business will be more busy.

*Customers*
*Need*: Look up the better business according to their preferences.
*Questions*:

       1. What are the top ranked (restaurants, shops...) in my location?
       2. What of these business open today?
       3. Get the top ranking business according to: age of the reviewers, type of business, open_hours and localization.

In the challenge webpage it is also proposed some interesting questions related with some data science challenges and business needs, among which I’ve selected the following questions to be considered:

      1. How much of a business success is really just location, location, location?
      2. Are there more reviews for sports bars on major game days and if so, could you predict that?
      3. How much influence does my social circle have on my business choices and my ratings?
      4. What cuisines are Yelpers raving about in these different countries?
      5. In which countries are Yelpers sticklers for service quality?

The questions (with the associated underlying variables) that I will develop corresponds to the most common needs of two targeted users: business owners and customers.

<h2 id="Application-design">Application design </h2>

As the design of this application is focused to answer the questions proposed before; first it is defined a list of the specific functional requirements that the application should fulfil. This list is corresponds to the data and task abstractions and the different visualization methods and interaction levels.

The application design is based in the following four main parts:

      * Interactive map: It is the main layout of the application.
      * Business explorer: On the right site, it is an absolute panel that gives the user different exploration options.
      * Graph summary: On the lower left side, that shows the different chart options (Bar chart, scatter plot and chart summary).
      * Data explorer: It can be accessed through the top navigation bar and shows a table with more detailed information.

<h3 id="Components-description">Components description </h3>

In this section it is described the main components of the application and the different use cases and tasks that a user could perform to answer the proposed questions.

<h3 id="Interactive-map">Interactive map </h3>

The interactive map shows a map with the data location. It can be navigated and zoomed to filter and show an interesting area.

![Alt text] (https://lh3.googleusercontent.com/INX-iQDemJp78FkgywWUk2xR479cYTgWcGhbPIAlD3YTITa-s1yfIRk5zCQkxEtOWWH8M_9x9eU89luCM-FCBex19AoyS_wwJjPgHbQELc9Q3wUc7OcUi7ggAl4UmJTYzg  "Interactive map")

<h3 id="Popup-message">Popup message </h3>

In the following picture it is shown an image with a zoomed region area showing in which the user has selected one of the business to show specific information such as the business categories that this business belongs to with the stars score and number of reviews.

![Alt text] (https://lh6.googleusercontent.com/4TTe09UIbThvBJMcdhlZFM70qXwOYL47El5fvgjvMnTwUatO0gv_rkmxSTmn0QVoD8HTJN3z8ZYmpLbbiFnwso2ej7WZk7pfHKtTitzMkVxf4ktz0Z1g_3Dd0xCkSuLDnw  "Popup message")

<h3 id="Business-explorer">Business explorer </h3>

The business explorer allows the user to select interesting information and filter data. It is divided in two main parts: business explorer and filter options.

Between the different filter options, it is allowed to show the currently open business that could be very interesting if it is compared with the closed business, for example to know how many stars had a business already closed in this area.This component also offers the possibility to restrict the data to show only the most ranking business with the minimum review number and the minimum stars sliders

<h3 id="Graph-summary">Graph summary </h3>

The graph summary is an absolute panel displayed above the interactive map that offers different analytical visualization options such as bar chart, scatter plot and a bar chart summary of the current states.

![Alt text] (https://lh5.googleusercontent.com/1-1lJl_RgsETTN-9t6anr_D8p4ien465P5CRcip9AE7TEYUxBoTzCLZA_itW2Q6aVfSLodNLhWCpeFH08dTGzYxJOWUAmfag5vxUyHlZj0xjDYDeK8zKETP6MnFr763YOQ "Graph summary")

The following image shows a scatter plot of the current selected data, this visualization allows to find trends and outlier easily. For example in this figure we can visualize the stars and number of reviews for that each stars has with some inline gaps that indicates that most of the rankings are done with no more of 2500 reviews.

![Alt text] (https://lh3.googleusercontent.com/o4Cx2i-gUsLTQ7gPr5lR0taR1TyTJ94Eqrt1l0qqGH6zxro4qtNI2iyiISaSeiUUovdzODjWyYTcQXm9DHa40U0iEFPM6YxUoFsJFHWttSLRWBBzIsxZyxSsiLIxviHVPw "Graph summary")

The following image shows the states summary tab of the absolute panel, this view shows a summary of the selected variable in the business explorer aggregated by each the state that are within the visualization area. It is very interesting because it help us to focalize the attention for example only the areas with more number of reviews.
In this figure it is shown also one the filtering options that allows the chart selecting the interesting region area to zoom and visualize this area.

![Alt text] (https://lh3.googleusercontent.com/WkCW5SnWbGPexISTRrWOpiCRYshJZC4pb7O2h-_cpwEbLMrZACqXTk-5KjtaG_SUwECqgdym95fAfrTpYsyaKc3luzwbQZVAei-Ay9m20qz7tf0ynAm5YRDogffrlWo_0A "Graph summary")

<h3 id="Data-explorer">Data explorer </h3>

The data explorer is a table that show more detailed information of each of the states, it allows also to filter information by location and state or given the maximum and minimum score.

![Alt text] (https://lh3.googleusercontent.com/LWn7_S0XReHqHSoDkzmp4VtBeD9WovhcxguEHUvtyVNiitDjyYx9LncZR93gLVtBIRHOD59zLRainvnp3XkL8eQjNAkARrd3EWDwsHQUaKOiZI6faXQ3D84SStrN9DWD_w "Data explorer")


The following image shows the possibility to search in this data explorer the most ranked city and then navigate to this city through the Action column.

![Alt text] (https://lh5.googleusercontent.com/NseXxvo6XUqXGw6RactJKetsFwsuiXLRWZpGZ0ZLDkjY-qiM_toeQQeYtG0BGnVKBNNtsM16B05DDDippGuEk21k2wbUiQCa2eg-JByH2i-ZyNWcWR_SK1ll1uhDeLXXIA "Go task")

<h2 id="Functional-requirements-definition">Functional requirements definition </h2>

<h3 id="Data-and-task-abstractions">Data and task abstractions </h3>

The data that should be visualized in this application is extracted from the questions proposed before and ordered by the frequency of appearance in the questions:

   * ranking mark
   * average rating
   * review counts
   * localization
   * business category
   * number of hours open
   * season of the year
   * number of services
  
For the definition of the task abstractions have been considered the following main tasks:

  * Express geospatial positions
            Navigation and interaction to show information from a specific position
  * Find and locate outliers
            Offer different filtering options
   * Filter 1: Location area
   * Filter 2: ranking mark
   * Filter 3: review counts
   * Filter 4: users popularity
   * Filter 5: open /closed business
   * Filter 6: state, country, business name and zipcode.
   * Information aggregation
            Cluster 1: ranking mark
            Cluster 2: review counts
            Cluster 3: ranking mark difference between current stars and review stars
    * Summarize to offer a general view of the current data
            Summary: average rating by states
    * Data exploration
            Ordered table: show raking details

<h3 id="Interaction-and-visual-encoding">Interaction and visual encoding </h3>

The main visualization methods identified that best answer the proposed questions are:

   * Bar chart
      * It helps to lookup and compare values.
      * It shows one quantitative value attribute and one categorical value attribute.

   * Histogram
      * It helps to find trends, outliers, distribution, correlation and locate clusters.
      * It shows two quantitative values attributes: latitude and longitude to express location in a map.  Two categorical key attributes:
           * Color: stars mark /review_count/ stars difference.
           * Size: stars mark /review_count/ stars difference.

    * Interactive map
       *  Used to locate and filter per region data.
       *  It allows to identify clusters, lookup and compare values, outliers and find trends.

The different interaction methods with each of the above visualization methods are enclosed within the following tasks performed in the main application area:

  * Views synchronization
    * Go task
    * Selection
    * Zoom
    * Map navigation
    * Chart navigation

<h2 id="Development">Development </h2>

The development of this application has followed the following stages:

#### 0- Research of the available tools to develop the project

The project has been developed in the R programming language with the shiny library. Nevertheless, this application has made use of other libraries such as leaflet library in the implementation of the interactive map with the clustering option and the plotly library in the development of the charts of the graphics summary absolute panel.

#### 1- Data Preprocessing to get the data model

The source code that corresponds to this part it is located in the DataPreprocessing folder and it has to be launched before the application starts.

As the most of the application it is done with the business data, for testing purposes it recommended only run the part associated to clean and load this data. Only it is required to load the reviews for the calculate the ranking difference.
The phase could be subdivided in the following stages:

#####   1.1. Data collection
The data used for the development of this application is freely downloaded from the webpage http://www.yelp.com/dataset_challenge.
#####   1.2. Transform json and load the data in R
For this purpose I used the library jsonlite to read and save in R the data and convert it into data.frames objects. Nevertheless, in the case of the reviews data set it is also required a compression and reduction of the dataset due to huge volume of text data.



#####   1.3. Clean and filter the data
In the cleaning data process, I transformed most of the variables with NA value into 0 or 0:00 in case of hours. This allows me to visualize these data without losing the lost of information knowledge in some cases.
To visualize the data and locate it in the map, it is also extracted the zip_code from the business dataset.

#### 2- UI - View development

#####   2.1. Composition and development of the different widgets in the ui.R file
 
The UI is composed of two main views separate with a navbar and the tabPanel object, organized hierarchically with the composition of the following elements:

  * Data Explorer
    * selectInput (states, cities, zipcode, min and max score)
    * dataTableOutput
  * Interactive Map
    * leafletOutput (Interactive map)
    * absolutePanel (Graphs summary)
    * absolutePanel (Business explorer)
            
#### 3- UI - Controller development

This phase correspond to the development of the server side of the graphical interface server.R, it is responsible to perform the next two main tasks:

#####   3.1. Development of the logic associated to each view
#####   3.2. Coordination of each view to create an integrate and reactive design
   
The source code of this part it is composed of the following shiny elements to maintain synchronized the different views:

1. A reactive expression that returns the set of business that are in bounds right now
2. A reactive expression that filters the business, returning a data frame
3. Render plots to show a bar chart, a histogram and a scatterplot
4. An observer responsible for maintaining the circles and legend, according to the variables the user has chosen to map to color and size
5. An observer to show a popup with business info when the map is clicked
6. Observers to update the data explorer according to the filter options
7. Common functions that performs common calculations


<h2 id="Contact-information">Contact information </h2>      

Yolanda de la Hoz Simón. yolanda93h@gmail.com

<h2 id="Web-page">Web page </h2> 

https://yolanda93.github.io/yelp_challenge_ui/
