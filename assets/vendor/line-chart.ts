import LineChart from "../js/line-chart";

const lineChart = {
    mounted() {
        const { labels, values, sum, color } = JSON.parse(this.el.dataset.chartData);
        this.chart = new LineChart(this.el, labels, values, sum, color);

    },
    destroyed() {
        this.chart.destroy();
    },
};

export default lineChart;