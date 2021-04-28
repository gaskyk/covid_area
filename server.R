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

# Define server logic required to show a plot
shinyServer(function(input, output) {
    
    # Load the query from the API, UK first
    # Filters
    query_filter_uk <- c(
        'areaType=overview'
    )
    # Cases
    cases = list(
        date = "date",
        areaName = "areaName",
        cumCasesBySpecimenDateRate = "cumCasesBySpecimenDateRate"
    )
    # Call the API to get the data
    data_uk <- get_data(
        filters = query_filter_uk, 
        structure = cases
    )
    # Convert date to date format and get rolling case rates
    # Also select dates after 1 April 2020
    data_uk <- data_uk %>%
        arrange(desc(date)) %>%
        mutate(date = as.Date(date)+7,
               rollingCasesRate_uk = lag(cumCasesBySpecimenDateRate, n=7) - 
                   cumCasesBySpecimenDateRate) %>%
        filter(date >= as.Date('2021-01-01'),
               date <= format(Sys.Date(), format="%Y-%m-%d")) %>%
        select(date, rollingCasesRate_uk)
    
    # Return the requested dataset and plot
    output$plot <- renderPlotly({
        # Load the query from the API, now for the local area selected
        query_filter_ltla <- c(
            'areaType=ltla',
            paste0('areaName=', input$la[1])
        )
        data_ltla <- get_data(
            filters = query_filter_ltla, 
            structure = cases
        )
        # Create rolling cases rate
        data_ltla <- data_ltla %>%
            arrange(desc(date)) %>%
            mutate(date = as.Date(date)+7,
                   rollingCasesRate_ltla = abs(lag(cumCasesBySpecimenDateRate, n=7)) - 
                       cumCasesBySpecimenDateRate) %>%
            filter(date >= as.Date('2021-01-01'),
                   date <= format(Sys.Date(), format="%Y-%m-%d")) %>%
            select(date, rollingCasesRate_ltla)
        
        # Join data from the UK to selected local area into one dataset
        data <- data_uk %>%
            full_join(data_ltla, by = "date")
        
        # Plot
        x <- list(
            title = "Date"
        )
        y <- list(
            title = "Rate per 100k population"
        )
        plot_ly(data, x = ~date, y = ~rollingCasesRate_uk, name = 'UK',
                type = 'scatter', mode = 'lines') %>% 
            add_trace(y = ~rollingCasesRate_ltla, name = input$la, mode = 'lines') %>%
            layout(title = 'People tested positive', xaxis = x, yaxis = y)
    })
    
})
