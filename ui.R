##########################################
##                                      ##
##  Explore COVID-19 data by area       ##
##  Author: gaskyk                      ##
##  Date: 29-Nov-20                     ##
##                                      ##
##########################################

# Do only once - install from github
#library(remotes)
#remotes::install_github("publichealthengland/coronavirus-dashboard-api-R-sdk")

# Load libraries
library(tidyverse)
library(ukcovid19)
library(shiny)
library(plotly)

# Define UI for application that shows a plot
shinyUI(fluidPage(
    
    # Application title
    titlePanel("Explore COVID-19 data by local area"),
    
    # Sidebar panel for input local area
    sidebarPanel(
        
        # Input selector
        selectInput("la",
                    label = "Choose an area:",
                    choices = readr::read_csv("area_names.csv"))
    ),
    
    # Main panel for displaying outputs
    mainPanel(
        
        # Output plot
        plotlyOutput("plot")
    )
))
