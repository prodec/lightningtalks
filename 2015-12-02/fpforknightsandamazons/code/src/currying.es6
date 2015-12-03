function curry(fn) {
  return (a) => fn(a);
}

function curry2(fn) {
  return (first) => (last) => fn(first, last);
}

function curry3(fn) {
  return (first) => (middle) => (last) => fn(first, middle, last);
}

export {
  curry,
  curry2,
  curry3
};
