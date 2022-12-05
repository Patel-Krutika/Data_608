
d3.csv('ue_industry.csv', data => {
	
	console.log("Hello")
    const xScale = d3.scaleLinear()
        .domain(d3.extent(data, (d) => +d.index))
        .range([20, 1180]);
    
    const yScale = d3.scaleLinear()
        .domain(d3.extent(data, (d) => +d.Agriculture))
        .range([580, 20]);

    d3.select('#part4')
        .selectAll('circle')
        .data(data)
        .enter()
        .append('circle')
        .attr('r', d => 5)
        .attr('cx', d => d.index)
        .attr('cy', d => d.Agriculture);

});