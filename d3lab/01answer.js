d3.csv('ue_industry.csv', data => {

    // Define your scales and generator here.
	
			
	const xScale = d3.scaleLinear()
                .domain(d3.extent(data, d => +d.index))
                .range([1180, 20]);
            
	const yScale = d3.scaleLinear()
		.domain(d3.extent(data, d => +d.Agriculture))
		.range([580, 20]);
		
	const lineA = d3.line()
		.x(d => +d.x)
		.y(d => d.y)
	
    //d3.select('#answer1')
        // append more elements here

	d3.select('#answer1')
		.selectAll('path')
		.data(data)
		.enter()
		.append('path')
		.attr('d', d => lineA(d) )
		.attr('cx', d => xScale(d.index))
		.attr('cy', d => yScale(d.Agriculture));
});


        