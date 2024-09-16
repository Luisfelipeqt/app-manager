import Chart from "chart.js/auto";

class LineChart {
  /* 
    * @param ctx é o <canvas> onde o gráfico será renderizado
    * @param labels são o array do rótulos do eixo X (por exemplo, os meses)
    * @param values são o array dos valores que representam a quantidade de processos
  */
  constructor(ctx, labels, values, sum, color) {
    // Convert string values to numbers
    const numericValues = values;
    const totalSum = Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(sum / 100)

    this.chart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: labels, // Eixo X (por exemplo, os meses)
        datasets: [{
          label: `${totalSum}`,
          data: numericValues, // Quantidade de processos
          borderWidth: 1,
          backgroundColor: color, // Cor de fundo das barras
          borderColor: '#388E3C', // Cor da borda das barras
          borderRadius: 5, // Borda arredondada das barras
          hoverBackgroundColor: '#66BB6A', // Cor de fundo ao passar o mouse
          hoverBorderColor: '#2C6B2F' // Cor da borda ao passar o mouse
        }]
      },
      options: {
        scales: {
          x: {
            beginAtZero: true, // Começa o eixo X do zero
            grid: {
              color: '#E0E0E0' // Cor da grade do eixo X
            }
          },
          y: {
            beginAtZero: true, // Começa o eixo Y do zero
            suggestedMax: Math.max(...numericValues), // Define o valor máximo sugerido do eixo Y
            ticks: {
              callback: function(value) {
                return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value / 100); // Formata os valores no eixo Y como moeda
              }
            },
            grid: {
              color: '#E0E0E0' // Cor da grade do eixo Y
            }
          }
        },
        plugins: {
          legend: {
            position: 'top', // Posição da legenda
            labels: {
              color: '#333' // Cor dos textos da legenda
            }
          },
          tooltip: {
            callbacks: {
              label: function(context) {
                let value = context.raw;
                return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value / 100); // Formata os valores nas tooltips como moeda
              }
            },
            backgroundColor: '#333', // Cor do fundo das tooltips
            titleColor: '#FFF', // Cor do título das tooltips
            bodyColor: '#FFF' // Cor do corpo das tooltips
          }
        }
      }
    });
  }

  addPoint(label, value) {
    const labels = this.chart.data.labels;
    const data = this.chart.data.datasets[0].data;

    // Convert string value to number
    const numericValue = parseFloat(value.replace(/[R$.,]/g, '').replace(',', '.'));

    labels.push(label);
    data.push(numericValue);

    // Atualizando o gráfico
    if (data.length > 12) {
      data.shift();
      labels.shift();
    }

    this.chart.update();
  }

  destroy() {
    // Add code here to clean up the chart. 
    // This might involve removing chart elements from the DOM, 
    // disconnecting event listeners, or releasing resources.
    // For example, if you're using a charting library like Chart.js:
    if (this.chart) {
        this.chart.destroy();
    }
}
}

export default LineChart;
