function rest(array) {
  return array.slice(1);
}

function map(array, fn) {
  function go(vs, acc) {
    if (vs.length === 0) {
      return acc;
    } else {
      let head = vs[0];
      return go(rest(vs), acc.concat([fn(head)]));
    }
  }

  return go(array, []);
}

function add1(n) {
  return n + 1;
}

function sub1(n) {
  return n - 1;
}

function recAdd(a, b) {
  if (b == 0) {
    return a;
  } else {
    return add1(recAdd(a, sub1(b)));
  }
}
