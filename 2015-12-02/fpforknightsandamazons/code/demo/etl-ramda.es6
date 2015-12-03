import fs from "fs";
import path from "path";
import R from "ramda";

function readFile(path) {
  return new Promise((resolve, reject) => {
    fs.readFile(path, (err, data) => {
      resolve(data);
    });
  });
}

function averageAirTemperature(data) {
  return R.pipe(R.map(R.compose(parseFloat, R.prop("TempAr (oC)"))),
                R.sum,
                R.flip(R.divide)(data.length))(data);
}

function extractData(rawData) {
  return R.pipe(R.split("\n"),
                R.map(R.split(",")),
                R.filter((d) => d.length > 1),
                (ds) => R.map((d) => R.zipObj(R.head(ds), d))(R.tail(ds)))(rawData);
}

async function main() {
  try {
    let data = extractData((await readFile(path.resolve(__dirname, "../data/31954.csv"))).toString());

    console.log("Temperatura média do ar: ", averageAirTemperature(data));
  } catch(err) {
    console.log("===>", err);
  }
}

main();
