import fs from "fs";
import path from "path";

function readFile(path) {
  return new Promise((resolve, reject) => {
    fs.readFile(path, (err, data) => {
      resolve(data);
    });
  });
}

function dataPointFrom(header, data) {
  let dataPoint = {};

  for (let i = 0; i < header.length; i++) {
    dataPoint[header[i]] = data[i];
  }

  return dataPoint;
}

function filterDataPointsWithAirTemperature(dataPoints) {
  let filtered = [];

  for (let i = 0; i < dataPoints.length; i++) {
    let dataPoint = dataPoints[i];

    if (dataPoint["TempAr (oC)"] != null) {
      filtered.push(dataPoint);
    }
  }

  return filtered;
}

function showAverageAirTemperature(dataPoints) {
  let sum = 0,
      filtered = filterDataPointsWithAirTemperature(dataPoints);

  for (let i = 0; i < dataPoints.length; i++) {
    let dataPoint = dataPoints[i];

    if (dataPoint["TempAr (oC)"] != null) {
      sum += parseFloat(dataPoint["TempAr (oC)"]);
    }

  }

  console.log("Temperatura média do ar: ", sum / filtered.length);
}

async function main() {
  let data = (await readFile(path.resolve(__dirname, "../data/31954.csv"))).toString(),
      lines = data.split("\n"),
      header = lines[0].split(","),
      dataPoints = [];

  for (let i = 1; i < lines.length; i++) {
    dataPoints.push(dataPointFrom(header, lines[i].split(",")));
  }

  showAverageAirTemperature(dataPoints);
}

main();
