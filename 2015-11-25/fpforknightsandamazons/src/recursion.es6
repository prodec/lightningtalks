import { first, rest, isFunction } from "./prelude";
import { partial1 } from "./partial";

function contains(array, x) {
  if (array.length === 0) {
    return false;
  } else {
    if (first(array) === x) {
      return true;
    } else {
      return contains(rest(array), x);
    }
  }
}

function add1(n) {
  return n + 1;
}

function sub1(n) {
  return n - 1;
}

function recSum(a, b) {
  if (b === 0) {
    return a;
  } else {
    return add1(recSum(a, sub1(b)));
  }
}

function trampoline(fn) {
  let result = fn.apply(fn, rest(arguments));

  while (isFunction(result)) {
    result = result();
  }

  return result;
}

export {
  contains,
  recSum,
  trampoline,
  lazyRecSum
};
