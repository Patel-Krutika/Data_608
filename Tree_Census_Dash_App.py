# -*- coding: utf-8 -*-
"""
Created on Sat Oct 22 14:26:07 2022

@author: Krutika
"""

from dash import Dash
import dash_core_components as dcc
import dash_html_components as html
import pandas as pd
import numpy as np
from dash.dependencies import Input, Output
import plotly.express as px

# initialize_app

external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']
app = Dash('App', external_stylesheets=external_stylesheets) 


# read in dataset
data = pd.read_csv("2015_Street_Tree_Census_Data.csv")

# drop na rows from the spc_common subset
data = data.dropna(subset = ['spc_common'])

#Build a dash app for an arborist studying the health of various tree species (as defined by the variable 'spc_common') accross each borough (defined by the variable 'borough'). This arborist would like to answer the following two questions for each species in each borough.

#What proportion of trees are in good, fair, or poor health according to the health variable?

#Are stewards (steward activity measured by the 'steward' variable) having an impact on the health of trees?


app.layout = html.Div([
    html.H1("Tree Census Data", style={'text-align':'center'}),
    
    html.H4('Species'),
    dcc.Dropdown(id='species',
                options = [{'label': idx, 'value': idx} for idx in data['spc_common'].unique()],
                 value='red maple',
                 style={'width':'40'}
                ),
    
    html.H4('Borough'),
    dcc.Dropdown(id='borough',
                 options = [{'label': idx, 'value': idx} for idx in data['borough'].unique()],
                 value = 'Brooklyn',
                 style={'width':'40'}),
    html.Br(),
    
    html.Div(id = 'output_container', children =[ 
        
        html.Div([
            html.H3("Tree Species Health by Borough"),
            dcc.Graph(id='graph_health', figure={})
        ], className="six columns"),

        html.Div([
            html.H3('Tree Species Health Proportions for Steward Levels'),
            dcc.Graph(id='graph_steward', figure={})
        ], className="six columns"),
    ], className="row")
])

app.css.append_css({
    'external_url': 'https://codepen.io/chriddyp/pen/bWLwgP.css'
})

@app.callback(
[Output(component_id='output_container_1', component_property='children'),
Output(component_id='graph_health', component_property='figure'),
Output(component_id='graph_steward', component_property='figure')],
[Input(component_id='species', component_property='value'),
 Input(component_id='borough', component_property='value')])

def update_graph(species, borough):
    
    container_1 = 'Health proportions for {} species in {}.'.format(species,borough)
    
    # create a copy of original data
    dff = data.copy()

    
    # filter the data set for only the selected species and borough
    dff = dff[dff['spc_common']==species]
    dff = dff[dff['borough']==borough]
    
    # create a list of health levels
    health = ['good',' fair','poor']
    
    n = len(dff)
    # create a list of health level proportions
    prop = [len(dff[dff['health']=='Good'])/n, len(dff[dff['health']=='Fair'])/n, len(dff[dff['health']=='Poor'])/n]
    
    # create data frame
    df = pd.DataFrame()
    df['Health'] = health
    df['Proportion'] = prop
    
    # create bar graph
    fig_1 = px.bar(df, x='Health', y='Proportion')
    

    container_2 = 'Health prportions for {} species in {} for number of stewards.'.format(species, borough)    
    
    # drop na rows from stewards subset
    dff2 = dff.dropna(subset = ['steward'])
    
    # create empty dataframe
    df2 = pd.DataFrame()
    
    # create lists for good, fair, and poor proportions respectivly
    good, fair, poor = [], [], []
    
    # assign the respective health proportion for each steward value
    for s in dff2['steward'].unique():
        temp = dff2[dff2['steward'] == s]
        n = len(temp)
        good.append(len(dff2[dff2['health']=='Good'])/n)
        fair.append(len(dff2[dff2['health']=='Fair'])/n)
        poor.append(len(dff2[dff2['health']=='Poor'])/n)
        
    # create final data frame
    df2['Steward'] = dff2['steward'].unique()
    df2['Good'], df2['Fair'], df2['Poor'] = good, fair, poor
    
    # create grouped bar graph
    fig_2 = px.bar(
    data_frame = df2,
    x = 'Steward',
    y = ['Good', 'Fair', 'Poor'],
    opacity = 0.9,
    orientation = "v",
    barmode = 'group'
    )
    fig_2.update_xaxes(categoryorder='array', categoryarray= ['None', '1or2', '3or4','4orMore'])
    fig_2.update_yaxes(title_text = 'Proportion')    
        
    

    
    return container_1, fig_1, fig_2

if __name__ == '__main__':
    app.run_server(debug=True, use_reloader = False)