import { first, rest } from "./prelude";

function map(fn, array) {
  let acc = [];

  for (let i = 0; i < array.length; i++) {
    acc.push(fn(array[i]));
  }

  return acc;
}

function foldLeft(fn, acc, array) {
  if (array.length === 0) {
    return acc;
  } else {
    return foldLeft(fn, fn(acc, first(array)), rest(array));
  }
}

function take(n, array) {
  function go(m, ns, acc) {
    if (m == 0) {
      return acc;
    } else {
      return go(m - 1, rest(ns), acc.concat(first(ns)));
    }
  }

  return go(n, array, []);
}

function mapFromFoldLeft(fn, array) {
  return foldLeft(((acc, v) => acc.concat([fn(v)])), [], array);
}

function containsFromFoldLeft(values, value) {
  return foldLeft((found, v) => {
    return !truthy(found) ? v === value : found;
  }, false, values);
}


let values = [1, 2, 3, 4, 5, 6];
values.map((n) => n * 10)
  .filter((n) => n > 30)
  .reduce((a, b) => a * b, 1);

_.chain({ John: "Alice", Bob: "Alice", Alice: "John", Julia: "Bob" }).
  pairs().
  reduce((votes, [voter, votee]) => {
    return _.extend(votes, { [votee]: (votes[votee] || []).concat([voter]) }, {});
  }, {}).
  value();

R.pipe(R.invert,
       R.foldl())
